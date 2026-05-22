export interface IngredientDto {
  id: number
  name: string
  unit: string
  purchasePricePerUnit: number
  category: string | null
  createdAt: string
  updatedAt: string
}

export interface CreateIngredientRequest {
  name: string
  unit: string
  purchasePricePerUnit: number
  category?: string
}

export type UpdateIngredientRequest = CreateIngredientRequest
