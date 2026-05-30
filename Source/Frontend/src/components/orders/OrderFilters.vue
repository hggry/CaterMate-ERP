<script setup lang="ts">
import Select from 'primevue/select'
import DatePicker from 'primevue/datepicker'
import Button from 'primevue/button'
import { ALL_ORDER_STATUSES, type OrderStatus } from '@/types/order'
import { useOrderStatus } from '@/composables/useOrderStatus'

const status = defineModel<OrderStatus | null>('status')
const from = defineModel<Date | null>('from')
const to = defineModel<Date | null>('to')

const { labelFor } = useOrderStatus()

const statusOptions = ALL_ORDER_STATUSES.map((value) => ({ value, label: labelFor(value) }))

function reset(): void {
  status.value = null
  from.value = null
  to.value = null
}
</script>

<template>
  <div class="order-filters">
    <div class="order-filters__field">
      <label>Status</label>
      <Select
        v-model="status"
        :options="statusOptions"
        option-label="label"
        option-value="value"
        placeholder="Alle Status"
        show-clear
      />
    </div>
    <div class="order-filters__field">
      <label>Eventdatum ab</label>
      <DatePicker v-model="from" date-format="dd.mm.yy" show-button-bar />
    </div>
    <div class="order-filters__field">
      <label>Eventdatum bis</label>
      <DatePicker v-model="to" date-format="dd.mm.yy" show-button-bar />
    </div>
    <Button
      label="Zurücksetzen"
      icon="pi pi-filter-slash"
      severity="secondary"
      outlined
      @click="reset"
    />
  </div>
</template>

<style scoped>
.order-filters {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 1rem;
  margin-bottom: 1rem;
}

.order-filters__field {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.order-filters__field label {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}
</style>
