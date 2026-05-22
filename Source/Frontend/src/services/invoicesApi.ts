import http, { downloadBlob } from './http'
import type { InvoiceDto } from '@/types/invoice'

// Spec-derived (backend_api.md §5.7) — endpoints not implemented yet.
export const invoicesApi = {
  create: (orderId: number): Promise<InvoiceDto> =>
    http.post<InvoiceDto>(`/orders/${orderId}/invoice`).then((r) => r.data),

  get: (orderId: number): Promise<InvoiceDto> =>
    http.get<InvoiceDto>(`/orders/${orderId}/invoice`).then((r) => r.data),

  downloadPdf: (orderId: number, invoiceNumber: string): Promise<void> =>
    downloadBlob(`/orders/${orderId}/invoice/pdf`, `Rechnung_${invoiceNumber}.pdf`),
}
