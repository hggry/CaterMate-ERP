<script setup lang="ts">
import DatePicker from 'primevue/datepicker'
import Button from 'primevue/button'

const from = defineModel<Date | null>('from')
const to = defineModel<Date | null>('to')

function reset(): void {
  from.value = null
  to.value = null
}
</script>

<template>
  <div class="order-filters">
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

/* Phone: stack date fields and reset button, each full width. */
@media (max-width: 767.98px) {
  .order-filters {
    flex-direction: column;
    align-items: stretch;
  }

  .order-filters__field :deep(.p-datepicker) {
    width: 100%;
  }

  .order-filters > :deep(.p-button) {
    width: 100%;
  }
}
</style>
