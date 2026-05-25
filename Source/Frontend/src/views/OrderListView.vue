<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import DataTable, { type DataTableRowClickEvent } from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import OrderFilters from '@/components/orders/OrderFilters.vue'
import CreateOrderDialog from '@/components/orders/CreateOrderDialog.vue'
import StatusTag from '@/components/common/StatusTag.vue'
import { ordersApi } from '@/services/ordersApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import { ORDER_STATUSES, type OrderDto, type OrderQuery, type OrderStatus } from '@/types/order'

const route = useRoute()
const router = useRouter()
const { formatDate } = useFormat()

const createDialogVisible = ref(false)

const status = ref<OrderStatus | null>(null)
const from = ref<Date | null>(null)
const to = ref<Date | null>(null)

const { data: orders, loading, error, execute } = useApi(ordersApi.list)

function load(): void {
  const query: OrderQuery = {}
  if (status.value) query.status = status.value
  if (from.value) query.from = from.value.toISOString()
  if (to.value) query.to = to.value.toISOString()
  execute(query)
}

onMounted(() => {
  const queryStatus = route.query.status
  if (
    typeof queryStatus === 'string' &&
    (ORDER_STATUSES as readonly string[]).includes(queryStatus)
  ) {
    status.value = queryStatus as OrderStatus
  }
  load()
})

watch([status, from, to], load)

function onRowClick(event: DataTableRowClickEvent): void {
  router.push({ name: 'order-detail', params: { id: String(event.data.id) } })
}

function onOrderCreated(order: OrderDto): void {
  router.push({ name: 'order-detail', params: { id: String(order.id) } })
}
</script>

<template>
  <div class="order-list">
    <header class="order-list__header">
      <h1>Aufträge</h1>
      <Button label="Neuer Auftrag" icon="pi pi-plus" @click="createDialogVisible = true" />
    </header>

    <OrderFilters v-model:status="status" v-model:from="from" v-model:to="to" />

    <CreateOrderDialog v-model:visible="createDialogVisible" @saved="onOrderCreated" />

    <Message v-if="error" severity="error" :closable="false">
      Aufträge konnten nicht geladen werden.
    </Message>

    <div v-if="loading" class="order-list__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <DataTable
      v-else
      :value="orders ?? []"
      paginator
      :rows="10"
      row-hover
      data-key="id"
      class="order-list__table"
      @row-click="onRowClick"
    >
      <template #empty>Keine Aufträge gefunden.</template>
      <Column field="id" header="Nr." style="width: 5rem" />
      <Column field="customerName" header="Kunde" />
      <Column header="Eventdatum">
        <template #body="{ data }">{{ formatDate(data.eventDate) }}</template>
      </Column>
      <Column field="guestCount" header="Personen" style="width: 8rem" />
      <Column field="location" header="Ort" />
      <Column header="Status" style="width: 12rem">
        <template #body="{ data }">
          <StatusTag :status="data.status" />
        </template>
      </Column>
    </DataTable>
  </div>
</template>

<style scoped>
.order-list__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.order-list__header h1 {
  margin: 0;
}

.order-list__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}

.order-list__table :deep(tbody tr) {
  cursor: pointer;
}
</style>
