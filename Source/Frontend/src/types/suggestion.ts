// Spec-derived (Doc/TechSpec/backend_api.md §5.9) — AI dish suggestions.
// Backend endpoint is not implemented yet.
export interface DishSuggestionDto {
  menuItemId: number
  menuItemName: string
  reason: string
}

export interface DishSuggestionsResponse {
  suggestions: DishSuggestionDto[]
}
