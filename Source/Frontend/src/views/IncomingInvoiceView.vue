<script setup lang="ts">
import { reactive, ref } from 'vue'
import FileUpload, { type FileUploadUploaderEvent } from 'primevue/fileupload'
import Button from 'primevue/button'
import Card from 'primevue/card'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import SuggestionRow from '@/components/incoming/SuggestionRow.vue'
import { incomingInvoicesApi } from '@/services/incomingInvoicesApi'
import { useToast } from '@/composables/useToast'
import { ApiError, apiErrorMessage } from '@/types/api'
import type { PriceSuggestionDto } from '@/types/incomingInvoice'

type Phase = 'idle' | 'processing' | 'review' | 'done'

const toast = useToast()

const phase = ref<Phase>('idle')
const invoiceId = ref<number | null>(null)
const suggestions = ref<PriceSuggestionDto[]>([])
const decisions = reactive<Record<number, boolean | null>>({})
const confirming = ref(false)

async function pollSuggestions(id: number): Promise<PriceSuggestionDto[] | null> {
  for (let attempt = 0; attempt < 20; attempt++) {
    await new Promise((resolve) => setTimeout(resolve, 2000))
    try {
      const result = await incomingInvoicesApi.getSuggestions(id)
      if (result.length > 0) return result
    } catch (e) {
      // 404/409 mean the OCR job is still running — keep polling.
      if (!(e instanceof ApiError && (e.status === 404 || e.status === 409))) {
        throw e
      }
    }
  }
  return null
}

async function onUpload(event: FileUploadUploaderEvent): Promise<void> {
  const file = Array.isArray(event.files) ? event.files[0] : event.files
  if (!file) return

  phase.value = 'processing'
  try {
    const created = await incomingInvoicesApi.upload(file)
    invoiceId.value = created.id
    const result = await pollSuggestions(created.id)
    if (!result) {
      toast.error('Die Verarbeitung dauert ungewöhnlich lange. Bitte später erneut versuchen.')
      phase.value = 'idle'
      return
    }
    suggestions.value = result
    for (const suggestion of result) {
      decisions[suggestion.id] = null
    }
    phase.value = 'review'
  } catch (e) {
    toast.error(apiErrorMessage(e))
    phase.value = 'idle'
  }
}

async function confirmDecisions(): Promise<void> {
  if (invoiceId.value === null) return
  const decided = Object.entries(decisions)
    .filter(([, accepted]) => accepted !== null)
    .map(([id, accepted]) => ({ suggestionId: Number(id), accepted: accepted as boolean }))

  if (decided.length === 0) {
    toast.error('Bitte mindestens eine Position bewerten.')
    return
  }

  confirming.value = true
  try {
    await incomingInvoicesApi.confirm(invoiceId.value, { decisions: decided })
    toast.success('Preisänderungen wurden übernommen.')
    phase.value = 'done'
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    confirming.value = false
  }
}

function reset(): void {
  phase.value = 'idle'
  invoiceId.value = null
  suggestions.value = []
  for (const key of Object.keys(decisions)) {
    delete decisions[Number(key)]
  }
}
</script>

<template>
  <div class="incoming-view">
    <h1>Eingangsrechnung erfassen</h1>

    <Card v-if="phase === 'idle'">
      <template #content>
        <p>Lieferantenrechnung als Bild oder PDF hochladen — die KI wertet die Positionen aus.</p>
        <FileUpload
          mode="basic"
          custom-upload
          auto
          accept="image/*,application/pdf"
          :max-file-size="10000000"
          choose-label="Rechnung hochladen"
          @uploader="onUpload"
        />
      </template>
    </Card>

    <div v-else-if="phase === 'processing'" class="incoming-view__processing">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
      <p>Die Rechnung wird verarbeitet …</p>
    </div>

    <template v-else-if="phase === 'review'">
      <Message severity="info" :closable="false">
        Bitte prüfen Sie die vorgeschlagenen Einkaufspreis-Änderungen Position für Position.
      </Message>
      <Card>
        <template #content>
          <SuggestionRow
            v-for="suggestion in suggestions"
            :key="suggestion.id"
            v-model="decisions[suggestion.id]"
            :suggestion="suggestion"
          />
        </template>
      </Card>
      <div class="incoming-view__actions">
        <Button label="Abbrechen" severity="secondary" text @click="reset" />
        <Button
          label="Bestätigen"
          icon="pi pi-check"
          :loading="confirming"
          @click="confirmDecisions"
        />
      </div>
    </template>

    <template v-else>
      <Message severity="success" :closable="false">
        Die Stammdaten wurden aktualisiert.
      </Message>
      <Button label="Weitere Rechnung erfassen" icon="pi pi-plus" @click="reset" />
    </template>
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

.incoming-view__processing {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 3rem;
}

.incoming-view__actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}
</style>
