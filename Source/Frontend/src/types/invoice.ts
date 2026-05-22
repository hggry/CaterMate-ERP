import type { QuotePositionDto } from './quote'

// Spec-derived (Doc/TechSpec/backend_api.md §5.7) — backend endpoints
// for invoices are not implemented yet.
export interface InvoiceDto {
  id: number
  invoiceNumber: string
  orderId: number
  customerName: string
  issueDate: string
  dueDate: string
  positions: QuotePositionDto[]
  totalNet: number
  totalVat: number
  totalGross: number
}
