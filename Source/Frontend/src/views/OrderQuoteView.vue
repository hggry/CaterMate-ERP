<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import Button from 'primevue/button'
import Card from 'primevue/card'
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

const canCreate = computed(() => order.value?.status === 'Geprüft' && !quote.value)
const canRelease = computed(() => order.value?.status === 'Geprüft' && !!quote.value)

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
          v-if="canRelease"
          label="Angebot freigeben"
          icon="pi pi-check"
          :loading="busy"
          @click="releaseQuote"
        />
      </div>
    </template>
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
}
</style>
