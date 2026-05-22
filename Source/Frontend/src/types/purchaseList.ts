// Spec-derived (Doc/TechSpec/backend_api.md §5.6) — backend endpoints
// for purchase lists are not implemented yet.
export interface PurchaseListItemDto {
  id: number
  ingredientId: number
  ingredientName: string
  requiredQuantity: number
  unit: string
  isDone: boolean
}

export interface PurchaseGroupDto {
  category: string
  items: PurchaseListItemDto[]
}

export interface PurchaseListDto {
  id: number
  orderId: number
  safetyMargin: number
  groups: PurchaseGroupDto[]
}
