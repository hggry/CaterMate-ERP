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
import { useBreakpoint } from '@/composables/useBreakpoint'
import type { IngredientDto } from '@/types/ingredient'

const { data: ingredients, loading, error, execute } = useApi(ingredientsApi.list)
const { formatCurrency } = useFormat()
const { isPhone } = useBreakpoint()

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

    <!-- Phone: tappable card list (tap a card to edit) -->
    <ul v-else-if="isPhone" class="ingredients-view__cards">
      <li v-if="filteredIngredients.length === 0" class="ingredients-view__empty">
        Keine Zutaten vorhanden.
      </li>
      <li
        v-for="item in filteredIngredients"
        :key="item.id"
        class="icard"
        @click="openEdit(item)"
      >
        <div class="icard__top">
          <span class="icard__name">{{ item.name }}</span>
          <span class="icard__cat">{{ item.category ?? '—' }}</span>
        </div>
        <div class="icard__meta">
          <span>{{ formatCurrency(item.purchasePricePerUnit) }} / {{ item.unit }}</span>
        </div>
      </li>
    </ul>

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

/* Phone card list (markup only renders below 768px). */
.ingredients-view__cards {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
}

.ingredients-view__empty {
  color: var(--p-text-muted-color);
  text-align: center;
  padding: 2rem 0;
}

.icard {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  padding: 0.875rem;
  border: 1px solid var(--p-content-border-color);
  border-radius: var(--p-border-radius, 8px);
  background: var(--p-content-background);
  cursor: pointer;
}

.icard:active {
  background: var(--cm-sand);
}

.icard__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
}

.icard__name {
  font-weight: 600;
}

.icard__cat {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.icard__meta {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

@media (max-width: 767.98px) {
  /* Natural page scroll instead of the fixed-height internal scroll. */
  .ingredients-view {
    height: auto;
    overflow: visible;
  }

  .ingredients-view__header {
    align-items: stretch;
  }

  .ingredients-view__filters > :deep(.p-button) {
    width: 100%;
  }
}
</style>
