<script setup lang="ts">
import Panel from 'primevue/panel'
import type { OrderDto } from '@/types/order'
import { useFormat } from '@/composables/useFormat'

const props = defineProps<{ order: OrderDto }>()

const { formatDateTime } = useFormat()
</script>

<template>
  <Panel header="Anfrage aus Telegram">
    <div class="request-panel">
      <div class="request-panel__row">
        <span class="request-panel__label">Kunde</span>
        <span>{{ props.order.customerName }}</span>
      </div>
      <div class="request-panel__row">
        <span class="request-panel__label">Telefon</span>
        <span>{{ props.order.customerPhone ?? '—' }}</span>
      </div>
      <div class="request-panel__row">
        <span class="request-panel__label">Eventdatum</span>
        <span>{{ formatDateTime(props.order.eventDate) }}</span>
      </div>
      <div class="request-panel__row">
        <span class="request-panel__label">Eingegangen am</span>
        <span>{{ formatDateTime(props.order.createdAt) }}</span>
      </div>
      <div class="request-panel__row request-panel__row--block">
        <span class="request-panel__label">Sonderwünsche</span>
        <span>{{ props.order.specialWishes || '—' }}</span>
      </div>
      <div class="request-panel__row request-panel__row--block">
        <span class="request-panel__label">Allergien</span>
        <span>{{ props.order.allergies || '—' }}</span>
      </div>
      <div class="request-panel__row request-panel__row--block">
        <span class="request-panel__label">Gerichtswünsche</span>
        <span>{{ props.order.dishWishes || '—' }}</span>
      </div>
    </div>
  </Panel>
</template>

<style scoped>
.request-panel {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.request-panel__row {
  display: flex;
  gap: 1rem;
}

.request-panel__row--block {
  flex-direction: column;
  gap: 0.25rem;
}

.request-panel__label {
  min-width: 9rem;
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}
</style>
