// AI dish suggestions (Doc/TechSpec/backend_api.md §5.9).
export interface DishSuggestionDto {
  menuItemId: number
  menuItemName: string
  reason: string
}

export interface DishSuggestionsResponse {
  suggestions: DishSuggestionDto[]
}
