<script setup lang="ts">
import { ref, watch } from 'vue'
import Button from 'primevue/button'
import Panel from 'primevue/panel'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import DatePicker from 'primevue/datepicker'
import Textarea from 'primevue/textarea'
import MenuItemPickerDialog from '@/components/orders/MenuItemPickerDialog.vue'
import { ordersApi } from '@/services/ordersApi'
import { useToast } from '@/composables/useToast'
import { useOrderContext } from '@/composables/useOrderContext'
import { useFormat } from '@/composables/useFormat'
import { apiErrorMessage } from '@/types/api'
import type { OrderDto, OrderStatus, UpdateOrderRequest } from '@/types/order'

const { order, orderId, reload } = useOrderContext()
const toast = useToast()
const { formatCurrency, formatDateTime } = useFormat()

const form = ref<{
  customerName: string
  customerPhone: string
  eventDate: Date | null
  guestCount: number
  eventType: string
  location: string
  budget: number | null
  specialWishes: string
  allergies: string
  dishWishes: string
}>({
  customerName: '',
  customerPhone: '',
  eventDate: null,
  guestCount: 1,
  eventType: '',
  location: '',
  budget: null,
  specialWishes: '',
  allergies: '',
  dishWishes: '',
})

const assignedIds = ref<number[]>([])
const saving = ref(false)
const pickerVisible = ref(false)

function syncForm(o: OrderDto): void {
  form.value = {
    customerName: o.customerName,
    customerPhone: o.customerPhone ?? '',
    eventDate: new Date(o.eventDate),
    guestCount: o.guestCount,
    eventType: o.eventType ?? '',
    location: o.location,
    budget: o.budget,
    specialWishes: o.specialWishes ?? '',
    allergies: o.allergies ?? '',
    dishWishes: o.dishWishes ?? '',
  }
  assignedIds.value = o.assignedMenuItems.map((m) => m.id)
}

watch(order, (o) => o && syncForm(o), { immediate: true })

function buildPayload(extra: Partial<UpdateOrderRequest> = {}): UpdateOrderRequest {
  return {
    customerName: form.value.customerName || undefined,
    customerPhone: form.value.customerPhone || undefined,
    eventDate: form.value.eventDate?.toISOString(),
    guestCount: form.value.guestCount,
    eventType: form.value.eventType || undefined,
    location: form.value.location,
    budget: form.value.budget ?? undefined,
    specialWishes: form.value.specialWishes || undefined,
    allergies: form.value.allergies || undefined,
    dishWishes: form.value.dishWishes || undefined,
    ...extra,
  }
}

async function patch(payload: UpdateOrderRequest, successText: string): Promise<void> {
  if (form.value.guestCount < 1) {
    toast.error('Personenanzahl muss größer als 0 sein.')
    return
  }
  saving.value = true
  try {
    await ordersApi.update(orderId, payload)
    await reload()
    toast.success(successText)
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    saving.value = false
  }
}

function saveDetails(): Promise<void> {
  return patch(buildPayload(), 'Auftragsdaten gespeichert.')
}

function markAsChecked(): Promise<void> {
  return patch(buildPayload({ status: 'Geprüft' }), 'Auftrag wurde als geprüft markiert.')
}

function advanceStatus(status: OrderStatus, successText: string): Promise<void> {
  return patch({ status }, successText)
}

async function removeMenuItem(id: number): Promise<void> {
  const newIds = assignedIds.value.filter((x) => x !== id)
  saving.value = true
  try {
    await ordersApi.update(orderId, { assignedMenuItemIds: newIds })
    await reload()
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div v-if="order" class="order-overview">
    <div class="order-overview__header">
      <h2>Auftragsübersicht</h2>
      <div class="order-overview__header-actions">
        <Button
          v-if="order.status === 'Neu'"
          label="Als geprüft markieren"
          icon="pi pi-check"
          :loading="saving"
          @click="markAsChecked"
        />
        <Button
          v-if="order.status === 'InBeschaffung'"
          label="In Vorbereitung"
          icon="pi pi-arrow-right"
          :loading="saving"
          @click="advanceStatus('InVorbereitung', 'Auftrag ist in Vorbereitung.')"
        />
        <Button
          v-if="order.status === 'InVorbereitung'"
          label="Als durchgeführt markieren"
          icon="pi pi-check"
          :loading="saving"
          @click="advanceStatus('Durchgeführt', 'Auftrag wurde als durchgeführt markiert.')"
        />
        <Button
          label="Änderungen speichern"
          icon="pi pi-save"
          severity="secondary"
          :loading="saving"
          @click="saveDetails"
        />
      </div>
    </div>

    <div class="order-overview__main">
      <div class="order-overview__left">
        <Panel header="Kundendaten">
          <div class="order-overview__form">
            <div class="order-overview__field">
              <label for="customerName">Kunde</label>
              <InputText id="customerName" v-model="form.customerName" />
            </div>
            <div class="order-overview__field">
              <label for="customerPhone">Telefon</label>
              <InputText id="customerPhone" v-model="form.customerPhone" />
            </div>
            <div class="order-overview__field">
              <label for="eventDate">Eventdatum</label>
              <DatePicker
                id="eventDate"
                v-model="form.eventDate"
                date-format="dd.mm.yy"
                show-icon
                fluid
              />
            </div>
            <div class="order-overview__field">
              <span class="order-overview__field-label">Eingegangen am</span>
              <span class="order-overview__field-value">{{ formatDateTime(order.createdAt) }}</span>
            </div>
          </div>
        </Panel>

        <Panel header="Auftragsdaten">
          <div class="order-overview__form">
            <div class="order-overview__field">
              <label for="guestCount">Personenanzahl</label>
              <InputNumber
                v-model="form.guestCount"
                input-id="guestCount"
                :min="1"
                :max="5000"
                show-buttons
              />
            </div>
            <div class="order-overview__field">
              <label for="eventType">Eventtyp</label>
              <InputText id="eventType" v-model="form.eventType" />
            </div>
            <div class="order-overview__field">
              <label for="location">Ort</label>
              <InputText id="location" v-model="form.location" />
            </div>
            <div class="order-overview__field">
              <label for="budget">Budget</label>
              <InputNumber
                v-model="form.budget"
                input-id="budget"
                suffix=" €"
                :min="0"
                :max-fraction-digits="2"
                :use-grouping="false"
              />
            </div>
            <div class="order-overview__field">
              <label for="specialWishes">Sonderwünsche</label>
              <Textarea id="specialWishes" v-model="form.specialWishes" rows="2" auto-resize />
            </div>
            <div class="order-overview__field">
              <label for="allergies">Allergien</label>
              <InputText id="allergies" v-model="form.allergies" />
            </div>
            <div class="order-overview__field">
              <label for="dishWishes">Gerichtswünsche</label>
              <Textarea id="dishWishes" v-model="form.dishWishes" rows="2" auto-resize />
            </div>
          </div>
        </Panel>
      </div>

      <Panel header="Menüartikel" class="order-overview__right">
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
              :loading="saving"
              @click="removeMenuItem(item.id)"
            />
          </div>
        </div>
        <Button
          label="Menüartikel hinzufügen"
          icon="pi pi-plus"
          severity="secondary"
          class="order-overview__add-btn"
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
}

.order-overview__header h2 {
  margin: 0;
}

.order-overview__header-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.order-overview__main {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  align-items: start;
}

.order-overview__left {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.order-overview__right {
  position: sticky;
  top: 0;
}

.order-overview__form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.order-overview__field {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.order-overview__field-label {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.order-overview__field-value {
  font-size: 0.9375rem;
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
