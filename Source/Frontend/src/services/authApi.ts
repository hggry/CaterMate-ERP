import http from './http'
import type { AuthDto, LoginRequest } from '@/types/auth'

export const authApi = {
  login: (payload: LoginRequest): Promise<AuthDto> =>
    http.post<AuthDto>('/auth/login', payload).then((r) => r.data),
}
