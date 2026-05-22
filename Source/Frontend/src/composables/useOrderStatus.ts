import { ORDER_STATUSES, type OrderStatus } from '@/types/order'

export type OrderActionKind = 'status' | 'navigate' | 'download'

export interface OrderAction {
  label: string
  kind: OrderActionKind
  targetStatus?: OrderStatus
}

// Central status-transition map (see plan §B.3). Views read this map instead
// of scattering per-status v-if checks.
const ACTIONS: Record<OrderStatus, OrderAction[]> = {
  Neu: [{ label: 'Als geprüft markieren', kind: 'status', targetStatus: 'Geprüft' }],
  Geprüft: [{ label: 'Angebot erstellen', kind: 'navigate' }],
  AngebotErstellt: [
    { label: 'Angebot herunterladen', kind: 'download' },
    { label: 'Auftrag bestätigen', kind: 'status', targetStatus: 'Bestätigt' },
  ],
  Bestätigt: [{ label: 'Einkaufsliste öffnen', kind: 'navigate' }],
  InBeschaffung: [{ label: 'In Vorbereitung', kind: 'status', targetStatus: 'InVorbereitung' }],
  InVorbereitung: [
    { label: 'Als durchgeführt markieren', kind: 'status', targetStatus: 'Durchgeführt' },
  ],
  Durchgeführt: [{ label: 'Rechnung erstellen', kind: 'navigate' }],
  Abgerechnet: [{ label: 'Rechnung herunterladen', kind: 'download' }],
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
  function actionsFor(status: OrderStatus): OrderAction[] {
    return ACTIONS[status]
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

  return { actionsFor, labelFor, severityFor, indexOf }
}
