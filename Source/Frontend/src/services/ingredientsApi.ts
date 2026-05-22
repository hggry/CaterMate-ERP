import http from './http'
import type {
  CreateIngredientRequest,
  IngredientDto,
  UpdateIngredientRequest,
} from '@/types/ingredient'

// The backend exposes no DELETE for ingredients (see IngredientsController).
export const ingredientsApi = {
  list: (): Promise<IngredientDto[]> =>
    http.get<IngredientDto[]>('/ingredients').then((r) => r.data),

  getById: (id: number): Promise<IngredientDto> =>
    http.get<IngredientDto>(`/ingredients/${id}`).then((r) => r.data),

  create: (payload: CreateIngredientRequest): Promise<IngredientDto> =>
    http.post<IngredientDto>('/ingredients', payload).then((r) => r.data),

  update: (id: number, payload: UpdateIngredientRequest): Promise<IngredientDto> =>
    http.put<IngredientDto>(`/ingredients/${id}`, payload).then((r) => r.data),
}
