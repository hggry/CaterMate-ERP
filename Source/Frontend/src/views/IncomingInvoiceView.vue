<script setup lang="ts">
import { onMounted, ref } from 'vue'
import FileUpload, { type FileUploadUploaderEvent } from 'primevue/fileupload'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Card from 'primevue/card'
import Tag from 'primevue/tag'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import { incomingInvoicesApi } from '@/services/incomingInvoicesApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import { useToast } from '@/composables/useToast'
import { apiErrorMessage } from '@/types/api'

const { data: invoices, loading, error, execute } = useApi(incomingInvoicesApi.list)
const { formatDateTime } = useFormat()
const toast = useToast()

const uploading = ref(false)

onMounted(() => execute())

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

    <div v-if="loading" class="incoming-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <DataTable v-else :value="invoices ?? []" paginator :rows="15" data-key="id">
      <template #empty>Noch keine Eingangsrechnungen hochgeladen.</template>
      <Column field="id" header="Nr." style="width: 5rem">
        <template #body="{ data }">#{{ data.id }}</template>
      </Column>
      <Column field="fileName" header="Datei">
        <template #body="{ data }">{{ data.fileName ?? '—' }}</template>
      </Column>
      <Column header="Status" style="width: 11rem">
        <template #body="{ data }">
          <Tag :value="statusInfo(data.status).label" :severity="statusInfo(data.status).severity" />
        </template>
      </Column>
      <Column header="Hochgeladen am" style="width: 13rem">
        <template #body="{ data }">{{ formatDateTime(data.createdAt) }}</template>
      </Column>
      <Column header="Geprüft am" style="width: 13rem">
        <template #body="{ data }">{{ formatDateTime(data.processedAt) }}</template>
      </Column>
    </DataTable>
  </div>
</template>

<style scoped>
.incoming-view {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.incoming-view h1 {
  margin: 0;
}

.incoming-view__upload {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-top: 0.5rem;
}

.incoming-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}
</style>
