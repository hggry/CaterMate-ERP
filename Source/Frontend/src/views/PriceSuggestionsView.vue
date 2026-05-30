<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import InputText from 'primevue/inputtext'
import Select from 'primevue/select'
import { incomingInvoicesApi } from '@/services/incomingInvoicesApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import { useResponsivePageRows } from '@/composables/useResponsivePageRows'
import { useToast } from '@/composables/useToast'
import { useSuggestionsStore } from '@/stores/suggestionsStore'
import { apiErrorMessage } from '@/types/api'
import type { PriceSuggestionDto } from '@/types/incomingInvoice'

const { data: suggestions, loading, error, execute } = useApi(incomingInvoicesApi.getAllSuggestions)
const { formatCurrency } = useFormat()
const toast = useToast()
const suggestionsStore = useSuggestionsStore()

const busyId = ref<number | null>(null)
const search = ref('')
const ingredientFilter = ref<string | null>(null)

const collator = new Intl.Collator('de-AT', { sensitivity: 'base' })

const ingredientOptions = computed(() =>
  Array.from(new Set((suggestions.value ?? []).map((item) => item.ingredientName)))
    .sort(collator.compare)
    .map((value) => ({ label: value, value })),
)

const filteredSuggestions = computed(() => {
  const term = search.value.trim().toLocaleLowerCase('de-AT')

  return (suggestions.value ?? []).filter((item) => {
    const matchesSearch = !term || [
      String(item.incomingInvoiceId),
      item.ingredientName,
      String(item.currentPrice),
      String(item.suggestedPrice),
    ].some((value) => value.toLocaleLowerCase('de-AT').includes(term))
    const matchesIngredient = !ingredientFilter.value || item.ingredientName === ingredientFilter.value

    return matchesSearch && matchesIngredient
  })
})

const totalFilteredSuggestions = computed(() => filteredSuggestions.value.length)
const {
  tableViewport,
  rows: pageRows,
  first,
  resetFirst,
} = useResponsivePageRows(totalFilteredSuggestions, { defaultRows: 15, minRows: 4, maxRows: 25 })

watch([search, ingredientFilter], resetFirst)

async function reload(): Promise<void> {
  await execute()
  suggestionsStore.count = suggestions.value?.length ?? 0
}

onMounted(() => reload())

function resetFilters(): void {
  search.value = ''
  ingredientFilter.value = null
}

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

    <div class="suggestions-view__filters">
      <div class="suggestions-view__filter-field">
        <label>Suche</label>
        <InputText v-model="search" placeholder="Rechnung, Zutat oder Preis" />
      </div>
      <div class="suggestions-view__filter-field">
        <label>Zutat</label>
        <Select
          v-model="ingredientFilter"
          :options="ingredientOptions"
          option-label="label"
          option-value="value"
          placeholder="Alle Zutaten"
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

    <div v-if="loading" class="suggestions-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <div v-else ref="tableViewport" class="suggestions-view__table">
      <DataTable
        v-model:first="first"
        :value="filteredSuggestions"
        paginator
        :rows="pageRows"
        data-key="id"
        sort-field="ingredientName"
        :sort-order="1"
        class="suggestions-view__datatable"
      >
        <template #empty>Keine offenen Preisänderungsvorschläge.</template>
        <Column field="incomingInvoiceId" header="Rechnung" sortable style="width: 7rem">
          <template #body="{ data }">#{{ data.incomingInvoiceId }}</template>
        </Column>
        <Column field="ingredientName" header="Zutat" sortable />
        <Column field="currentPrice" header="Aktueller Preis" sortable style="width: 11rem">
          <template #body="{ data }">{{ formatCurrency(data.currentPrice) }}</template>
        </Column>
        <Column field="suggestedPrice" header="Vorschlag" sortable style="width: 11rem">
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
  </div>
</template>

<style scoped>
.suggestions-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
  gap: 1rem;
  overflow: hidden;
}

.suggestions-view__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  flex-shrink: 0;
}

.suggestions-view__header h1 {
  margin: 0;
}

.suggestions-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
  flex: 1;
  min-height: 0;
}

.suggestions-view__filters {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 1rem;
  flex-shrink: 0;
}

.suggestions-view__filter-field {
  display: flex;
  flex: 1 1 12rem;
  min-width: 12rem;
  flex-direction: column;
  gap: 0.25rem;
}

.suggestions-view__filter-field label {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.suggestions-view__filter-field :deep(.p-inputtext),
.suggestions-view__filter-field :deep(.p-select) {
  width: 100%;
}

.suggestions-view__table {
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.suggestions-view__datatable {
  height: 100%;
}

.suggestions-view__actions {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

@media (max-width: 48rem) {
  .suggestions-view__filters > .p-button {
    width: 100%;
  }
}
</style>
