<script setup lang="ts">
import { computed, ref } from 'vue'
import type { OrderDto } from '@/types/order'

const props = defineProps<{ orders: OrderDto[] }>()

// ── Month navigation ──────────────────────────────────────────────────────
const anchor = ref(startOfMonth(new Date()))

function startOfMonth(d: Date): Date {
  return new Date(d.getFullYear(), d.getMonth(), 1)
}

function prevMonth(): void {
  anchor.value = new Date(anchor.value.getFullYear(), anchor.value.getMonth() - 1, 1)
}

function nextMonth(): void {
  anchor.value = new Date(anchor.value.getFullYear(), anchor.value.getMonth() + 1, 1)
}

const monthYearLabel = computed(() =>
  anchor.value.toLocaleDateString('de-AT', { month: 'long', year: 'numeric' }),
)

// ── Event density ─────────────────────────────────────────────────────────
const dateFormatter = new Intl.DateTimeFormat('de-AT', {
  day: '2-digit', month: '2-digit', year: 'numeric',
})

function dayKey(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

const countsByDay = computed(() => {
  const map = new Map<string, number>()
  for (const order of props.orders) {
    const key = dayKey(new Date(order.eventDate))
    map.set(key, (map.get(key) ?? 0) + 1)
  }
  return map
})

function levelOf(count: number): number {
  if (count <= 0) return 0
  if (count === 1) return 1
  if (count === 2) return 2
  if (count === 3) return 3
  return 4
}

// ISO week number (Mon = first day of week)
function isoWeek(d: Date): number {
  const utc = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()))
  const day = utc.getUTCDay() || 7
  utc.setUTCDate(utc.getUTCDate() + 4 - day)
  const yearStart = new Date(Date.UTC(utc.getUTCFullYear(), 0, 1))
  return Math.ceil(((utc.getTime() - yearStart.getTime()) / 86_400_000 + 1) / 7)
}

// ── Calendar grid ─────────────────────────────────────────────────────────
interface CalDay {
  date: Date
  key: string
  count: number
  level: number
  isToday: boolean
  isPast: boolean
}

interface CalWeek {
  kw: number
  days: (CalDay | null)[]
}

const WEEKDAY_LABELS = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']

const calendarWeeks = computed((): CalWeek[] => {
  const year  = anchor.value.getFullYear()
  const month = anchor.value.getMonth()
  const firstDay    = new Date(year, month, 1)
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const startPad    = (firstDay.getDay() + 6) % 7  // Mon=0…Sun=6

  const today = new Date()
  today.setHours(0, 0, 0, 0)

  // Build flat array: null for padding, CalDay for real days
  const flat: (CalDay | null)[] = []
  for (let i = 0; i < startPad; i++) flat.push(null)
  for (let d = 1; d <= daysInMonth; d++) {
    const date  = new Date(year, month, d)
    const key   = dayKey(date)
    const count = countsByDay.value.get(key) ?? 0
    flat.push({
      date, key, count,
      level: levelOf(count),
      isToday: date.getTime() === today.getTime(),
      isPast:  date < today,
    })
  }

  // Chunk into weeks of 7
  const weeks: CalWeek[] = []
  for (let i = 0; i < flat.length; i += 7) {
    const slice = flat.slice(i, i + 7)
    while (slice.length < 7) slice.push(null)
    const firstReal = slice.find((d): d is CalDay => d !== null)
    weeks.push({ kw: firstReal ? isoWeek(firstReal.date) : 0, days: slice })
  }
  return weeks
})

function cellTitle(day: CalDay): string {
  const label = dateFormatter.format(day.date)
  if (day.count === 0) return `${label}: keine Events`
  return `${label}: ${day.count} Event${day.count > 1 ? 's' : ''}`
}
</script>

<template>
  <div class="heatmap">
    <!-- Month navigation -->
    <div class="heatmap__nav">
      <button class="heatmap__nav-btn" title="Vorheriger Monat" @click="prevMonth">
        <i class="pi pi-chevron-left" />
      </button>
      <span class="heatmap__nav-label">{{ monthYearLabel }}</span>
      <button class="heatmap__nav-btn" title="Nächster Monat" @click="nextMonth">
        <i class="pi pi-chevron-right" />
      </button>
    </div>

    <!-- Calendar grid: KW + 7 weekday columns -->
    <div class="heatmap__calendar">
      <!-- Header row -->
      <span class="heatmap__kw-header">KW</span>
      <span
        v-for="label in WEEKDAY_LABELS"
        :key="label"
        class="heatmap__weekday-label"
      >{{ label }}</span>

      <!-- Week rows -->
      <template v-for="week in calendarWeeks" :key="week.kw">
        <span class="heatmap__kw">{{ week.kw }}</span>
        <span
          v-for="(day, i) in week.days"
          :key="day ? day.key : `pad-${i}`"
          class="heatmap__cell"
          :class="day ? [
            `heatmap__cell--l${day.level}`,
            { 'heatmap__cell--past': day.isPast, 'heatmap__cell--today': day.isToday }
          ] : 'heatmap__cell--empty'"
          :title="day ? cellTitle(day) : ''"
        >
          <span v-if="day" class="heatmap__day-num">{{ day.date.getDate() }}</span>
        </span>
      </template>
    </div>

    <!-- Legend -->
    <div class="heatmap__legend">
      <span>weniger</span>
      <span class="heatmap__legend-cell heatmap__cell--l0" />
      <span class="heatmap__legend-cell heatmap__cell--l1" />
      <span class="heatmap__legend-cell heatmap__cell--l2" />
      <span class="heatmap__legend-cell heatmap__cell--l3" />
      <span class="heatmap__legend-cell heatmap__cell--l4" />
      <span>mehr</span>
    </div>
  </div>
</template>

<style scoped>
.heatmap {
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
  align-items: center;
}

/* Navigation */
.heatmap__nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  gap: 0.5rem;
}

.heatmap__nav-label {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--p-text-color);
  text-align: center;
  flex: 1;
}

.heatmap__nav-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 1.75rem;
  height: 1.75rem;
  border: 1px solid var(--p-content-border-color);
  border-radius: var(--p-border-radius, 6px);
  background: none;
  cursor: pointer;
  color: var(--p-text-muted-color);
  font-size: 0.75rem;
  transition: border-color 0.15s, color 0.15s;
  flex-shrink: 0;
}

.heatmap__nav-btn:hover {
  border-color: var(--cm-avocado);
  color: var(--cm-avocado);
}

/* Calendar grid */
.heatmap__calendar {
  display: grid;
  /* KW column + 7 day columns, fixed small size */
  grid-template-columns: 1.75rem repeat(7, 1.75rem);
  gap: 0.25rem;
}

/* Header cells */
.heatmap__kw-header,
.heatmap__weekday-label {
  height: 1.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.625rem;
  font-weight: 600;
  color: var(--p-text-muted-color);
}

/* KW numbers */
.heatmap__kw {
  height: 1.75rem;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.625rem;
  color: var(--p-text-muted-color);
}

/* Day cells */
.heatmap__cell {
  width: 1.75rem;
  height: 1.75rem;
  border-radius: 3px;
  background: var(--p-content-border-color);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: default;
}

.heatmap__cell--empty {
  background: transparent;
  pointer-events: none;
}

.heatmap__day-num {
  font-size: 0.625rem;
  color: var(--p-text-muted-color);
  user-select: none;
  line-height: 1;
}

/* Colour levels */
.heatmap__cell--l1 { background: #b8d47a; }
.heatmap__cell--l2 { background: #8eba3f; }
.heatmap__cell--l3 { background: #6b9523; }
.heatmap__cell--l4 { background: var(--cm-avocado); }

.heatmap__cell--l1 .heatmap__day-num,
.heatmap__cell--l2 .heatmap__day-num,
.heatmap__cell--l3 .heatmap__day-num,
.heatmap__cell--l4 .heatmap__day-num {
  color: #fff;
}

.heatmap__cell--past { opacity: 0.5; }

.heatmap__cell--today {
  outline: 2px solid var(--cm-avocado);
  outline-offset: -2px;
}

/* Legend — compact */
.heatmap__legend {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  font-size: 0.625rem;
  color: var(--p-text-muted-color);
  margin-top: 0.375rem;
}

.heatmap__legend-cell {
  width: 0.75rem;
  height: 0.75rem;
  border-radius: 2px;
  background: var(--p-content-border-color);
  flex-shrink: 0;
}

.heatmap__legend-cell.heatmap__cell--l1 { background: #b8d47a; }
.heatmap__legend-cell.heatmap__cell--l2 { background: #8eba3f; }
.heatmap__legend-cell.heatmap__cell--l3 { background: #6b9523; }
.heatmap__legend-cell.heatmap__cell--l4 { background: var(--cm-avocado); }
</style>
