import http, { downloadBlob } from './http'
import type { QuoteDto } from '@/types/quote'

// Spec-derived (backend_api.md §5.5) — endpoints not implemented yet.
export const quotesApi = {
  create: (orderId: number): Promise<QuoteDto> =>
    http.post<QuoteDto>(`/orders/${orderId}/quote`).then((r) => r.data),

  get: (orderId: number): Promise<QuoteDto> =>
    http.get<QuoteDto>(`/orders/${orderId}/quote`).then((r) => r.data),

  update: (orderId: number, quote: QuoteDto): Promise<QuoteDto> =>
    http.put<QuoteDto>(`/orders/${orderId}/quote`, quote).then((r) => r.data),

  downloadPdf: (orderId: number): Promise<void> =>
    downloadBlob(`/orders/${orderId}/quote/pdf`, `Angebot_${orderId}.pdf`),

  // Triggers the backend to send the quote PDF to the customer via webhook.
  sendToCustomer: (orderId: number): Promise<void> =>
    http.post(`/orders/${orderId}/quote/send`).then(() => undefined),
}
