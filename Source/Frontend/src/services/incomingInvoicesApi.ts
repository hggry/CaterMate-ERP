import http from './http'
import type {
  ConfirmSuggestionsRequest,
  IncomingInvoiceDto,
  PriceSuggestionDto,
} from '@/types/incomingInvoice'

// Spec-derived (backend_api.md §5.8) — endpoints not implemented yet.
export const incomingInvoicesApi = {
  upload: (file: File): Promise<IncomingInvoiceDto> => {
    const formData = new FormData()
    formData.append('file', file)
    return http
      .post<IncomingInvoiceDto>('/incoming-invoices', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      .then((r) => r.data)
  },

  list: (): Promise<IncomingInvoiceDto[]> =>
    http.get<IncomingInvoiceDto[]>('/incoming-invoices').then((r) => r.data),

  getSuggestions: (id: number): Promise<PriceSuggestionDto[]> =>
    http.get<PriceSuggestionDto[]>(`/incoming-invoices/${id}/suggestions`).then((r) => r.data),

  confirm: (id: number, payload: ConfirmSuggestionsRequest): Promise<void> =>
    http.post(`/incoming-invoices/${id}/confirm`, payload).then(() => undefined),

  getAllSuggestions: (): Promise<PriceSuggestionDto[]> =>
    http.get<PriceSuggestionDto[]>('/incoming-invoices/suggestions').then((r) => r.data),

  acceptSuggestion: (id: number): Promise<void> =>
    http.post(`/incoming-invoices/suggestions/${id}/accept`).then(() => undefined),

  discardSuggestion: (id: number): Promise<void> =>
    http.post(`/incoming-invoices/suggestions/${id}/discard`).then(() => undefined),
}
