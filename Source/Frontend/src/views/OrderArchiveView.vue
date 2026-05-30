<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Button from 'primevue/button'
import OrderFilters from '@/components/orders/OrderFilters.vue'
import OrdersTable from '@/components/orders/OrdersTable.vue'
import { ordersApi } from '@/services/ordersApi'
import { useApi } from '@/composables/useApi'
import type { OrderQuery, OrderStatus } from '@/types/order'

const router = useRouter()

const status = ref<OrderStatus | null>(null)
const from = ref<Date | null>(null)
const to = ref<Date | null>(null)

const { data: orders, loading, error, execute } = useApi(ordersApi.list)

// Only settled orders that already happened (before today).
const pastOrders = computed(() => {
  const startOfToday = new Date()
  startOfToday.setHours(0, 0, 0, 0)
  return (orders.value ?? []).filter(
    (o) => new Date(o.eventDate) < startOfToday && o.status === 'Abgerechnet',
  )
})

function load(): void {
  const query: OrderQuery = {}
  if (status.value) query.status = status.value
  if (from.value) query.from = from.value.toISOString()
  if (to.value) query.to = to.value.toISOString()
  execute(query)
}

onMounted(load)
watch([status, from, to], load)

function openOrder(orderId: number): void {
  router.push({ name: 'order-detail', params: { id: String(orderId) } })
}
</script>

<template>
  <div class="order-archive">
    <header class="order-archive__header">
      <h1>Vergangene Aufträge</h1>
      <Button
        label="Zurück zu aktuellen Aufträgen"
        icon="pi pi-arrow-left"
        severity="secondary"
        text
        @click="router.push({ name: 'orders' })"
      />
    </header>

    <OrderFilters v-model:status="status" v-model:from="from" v-model:to="to" />

    <OrdersTable
      :orders="pastOrders"
      :loading="loading"
      :error="!!error"
      :sort-order="-1"
      empty-text="Keine vergangenen Aufträge."
      @row-click="openOrder"
    />
  </div>
</template>

<style scoped>
.order-archive {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
  overflow: hidden;
}

.order-archive__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
  flex-shrink: 0;
}

.order-archive__header h1 {
  margin: 0;
}

.order-archive :deep(.order-filters) {
  flex-shrink: 0;
}
</style>
