<script setup lang="ts">
import { computed } from 'vue'
import { useOrderStatus } from '@/composables/useOrderStatus'
import { ORDER_STATUSES, type OrderStatus } from '@/types/order'

const props = defineProps<{ ordersByStatus: Partial<Record<OrderStatus, number>> }>()
const emit = defineEmits<{ select: [status: OrderStatus] }>()

const { labelFor } = useOrderStatus()

const kpis = computed(() =>
  ORDER_STATUSES.map((status) => ({
    status,
    label: labelFor(status),
    count: props.ordersByStatus[status] ?? 0,
  })),
)
</script>

<template>
  <section class="status-kpis">
    <button
      v-for="kpi in kpis"
      :key="kpi.status"
      type="button"
      class="status-kpis__kpi"
      @click="emit('select', kpi.status)"
    >
      <span class="status-kpis__count">{{ kpi.count }}</span>
      <span class="status-kpis__label">{{ kpi.label }}</span>
    </button>
  </section>
</template>

<style scoped>
.status-kpis {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(9rem, 1fr));
  gap: 0.75rem;
}

.status-kpis__kpi {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  padding: 1rem;
  border: 1px solid var(--p-content-border-color);
  border-radius: var(--p-border-radius, 6px);
  background: var(--p-content-background);
  cursor: pointer;
  text-align: left;
  transition: border-color 0.15s ease;
}

.status-kpis__kpi:hover {
  border-color: var(--p-primary-color);
}

.status-kpis__count {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--p-primary-color);
}

.status-kpis__label {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}
</style>
