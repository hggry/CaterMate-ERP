import { nextTick, onBeforeUnmount, onMounted, ref, watch, type Ref } from 'vue'

interface ResponsivePageRowsOptions {
  defaultRows?: number
  minRows?: number
  maxRows?: number
}

export function useResponsivePageRows(
  totalItems: Ref<number>,
  options: ResponsivePageRowsOptions = {},
) {
  const tableViewport = ref<HTMLElement | null>(null)
  const rows = ref(options.defaultRows ?? 10)
  const first = ref(0)

  const minRows = options.minRows ?? 4
  const maxRows = options.maxRows ?? 25

  let resizeObserver: ResizeObserver | null = null
  let animationFrame = 0

  function clampFirst(): void {
    if (totalItems.value <= 0) {
      first.value = 0
      return
    }

    const maxFirst = Math.floor((totalItems.value - 1) / rows.value) * rows.value
    if (first.value > maxFirst) first.value = maxFirst
  }

  function calculateRows(): void {
    if (animationFrame) window.cancelAnimationFrame(animationFrame)

    animationFrame = window.requestAnimationFrame(() => {
      const viewport = tableViewport.value
      if (!viewport) return

      const tableHead = viewport.querySelector('thead') as HTMLElement | null
      const paginator = viewport.querySelector('.p-paginator') as HTMLElement | null
      const firstRow = viewport.querySelector('tbody tr') as HTMLElement | null

      const tableHeadHeight = tableHead?.getBoundingClientRect().height ?? 48
      const paginatorHeight = paginator?.getBoundingClientRect().height ?? 56
      const rowHeight = firstRow?.getBoundingClientRect().height ?? 48
      const availableHeight = viewport.clientHeight - tableHeadHeight - paginatorHeight - 2
      const calculatedRows = Math.floor(availableHeight / rowHeight)
      const boundedRows = Math.min(maxRows, Math.max(minRows, calculatedRows || minRows))

      if (rows.value !== boundedRows) rows.value = boundedRows
      clampFirst()
    })
  }

  async function recalculateRows(): Promise<void> {
    await nextTick()
    calculateRows()
  }

  function resetFirst(): void {
    first.value = 0
    void recalculateRows()
  }

  onMounted(() => {
    resizeObserver = new ResizeObserver(calculateRows)
    if (tableViewport.value) resizeObserver.observe(tableViewport.value)
    window.addEventListener('resize', calculateRows)
    void recalculateRows()
  })

  onBeforeUnmount(() => {
    if (animationFrame) window.cancelAnimationFrame(animationFrame)
    resizeObserver?.disconnect()
    window.removeEventListener('resize', calculateRows)
  })

  watch(totalItems, () => {
    clampFirst()
    void recalculateRows()
  })

  watch(rows, clampFirst)

  return {
    tableViewport,
    rows,
    first,
    recalculateRows,
    resetFirst,
  }
}
