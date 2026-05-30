<script setup lang="ts">
import { computed } from 'vue'
import { useOrderStatus } from '@/composables/useOrderStatus'
import { ORDER_STATUSES, type OrderStatus } from '@/types/order'

const props = defineProps<{ ordersByStatus: Partial<Record<OrderStatus, number>> }>()
const emit = defineEmits<{ select: [status: OrderStatus] }>()

const { labelFor, tagStyleFor } = useOrderStatus()

const kpis = computed(() =>
  ORDER_STATUSES.map((status) => ({
    status,
    label: labelFor(status),
    count: props.ordersByStatus[status] ?? 0,
    style: tagStyleFor(status),
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
      :style="{ '--kpi-accent': kpi.style.background }"
      @click="emit('select', kpi.status)"
    >
      <span class="status-kpis__dot" :style="{ background: kpi.style.background }" />
      <span class="status-kpis__count">{{ kpi.count }}</span>
      <span class="status-kpis__label">{{ kpi.label }}</span>
    </button>
  </section>
</template>

<style scoped>
.status-kpis {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 0.75rem;
}

@media (max-width: 1200px) {
  .status-kpis {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (max-width: 600px) {
  .status-kpis {
    grid-template-columns: repeat(2, 1fr);
  }
}

.status-kpis__kpi {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  padding: 0.875rem 1rem;
  border: 1px solid var(--p-content-border-color);
  border-radius: var(--p-border-radius, 6px);
  background: var(--p-content-background);
  cursor: pointer;
  text-align: left;
  transition: border-color 0.15s ease, box-shadow 0.15s ease;
}

.status-kpis__kpi:hover {
  border-color: var(--kpi-accent);
  box-shadow: 0 0 0 1px var(--kpi-accent);
}

.status-kpis__dot {
  width: 0.5rem;
  height: 0.5rem;
  border-radius: 50%;
  margin-bottom: 0.25rem;
}

.status-kpis__count {
  font-size: 1.625rem;
  font-weight: 700;
  color: var(--p-text-color);
  line-height: 1;
}

.status-kpis__label {
  font-size: 0.8rem;
  color: var(--p-text-muted-color);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
