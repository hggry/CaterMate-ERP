// The linear forward pipeline. Drives the stepper, funnel and indexOf logic.
export const ORDER_STATUSES = [
  'Neu',
  'Geprüft',
  'AngebotErstellt',
  'Bestätigt',
  'InBeschaffung',
  'InVorbereitung',
  'Durchgeführt',
  'Abgerechnet',
] as const

// Off-pipeline terminal state for cancelled orders (reactivatable via reopen).
export const CANCELLED_STATUS = 'Storniert' as const

export type OrderStatus = (typeof ORDER_STATUSES)[number] | typeof CANCELLED_STATUS

// Full set incl. the cancelled state — used for status filters.
export const ALL_ORDER_STATUSES: readonly OrderStatus[] = [...ORDER_STATUSES, CANCELLED_STATUS]

export interface AssignedMenuItemDto {
  id: number
  name: string
  category: string
  salesPricePerPerson: number
  // Portion count set by the AI agent; null = full guest count applies.
  count: number | null
}

export interface OrderDto {
  id: number
  customerId: number
  customerName: string
  customerPhone: string | null
  eventDate: string
  eventType: string | null
  location: string
  guestCount: number
  budget: number | null
  specialWishes: string | null
  allergies: string | null
  dishWishes: string | null
  status: OrderStatus
  createdAt: string
  updatedAt: string
  assignedMenuItems: AssignedMenuItemDto[]
}

export interface MenuItemWithCount {
  menuItemId: number
  count: number | null
}

export interface UpdateOrderRequest {
  status?: OrderStatus
  assignedMenuItemIds?: number[]
  // With-count update — takes priority over assignedMenuItemIds.
  assignedMenuItemsWithCounts?: MenuItemWithCount[]
  customerName?: string
  customerPhone?: string
  eventDate?: string
  guestCount?: number
  eventType?: string
  location?: string
  budget?: number
  specialWishes?: string
  allergies?: string
  dishWishes?: string
}

export interface CreateOrderRequest {
  customerName: string
  customerPhone?: string
  eventDate: string
  eventType?: string
  location: string
  guestCount: number
  budget?: number
  specialWishes?: string
  allergies?: string
  dishWishes?: string
}

export interface OrderQuery {
  status?: OrderStatus
  from?: string
  to?: string
}
