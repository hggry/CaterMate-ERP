<script setup lang="ts">
import { computed, watch } from 'vue'
import DataTable, { type DataTableRowClickEvent } from 'primevue/datatable'
import Column from 'primevue/column'
import Select from 'primevue/select'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import StatusTag from '@/components/common/StatusTag.vue'
import { useFormat } from '@/composables/useFormat'
import { useOrderStatus } from '@/composables/useOrderStatus'
import { useResponsivePageRows } from '@/composables/useResponsivePageRows'
import { useBreakpoint } from '@/composables/useBreakpoint'
import { ALL_ORDER_STATUSES, type OrderDto, type OrderStatus } from '@/types/order'

const props = withDefaults(
  defineProps<{
    orders: OrderDto[]
    loading?: boolean
    error?: boolean
    sortOrder?: number
    emptyText?: string
  }>(),
  { loading: false, error: false, sortOrder: 1, emptyText: 'Keine Aufträge gefunden.' },
)

const status = defineModel<OrderStatus | null>('status', { default: null })

const emit = defineEmits<{ rowClick: [orderId: number] }>()
const { formatDate } = useFormat()
const { labelFor } = useOrderStatus()
const { isPhone } = useBreakpoint()

const statusOptions = ALL_ORDER_STATUSES.map((value) => ({ value, label: labelFor(value) }))

const totalOrders = computed(() => props.orders.length)
const {
  tableViewport,
  rows: pageRows,
  first,
  resetFirst,
} = useResponsivePageRows(totalOrders, { defaultRows: 10, minRows: 4, maxRows: 25 })

// The DataTable sorts itself by event date; the mobile card list needs an
// explicitly sorted copy to match that order.
const sortedOrders = computed(() => {
  const copy = [...props.orders]
  copy.sort((a, b) => {
    const diff = new Date(a.eventDate).getTime() - new Date(b.eventDate).getTime()
    return (props.sortOrder ?? 1) >= 0 ? diff : -diff
  })
  return copy
})

watch(() => props.orders, resetFirst)

function onRowClick(event: DataTableRowClickEvent): void {
  emit('rowClick', event.data.id)
}
</script>

<template>
  <div ref="tableViewport" class="orders-table__viewport">
    <Message v-if="error" severity="error" :closable="false">
      Aufträge konnten nicht geladen werden.
    </Message>

    <div v-else-if="loading" class="orders-table__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <!-- Phone: status filter + tappable card list (no table, no horizontal scroll) -->
    <template v-else-if="isPhone">
      <Select
        v-model="status"
        :options="statusOptions"
        option-label="label"
        option-value="value"
        placeholder="Status filtern"
        show-clear
        class="orders-cards__filter"
      />
      <p v-if="sortedOrders.length === 0" class="orders-cards__empty">{{ emptyText }}</p>
      <ul v-else class="orders-cards">
        <li
          v-for="o in sortedOrders"
          :key="o.id"
          class="orders-card"
          @click="emit('rowClick', o.id)"
        >
          <div class="orders-card__top">
            <span class="orders-card__customer">{{ o.customerName }}</span>
            <StatusTag :status="o.status" />
          </div>
          <div class="orders-card__meta">
            <span><i class="pi pi-calendar" /> {{ formatDate(o.eventDate) }}</span>
            <span><i class="pi pi-users" /> {{ o.guestCount }}</span>
          </div>
          <div v-if="o.location" class="orders-card__location">
            <i class="pi pi-map-marker" /> {{ o.location }}
          </div>
        </li>
      </ul>
    </template>

    <DataTable
      v-else
      v-model:first="first"
      :value="orders"
      paginator
      :rows="pageRows"
      row-hover
      data-key="id"
      sort-field="eventDate"
      :sort-order="sortOrder"
      class="orders-table"
      @row-click="onRowClick"
    >
      <template #empty>{{ emptyText }}</template>
      <Column field="id" header="Nr." sortable style="width: 5rem" header-class="col-optional" body-class="col-optional" />
      <Column field="customerName" header="Kunde" sortable />
      <Column field="eventDate" header="Eventdatum" sortable>
        <template #body="{ data }">{{ formatDate(data.eventDate) }}</template>
      </Column>
      <Column field="guestCount" header="Personen" sortable style="width: 8rem" />
      <Column field="location" header="Ort" sortable header-class="col-optional" body-class="col-optional" />

      <!-- Status column: filter dropdown replaces the sort button -->
      <Column field="status" style="width: 14rem">
        <template #header>
          <Select
            v-model="status"
            :options="statusOptions"
            option-label="label"
            option-value="value"
            placeholder="Status"
            show-clear
            class="orders-table__status-filter"
            @click.stop
          />
        </template>
        <template #body="{ data }">
          <StatusTag :status="data.status" />
        </template>
      </Column>
    </DataTable>
  </div>
</template>

<style scoped>
.orders-table__viewport {
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.orders-table__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
  height: 100%;
}

.orders-table {
  height: 100%;
}

.orders-table :deep(tbody tr) {
  cursor: pointer;
}

.orders-table__status-filter {
  width: 100%;
}

/* Keep the header cell looking like a normal column header */
.orders-table :deep(.p-datatable-column-header-content) {
  width: 100%;
}

/* ── Tablet (768–1023px): drop low-priority columns, keep the table ──────── */
@media (min-width: 768px) and (max-width: 1023.98px) {
  .orders-table :deep(.col-optional) {
    display: none;
  }
}

/* ── Phone (< 768px): card list ─────────────────────────────────────────── */
.orders-cards__filter {
  width: 100%;
  margin-bottom: 1rem;
}

.orders-cards__empty {
  color: var(--p-text-muted-color);
  text-align: center;
  padding: 2rem 0;
}

.orders-cards {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
  height: 100%;
  overflow-y: auto;
}

.orders-card {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  padding: 0.875rem;
  border: 1px solid var(--p-content-border-color);
  border-radius: var(--p-border-radius, 8px);
  background: var(--p-content-background);
  cursor: pointer;
}

.orders-card:active {
  background: var(--cm-sand);
}

.orders-card__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
}

.orders-card__customer {
  font-weight: 600;
  color: var(--p-text-color);
}

.orders-card__meta {
  display: flex;
  gap: 1rem;
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.orders-card__meta i,
.orders-card__location i {
  margin-right: 0.25rem;
  font-size: 0.8125rem;
}

.orders-card__location {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
