<script setup lang="ts">
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import DatePicker from 'primevue/datepicker'
import Textarea from 'primevue/textarea'
import Message from 'primevue/message'
import type { OrderFormData, OrderFormErrors } from './orderFormSchema'

// `form` is a shared reactive object owned by the parent; fields are bound with
// v-model and mutated in place, so the parent sees changes by reference.
defineProps<{
  form: OrderFormData
  errors?: OrderFormErrors
  readonly?: boolean
}>()
</script>

<template>
  <div class="order-form">
    <div class="order-form__section">Kundendaten</div>

    <div class="order-form__row">
      <div class="order-form__field">
        <label for="of-customer-name">Name *</label>
        <InputText id="of-customer-name" v-model="form.customerName" :disabled="readonly" fluid />
        <Message v-if="errors?.customerName" severity="error" size="small" variant="simple">
          {{ errors.customerName }}
        </Message>
      </div>

      <div class="order-form__field">
        <label for="of-customer-phone">Telefon</label>
        <InputText id="of-customer-phone" v-model="form.customerPhone" :disabled="readonly" fluid />
      </div>
    </div>

    <div class="order-form__section">Eventdetails</div>

    <div class="order-form__row">
      <div class="order-form__field">
        <label for="of-event-date">Eventdatum *</label>
        <DatePicker
          id="of-event-date"
          v-model="form.eventDate"
          date-format="dd.mm.yy"
          show-icon
          :disabled="readonly"
          fluid
        />
        <Message v-if="errors?.eventDate" severity="error" size="small" variant="simple">
          {{ errors.eventDate }}
        </Message>
      </div>

      <div class="order-form__field">
        <label for="of-event-type">Eventtyp</label>
        <InputText id="of-event-type" v-model="form.eventType" :disabled="readonly" fluid />
      </div>
    </div>

    <div class="order-form__row">
      <div class="order-form__field">
        <label for="of-location">Ort *</label>
        <InputText id="of-location" v-model="form.location" :disabled="readonly" fluid />
        <Message v-if="errors?.location" severity="error" size="small" variant="simple">
          {{ errors.location }}
        </Message>
      </div>

      <div class="order-form__field">
        <label for="of-guest-count">Personenanzahl *</label>
        <InputNumber
          v-model="form.guestCount"
          input-id="of-guest-count"
          :min="1"
          :max="5000"
          :use-grouping="false"
          show-buttons
          :disabled="readonly"
          fluid
        />
        <Message v-if="errors?.guestCount" severity="error" size="small" variant="simple">
          {{ errors.guestCount }}
        </Message>
      </div>
    </div>

    <div class="order-form__field">
      <label for="of-budget">Budget</label>
      <InputNumber
        v-model="form.budget"
        input-id="of-budget"
        suffix=" €"
        :min="0"
        :max-fraction-digits="2"
        :use-grouping="false"
        :disabled="readonly"
        fluid
      />
      <Message v-if="errors?.budget" severity="error" size="small" variant="simple">
        {{ errors.budget }}
      </Message>
    </div>

    <div class="order-form__section">Wünsche & Hinweise</div>

    <div class="order-form__field">
      <label for="of-special-wishes">Sonderwünsche</label>
      <Textarea
        id="of-special-wishes"
        v-model="form.specialWishes"
        rows="2"
        :disabled="readonly"
        fluid
        auto-resize
      />
    </div>

    <div class="order-form__field">
      <label for="of-allergies">Allergien</label>
      <InputText id="of-allergies" v-model="form.allergies" :disabled="readonly" fluid />
    </div>

    <div class="order-form__field">
      <label for="of-dish-wishes">Gerichtswünsche</label>
      <Textarea
        id="of-dish-wishes"
        v-model="form.dishWishes"
        rows="2"
        :disabled="readonly"
        fluid
        auto-resize
      />
    </div>
  </div>
</template>

<style scoped>
.order-form {
  display: flex;
  flex-direction: column;
  gap: 0.875rem;
}

.order-form__section {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--p-text-muted-color);
  padding-top: 0.25rem;
}

.order-form__row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.875rem;
}

.order-form__field {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}
</style>
