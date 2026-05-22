import axios, { AxiosError } from 'axios'
import { ApiError, type ProblemDetails } from '@/types/api'

export const TOKEN_KEY = 'catermate_token'

// The frontend always calls the relative /api path. Vite proxies it to the
// backend in dev; nginx proxies it in the Docker build.
const http = axios.create({
  baseURL: '/api',
  headers: { 'Content-Type': 'application/json' },
})

http.interceptors.request.use((config) => {
  const token = localStorage.getItem(TOKEN_KEY)
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

http.interceptors.response.use(
  (response) => response,
  async (error: AxiosError<ProblemDetails>) => {
    if (error.response?.status === 401) {
      // Lazy imports break the http <-> authStore/router import cycle.
      const { useAuthStore } = await import('@/stores/authStore')
      const { default: router } = await import('@/router')
      useAuthStore().logout()
      if (router.currentRoute.value.name !== 'login') {
        await router.push({ name: 'login' })
      }
    }
    throw toApiError(error)
  },
)

function toApiError(error: AxiosError<ProblemDetails>): ApiError {
  const response = error.response
  if (response?.data && typeof response.data === 'object') {
    const pd = response.data
    return new ApiError(pd.status ?? response.status, pd.title ?? 'Fehler', pd.detail ?? '')
  }
  if (response) {
    return new ApiError(response.status, 'Fehler', error.message)
  }
  return new ApiError(0, 'Netzwerkfehler', 'Der Server ist nicht erreichbar.')
}

// Downloads a binary response (e.g. a PDF) as a browser file download.
export async function downloadBlob(url: string, filename: string): Promise<void> {
  const response = await http.get(url, { responseType: 'blob' })
  const blobUrl = URL.createObjectURL(response.data as Blob)
  const link = document.createElement('a')
  link.href = blobUrl
  link.download = filename
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(blobUrl)
}

export default http
