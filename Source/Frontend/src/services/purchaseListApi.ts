import http, { downloadBlob } from './http'
import type { PurchaseListDto } from '@/types/purchaseList'

// Spec-derived (backend_api.md §5.6) — endpoints not implemented yet.
export const purchaseListApi = {
  get: (orderId: number): Promise<PurchaseListDto> =>
    http.get<PurchaseListDto>(`/orders/${orderId}/purchase-list`).then((r) => r.data),

  updateItem: (itemId: number, isDone: boolean): Promise<void> =>
    http.patch(`/purchase-list-items/${itemId}`, { isDone }).then(() => undefined),

  downloadPdf: (orderId: number): Promise<void> =>
    downloadBlob(`/orders/${orderId}/purchase-list/pdf`, `Einkaufsliste_${orderId}.pdf`),
}
