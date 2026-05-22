import { ref, shallowRef, type Ref } from 'vue'
import { ApiError } from '@/types/api'

interface UseApiResult<T, A extends unknown[]> {
  data: Ref<T | null>
  loading: Ref<boolean>
  error: Ref<ApiError | null>
  execute: (...args: A) => Promise<T | null>
}

// Wraps an async API call with reactive loading/error/data state.
export function useApi<T, A extends unknown[]>(
  fn: (...args: A) => Promise<T>,
): UseApiResult<T, A> {
  const data = shallowRef<T | null>(null)
  const loading = ref(false)
  const error = ref<ApiError | null>(null)

  async function execute(...args: A): Promise<T | null> {
    loading.value = true
    error.value = null
    try {
      const result = await fn(...args)
      data.value = result
      return result
    } catch (e) {
      error.value = e instanceof ApiError ? e : new ApiError(0, 'Fehler', String(e))
      return null
    } finally {
      loading.value = false
    }
  }

  return { data, loading, error, execute }
}
