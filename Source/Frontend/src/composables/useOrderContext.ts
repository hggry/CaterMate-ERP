import { inject, type InjectionKey, type Ref } from 'vue'
import type { OrderDto } from '@/types/order'

// Shared order state provided by OrderDetailView to its tab child views.
export interface OrderContext {
  order: Ref<OrderDto | null>
  orderId: number
  reload: () => Promise<void>
}

export const ORDER_CONTEXT: InjectionKey<OrderContext> = Symbol('orderContext')

export function useOrderContext(): OrderContext {
  const context = inject(ORDER_CONTEXT)
  if (!context) {
    throw new Error('useOrderContext must be used within OrderDetailView.')
  }
  return context
}
