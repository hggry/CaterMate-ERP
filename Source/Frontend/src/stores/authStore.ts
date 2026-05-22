import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { authApi } from '@/services/authApi'
import { TOKEN_KEY } from '@/services/http'

const EXPIRY_KEY = 'catermate_expires_at'
const USER_KEY = 'catermate_username'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem(TOKEN_KEY))
  const expiresAt = ref<string | null>(localStorage.getItem(EXPIRY_KEY))
  const username = ref<string | null>(localStorage.getItem(USER_KEY))

  const isAuthenticated = computed(() => {
    if (!token.value || !expiresAt.value) return false
    return new Date(expiresAt.value).getTime() > Date.now()
  })

  async function login(user: string, password: string): Promise<void> {
    const auth = await authApi.login({ username: user, password })
    token.value = auth.token
    expiresAt.value = auth.expiresAt
    username.value = user
    localStorage.setItem(TOKEN_KEY, auth.token)
    localStorage.setItem(EXPIRY_KEY, auth.expiresAt)
    localStorage.setItem(USER_KEY, user)
  }

  function logout(): void {
    token.value = null
    expiresAt.value = null
    username.value = null
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem(EXPIRY_KEY)
    localStorage.removeItem(USER_KEY)
  }

  return { token, expiresAt, username, isAuthenticated, login, logout }
})
