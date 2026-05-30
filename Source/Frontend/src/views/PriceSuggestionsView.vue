<script setup lang="ts">
import { onMounted, ref } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import { incomingInvoicesApi } from '@/services/incomingInvoicesApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import { useToast } from '@/composables/useToast'
import { useSuggestionsStore } from '@/stores/suggestionsStore'
import { apiErrorMessage } from '@/types/api'
import type { PriceSuggestionDto } from '@/types/incomingInvoice'

const { data: suggestions, loading, error, execute } = useApi(incomingInvoicesApi.getAllSuggestions)
const { formatCurrency } = useFormat()
const toast = useToast()
const suggestionsStore = useSuggestionsStore()

const busyId = ref<number | null>(null)

async function reload(): Promise<void> {
  await execute()
  suggestionsStore.count = suggestions.value?.length ?? 0
}

onMounted(() => reload())

async function accept(item: PriceSuggestionDto): Promise<void> {
  busyId.value = item.id
  try {
    await incomingInvoicesApi.acceptSuggestion(item.id)
    toast.success(`Einkaufspreis für „${item.ingredientName}" übernommen.`)
    await reload()
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    busyId.value = null
  }
}

async function discard(item: PriceSuggestionDto): Promise<void> {
  busyId.value = item.id
  try {
    await incomingInvoicesApi.discardSuggestion(item.id)
    toast.success(`Vorschlag für „${item.ingredientName}" verworfen.`)
    await reload()
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    busyId.value = null
  }
}
</script>

<template>
  <div class="suggestions-view">
    <header class="suggestions-view__header">
      <h1>Preisänderungsvorschläge</h1>
      <Button
        icon="pi pi-refresh"
        severity="secondary"
        text
        rounded
        aria-label="Aktualisieren"
        :loading="loading"
        @click="reload"
      />
    </header>

    <Message v-if="error" severity="error" :closable="false">
      Vorschläge konnten nicht geladen werden.
    </Message>

    <div v-if="loading" class="suggestions-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <DataTable v-else :value="suggestions ?? []" data-key="id">
      <template #empty>Keine offenen Preisänderungsvorschläge.</template>
      <Column header="Rechnung" style="width: 7rem">
        <template #body="{ data }">#{{ data.incomingInvoiceId }}</template>
      </Column>
      <Column field="ingredientName" header="Zutat" />
      <Column header="Aktueller Preis" style="width: 11rem">
        <template #body="{ data }">{{ formatCurrency(data.currentPrice) }}</template>
      </Column>
      <Column header="Vorschlag" style="width: 11rem">
        <template #body="{ data }">{{ formatCurrency(data.suggestedPrice) }}</template>
      </Column>
      <Column header="Aktionen" style="width: 16rem">
        <template #body="{ data }">
          <div class="suggestions-view__actions">
            <Button
              label="Übernehmen"
              icon="pi pi-check"
              size="small"
              :loading="busyId === data.id"
              @click="accept(data)"
            />
            <Button
              label="Verwerfen"
              icon="pi pi-times"
              severity="secondary"
              size="small"
              :loading="busyId === data.id"
              @click="discard(data)"
            />
          </div>
        </template>
      </Column>
    </DataTable>
  </div>
</template>

<style scoped>
.suggestions-view {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.suggestions-view__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.suggestions-view__header h1 {
  margin: 0;
}

.suggestions-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}

.suggestions-view__actions {
  display: flex;
  gap: 0.5rem;
}
</style>
