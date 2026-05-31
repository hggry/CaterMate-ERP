<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import Button from 'primevue/button'
import Card from 'primevue/card'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import { useConfirm } from 'primevue/useconfirm'
import PositionsTable from '@/components/common/PositionsTable.vue'
import { invoicesApi } from '@/services/invoicesApi'
import { ordersApi } from '@/services/ordersApi'
import { useToast } from '@/composables/useToast'
import { useFormat } from '@/composables/useFormat'
import { useOrderContext } from '@/composables/useOrderContext'
import { ApiError, apiErrorMessage } from '@/types/api'
import type { InvoiceDto } from '@/types/invoice'

const { order, orderId, reload } = useOrderContext()
const toast = useToast()
const confirm = useConfirm()
const { formatCurrency, formatDate } = useFormat()

const invoice = ref<InvoiceDto | null>(null)
const loading = ref(false)
const loadError = ref(false)
const busy = ref(false)

const canCreate = computed(() => order.value?.status === 'Durchgeführt' && !invoice.value)
const canConfirmPayment = computed(() => !!invoice.value && order.value?.status === 'Durchgeführt')

async function loadInvoice(): Promise<void> {
  loading.value = true
  loadError.value = false
  try {
    invoice.value = await invoicesApi.get(orderId)
  } catch (e) {
    if (e instanceof ApiError && e.status === 404) {
      invoice.value = null
    } else {
      loadError.value = true
    }
  } finally {
    loading.value = false
  }
}

onMounted(loadInvoice)

function confirmCreateInvoice(): void {
  confirm.require({
    message:
      'Die Rechnung wird mit fortlaufender Rechnungsnummer erstellt. Fortfahren?',
    header: 'Rechnung erstellen',
    icon: 'pi pi-exclamation-triangle',
    accept: createInvoice,
  })
}

async function createInvoice(): Promise<void> {
  busy.value = true
  try {
    invoice.value = await invoicesApi.create(orderId)
    await reload()
    toast.success('Rechnung wurde erstellt.')
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    busy.value = false
  }
}

async function confirmPayment(): Promise<void> {
  confirm.require({
    message: 'Zahlungseingang bestätigen? Der Auftrag wird damit als vollständig abgerechnet markiert.',
    header: 'Zahlungseingang bestätigen',
    icon: 'pi pi-check-circle',
    accept: async () => {
      busy.value = true
      try {
        await ordersApi.update(orderId, { status: 'Abgerechnet' })
        await reload()
        toast.success('Zahlungseingang bestätigt. Auftrag abgeschlossen.')
      } catch (e) {
        toast.error(apiErrorMessage(e))
      } finally {
        busy.value = false
      }
    },
  })
}

async function downloadPdf(): Promise<void> {
  if (!invoice.value) return
  try {
    await invoicesApi.downloadPdf(orderId, invoice.value.invoiceNumber)
  } catch (e) {
    toast.error(apiErrorMessage(e))
  }
}
</script>

<template>
  <div class="invoice-view">
    <div v-if="loading" class="invoice-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <Message v-else-if="loadError" severity="error" :closable="false">
      Rechnung konnte nicht geladen werden.
    </Message>

    <template v-else-if="!invoice">
      <Message severity="info" :closable="false">
        Für diesen Auftrag wurde noch keine Rechnung erstellt.
      </Message>
      <Button
        v-if="canCreate"
        label="Rechnung erstellen"
        icon="pi pi-file"
        :loading="busy"
        @click="confirmCreateInvoice"
      />
    </template>

    <template v-else>
      <Card>
        <template #content>
          <div class="invoice-view__meta">
            <div>
              <span class="invoice-view__label">Rechnungsnummer</span>
              <strong>{{ invoice.invoiceNumber }}</strong>
            </div>
            <div>
              <span class="invoice-view__label">Ausstellungsdatum</span>
              <span>{{ formatDate(invoice.issueDate) }}</span>
            </div>
            <div>
              <span class="invoice-view__label">Zahlungsziel</span>
              <span>{{ formatDate(invoice.dueDate) }}</span>
            </div>
          </div>
        </template>
      </Card>

      <PositionsTable :positions="invoice.positions" />

      <Card class="invoice-view__summary">
        <template #content>
          <div class="invoice-view__row">
            <span>Zwischensumme (Netto)</span>
            <span>{{ formatCurrency(invoice.totalNet) }}</span>
          </div>
          <div class="invoice-view__row">
            <span>USt.</span>
            <span>{{ formatCurrency(invoice.totalVat) }}</span>
          </div>
          <div class="invoice-view__row invoice-view__row--total">
            <span>Gesamtbetrag (Brutto)</span>
            <span>{{ formatCurrency(invoice.totalGross) }}</span>
          </div>
        </template>
      </Card>

      <div class="invoice-view__actions">
        <Button
          label="Rechnung herunterladen"
          icon="pi pi-download"
          severity="secondary"
          outlined
          @click="downloadPdf"
        />
        <Button
          v-if="canConfirmPayment"
          label="Zahlungseingang bestätigen"
          icon="pi pi-check-circle"
          :loading="busy"
          @click="confirmPayment"
        />
      </div>
    </template>
  </div>
</template>

<style scoped>
.invoice-view {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.invoice-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}

.invoice-view__meta {
  display: flex;
  flex-wrap: wrap;
  gap: 2rem;
}

.invoice-view__meta div {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.invoice-view__label {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.invoice-view__summary {
  max-width: 28rem;
  margin-left: auto;
}

.invoice-view__row {
  display: flex;
  justify-content: space-between;
  gap: 2rem;
  padding: 0.25rem 0;
}

.invoice-view__row--total {
  margin-top: 0.5rem;
  padding-top: 0.5rem;
  border-top: 1px solid var(--p-content-border-color);
  font-weight: 700;
}

.invoice-view__actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
}

/* Phone: full-width summary, tighter meta. */
@media (max-width: 767.98px) {
  .invoice-view__summary {
    max-width: none;
    margin-left: 0;
  }

  .invoice-view__meta {
    gap: 1rem;
  }
}
</style>
