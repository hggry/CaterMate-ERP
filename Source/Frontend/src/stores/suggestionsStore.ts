import { defineStore } from 'pinia'
import { ref } from 'vue'
import { incomingInvoicesApi } from '@/services/incomingInvoicesApi'

// Holds the number of open price-change suggestions for the sidebar badge.
export const useSuggestionsStore = defineStore('suggestions', () => {
  const count = ref(0)

  async function refresh(): Promise<void> {
    try {
      const list = await incomingInvoicesApi.getAllSuggestions()
      count.value = list.length
    } catch {
      // Badge is best-effort — ignore failures.
    }
  }

  return { count, refresh }
})
