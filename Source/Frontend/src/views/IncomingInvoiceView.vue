<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import FileUpload, { type FileUploadUploaderEvent } from 'primevue/fileupload'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Card from 'primevue/card'
import Tag from 'primevue/tag'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import InputText from 'primevue/inputtext'
import Select from 'primevue/select'
import Button from 'primevue/button'
import { incomingInvoicesApi } from '@/services/incomingInvoicesApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import { useResponsivePageRows } from '@/composables/useResponsivePageRows'
import { useToast } from '@/composables/useToast'
import { apiErrorMessage } from '@/types/api'

const { data: invoices, loading, error, execute } = useApi(incomingInvoicesApi.list)
const { formatDateTime } = useFormat()
const toast = useToast()

const uploading = ref(false)
const search = ref('')
const statusFilter = ref<string | null>(null)

const statusOptions = computed(() => {
  const statuses = new Set((invoices.value ?? []).map((invoice) => invoice.status).filter(Boolean))
  return Array.from(statuses)
    .sort()
    .map((status) => ({ label: statusInfo(status).label, value: status }))
})

const filteredInvoices = computed(() => {
  const term = search.value.trim().toLocaleLowerCase('de-AT')

  return (invoices.value ?? []).filter((invoice) => {
    const matchesSearch = !term || [
      String(invoice.id),
      invoice.fileName ?? '',
      statusInfo(invoice.status).label,
      invoice.status,
    ].some((value) => value.toLocaleLowerCase('de-AT').includes(term))
    const matchesStatus = !statusFilter.value || invoice.status === statusFilter.value

    return matchesSearch && matchesStatus
  })
})

const totalFilteredInvoices = computed(() => filteredInvoices.value.length)
const {
  tableViewport,
  rows: pageRows,
  first,
  resetFirst,
} = useResponsivePageRows(totalFilteredInvoices, { defaultRows: 15, minRows: 4, maxRows: 25 })

onMounted(() => execute())
watch([search, statusFilter], resetFirst)

function resetFilters(): void {
  search.value = ''
  statusFilter.value = null
}

function statusInfo(status: string): { label: string; severity: 'info' | 'success' | 'secondary' } {
  switch (status) {
    case 'Pending':
      return { label: 'Hochgeladen', severity: 'info' }
    case 'Ready':
      return { label: 'Geprüft', severity: 'success' }
    default:
      return { label: status, severity: 'secondary' }
  }
}

async function onUpload(event: FileUploadUploaderEvent): Promise<void> {
  const file = Array.isArray(event.files) ? event.files[0] : event.files
  if (!file) return

  uploading.value = true
  try {
    await incomingInvoicesApi.upload(file)
    toast.success(
      'Rechnung hochgeladen. Sie wird im Hintergrund geprüft — etwaige Preisänderungsvorschläge erscheinen im Tab „Preisänderungsvorschläge".',
    )
    await execute()
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    uploading.value = false
  }
}
</script>

<template>
  <div class="incoming-view">
    <h1>Eingangsrechnungen</h1>

    <Card>
      <template #content>
        <p>Lieferantenrechnung als Bild oder PDF hochladen — die KI prüft die Positionen im Hintergrund.</p>
        <div class="incoming-view__upload">
          <FileUpload
            mode="basic"
            custom-upload
            auto
            accept="image/*,application/pdf"
            :max-file-size="10000000"
            choose-label="Rechnung hochladen"
            :disabled="uploading"
            @uploader="onUpload"
          />
          <ProgressSpinner v-if="uploading" style="width: 2rem; height: 2rem" />
        </div>
      </template>
    </Card>

    <Message severity="info" :closable="false">
      Preisänderungsvorschläge entstehen erst, wenn ein Einkaufspreis mehrfach in Folge deutlich über dem Referenzwert
      liegt. Sie erscheinen dann im Tab „Preisänderungsvorschläge" — nicht zwingend nach jedem Upload.
    </Message>

    <Message v-if="error" severity="error" :closable="false">
      Eingangsrechnungen konnten nicht geladen werden.
    </Message>

    <div class="incoming-view__filters">
      <div class="incoming-view__filter-field">
        <label>Suche</label>
        <InputText v-model="search" placeholder="Nr., Datei oder Status" />
      </div>
      <div class="incoming-view__filter-field">
        <label>Status</label>
        <Select
          v-model="statusFilter"
          :options="statusOptions"
          option-label="label"
          option-value="value"
          placeholder="Alle Status"
          show-clear
        />
      </div>
      <Button
        label="Zurücksetzen"
        icon="pi pi-filter-slash"
        severity="secondary"
        outlined
        @click="resetFilters"
      />
    </div>

    <div v-if="loading" class="incoming-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <div v-else ref="tableViewport" class="incoming-view__table">
      <DataTable
        v-model:first="first"
        :value="filteredInvoices"
        paginator
        :rows="pageRows"
        data-key="id"
        sort-field="createdAt"
        :sort-order="-1"
        class="incoming-view__datatable"
      >
        <template #empty>Noch keine Eingangsrechnungen hochgeladen.</template>
        <Column field="id" header="Nr." sortable style="width: 5rem">
          <template #body="{ data }">#{{ data.id }}</template>
        </Column>
        <Column field="fileName" header="Datei" sortable>
          <template #body="{ data }">{{ data.fileName ?? '—' }}</template>
        </Column>
        <Column field="status" header="Status" sortable style="width: 11rem">
          <template #body="{ data }">
            <Tag :value="statusInfo(data.status).label" :severity="statusInfo(data.status).severity" />
          </template>
        </Column>
        <Column field="createdAt" header="Hochgeladen am" sortable style="width: 13rem">
          <template #body="{ data }">{{ formatDateTime(data.createdAt) }}</template>
        </Column>
        <Column field="processedAt" header="Geprüft am" sortable style="width: 13rem">
          <template #body="{ data }">{{ formatDateTime(data.processedAt) }}</template>
        </Column>
      </DataTable>
    </div>
  </div>
</template>

<style scoped>
.incoming-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
  gap: 1rem;
  overflow: hidden;
}

.incoming-view h1 {
  margin: 0;
  flex-shrink: 0;
}

.incoming-view :deep(.p-card),
.incoming-view > .p-message {
  flex-shrink: 0;
}

.incoming-view__upload {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-top: 0.5rem;
}

.incoming-view__filters {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 1rem;
  flex-shrink: 0;
}

.incoming-view__filter-field {
  display: flex;
  flex: 1 1 12rem;
  min-width: 12rem;
  flex-direction: column;
  gap: 0.25rem;
}

.incoming-view__filter-field label {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.incoming-view__filter-field :deep(.p-inputtext),
.incoming-view__filter-field :deep(.p-select) {
  width: 100%;
}

.incoming-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
  flex: 1;
  min-height: 0;
}

.incoming-view__table {
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.incoming-view__datatable {
  height: 100%;
}

@media (max-width: 767.98px) {
  /* Natural page scroll; let the wide table scroll horizontally on its own. */
  .incoming-view {
    height: auto;
    overflow: visible;
  }

  .incoming-view__table {
    overflow-x: auto;
  }

  .incoming-view__datatable {
    height: auto;
  }

  .incoming-view__upload {
    align-items: flex-start;
    flex-direction: column;
  }

  .incoming-view__filters > :deep(.p-button) {
    width: 100%;
  }
}
</style>
