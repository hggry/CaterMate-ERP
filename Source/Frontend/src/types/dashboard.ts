import type { OrderStatus } from './order'

// Spec-derived (Doc/TechSpec/backend_api.md §5.10) — backend endpoint
// for the dashboard is not implemented yet.
export interface RevenueByMonth {
  month: string
  totalGross: number
}

export interface GuestsByMonth {
  month: string
  guests: number
}

export interface TopCustomer {
  customerName: string
  orderCount: number
  totalRevenue: number
}

export interface DashboardKpis {
  revenueThisMonth: number
  revenueThisYear: number
  avgOrderValue: number
  openQuoteValue: number
}

export interface DashboardDto {
  ordersByStatus: Partial<Record<OrderStatus, number>>
  revenueByMonth: RevenueByMonth[]
  guestsByMonth: GuestsByMonth[]
  topCustomers: TopCustomer[]
  kpis: DashboardKpis
}
