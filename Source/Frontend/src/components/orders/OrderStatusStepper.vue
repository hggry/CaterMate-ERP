<script setup lang="ts">
import { computed } from 'vue'
import { ORDER_STATUSES, type OrderStatus } from '@/types/order'
import { useOrderStatus } from '@/composables/useOrderStatus'

const props = defineProps<{ status: OrderStatus }>()

const { labelFor, indexOf } = useOrderStatus()

const currentIndex = computed(() => indexOf(props.status))

const isTerminal = computed(() => props.status === 'Abgerechnet')

function stateOf(index: number): 'done' | 'active' | 'upcoming' {
  if (index < currentIndex.value) return 'done'
  if (index === currentIndex.value) return isTerminal.value ? 'done' : 'active'
  return 'upcoming'
}
</script>

<template>
  <ol class="stepper">
    <li
      v-for="(s, i) in ORDER_STATUSES"
      :key="s"
      class="stepper__step"
      :class="`stepper__step--${stateOf(i)}`"
    >
      <span class="stepper__marker">
        <i v-if="stateOf(i) === 'done'" class="pi pi-check" />
        <template v-else>{{ i + 1 }}</template>
      </span>
      <span class="stepper__label">{{ labelFor(s) }}</span>
    </li>
  </ol>
</template>

<style scoped>
.stepper {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.25rem 0.5rem;
  margin: 0;
  padding: 0;
  list-style: none;
}

.stepper__step {
  display: flex;
  align-items: center;
  gap: 0.375rem;
  font-size: clamp(0.75rem, 2.5vw, 0.8125rem);
  color: var(--p-text-muted-color);
}

/* Horizontal connector between steps (wide layout). */
.stepper__step:not(:last-child)::after {
  content: '';
  width: 1.25rem;
  height: 1px;
  background: var(--p-content-border-color);
  margin-left: 0.25rem;
}

.stepper__marker {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 1.5rem;
  height: 1.5rem;
  border-radius: 50%;
  border: 1px solid var(--p-content-border-color);
  font-size: 0.75rem;
  font-weight: 600;
  flex-shrink: 0;
}

.stepper__step--done .stepper__marker {
  background: var(--p-primary-color);
  border-color: var(--p-primary-color);
  color: var(--p-primary-contrast-color);
}

.stepper__step--active .stepper__marker {
  border-color: var(--p-primary-color);
  color: var(--p-primary-color);
}

.stepper__step--active .stepper__label {
  color: var(--p-text-color);
  font-weight: 600;
}

/* Narrow layout: switch to a vertical stepper with a connecting line that
   runs down from each marker to the next. */
@media (max-width: 640px) {
  .stepper {
    flex-direction: column;
    flex-wrap: nowrap;
    align-items: stretch;
    gap: 0;
  }

  .stepper__step {
    gap: 0.625rem;
    padding: 0.25rem 0;
  }

  /* Replace the horizontal connector with a vertical one under the marker. */
  .stepper__step:not(:last-child)::after {
    display: none;
  }

  .stepper__step:not(:last-child) .stepper__marker::after {
    content: '';
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    width: 2px;
    height: 0.5rem;
    background: var(--p-content-border-color);
  }

  .stepper__step--done .stepper__marker::after {
    background: var(--p-primary-color);
  }
}
</style>
