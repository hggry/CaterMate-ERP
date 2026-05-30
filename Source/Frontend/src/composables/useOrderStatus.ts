import { ORDER_STATUSES, CANCELLED_STATUS, type OrderStatus } from '@/types/order'

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
  Storniert: null,
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
  Storniert: 'order-detail',
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
  Storniert: 'Storniert',
}

export type TagSeverity = 'secondary' | 'info' | 'warn' | 'success' | 'danger'

// PrimeVue severity kept as fallback (used by components that don't support custom style).
const SEVERITIES: Record<OrderStatus, TagSeverity> = {
  Neu:            'secondary',
  Geprüft:        'secondary',
  AngebotErstellt: 'info',
  Bestätigt:      'info',
  InBeschaffung:  'info',
  InVorbereitung: 'warn',
  Durchgeführt:   'success',
  Abgerechnet:    'success',
  Storniert:      'danger',
}

// Precise brand-colour styles for StatusTag (bg + text).
// Palette: Sand #EAE0CC | Caramel #C2A87C | Teal #20A090 | Avocado #7AAA28
//          Espresso #3E2818 | Rot-Orange #E84020
export interface TagStyle { background: string; color: string; [key: string]: string }

const TAG_STYLES: Record<OrderStatus, TagStyle> = {
  Neu:             { background: '#EAE0CC', color: '#3E2818' },  // Sand / Espresso  — neutral, unbearbeitet
  Geprüft:         { background: '#C2A87C', color: '#ffffff' },  // Caramel          — in Prüfung
  AngebotErstellt: { background: '#5BC4B8', color: '#ffffff' },  // Light Teal       — Angebot draußen
  Bestätigt:       { background: '#20A090', color: '#ffffff' },  // Deep Teal        — Kunde bestätigt ✓
  InBeschaffung:   { background: '#5BC4B8', color: '#ffffff' },  // Light Teal       — operativ aktiv
  InVorbereitung:  { background: '#7AAA28', color: '#ffffff' },  // Avocado          — nah am Ziel
  Durchgeführt:    { background: '#5a7d1e', color: '#ffffff' },  // Avocado dunkel   — Event gelaufen
  Abgerechnet:     { background: '#3E2818', color: '#ffffff' },  // Espresso         — vollständig abgeschlossen
  Storniert:       { background: '#E84020', color: '#ffffff' },  // Rot-Orange       — abgesagt
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

  function tagStyleFor(status: OrderStatus): TagStyle {
    return TAG_STYLES[status]
  }

  // Position in the linear pipeline; -1 for the off-pipeline cancelled state.
  function indexOf(status: OrderStatus): number {
    return (ORDER_STATUSES as readonly string[]).indexOf(status)
  }

  function isCancelled(status: OrderStatus): boolean {
    return status === CANCELLED_STATUS
  }

  return { primaryActionFor, tabForStatus, labelFor, severityFor, tagStyleFor, indexOf, isCancelled }
}
