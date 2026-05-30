<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import Button from 'primevue/button'
import OrderFilters from '@/components/orders/OrderFilters.vue'
import OrdersTable from '@/components/orders/OrdersTable.vue'
import CreateOrderDialog from '@/components/orders/CreateOrderDialog.vue'
import { ordersApi } from '@/services/ordersApi'
import { useApi } from '@/composables/useApi'
import {
  ORDER_STATUSES,
  CANCELLED_STATUS,
  type OrderDto,
  type OrderQuery,
  type OrderStatus,
} from '@/types/order'

const route = useRoute()
const router = useRouter()

const createDialogVisible = ref(false)

const status = ref<OrderStatus | null>(null)
const from = ref<Date | null>(null)
const to = ref<Date | null>(null)

const { data: orders, loading, error, execute } = useApi(ordersApi.list)

// Past orders stay visible until they are settled. Cancelled orders are hidden
// unless the user explicitly filters for them.
const activeOrders = computed(() => {
  const startOfToday = new Date()
  startOfToday.setHours(0, 0, 0, 0)
  return (orders.value ?? []).filter((o) => {
    if (new Date(o.eventDate) < startOfToday && o.status === 'Abgerechnet') return false
    if (o.status === CANCELLED_STATUS && status.value !== CANCELLED_STATUS) return false
    return true
  })
})

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

function openOrder(orderId: number): void {
  router.push({ name: 'order-detail', params: { id: String(orderId) } })
}

function onOrderCreated(order: OrderDto): void {
  router.push({ name: 'order-detail', params: { id: String(order.id) } })
}
</script>

<template>
  <div class="order-list">
    <header class="order-list__header">
      <h1>Aufträge</h1>
      <div class="order-list__actions">
        <Button
          label="Vergangene Aufträge"
          icon="pi pi-history"
          severity="secondary"
          outlined
          @click="router.push({ name: 'orders-archive' })"
        />
        <Button label="Neuer Auftrag" icon="pi pi-plus" @click="createDialogVisible = true" />
      </div>
    </header>

    <OrderFilters v-model:status="status" v-model:from="from" v-model:to="to" />

    <CreateOrderDialog v-model:visible="createDialogVisible" @saved="onOrderCreated" />

    <OrdersTable
      :orders="activeOrders"
      :loading="loading"
      :error="!!error"
      :sort-order="1"
      empty-text="Keine aktiven Aufträge."
      @row-click="openOrder"
    />
  </div>
</template>

<style scoped>
.order-list {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
  overflow: hidden;
}

.order-list__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
  flex-shrink: 0;
}

.order-list__header h1 {
  margin: 0;
}

.order-list__actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.order-list :deep(.order-filters) {
  flex-shrink: 0;
}
</style>
