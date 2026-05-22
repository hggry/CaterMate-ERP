// RFC 7807 Problem Details — the backend's error response shape.
export interface ProblemDetails {
  status: number
  title: string
  detail?: string
}

// Resolves a thrown value to a German, user-facing message.
export function apiErrorMessage(e: unknown): string {
  return e instanceof ApiError ? e.detail || e.title : 'Ein Fehler ist aufgetreten.'
}

// Normalized error thrown by the API layer (services/http.ts).
export class ApiError extends Error {
  readonly status: number
  readonly title: string
  readonly detail: string

  constructor(status: number, title: string, detail = '') {
    super(detail || title)
    this.name = 'ApiError'
    this.status = status
    this.title = title
    this.detail = detail
  }
}
