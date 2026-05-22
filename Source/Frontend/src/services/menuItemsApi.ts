import http from './http'
import type {
  CreateMenuItemRequest,
  MenuItemDto,
  UpdateMenuItemRequest,
} from '@/types/menuItem'

export const menuItemsApi = {
  list: (category?: string): Promise<MenuItemDto[]> =>
    http
      .get<MenuItemDto[]>('/menu-items', { params: category ? { category } : {} })
      .then((r) => r.data),

  getById: (id: number): Promise<MenuItemDto> =>
    http.get<MenuItemDto>(`/menu-items/${id}`).then((r) => r.data),

  create: (payload: CreateMenuItemRequest): Promise<MenuItemDto> =>
    http.post<MenuItemDto>('/menu-items', payload).then((r) => r.data),

  update: (id: number, payload: UpdateMenuItemRequest): Promise<MenuItemDto> =>
    http.put<MenuItemDto>(`/menu-items/${id}`, payload).then((r) => r.data),

  remove: (id: number): Promise<void> =>
    http.delete(`/menu-items/${id}`).then(() => undefined),
}
