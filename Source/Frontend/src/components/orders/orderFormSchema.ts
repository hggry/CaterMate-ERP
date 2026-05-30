import { z } from 'zod'
import type { CreateOrderRequest, OrderDto } from '@/types/order'

// Shared form state for both creating and editing an order. Optional text
// fields are empty strings (not null) so they bind cleanly to inputs.
export interface OrderFormData {
  customerName: string
  customerPhone: string
  eventDate: Date | null
  eventType: string
  location: string
  guestCount: number | null
  budget: number | null
  specialWishes: string
  allergies: string
  dishWishes: string
}

export type OrderFormErrors = Partial<Record<keyof OrderFormData, string>>

function buildSchema(requireFutureDate: boolean) {
  const eventDate = z.date({
    required_error: 'Eventdatum ist erforderlich.',
    invalid_type_error: 'Eventdatum ist erforderlich.',
  })
  return z.object({
    customerName: z.string().trim().min(1, 'Name ist erforderlich.'),
    customerPhone: z.string().trim().optional(),
    eventDate: requireFutureDate
      ? eventDate.refine((d) => d.getTime() > Date.now(), 'Eventdatum muss in der Zukunft liegen.')
      : eventDate,
    eventType: z.string().trim().optional(),
    location: z.string().trim().min(1, 'Ort ist erforderlich.'),
    guestCount: z
      .number({
        required_error: 'Personenanzahl ist erforderlich.',
        invalid_type_error: 'Personenanzahl ist erforderlich.',
      })
      .int('Ganze Zahl erforderlich.')
      .min(1, 'Mindestens 1 Person.')
      .max(5000, 'Maximal 5000 Personen.'),
    budget: z.number().min(0, 'Budget darf nicht negativ sein.').nullable().optional(),
    specialWishes: z.string().trim().optional(),
    allergies: z.string().trim().optional(),
    dishWishes: z.string().trim().optional(),
  })
}

const createSchema = buildSchema(true)
const editSchema = buildSchema(false)

type ParsedOrder = z.infer<typeof editSchema>

export function emptyOrderForm(): OrderFormData {
  return {
    customerName: '',
    customerPhone: '',
    eventDate: null,
    eventType: '',
    location: '',
    guestCount: null,
    budget: null,
    specialWishes: '',
    allergies: '',
    dishWishes: '',
  }
}

export function orderToForm(o: OrderDto): OrderFormData {
  return {
    customerName: o.customerName,
    customerPhone: o.customerPhone ?? '',
    eventDate: new Date(o.eventDate),
    eventType: o.eventType ?? '',
    location: o.location,
    guestCount: o.guestCount,
    budget: o.budget,
    specialWishes: o.specialWishes ?? '',
    allergies: o.allergies ?? '',
    dishWishes: o.dishWishes ?? '',
  }
}

function toRequest(p: ParsedOrder): CreateOrderRequest {
  return {
    customerName: p.customerName,
    customerPhone: p.customerPhone || undefined,
    eventDate: p.eventDate.toISOString(),
    eventType: p.eventType || undefined,
    location: p.location,
    guestCount: p.guestCount,
    budget: p.budget ?? undefined,
    specialWishes: p.specialWishes || undefined,
    allergies: p.allergies || undefined,
    dishWishes: p.dishWishes || undefined,
  }
}

export interface ValidationResult {
  valid: boolean
  errors: OrderFormErrors
  request?: CreateOrderRequest
}

// Validates the form. `requireFutureDate` enforces the future-date rule for new
// orders; editing an existing order skips it (the event may already be near/past).
export function validateOrderForm(
  data: OrderFormData,
  options: { requireFutureDate?: boolean } = {},
): ValidationResult {
  const schema = options.requireFutureDate ? createSchema : editSchema
  const result = schema.safeParse(data)
  if (result.success) {
    return { valid: true, errors: {}, request: toRequest(result.data) }
  }
  const errors: OrderFormErrors = {}
  for (const issue of result.error.issues) {
    const key = issue.path[0] as keyof OrderFormData
    if (key && !errors[key]) errors[key] = issue.message
  }
  return { valid: false, errors }
}
