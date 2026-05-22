import http from './http'
import type { DashboardDto } from '@/types/dashboard'

// Spec-derived (backend_api.md §5.10) — endpoint not implemented yet.
export const dashboardApi = {
  get: (): Promise<DashboardDto> => http.get<DashboardDto>('/dashboard').then((r) => r.data),
}
