<script setup lang="ts">
import { ref } from 'vue'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import DatePicker from 'primevue/datepicker'
import Textarea from 'primevue/textarea'
import Button from 'primevue/button'
import Message from 'primevue/message'
import { Form, FormField, type FormSubmitEvent } from '@primevue/forms'
import { zodResolver } from '@primevue/forms/resolvers/zod'
import { z } from 'zod'
import { ordersApi } from '@/services/ordersApi'
import { useToast } from '@/composables/useToast'
import { apiErrorMessage } from '@/types/api'
import type { CreateOrderRequest, OrderDto } from '@/types/order'

const visible = defineModel<boolean>('visible', { required: true })
const emit = defineEmits<{ saved: [order: OrderDto] }>()

const toast = useToast()
const saving = ref(false)

const schema = z.object({
  customerName: z.string().min(1, 'Name ist erforderlich.'),
  customerPhone: z.string().nullish(),
  eventDate: z.date({ required_error: 'Eventdatum ist erforderlich.' }),
  eventType: z.string().nullish(),
  location: z.string().min(1, 'Ort ist erforderlich.'),
  guestCount: z
    .number({ message: 'Personenanzahl ist erforderlich.' })
    .int()
    .min(1, 'Mindestens 1 Person.')
    .max(5000, 'Maximal 5000 Personen.'),
  budget: z.number().min(0, 'Budget darf nicht negativ sein.').nullish(),
  specialWishes: z.string().nullish(),
  allergies: z.string().nullish(),
  dishWishes: z.string().nullish(),
})
const resolver = zodResolver(schema)

function initialValues(): Record<string, unknown> {
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

async function onSubmit(event: FormSubmitEvent): Promise<void> {
  if (!event.valid) return
  const values = event.values as {
    customerName: string
    customerPhone?: string
    eventDate: Date
    eventType?: string
    location: string
    guestCount: number
    budget?: number
    specialWishes?: string
    allergies?: string
    dishWishes?: string
  }
  const payload: CreateOrderRequest = {
    customerName: values.customerName,
    customerPhone: values.customerPhone?.trim() || undefined,
    eventDate: values.eventDate.toISOString(),
    eventType: values.eventType?.trim() || undefined,
    location: values.location,
    guestCount: values.guestCount,
    budget: values.budget ?? undefined,
    specialWishes: values.specialWishes?.trim() || undefined,
    allergies: values.allergies?.trim() || undefined,
    dishWishes: values.dishWishes?.trim() || undefined,
  }
  saving.value = true
  try {
    const result = await ordersApi.create(payload)
    toast.success('Auftrag angelegt.')
    visible.value = false
    emit('saved', result)
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <Dialog
    v-model:visible="visible"
    header="Neuer Auftrag"
    modal
    :style="{ width: '40rem' }"
  >
    <Form
      v-if="visible"
      :resolver="resolver"
      :initial-values="initialValues()"
      class="create-order-dialog__form"
      @submit="onSubmit"
    >
      <div class="create-order-dialog__section">Kundendaten</div>

      <div class="create-order-dialog__row">
        <FormField v-slot="$field" name="customerName" class="create-order-dialog__field">
          <label for="co-customer-name">Name *</label>
          <InputText id="co-customer-name" name="customerName" fluid />
          <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
            {{ $field.error?.message }}
          </Message>
        </FormField>

        <FormField name="customerPhone" class="create-order-dialog__field">
          <label for="co-customer-phone">Telefon</label>
          <InputText id="co-customer-phone" name="customerPhone" fluid />
        </FormField>
      </div>

      <div class="create-order-dialog__section">Eventdetails</div>

      <div class="create-order-dialog__row">
        <FormField v-slot="$field" name="eventDate" class="create-order-dialog__field">
          <label for="co-event-date">Eventdatum *</label>
          <DatePicker
            id="co-event-date"
            name="eventDate"
            date-format="dd.mm.yy"
            show-icon
            fluid
          />
          <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
            {{ $field.error?.message }}
          </Message>
        </FormField>

        <FormField name="eventType" class="create-order-dialog__field">
          <label for="co-event-type">Eventtyp</label>
          <InputText id="co-event-type" name="eventType" fluid />
        </FormField>
      </div>

      <div class="create-order-dialog__row">
        <FormField v-slot="$field" name="location" class="create-order-dialog__field">
          <label for="co-location">Ort *</label>
          <InputText id="co-location" name="location" fluid />
          <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
            {{ $field.error?.message }}
          </Message>
        </FormField>

        <FormField v-slot="$field" name="guestCount" class="create-order-dialog__field">
          <label for="co-guest-count">Personenanzahl *</label>
          <InputNumber
            input-id="co-guest-count"
            name="guestCount"
            :min="1"
            :max="5000"
            :use-grouping="false"
            fluid
          />
          <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
            {{ $field.error?.message }}
          </Message>
        </FormField>
      </div>

      <FormField name="budget" class="create-order-dialog__field">
        <label for="co-budget">Budget</label>
        <InputNumber
          input-id="co-budget"
          name="budget"
          suffix=" €"
          :min="0"
          :max-fraction-digits="2"
          :use-grouping="false"
          fluid
        />
      </FormField>

      <div class="create-order-dialog__section">Wünsche & Hinweise</div>

      <FormField name="specialWishes" class="create-order-dialog__field">
        <label for="co-special-wishes">Sonderwünsche</label>
        <Textarea id="co-special-wishes" name="specialWishes" rows="2" fluid auto-resize />
      </FormField>

      <FormField name="allergies" class="create-order-dialog__field">
        <label for="co-allergies">Allergien</label>
        <InputText id="co-allergies" name="allergies" fluid />
      </FormField>

      <FormField name="dishWishes" class="create-order-dialog__field">
        <label for="co-dish-wishes">Gerichtswünsche</label>
        <Textarea id="co-dish-wishes" name="dishWishes" rows="2" fluid auto-resize />
      </FormField>

      <div class="create-order-dialog__actions">
        <Button
          label="Abbrechen"
          severity="secondary"
          text
          type="button"
          @click="visible = false"
        />
        <Button label="Auftrag anlegen" icon="pi pi-save" type="submit" :loading="saving" />
      </div>
    </Form>
  </Dialog>
</template>

<style scoped>
.create-order-dialog__form {
  display: flex;
  flex-direction: column;
  gap: 0.875rem;
}

.create-order-dialog__section {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--p-text-muted-color);
  padding-top: 0.25rem;
}

.create-order-dialog__row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.875rem;
}

.create-order-dialog__field {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.create-order-dialog__actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  padding-top: 0.5rem;
}
</style>
