<script setup lang="ts">
import { computed } from 'vue'
import { useFormat } from '@/composables/useFormat'
import type { DashboardKpis } from '@/types/dashboard'

const props = defineProps<{ kpis: DashboardKpis | undefined }>()
const { formatCurrency } = useFormat()

const cards = computed(() => [
  {
    icon: 'pi pi-euro',
    label: 'Umsatz akt. Monat',
    value: formatCurrency(props.kpis?.revenueThisMonth ?? 0),
    color: 'var(--cm-avocado)',
    bg: 'color-mix(in srgb, var(--cm-avocado) 12%, transparent)',
  },
  {
    icon: 'pi pi-chart-line',
    label: 'Umsatz akt. Jahr',
    value: formatCurrency(props.kpis?.revenueThisYear ?? 0),
    color: 'var(--cm-teal)',
    bg: 'color-mix(in srgb, var(--cm-teal) 12%, transparent)',
  },
  {
    icon: 'pi pi-receipt',
    label: 'Ø Auftragswert',
    value: formatCurrency(props.kpis?.avgOrderValue ?? 0),
    color: 'var(--cm-caramel)',
    bg: 'color-mix(in srgb, var(--cm-caramel) 18%, transparent)',
  },
  {
    icon: 'pi pi-file',
    label: 'Offene Angebote',
    value: formatCurrency(props.kpis?.openQuoteValue ?? 0),
    color: 'var(--cm-espresso)',
    bg: 'color-mix(in srgb, var(--cm-espresso) 10%, transparent)',
  },
])
</script>

<template>
  <section class="kpi-cards">
    <div
      v-for="card in cards"
      :key="card.label"
      class="kpi-cards__card"
    >
      <span class="kpi-cards__icon-wrap" :style="{ background: card.bg }">
        <i :class="card.icon" :style="{ color: card.color }" />
      </span>
      <div class="kpi-cards__body">
        <span class="kpi-cards__value">{{ card.value }}</span>
        <span class="kpi-cards__label">{{ card.label }}</span>
      </div>
    </div>
  </section>
</template>

<style scoped>
.kpi-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(13rem, 1fr));
  gap: 0.75rem;
}

.kpi-cards__card {
  display: flex;
  align-items: center;
  gap: 0.875rem;
  padding: 1rem 1.25rem;
  border: 1px solid var(--p-content-border-color);
  border-radius: var(--p-border-radius, 6px);
  background: var(--p-content-background);
}

.kpi-cards__icon-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 50%;
  flex-shrink: 0;
  font-size: 1.125rem;
}

.kpi-cards__body {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
  min-width: 0;
}

.kpi-cards__value {
  font-size: 1.25rem;
  font-weight: 700;
}

.kpi-cards__label {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}
</style>
