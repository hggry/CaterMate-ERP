const dateFormatter = new Intl.DateTimeFormat('de-AT', {
  day: '2-digit',
  month: '2-digit',
  year: 'numeric',
})

const dateTimeFormatter = new Intl.DateTimeFormat('de-AT', {
  day: '2-digit',
  month: '2-digit',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
})

const currencyFormatter = new Intl.NumberFormat('de-AT', {
  style: 'currency',
  currency: 'EUR',
})

type DateInput = string | Date | null | undefined

function toDate(value: DateInput): Date | null {
  if (!value) return null
  const date = value instanceof Date ? value : new Date(value)
  return Number.isNaN(date.getTime()) ? null : date
}

// Austrian-locale formatting helpers (dd.MM.yyyy, EUR). Native Intl — no
// date library needed for the MVP.
export function useFormat() {
  function formatDate(value: DateInput): string {
    const date = toDate(value)
    return date ? dateFormatter.format(date) : '—'
  }

  function formatDateTime(value: DateInput): string {
    const date = toDate(value)
    return date ? dateTimeFormatter.format(date) : '—'
  }

  function formatCurrency(value: number | null | undefined): string {
    return value == null ? '—' : currencyFormatter.format(value)
  }

  return { formatDate, formatDateTime, formatCurrency }
}
