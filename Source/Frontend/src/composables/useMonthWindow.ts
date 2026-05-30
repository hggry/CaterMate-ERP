// Builds a fixed, gap-free window of months so monthly bar charts stay
// comparable even when the backend only returns months that have data.
const monthLabelFormatter = new Intl.DateTimeFormat('de-AT', {
  month: 'short',
  year: '2-digit',
})

export interface MonthBucket {
  key: string // 'YYYY-MM'
  label: string // e.g. 'Mai 25'
}

function monthKey(date: Date): string {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  return `${year}-${month}`
}

export function useMonthWindow() {
  // Window spanning `past` months back to `future` months ahead of the current
  // month (inclusive). Default 10 + current + 1 = 12 columns.
  function buildMonthWindow(past = 10, future = 1): MonthBucket[] {
    const now = new Date()
    const buckets: MonthBucket[] = []
    for (let offset = -past; offset <= future; offset++) {
      const date = new Date(now.getFullYear(), now.getMonth() + offset, 1)
      buckets.push({ key: monthKey(date), label: monthLabelFormatter.format(date) })
    }
    return buckets
  }

  // Maps a sparse list of { month: 'YYYY-MM', [valueKey]: number } onto the
  // window, defaulting missing months to 0.
  function mapToWindow<T extends { month: string }>(
    window: MonthBucket[],
    rows: T[],
    valueKey: keyof T,
  ): number[] {
    const byMonth = new Map(rows.map((r) => [r.month, Number(r[valueKey]) || 0]))
    return window.map((b) => byMonth.get(b.key) ?? 0)
  }

  return { buildMonthWindow, mapToWindow }
}
