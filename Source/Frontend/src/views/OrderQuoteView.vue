<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import Button from 'primevue/button'
import Card from 'primevue/card'
import Dialog from 'primevue/dialog'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import PositionsTable from '@/components/common/PositionsTable.vue'
import { quotesApi } from '@/services/quotesApi'
import { ordersApi } from '@/services/ordersApi'
import { useToast } from '@/composables/useToast'
import { useFormat } from '@/composables/useFormat'
import { useOrderContext } from '@/composables/useOrderContext'
import { ApiError, apiErrorMessage } from '@/types/api'
import type { QuoteDto } from '@/types/quote'

const { order, orderId, reload } = useOrderContext()
const toast = useToast()
const { formatCurrency } = useFormat()

const quote = ref<QuoteDto | null>(null)
const loading = ref(false)
const loadError = ref(false)
const busy = ref(false)
const sending = ref(false)
const sendDialogVisible = ref(false)

const canCreate = computed(() => order.value?.status === 'Geprüft' && !quote.value)
const canRelease = computed(() => order.value?.status === 'Geprüft' && !!quote.value)
// Sending is only possible once the quote has been released.
const canSend = computed(() => order.value?.status === 'AngebotErstellt' && !!quote.value)
const overBudget = computed(() =>
  quote.value !== null &&
  order.value?.budget != null &&
  quote.value!.totalGross > order.value.budget,
)

async function loadQuote(): Promise<void> {
  loading.value = true
  loadError.value = false
  try {
    quote.value = await quotesApi.get(orderId)
  } catch (e) {
    if (e instanceof ApiError && e.status === 404) {
      quote.value = null
    } else {
      loadError.value = true
    }
  } finally {
    loading.value = false
  }
}

onMounted(loadQuote)

async function createQuote(): Promise<void> {
  busy.value = true
  try {
    quote.value = await quotesApi.create(orderId)
    toast.success('Angebot wurde erstellt.')
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    busy.value = false
  }
}

async function sendQuote(): Promise<void> {
  sending.value = true
  try {
    await quotesApi.sendToCustomer(orderId)
    toast.success('Angebot wurde an den Kunden gesendet.')
    sendDialogVisible.value = false
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    sending.value = false
  }
}

async function saveQuote(): Promise<void> {
  if (!quote.value) return
  busy.value = true
  try {
    quote.value = await quotesApi.update(orderId, quote.value)
    toast.success('Angebot gespeichert.')
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    busy.value = false
  }
}

async function releaseQuote(): Promise<void> {
  busy.value = true
  try {
    await ordersApi.update(orderId, { status: 'AngebotErstellt' })
    await reload()
    toast.success('Angebot wurde freigegeben.')
    // Offer to send the released quote to the customer right away.
    sendDialogVisible.value = true
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    busy.value = false
  }
}

async function downloadPdf(): Promise<void> {
  try {
    await quotesApi.downloadPdf(orderId)
  } catch (e) {
    toast.error(apiErrorMessage(e))
  }
}
</script>

<template>
  <div class="quote-view">
    <div v-if="loading" class="quote-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <Message v-else-if="loadError" severity="error" :closable="false">
      Angebot konnte nicht geladen werden.
    </Message>

    <template v-else-if="!quote">
      <Message severity="info" :closable="false">
        Für diesen Auftrag wurde noch kein Angebot erstellt.
      </Message>
      <Button
        v-if="canCreate"
        label="Angebot erstellen"
        icon="pi pi-file"
        :loading="busy"
        @click="createQuote"
      />
    </template>

    <template v-else>
      <Message v-if="overBudget" severity="error" :closable="false">
        Die Angebotssumme ({{ formatCurrency(quote.totalGross) }}) übersteigt das Budget des Kunden
        von {{ formatCurrency(order!.budget!) }}.
      </Message>

      <PositionsTable :positions="quote.positions" editable />

      <Card class="quote-view__summary">
        <template #content>
          <div class="quote-view__row">
            <span>Verwaltungspauschale</span>
            <span>{{ formatCurrency(quote.adminFee) }}</span>
          </div>
          <div class="quote-view__row">
            <span>Gewinnmarge</span>
            <span>{{ Math.round(quote.profitMargin * 100) }} %</span>
          </div>
          <div class="quote-view__row">
            <span>Zwischensumme (Netto)</span>
            <span>{{ formatCurrency(quote.totalNet) }}</span>
          </div>
          <div class="quote-view__row">
            <span>USt.</span>
            <span>{{ formatCurrency(quote.totalVat) }}</span>
          </div>
          <div class="quote-view__row quote-view__row--total">
            <span>Gesamtbetrag (Brutto)</span>
            <span>{{ formatCurrency(quote.totalGross) }}</span>
          </div>
        </template>
      </Card>

      <div class="quote-view__actions">
        <Button
          label="Änderungen speichern"
          icon="pi pi-save"
          severity="secondary"
          :loading="busy"
          @click="saveQuote"
        />
        <Button
          label="Angebot herunterladen"
          icon="pi pi-download"
          severity="secondary"
          outlined
          @click="downloadPdf"
        />
        <Button
          v-if="canSend"
          label="Angebot an Kunde senden"
          icon="pi pi-send"
          :loading="sending"
          @click="sendQuote"
        />
        <Button
          v-if="canRelease"
          label="Angebot freigeben"
          icon="pi pi-check"
          :loading="busy"
          @click="releaseQuote"
        />
      </div>
    </template>

    <Dialog
      v-model:visible="sendDialogVisible"
      header="Angebot versenden"
      modal
      :style="{ width: '28rem' }"
      :breakpoints="{ '767px': '95vw' }"
    >
      <p class="quote-view__dialog-text">
        Das Angebot wurde erstellt. Möchten Sie es jetzt an den Kunden senden?
      </p>
      <div class="quote-view__dialog-actions">
        <Button
          label="Später"
          severity="secondary"
          text
          :disabled="sending"
          @click="sendDialogVisible = false"
        />
        <Button
          label="Angebot an Kunde senden"
          icon="pi pi-send"
          :loading="sending"
          @click="sendQuote"
        />
      </div>
    </Dialog>
  </div>
</template>

<style scoped>
.quote-view {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.quote-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}

.quote-view__summary {
  max-width: 28rem;
  margin-left: auto;
}

.quote-view__row {
  display: flex;
  justify-content: space-between;
  gap: 2rem;
  padding: 0.25rem 0;
}

.quote-view__row--total {
  margin-top: 0.5rem;
  padding-top: 0.5rem;
  border-top: 1px solid var(--p-content-border-color);
  font-weight: 700;
}

.quote-view__actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.quote-view__dialog-text {
  margin: 0 0 1.5rem;
}

.quote-view__dialog-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

/* Phone: full-width summary and action buttons. */
@media (max-width: 767.98px) {
  .quote-view__summary {
    max-width: none;
    margin-left: 0;
  }

  .quote-view__actions :deep(.p-button) {
    flex: 1 1 12rem;
  }
}
</style>
