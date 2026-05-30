<script setup lang="ts">
import { computed } from 'vue'
import { useFormat } from '@/composables/useFormat'
import type { DashboardKpis } from '@/types/dashboard'

const props = defineProps<{ kpis: DashboardKpis | undefined }>()
const { formatCurrency } = useFormat()

const cards = computed(() => [
  { icon: 'pi pi-euro', label: 'Umsatz akt. Monat', value: formatCurrency(props.kpis?.revenueThisMonth ?? 0) },
  { icon: 'pi pi-chart-line', label: 'Umsatz akt. Jahr', value: formatCurrency(props.kpis?.revenueThisYear ?? 0) },
  { icon: 'pi pi-receipt', label: 'Ø Auftragswert', value: formatCurrency(props.kpis?.avgOrderValue ?? 0) },
  { icon: 'pi pi-file', label: 'Offene Angebote', value: formatCurrency(props.kpis?.openQuoteValue ?? 0) },
])
</script>

<template>
  <section class="kpi-cards">
    <div v-for="card in cards" :key="card.label" class="kpi-cards__card">
      <i :class="card.icon" class="kpi-cards__icon" />
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

.kpi-cards__icon {
  font-size: 1.5rem;
  color: var(--p-primary-color);
  flex-shrink: 0;
}

.kpi-cards__body {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
  min-width: 0;
}

.kpi-cards__value {
  font-size: 1.375rem;
  font-weight: 700;
}

.kpi-cards__label {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}
</style>
