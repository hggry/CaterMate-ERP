<script setup lang="ts">
import { computed } from 'vue'
import { useOrderStatus } from '@/composables/useOrderStatus'
import { ORDER_STATUSES, type OrderStatus } from '@/types/order'

const props = defineProps<{ ordersByStatus: Partial<Record<OrderStatus, number>> }>()
const emit = defineEmits<{ select: [status: OrderStatus] }>()

const { labelFor, tagStyleFor } = useOrderStatus()

// The pipeline tracks open work, so the completed stages ("Durchgeführt",
// "Abgerechnet") are excluded.
const CLOSED_STAGES: OrderStatus[] = ['Durchgeführt', 'Abgerechnet']
const OPEN_STAGES = ORDER_STATUSES.filter((status) => !CLOSED_STAGES.includes(status))

const rows = computed(() => {
  const counts = OPEN_STAGES.map((status) => props.ordersByStatus[status] ?? 0)
  const max = Math.max(1, ...counts)
  return OPEN_STAGES.map((status, i) => ({
    status,
    label: labelFor(status),
    count: counts[i],
    color: tagStyleFor(status).background,
    // Floor bar width so non-zero stages stay visible even when tiny.
    width: counts[i] === 0 ? 0 : Math.max(8, Math.round((counts[i] / max) * 100)),
  }))
})
</script>

<template>
  <div class="funnel">
    <button
      v-for="row in rows"
      :key="row.status"
      type="button"
      class="funnel__row"
      @click="emit('select', row.status)"
    >
      <span class="funnel__label">{{ row.label }}</span>
      <span class="funnel__track">
        <span class="funnel__bar" :style="{ width: `${row.width}%`, background: row.color }" />
      </span>
      <span class="funnel__count">{{ row.count }}</span>
    </button>
  </div>
</template>

<style scoped>
.funnel {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  height: 100%;
}

/* Each stage row grows to share the available height evenly. */
.funnel__row {
  display: grid;
  grid-template-columns: 8rem 1fr 2rem;
  align-items: center;
  gap: 0.625rem;
  flex: 1;
  min-height: 1.75rem;
  background: none;
  border: none;
  cursor: pointer;
  text-align: left;
}

.funnel__label {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.funnel__track {
  height: 1.25rem;
  background: var(--p-content-border-color);
  border-radius: 4px;
  overflow: hidden;
}

.funnel__bar {
  display: block;
  height: 100%;
  background: var(--p-primary-color);
  border-radius: 4px;
  transition: width 0.3s ease;
}

.funnel__count {
  font-size: 0.875rem;
  font-weight: 600;
  text-align: right;
}

.funnel__row:hover .funnel__bar {
  opacity: 0.85;
}

@media (max-width: 480px) {
  .funnel__row {
    grid-template-columns: 6rem 1fr 1.5rem;
  }
}
</style>
