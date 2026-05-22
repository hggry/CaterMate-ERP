export interface LoginRequest {
  username: string
  password: string
}

export interface AuthDto {
  token: string
  expiresAt: string
}
