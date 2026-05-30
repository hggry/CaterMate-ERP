<script setup lang="ts">
import DataTable, { type DataTableRowClickEvent } from 'primevue/datatable'
import Column from 'primevue/column'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import StatusTag from '@/components/common/StatusTag.vue'
import { useFormat } from '@/composables/useFormat'
import type { OrderDto } from '@/types/order'

withDefaults(
  defineProps<{
    orders: OrderDto[]
    loading?: boolean
    error?: boolean
    sortOrder?: number
    emptyText?: string
  }>(),
  { loading: false, error: false, sortOrder: 1, emptyText: 'Keine Aufträge gefunden.' },
)

const emit = defineEmits<{ rowClick: [orderId: number] }>()
const { formatDate } = useFormat()

function onRowClick(event: DataTableRowClickEvent): void {
  emit('rowClick', event.data.id)
}
</script>

<template>
  <Message v-if="error" severity="error" :closable="false">
    Aufträge konnten nicht geladen werden.
  </Message>

  <div v-else-if="loading" class="orders-table__center">
    <ProgressSpinner style="width: 3rem; height: 3rem" />
  </div>

  <DataTable
    v-else
    :value="orders"
    paginator
    :rows="10"
    row-hover
    data-key="id"
    sort-field="eventDate"
    :sort-order="sortOrder"
    class="orders-table"
    @row-click="onRowClick"
  >
    <template #empty>{{ emptyText }}</template>
    <Column field="id" header="Nr." sortable style="width: 5rem" />
    <Column field="customerName" header="Kunde" sortable />
    <Column field="eventDate" header="Eventdatum" sortable>
      <template #body="{ data }">{{ formatDate(data.eventDate) }}</template>
    </Column>
    <Column field="guestCount" header="Personen" sortable style="width: 8rem" />
    <Column field="location" header="Ort" sortable />
    <Column field="status" header="Status" sortable style="width: 12rem">
      <template #body="{ data }">
        <StatusTag :status="data.status" />
      </template>
    </Column>
  </DataTable>
</template>

<style scoped>
.orders-table__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}

.orders-table :deep(tbody tr) {
  cursor: pointer;
}
</style>
