<script setup lang="ts">
import { onMounted, ref } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import IngredientDialog from '@/components/masterdata/IngredientDialog.vue'
import { ingredientsApi } from '@/services/ingredientsApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import type { IngredientDto } from '@/types/ingredient'

const { data: ingredients, loading, error, execute } = useApi(ingredientsApi.list)
const { formatCurrency } = useFormat()

const dialogVisible = ref(false)
const editing = ref<IngredientDto | null>(null)

onMounted(() => execute())

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

    <div v-if="loading" class="ingredients-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <DataTable v-else :value="ingredients ?? []" paginator :rows="15" data-key="id">
      <template #empty>Keine Zutaten vorhanden.</template>
      <Column field="name" header="Name" />
      <Column field="unit" header="Einheit" style="width: 8rem" />
      <Column header="Einkaufspreis" style="width: 12rem">
        <template #body="{ data }">{{ formatCurrency(data.purchasePricePerUnit) }}</template>
      </Column>
      <Column header="Warengruppe">
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

    <IngredientDialog
      v-model:visible="dialogVisible"
      :ingredient="editing"
      @saved="onSaved"
    />
  </div>
</template>

<style scoped>
.ingredients-view__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.ingredients-view__header h1 {
  margin: 0;
}

.ingredients-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}
</style>
