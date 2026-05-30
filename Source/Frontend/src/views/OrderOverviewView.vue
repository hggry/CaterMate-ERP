<script setup lang="ts">
import { computed, onBeforeUnmount, reactive, ref, watch } from 'vue'
import Panel from 'primevue/panel'
import Message from 'primevue/message'
import OrderForm from '@/components/orders/OrderForm.vue'
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

const { order, orderId } = useOrderContext()
const toast = useToast()
const { formatDateTime } = useFormat()
const { indexOf } = useOrderStatus()

const form = reactive(emptyOrderForm())
const errors = ref<OrderFormErrors>({})

type SaveState = 'idle' | 'dirty' | 'saving' | 'saved' | 'error'
const saveState = ref<SaveState>('idle')

// Editing is locked once the offer is released — changing core data afterwards
// would desync the released quote / invoice.
const locked = computed(() =>
  order.value ? indexOf(order.value.status) >= indexOf('AngebotErstellt') : false,
)

const syncedOrderId = ref<number | null>(null)
let savedRequestJson = ''

function snapshotSaved(): void {
  const result = validateOrderForm(form)
  savedRequestJson = result.valid && result.request ? JSON.stringify(result.request) : ''
}

// Sync the form once per loaded order. Later reloads of the same order (after a
// save) must not clobber what the user is editing.
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
      <h2>Auftragsdaten</h2>
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

    <Panel header="Auftragsdaten">
      <OrderForm :form="form" :errors="errors" :readonly="locked" />
      <p class="order-overview__received">
        Eingegangen am {{ formatDateTime(order.createdAt) }}
      </p>
    </Panel>
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

.order-overview__received {
  margin: 1rem 0 0;
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}
</style>
