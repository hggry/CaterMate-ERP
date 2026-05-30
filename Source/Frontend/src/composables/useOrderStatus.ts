import { ORDER_STATUSES, type OrderStatus } from '@/types/order'

export type OrderActionKind = 'status' | 'navigate' | 'create-quote'

export interface OrderAction {
  label: string
  kind: OrderActionKind
  icon: string
  targetStatus?: OrderStatus
  targetRoute?: string
  // When set, the action requires explicit confirmation (irreversible / side effects).
  confirm?: string
}

// Single primary "next step" per status, driving the persistent action button
// in OrderDetailView. Terminal status has no follow-up action.
const ACTIONS: Record<OrderStatus, OrderAction | null> = {
  Neu: { label: 'Als geprüft markieren', kind: 'status', targetStatus: 'Geprüft', icon: 'pi pi-check' },
  Geprüft: { label: 'Angebot erstellen', kind: 'create-quote', targetRoute: 'order-quote', icon: 'pi pi-file' },
  AngebotErstellt: {
    label: 'Auftrag bestätigen',
    kind: 'status',
    targetStatus: 'Bestätigt',
    icon: 'pi pi-check',
    confirm: 'Der Auftrag wird bestätigt und die Beschaffung angestoßen (Einkaufsliste wird erstellt). Fortfahren?',
  },
  Bestätigt: { label: 'Einkaufsliste öffnen', kind: 'navigate', targetRoute: 'order-purchase-list', icon: 'pi pi-shopping-cart' },
  InBeschaffung: { label: 'In Vorbereitung', kind: 'status', targetStatus: 'InVorbereitung', icon: 'pi pi-arrow-right' },
  InVorbereitung: { label: 'Als durchgeführt markieren', kind: 'status', targetStatus: 'Durchgeführt', icon: 'pi pi-check' },
  Durchgeführt: { label: 'Rechnung erstellen', kind: 'navigate', targetRoute: 'order-invoice', icon: 'pi pi-file' },
  Abgerechnet: null,
}

// Tab a status's work happens in — used to auto-navigate after a status change.
const TAB_FOR_STATUS: Record<OrderStatus, string> = {
  Neu: 'order-detail',
  Geprüft: 'order-detail',
  AngebotErstellt: 'order-quote',
  Bestätigt: 'order-purchase-list',
  InBeschaffung: 'order-purchase-list',
  InVorbereitung: 'order-purchase-list',
  Durchgeführt: 'order-invoice',
  Abgerechnet: 'order-invoice',
}

const LABELS: Record<OrderStatus, string> = {
  Neu: 'Neu',
  Geprüft: 'Geprüft',
  AngebotErstellt: 'Angebot erstellt',
  Bestätigt: 'Bestätigt',
  InBeschaffung: 'In Beschaffung',
  InVorbereitung: 'In Vorbereitung',
  Durchgeführt: 'Durchgeführt',
  Abgerechnet: 'Abgerechnet',
}

export type TagSeverity = 'secondary' | 'info' | 'warn' | 'success'

const SEVERITIES: Record<OrderStatus, TagSeverity> = {
  Neu: 'info',
  Geprüft: 'secondary',
  AngebotErstellt: 'warn',
  Bestätigt: 'warn',
  InBeschaffung: 'warn',
  InVorbereitung: 'warn',
  Durchgeführt: 'success',
  Abgerechnet: 'success',
}

export function useOrderStatus() {
  function primaryActionFor(status: OrderStatus): OrderAction | null {
    return ACTIONS[status]
  }

  function tabForStatus(status: OrderStatus): string {
    return TAB_FOR_STATUS[status]
  }

  function labelFor(status: OrderStatus): string {
    return LABELS[status]
  }

  function severityFor(status: OrderStatus): TagSeverity {
    return SEVERITIES[status]
  }

  function indexOf(status: OrderStatus): number {
    return ORDER_STATUSES.indexOf(status)
  }

  return { primaryActionFor, tabForStatus, labelFor, severityFor, indexOf }
}
