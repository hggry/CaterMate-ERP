// Spec-derived (Doc/TechSpec/backend_api.md §5.5) — backend endpoints
// for quotes are not implemented yet.
export interface QuotePositionDto {
  menuItemId: number
  menuItemName: string
  quantity: number
  unitPrice: number
  totalNet: number
  vatRate: number
  vatAmount: number
  totalGross: number
}

export interface QuoteDto {
  id: number
  orderId: number
  positions: QuotePositionDto[]
  adminFee: number
  profitMargin: number
  totalNet: number
  totalVat: number
  totalGross: number
  createdAt: string
}
