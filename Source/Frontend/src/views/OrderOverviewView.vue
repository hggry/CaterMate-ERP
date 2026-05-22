<script setup lang="ts">
import { ref, watch } from 'vue'
import Button from 'primevue/button'
import Card from 'primevue/card'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Splitter from 'primevue/splitter'
import SplitterPanel from 'primevue/splitterpanel'
import OrderRequestPanel from '@/components/orders/OrderRequestPanel.vue'
import DishSuggestionsPanel from '@/components/orders/DishSuggestionsPanel.vue'
import MenuItemPicker from '@/components/orders/MenuItemPicker.vue'
import { ordersApi } from '@/services/ordersApi'
import { useToast } from '@/composables/useToast'
import { useOrderContext } from '@/composables/useOrderContext'
import { apiErrorMessage } from '@/types/api'
import type { OrderDto, OrderStatus, UpdateOrderRequest } from '@/types/order'

const { order, orderId, reload } = useOrderContext()
const toast = useToast()

const form = ref<{
  guestCount: number
  eventType: string
  location: string
  budget: number | null
}>({ guestCount: 1, eventType: '', location: '', budget: null })
const assignedIds = ref<number[]>([])
const saving = ref(false)

function syncForm(o: OrderDto): void {
  form.value = {
    guestCount: o.guestCount,
    eventType: o.eventType ?? '',
    location: o.location,
    budget: o.budget,
  }
  assignedIds.value = o.assignedMenuItems.map((m) => m.id)
}

watch(order, (o) => o && syncForm(o), { immediate: true })

function buildPayload(extra: Partial<UpdateOrderRequest> = {}): UpdateOrderRequest {
  return {
    guestCount: form.value.guestCount,
    eventType: form.value.eventType || undefined,
    location: form.value.location,
    budget: form.value.budget ?? undefined,
    assignedMenuItemIds: assignedIds.value,
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

function onAssign(menuItemId: number): void {
  if (!assignedIds.value.includes(menuItemId)) {
    assignedIds.value = [...assignedIds.value, menuItemId]
  }
}
</script>

<template>
  <div v-if="order" class="order-overview">
    <div class="order-overview__grid">
      <OrderRequestPanel :order="order" />

      <Card>
        <template #title>Auftragsdaten</template>
        <template #content>
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
                mode="currency"
                currency="EUR"
                locale="de-AT"
              />
            </div>
            <Button
              label="Änderungen speichern"
              icon="pi pi-save"
              severity="secondary"
              :loading="saving"
              @click="saveDetails"
            />
          </div>
        </template>
      </Card>
    </div>

    <Splitter class="order-overview__splitter">
      <SplitterPanel :size="45" :min-size="25">
        <DishSuggestionsPanel :order-id="orderId" @assign="onAssign" />
      </SplitterPanel>
      <SplitterPanel :size="55" :min-size="25">
        <MenuItemPicker v-model="assignedIds" />
      </SplitterPanel>
    </Splitter>

    <div class="order-overview__actions">
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
    </div>
  </div>
</template>

<style scoped>
.order-overview {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.order-overview__grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(20rem, 1fr));
  gap: 1rem;
  align-items: start;
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

.order-overview__splitter {
  min-height: 22rem;
}

.order-overview__actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}
</style>
