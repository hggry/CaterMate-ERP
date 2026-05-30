import http from './http'
import type { CreateOrderRequest, OrderDto, OrderQuery, UpdateOrderRequest } from '@/types/order'
import type { DishSuggestionsResponse } from '@/types/suggestion'

export const ordersApi = {
  list: (query: OrderQuery = {}): Promise<OrderDto[]> =>
    http.get<OrderDto[]>('/orders', { params: query }).then((r) => r.data),

  create: (payload: CreateOrderRequest): Promise<OrderDto> =>
    http.post<OrderDto>('/orders', payload).then((r) => r.data),

  getById: (id: number): Promise<OrderDto> =>
    http.get<OrderDto>(`/orders/${id}`).then((r) => r.data),

  update: (id: number, payload: UpdateOrderRequest): Promise<OrderDto> =>
    http.patch<OrderDto>(`/orders/${id}`, payload).then((r) => r.data),

  remove: (id: number): Promise<void> =>
    http.delete(`/orders/${id}`).then(() => undefined),

  // Reopen a released/confirmed/cancelled order back to 'Geprüft' (editable again).
  reopen: (id: number): Promise<OrderDto> =>
    http.post<OrderDto>(`/orders/${id}/reopen`).then((r) => r.data),

  // Cancel an order (sets status 'Storniert').
  cancel: (id: number): Promise<OrderDto> =>
    http.post<OrderDto>(`/orders/${id}/cancel`).then((r) => r.data),

  // AI dish suggestions (GET /orders/{id}/suggestions).
  getSuggestions: (id: number): Promise<DishSuggestionsResponse> =>
    http.get<DishSuggestionsResponse>(`/orders/${id}/suggestions`).then((r) => r.data),
}
