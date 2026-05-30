<script setup lang="ts">
import { computed } from 'vue'
import type { OrderDto } from '@/types/order'

const props = withDefaults(defineProps<{ orders: OrderDto[]; weeks?: number }>(), {
  weeks: 20,
})

const WEEKDAY_LABELS = ['Mo', '', 'Mi', '', 'Fr', '', 'So']
const monthFormatter = new Intl.DateTimeFormat('de-AT', { month: 'short' })
const dateFormatter = new Intl.DateTimeFormat('de-AT', {
  day: '2-digit',
  month: '2-digit',
  year: 'numeric',
})

function dayKey(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

// Count events per calendar day from the assigned event dates.
const countsByDay = computed(() => {
  const map = new Map<string, number>()
  for (const order of props.orders) {
    const key = dayKey(new Date(order.eventDate))
    map.set(key, (map.get(key) ?? 0) + 1)
  }
  return map
})

interface Cell {
  date: Date
  key: string
  count: number
  level: number
  inFuture: boolean
}

function levelOf(count: number): number {
  if (count <= 0) return 0
  if (count === 1) return 1
  if (count === 2) return 2
  if (count === 3) return 3
  return 4
}

// Grid starts on the Monday of the current week and runs `weeks` columns forward.
const columns = computed<Cell[][]>(() => {
  const start = new Date()
  start.setHours(0, 0, 0, 0)
  const isoWeekday = (start.getDay() + 6) % 7 // Mon=0 … Sun=6
  start.setDate(start.getDate() - isoWeekday)

  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const cols: Cell[][] = []
  for (let w = 0; w < props.weeks; w++) {
    const col: Cell[] = []
    for (let d = 0; d < 7; d++) {
      const date = new Date(start)
      date.setDate(start.getDate() + w * 7 + d)
      const key = dayKey(date)
      const count = countsByDay.value.get(key) ?? 0
      col.push({ date, key, count, level: levelOf(count), inFuture: date >= today })
    }
    cols.push(col)
  }
  return cols
})

// Month label above a week column when that week introduces a new month.
const monthLabels = computed(() =>
  columns.value.map((col, i) => {
    const firstOfWeek = col[0].date
    const prevMonth = i > 0 ? columns.value[i - 1][0].date.getMonth() : -1
    return firstOfWeek.getMonth() !== prevMonth ? monthFormatter.format(firstOfWeek) : ''
  }),
)

function cellTitle(cell: Cell): string {
  const label = dateFormatter.format(cell.date)
  if (cell.count === 0) return `${label}: keine Events`
  return `${label}: ${cell.count} Event${cell.count > 1 ? 's' : ''}`
}
</script>

<template>
  <div class="heatmap">
    <div class="heatmap__scroll">
      <div class="heatmap__grid">
        <div class="heatmap__months">
          <span
            v-for="(label, i) in monthLabels"
            :key="i"
            class="heatmap__month"
          >{{ label }}</span>
        </div>

        <div class="heatmap__body">
          <div class="heatmap__weekdays">
            <span v-for="(label, i) in WEEKDAY_LABELS" :key="i" class="heatmap__weekday">
              {{ label }}
            </span>
          </div>

          <div class="heatmap__weeks">
            <div v-for="(col, ci) in columns" :key="ci" class="heatmap__week">
              <span
                v-for="cell in col"
                :key="cell.key"
                class="heatmap__cell"
                :class="[`heatmap__cell--l${cell.level}`, { 'heatmap__cell--past': !cell.inFuture }]"
                :title="cellTitle(cell)"
              />
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="heatmap__legend">
      <span>weniger</span>
      <span class="heatmap__cell heatmap__cell--l0" />
      <span class="heatmap__cell heatmap__cell--l1" />
      <span class="heatmap__cell heatmap__cell--l2" />
      <span class="heatmap__cell heatmap__cell--l3" />
      <span class="heatmap__cell heatmap__cell--l4" />
      <span>mehr</span>
    </div>
  </div>
</template>

<style scoped>
.heatmap {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.heatmap__scroll {
  overflow-x: auto;
}

.heatmap__grid {
  display: inline-flex;
  flex-direction: column;
  gap: 0.25rem;
}

.heatmap__months {
  display: flex;
  margin-left: 1.75rem;
}

.heatmap__month {
  width: calc(0.875rem + 0.2rem);
  font-size: 0.6875rem;
  color: var(--p-text-muted-color);
  white-space: nowrap;
}

.heatmap__body {
  display: flex;
  gap: 0.25rem;
}

.heatmap__weekdays {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  width: 1.5rem;
}

.heatmap__weekday {
  height: 0.875rem;
  font-size: 0.6875rem;
  line-height: 0.875rem;
  color: var(--p-text-muted-color);
}

.heatmap__weeks {
  display: flex;
  gap: 0.2rem;
}

.heatmap__week {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.heatmap__cell {
  width: 0.875rem;
  height: 0.875rem;
  border-radius: 2px;
  background: var(--p-content-border-color);
}

.heatmap__cell--l1 {
  background: color-mix(in srgb, var(--p-primary-color) 30%, transparent);
}

.heatmap__cell--l2 {
  background: color-mix(in srgb, var(--p-primary-color) 50%, transparent);
}

.heatmap__cell--l3 {
  background: color-mix(in srgb, var(--p-primary-color) 75%, transparent);
}

.heatmap__cell--l4 {
  background: var(--p-primary-color);
}

.heatmap__cell--past {
  opacity: 0.45;
}

.heatmap__legend {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.6875rem;
  color: var(--p-text-muted-color);
}
</style>
