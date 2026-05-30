import { defineStore } from 'pinia'
import { ref } from 'vue'

const DARK_KEY = 'catermate_dark_mode'

export const useThemeStore = defineStore('theme', () => {
  const isDark = ref(localStorage.getItem(DARK_KEY) === 'true')

  function apply(): void {
    document.documentElement.classList.toggle('app-dark', isDark.value)
  }

  function toggle(): void {
    isDark.value = !isDark.value
    localStorage.setItem(DARK_KEY, String(isDark.value))
    apply()
  }

  // Apply on store creation so the correct mode is active immediately.
  apply()

  return { isDark, toggle }
})
