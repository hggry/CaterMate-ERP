<script setup lang="ts">
import { computed } from 'vue'
import { useFormat } from '@/composables/useFormat'
import type { OrderDto } from '@/types/order'

const props = defineProps<{ orders: OrderDto[]; limit?: number }>()
const emit = defineEmits<{ select: [orderId: number] }>()

const { formatDate } = useFormat()

const upcoming = computed(() => {
  const startOfToday = new Date()
  startOfToday.setHours(0, 0, 0, 0)
  return [...props.orders]
    .filter((o) => new Date(o.eventDate) >= startOfToday)
    .sort((a, b) => new Date(a.eventDate).getTime() - new Date(b.eventDate).getTime())
    .slice(0, props.limit ?? 6)
})
</script>

<template>
  <div class="upcoming">
    <p v-if="!upcoming.length" class="upcoming__empty">Keine anstehenden Events.</p>
    <button
      v-for="event in upcoming"
      :key="event.id"
      type="button"
      class="upcoming__row"
      @click="emit('select', event.id)"
    >
      <span class="upcoming__date">{{ formatDate(event.eventDate) }}</span>
      <span class="upcoming__info">
        <span class="upcoming__customer">{{ event.customerName }}</span>
        <span class="upcoming__meta">{{ event.guestCount }} Pers. · {{ event.location }}</span>
      </span>
    </button>
  </div>
</template>

<style scoped>
.upcoming {
  display: flex;
  flex-direction: column;
}

.upcoming__empty {
  margin: 0;
  color: var(--p-text-muted-color);
}

.upcoming__row {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 0.5rem 0;
  border: none;
  border-bottom: 1px solid var(--p-content-border-color);
  background: none;
  cursor: pointer;
  text-align: left;
}

.upcoming__row:last-child {
  border-bottom: none;
}

.upcoming__date {
  font-weight: 600;
  font-size: 0.875rem;
  white-space: nowrap;
  color: var(--p-primary-color);
}

.upcoming__info {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
  min-width: 0;
}

.upcoming__customer {
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.upcoming__meta {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
