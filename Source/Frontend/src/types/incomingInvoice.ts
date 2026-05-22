// Spec-derived (Doc/TechSpec/backend_api.md §5.8) — backend endpoints
// for incoming invoices (OCR) are not implemented yet.
export interface IncomingInvoiceDto {
  id: number
  status: string
}

export interface PriceSuggestionDto {
  id: number
  incomingInvoiceId: number
  ingredientId: number
  ingredientName: string
  currentPrice: number
  suggestedPrice: number
  accepted: boolean | null
}

export interface SuggestionDecision {
  suggestionId: number
  accepted: boolean
}

export interface ConfirmSuggestionsRequest {
  decisions: SuggestionDecision[]
}
