<script setup lang="ts">
import { computed } from 'vue'
import Chart from 'primevue/chart'

const props = withDefaults(
  defineProps<{
    labels: string[]
    values: number[]
    label: string
    color?: string
    /** Optional formatter for tooltip values (e.g. currency). */
    valueFormatter?: (value: number) => string
  }>(),
  { color: '#7aaa28' },
)

// Read theme colors at render time so axes stay legible in light/dark themes.
function themeColor(variable: string, fallback: string): string {
  if (typeof window === 'undefined') return fallback
  const value = getComputedStyle(document.documentElement).getPropertyValue(variable).trim()
  return value || fallback
}

const chartData = computed(() => ({
  labels: props.labels,
  datasets: [
    {
      label: props.label,
      data: props.values,
      backgroundColor: props.color,
      borderRadius: 4,
      maxBarThickness: 48,
    },
  ],
}))

const chartOptions = computed(() => {
  const textColor = themeColor('--p-text-muted-color', '#6b7280')
  const gridColor = themeColor('--p-content-border-color', '#e5e7eb')
  const fmt = props.valueFormatter
  return {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        callbacks: fmt
          ? { label: (ctx: { parsed: { y: number } }) => fmt(ctx.parsed.y) }
          : undefined,
      },
    },
    scales: {
      x: {
        ticks: { color: textColor },
        grid: { display: false },
      },
      y: {
        beginAtZero: true,
        ticks: { color: textColor },
        grid: { color: gridColor },
      },
    },
  }
})
</script>

<template>
  <div class="monthly-bar-chart">
    <Chart type="bar" :data="chartData" :options="chartOptions" />
  </div>
</template>

<style scoped>
.monthly-bar-chart {
  height: 100%;
  min-height: 12rem;
}

.monthly-bar-chart :deep(.p-chart) {
  height: 100%;
}
</style>
