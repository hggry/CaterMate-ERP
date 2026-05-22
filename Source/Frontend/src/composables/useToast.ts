import { useToast as usePrimeToast } from 'primevue/usetoast'

// Thin wrapper around PrimeVue's toast with German defaults.
export function useToast() {
  const toast = usePrimeToast()

  function success(detail: string, summary = 'Erfolg'): void {
    toast.add({ severity: 'success', summary, detail, life: 3000 })
  }

  function error(detail: string, summary = 'Fehler'): void {
    toast.add({ severity: 'error', summary, detail, life: 5000 })
  }

  function info(detail: string, summary = 'Hinweis'): void {
    toast.add({ severity: 'info', summary, detail, life: 3000 })
  }

  return { success, error, info }
}
