<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import InputText from 'primevue/inputtext'
import Select from 'primevue/select'
import { useConfirm } from 'primevue/useconfirm'
import MenuItemDialog from '@/components/masterdata/MenuItemDialog.vue'
import { menuItemsApi } from '@/services/menuItemsApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import { useResponsivePageRows } from '@/composables/useResponsivePageRows'
import { useToast } from '@/composables/useToast'
import { apiErrorMessage } from '@/types/api'
import type { MenuItemDto } from '@/types/menuItem'

const { data: menuItems, loading, error, execute } = useApi(menuItemsApi.list)
const { formatCurrency } = useFormat()
const toast = useToast()
const confirm = useConfirm()

const search = ref('')
const categoryFilter = ref<string | null>(null)
const allergenFilter = ref<string | null>(null)
const dialogVisible = ref(false)
const editing = ref<MenuItemDto | null>(null)

const collator = new Intl.Collator('de-AT', { sensitivity: 'base' })

const categoryOptions = computed(() => buildOptions(menuItems.value?.map((item) => item.category)))
const allergenOptions = computed(() => buildOptions(
  (menuItems.value ?? []).flatMap((item) => splitAllergens(item.allergens)),
))

const filteredMenuItems = computed(() => {
  const term = search.value.trim().toLocaleLowerCase('de-AT')

  return (menuItems.value ?? []).filter((item) => {
    const allergens = splitAllergens(item.allergens)
    const matchesSearch = !term || [item.name, item.category, item.allergens ?? '']
      .some((value) => value.toLocaleLowerCase('de-AT').includes(term))
    const matchesCategory = !categoryFilter.value || item.category === categoryFilter.value
    const matchesAllergen = !allergenFilter.value || allergens.includes(allergenFilter.value)

    return matchesSearch && matchesCategory && matchesAllergen
  })
})

const totalFilteredMenuItems = computed(() => filteredMenuItems.value.length)
const {
  tableViewport,
  rows: pageRows,
  first,
  resetFirst,
} = useResponsivePageRows(totalFilteredMenuItems, { defaultRows: 15, minRows: 4, maxRows: 25 })

onMounted(() => execute())

watch([search, categoryFilter, allergenFilter], resetFirst)

function buildOptions(values: Array<string | null | undefined> | undefined): Array<{ label: string, value: string }> {
  return Array.from(new Set((values ?? []).filter((value): value is string => !!value)))
    .sort(collator.compare)
    .map((value) => ({ label: value, value }))
}

function splitAllergens(allergens: string | null): string[] {
  return (allergens ?? '')
    .split(',')
    .map((value) => value.trim())
    .filter(Boolean)
}

function resetFilters(): void {
  search.value = ''
  categoryFilter.value = null
  allergenFilter.value = null
}

function openCreate(): void {
  editing.value = null
  dialogVisible.value = true
}

async function openEdit(item: MenuItemDto): Promise<void> {
  try {
    // Fetch the full item so the bill of materials is populated.
    editing.value = await menuItemsApi.getById(item.id)
    dialogVisible.value = true
  } catch (e) {
    toast.error(apiErrorMessage(e))
  }
}

function confirmDelete(item: MenuItemDto): void {
  confirm.require({
    header: 'Löschen bestätigen',
    message: `Menüartikel „${item.name}" wirklich löschen?`,
    icon: 'pi pi-exclamation-triangle',
    acceptLabel: 'Löschen',
    rejectLabel: 'Abbrechen',
    acceptProps: { severity: 'danger' },
    accept: async () => {
      try {
        await menuItemsApi.remove(item.id)
        toast.success('Menüartikel gelöscht.')
        execute()
      } catch (e) {
        toast.error(apiErrorMessage(e))
      }
    },
  })
}

function onSaved(): void {
  execute()
}
</script>

<template>
  <div class="menu-items-view">
    <header class="menu-items-view__header">
      <h1>Menüartikel</h1>
      <Button label="Neuer Menüartikel" icon="pi pi-plus" @click="openCreate" />
    </header>

    <Message v-if="error" severity="error" :closable="false">
      Menüartikel konnten nicht geladen werden.
    </Message>

    <div class="menu-items-view__filters">
      <div class="menu-items-view__filter-field">
        <label>Suche</label>
        <InputText v-model="search" placeholder="Bezeichnung, Kategorie oder Allergen" />
      </div>
      <div class="menu-items-view__filter-field">
        <label>Kategorie</label>
        <Select
          v-model="categoryFilter"
          :options="categoryOptions"
          option-label="label"
          option-value="value"
          placeholder="Alle Kategorien"
          show-clear
        />
      </div>
      <div class="menu-items-view__filter-field">
        <label>Allergen</label>
        <Select
          v-model="allergenFilter"
          :options="allergenOptions"
          option-label="label"
          option-value="value"
          placeholder="Alle Allergene"
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

    <div v-if="loading" class="menu-items-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <div v-else ref="tableViewport" class="menu-items-view__table">
      <DataTable
        v-model:first="first"
        :value="filteredMenuItems"
        paginator
        :rows="pageRows"
        data-key="id"
        sort-field="name"
        :sort-order="1"
        class="menu-items-view__datatable"
      >
        <template #empty>Keine Menüartikel vorhanden.</template>
        <Column field="name" header="Bezeichnung" sortable />
        <Column field="category" header="Kategorie" sortable style="width: 12rem" />
        <Column field="salesPricePerPerson" header="VK-Preis/Person" sortable style="width: 11rem">
          <template #body="{ data }">{{ formatCurrency(data.salesPricePerPerson) }}</template>
        </Column>
        <Column field="purchaseCostPerPerson" header="EK-Kosten/Person" sortable style="width: 11rem">
          <template #body="{ data }">{{ formatCurrency(data.purchaseCostPerPerson) }}</template>
        </Column>
        <Column field="allergens" header="Allergene" sortable>
          <template #body="{ data }">{{ data.allergens || '—' }}</template>
        </Column>
        <Column style="width: 8rem">
          <template #body="{ data }">
            <Button
              icon="pi pi-pencil"
              severity="secondary"
              text
              rounded
              aria-label="Bearbeiten"
              @click="openEdit(data)"
            />
            <Button
              icon="pi pi-trash"
              severity="danger"
              text
              rounded
              aria-label="Löschen"
              @click="confirmDelete(data)"
            />
          </template>
        </Column>
      </DataTable>
    </div>

    <MenuItemDialog
      v-model:visible="dialogVisible"
      :menu-item="editing"
      @saved="onSaved"
    />
  </div>
</template>

<style scoped>
.menu-items-view {
  display: flex;
  flex-direction: column;
  height: calc(100vh - 3rem);
  height: calc(100dvh - 3rem);
  min-height: 0;
  overflow: hidden;
}

.menu-items-view__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
  flex-shrink: 0;
}

.menu-items-view__header h1 {
  margin: 0;
}

.menu-items-view__filters {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 1rem;
  margin-bottom: 1rem;
  flex-shrink: 0;
}

.menu-items-view__filter-field {
  display: flex;
  flex: 1 1 12rem;
  min-width: 12rem;
  flex-direction: column;
  gap: 0.25rem;
}

.menu-items-view__filter-field label {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.menu-items-view__filter-field :deep(.p-inputtext),
.menu-items-view__filter-field :deep(.p-select) {
  width: 100%;
}

.menu-items-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
  flex: 1;
  min-height: 0;
}

.menu-items-view__table {
  flex: 1;
  min-height: 0;
  overflow: hidden;
}

.menu-items-view__datatable {
  height: 100%;
}

@media (max-width: 48rem) {
  .menu-items-view__header {
    align-items: stretch;
  }

  .menu-items-view__filters > .p-button {
    width: 100%;
  }
}
</style>
