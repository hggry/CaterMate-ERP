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

export type OrderStatus = (typeof ORDER_STATUSES)[number]

export interface AssignedMenuItemDto {
  id: number
  name: string
  category: string
  salesPricePerPerson: number
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

export interface UpdateOrderRequest {
  status?: OrderStatus
  assignedMenuItemIds?: number[]
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
