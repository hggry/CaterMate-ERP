<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import InputText from 'primevue/inputtext'
import Select from 'primevue/select'
import IngredientDialog from '@/components/masterdata/IngredientDialog.vue'
import { ingredientsApi } from '@/services/ingredientsApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import { useResponsivePageRows } from '@/composables/useResponsivePageRows'
import type { IngredientDto } from '@/types/ingredient'

const { data: ingredients, loading, error, execute } = useApi(ingredientsApi.list)
const { formatCurrency } = useFormat()

const search = ref('')
const categoryFilter = ref<string | null>(null)
const unitFilter = ref<string | null>(null)
const dialogVisible = ref(false)
const editing = ref<IngredientDto | null>(null)

const collator = new Intl.Collator('de-AT', { sensitivity: 'base' })

const categoryOptions = computed(() => buildOptions(ingredients.value?.map((item) => item.category)))
const unitOptions = computed(() => buildOptions(ingredients.value?.map((item) => item.unit)))

const filteredIngredients = computed(() => {
  const term = search.value.trim().toLocaleLowerCase('de-AT')

  return (ingredients.value ?? []).filter((item) => {
    const matchesSearch = !term || [item.name, item.unit, item.category ?? '']
      .some((value) => value.toLocaleLowerCase('de-AT').includes(term))
    const matchesCategory = !categoryFilter.value || item.category === categoryFilter.value
    const matchesUnit = !unitFilter.value || item.unit === unitFilter.value

    return matchesSearch && matchesCategory && matchesUnit
  })
})

const totalFilteredIngredients = computed(() => filteredIngredients.value.length)
const {
  tableViewport,
  rows: pageRows,
  first,
  resetFirst,
} = useResponsivePageRows(totalFilteredIngredients, { defaultRows: 15, minRows: 4, maxRows: 25 })

onMounted(() => execute())

watch([search, categoryFilter, unitFilter], resetFirst)

function buildOptions(values: Array<string | null | undefined> | undefined): Array<{ label: string, value: string }> {
  return Array.from(new Set((values ?? []).filter((value): value is string => !!value)))
    .sort(collator.compare)
    .map((value) => ({ label: value, value }))
}

function resetFilters(): void {
  search.value = ''
  categoryFilter.value = null
  unitFilter.value = null
}

function openCreate(): void {
  editing.value = null
  dialogVisible.value = true
}

function openEdit(item: IngredientDto): void {
  editing.value = item
  dialogVisible.value = true
}

function onSaved(): void {
  execute()
}
</script>

<template>
  <div class="ingredients-view">
    <header class="ingredients-view__header">
      <h1>Zutaten</h1>
      <Button label="Neue Zutat" icon="pi pi-plus" @click="openCreate" />
    </header>

    <Message v-if="error" severity="error" :closable="false">
      Zutaten konnten nicht geladen werden.
    </Message>

    <div class="ingredients-view__filters">
      <div class="ingredients-view__filter-field">
        <label>Suche</label>
        <InputText v-model="search" placeholder="Name, Einheit oder Warengruppe" />
      </div>
      <div class="ingredients-view__filter-field">
        <label>Warengruppe</label>
        <Select
          v-model="categoryFilter"
          :options="categoryOptions"
          option-label="label"
          option-value="value"
          placeholder="Alle Warengruppen"
          show-clear
        />
      </div>
      <div class="ingredients-view__filter-field">
        <label>Einheit</label>
        <Select
          v-model="unitFilter"
          :options="unitOptions"
          option-label="label"
          option-value="value"
          placeholder="Alle Einheiten"
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

    <div v-if="loading" class="ingredients-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <div v-else ref="tableViewport" class="ingredients-view__table">
      <DataTable
        v-model:first="first"
        :value="filteredIngredients"
        paginator
        :rows="pageRows"
        data-key="id"
        sort-field="name"
        :sort-order="1"
        class="ingredients-view__datatable"
      >
        <template #empty>Keine Zutaten vorhanden.</template>
        <Column field="name" header="Name" sortable />
        <Column field="unit" header="Einheit" sortable style="width: 8rem" />
        <Column field="purchasePricePerUnit" header="Einkaufspreis" sortable style="width: 12rem">
          <template #body="{ data }">{{ formatCurrency(data.purchasePricePerUnit) }}</template>
        </Column>
        <Column field="category" header="Warengruppe" sortable>
          <template #body="{ data }">{{ data.category ?? '—' }}</template>
        </Column>
        <Column style="width: 6rem">
          <template #body="{ data }">
            <Button
              icon="pi pi-pencil"
              severity="secondary"
              text
              rounded
              aria-label="Bearbeiten"
              @click="openEdit(data)"
            />
          </template>
        </Column>
      </DataTable>
    </div>

    <IngredientDialog
      v-model:visible="dialogVisible"
      :ingredient="editing"
      @saved="onSaved"
    />
  </div>
</template>

<style scoped>
.ingredients-view {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 3rem);
  height: calc(100dvh - 3rem);
  min-height: 0;
  overflow: hidden;
}

.ingredients-view__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
  flex-shrink: 0;
}

.ingredients-view__header h1 {
  margin: 0;
}

.ingredients-view__filters {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 1rem;
  margin-bottom: 1rem;
  flex-shrink: 0;
}

.ingredients-view__filter-field {
  display: flex;
  flex: 1 1 12rem;
  min-width: 12rem;
  flex-direction: column;
  gap: 0.25rem;
}

.ingredients-view__filter-field label {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.ingredients-view__filter-field :deep(.p-inputtext),
.ingredients-view__filter-field :deep(.p-select) {
  width: 100%;
}

.ingredients-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
  flex: 1;
  min-height: 0;
}

.ingredients-view__table {
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.ingredients-view__datatable {
  height: 100%;
}

@media (max-width: 48rem) {
  .ingredients-view__header {
    align-items: stretch;
  }

  .ingredients-view__filters > .p-button {
    width: 100%;
  }
}
</style>
