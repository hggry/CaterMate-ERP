// Mirrors the real backend MenuItemDto: the bill of materials uses
// quantityPerPerson and carries no ingredientName.
export interface BillOfMaterialsItemDto {
  ingredientId: number
  quantityPerPerson: number
}

export interface MenuItemDto {
  id: number
  name: string
  category: string
  salesPricePerPerson: number
  purchaseCostPerPerson: number
  allergens: string | null
  createdAt: string
  billOfMaterials: BillOfMaterialsItemDto[]
}

export interface BillOfMaterialsItemRequest {
  ingredientId: number
  quantityPerPerson: number
}

export interface CreateMenuItemRequest {
  name: string
  category: string
  salesPricePerPerson: number
  purchaseCostPerPerson: number
  allergens?: string
  billOfMaterials?: BillOfMaterialsItemRequest[]
}

export type UpdateMenuItemRequest = CreateMenuItemRequest
