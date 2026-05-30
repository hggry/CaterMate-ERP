<script setup lang="ts">
import { computed, onBeforeUnmount, reactive, ref, watch } from 'vue'
import Button from 'primevue/button'
import Panel from 'primevue/panel'
import Message from 'primevue/message'
import OrderForm from '@/components/orders/OrderForm.vue'
import DishSuggestionList from '@/components/orders/DishSuggestionList.vue'
import MenuItemPickerDialog from '@/components/orders/MenuItemPickerDialog.vue'
import { ordersApi } from '@/services/ordersApi'
import { useToast } from '@/composables/useToast'
import { useOrderContext } from '@/composables/useOrderContext'
import { useOrderStatus } from '@/composables/useOrderStatus'
import { useFormat } from '@/composables/useFormat'
import { apiErrorMessage } from '@/types/api'
import type { OrderDto } from '@/types/order'
import {
  emptyOrderForm,
  orderToForm,
  validateOrderForm,
  type OrderFormErrors,
} from '@/components/orders/orderFormSchema'

const { order, orderId, reload } = useOrderContext()
const toast = useToast()
const { formatCurrency, formatDateTime } = useFormat()
const { indexOf } = useOrderStatus()

const form = reactive(emptyOrderForm())
const errors = ref<OrderFormErrors>({})
const pickerVisible = ref(false)
const menuBusy = ref(false)

type SaveState = 'idle' | 'dirty' | 'saving' | 'saved' | 'error'
const saveState = ref<SaveState>('idle')

// Editing is locked once the offer is released — changing core data afterwards
// would desync the released quote / invoice.
const locked = computed(() =>
  order.value ? indexOf(order.value.status) >= indexOf('AngebotErstellt') : false,
)

const assignedIds = computed(() => order.value?.assignedMenuItems.map((m) => m.id) ?? [])
const showSuggestions = computed(() => order.value?.status === 'Neu')

const syncedOrderId = ref<number | null>(null)
let savedRequestJson = ''

function snapshotSaved(): void {
  const result = validateOrderForm(form)
  savedRequestJson = result.valid && result.request ? JSON.stringify(result.request) : ''
}

// Sync the form once per loaded order. Later reloads of the same order (after a
// save or a menu change) must not clobber what the user is editing.
watch(
  order,
  (o: OrderDto | null) => {
    if (o && o.id !== syncedOrderId.value) {
      Object.assign(form, orderToForm(o))
      syncedOrderId.value = o.id
      snapshotSaved()
      saveState.value = 'idle'
    }
  },
  { immediate: true },
)

const DEBOUNCE_MS = 700
let timer: ReturnType<typeof setTimeout> | null = null

watch(form, () => {
  if (locked.value) return
  saveState.value = 'dirty'
  if (timer) clearTimeout(timer)
  timer = setTimeout(() => {
    timer = null
    void doSave()
  }, DEBOUNCE_MS)
}, { deep: true })

async function doSave(): Promise<void> {
  if (locked.value) return
  const result = validateOrderForm(form)
  errors.value = result.errors
  if (!result.valid || !result.request) {
    saveState.value = 'error'
    return
  }
  const json = JSON.stringify(result.request)
  if (json === savedRequestJson) {
    saveState.value = 'saved'
    return
  }
  saveState.value = 'saving'
  try {
    const updated = await ordersApi.update(orderId, result.request)
    savedRequestJson = json
    order.value = updated
    saveState.value = 'saved'
  } catch (e) {
    saveState.value = 'error'
    toast.error(apiErrorMessage(e))
  }
}

// Persist any pending debounced edit before leaving the view.
function flush(): void {
  if (timer) {
    clearTimeout(timer)
    timer = null
    void doSave()
  }
}

onBeforeUnmount(flush)

async function setMenuItems(ids: number[]): Promise<void> {
  menuBusy.value = true
  try {
    await ordersApi.update(orderId, { assignedMenuItemIds: ids })
    await reload()
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    menuBusy.value = false
  }
}

function addMenuItem(id: number): void {
  if (assignedIds.value.includes(id)) return
  void setMenuItems([...assignedIds.value, id])
}

function removeMenuItem(id: number): void {
  void setMenuItems(assignedIds.value.filter((x) => x !== id))
}

const saveLabel = computed(() => {
  switch (saveState.value) {
    case 'saving':
      return 'Speichert…'
    case 'saved':
      return 'Alle Änderungen gespeichert'
    case 'dirty':
      return 'Ungespeicherte Änderungen…'
    case 'error':
      return 'Speichern fehlgeschlagen'
    default:
      return ''
  }
})
</script>

<template>
  <div v-if="order" class="order-overview">
    <div class="order-overview__header">
      <h2>Auftragsübersicht</h2>
      <span
        v-if="!locked && saveLabel"
        class="order-overview__save-state"
        :class="{ 'order-overview__save-state--error': saveState === 'error' }"
      >
        <i
          :class="
            saveState === 'saving'
              ? 'pi pi-spin pi-spinner'
              : saveState === 'saved'
                ? 'pi pi-check'
                : saveState === 'error'
                  ? 'pi pi-exclamation-circle'
                  : 'pi pi-pencil'
          "
        />
        {{ saveLabel }}
      </span>
    </div>

    <Message v-if="locked" severity="info" :closable="false">
      Auftrag ist freigegeben — Stammdaten sind gesperrt.
    </Message>

    <div class="order-overview__main">
      <Panel header="Auftragsdaten" class="order-overview__left">
        <OrderForm :form="form" :errors="errors" :readonly="locked" />
        <p class="order-overview__received">
          Eingegangen am {{ formatDateTime(order.createdAt) }}
        </p>
      </Panel>

      <Panel header="Menüartikel" class="order-overview__right">
        <DishSuggestionList
          v-if="showSuggestions"
          :order-id="orderId"
          :assigned-ids="assignedIds"
          :disabled="menuBusy"
          class="order-overview__suggestions"
          @add="addMenuItem"
        />

        <div class="order-overview__menu-list">
          <p v-if="!order.assignedMenuItems.length" class="order-overview__empty">
            Keine Menüartikel zugeordnet.
          </p>
          <div
            v-for="item in order.assignedMenuItems"
            :key="item.id"
            class="order-overview__menu-item"
          >
            <div class="order-overview__item-info">
              <span class="order-overview__item-name">{{ item.name }}</span>
              <span class="order-overview__item-meta">
                {{ item.category }} · {{ formatCurrency(item.salesPricePerPerson) }}/Person
              </span>
            </div>
            <Button
              icon="pi pi-times"
              severity="danger"
              text
              rounded
              size="small"
              :disabled="locked"
              :loading="menuBusy"
              @click="removeMenuItem(item.id)"
            />
          </div>
        </div>
        <Button
          label="Menüartikel hinzufügen"
          icon="pi pi-plus"
          severity="secondary"
          class="order-overview__add-btn"
          :disabled="locked"
          @click="pickerVisible = true"
        />
      </Panel>
    </div>

    <MenuItemPickerDialog
      v-model:visible="pickerVisible"
      :order-id="orderId"
      :assigned-ids="assignedIds"
      @changed="reload"
    />
  </div>
</template>

<style scoped>
.order-overview {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.order-overview__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}

.order-overview__header h2 {
  margin: 0;
}

.order-overview__save-state {
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.order-overview__save-state--error {
  color: var(--p-red-500, #ef4444);
}

.order-overview__main {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  align-items: start;
}

.order-overview__right {
  position: sticky;
  top: 0;
}

.order-overview__received {
  margin: 1rem 0 0;
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.order-overview__suggestions {
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--p-content-border-color);
}

.order-overview__menu-list {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  margin-bottom: 0.75rem;
}

.order-overview__empty {
  color: var(--p-text-muted-color);
  margin: 0 0 0.5rem;
}

.order-overview__menu-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.375rem 0;
  border-bottom: 1px solid var(--p-content-border-color);
}

.order-overview__menu-item:last-child {
  border-bottom: none;
}

.order-overview__item-info {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.order-overview__item-name {
  font-weight: 500;
}

.order-overview__item-meta {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.order-overview__add-btn {
  margin-top: 0.25rem;
}
</style>
