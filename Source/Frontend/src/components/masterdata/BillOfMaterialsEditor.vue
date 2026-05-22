<script setup lang="ts">
import { onMounted } from 'vue'
import Select from 'primevue/select'
import InputNumber from 'primevue/inputnumber'
import Button from 'primevue/button'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import { ingredientsApi } from '@/services/ingredientsApi'
import { useApi } from '@/composables/useApi'
import type { BillOfMaterialsItemRequest } from '@/types/menuItem'

const rows = defineModel<BillOfMaterialsItemRequest[]>({ default: () => [] })

const { data: ingredients, loading, error, execute } = useApi(ingredientsApi.list)

onMounted(() => execute())

function addRow(): void {
  rows.value = [...rows.value, { ingredientId: 0, quantityPerPerson: 0 }]
}

function removeRow(index: number): void {
  rows.value = rows.value.filter((_, i) => i !== index)
}

function unitFor(ingredientId: number): string {
  return ingredients.value?.find((i) => i.id === ingredientId)?.unit ?? ''
}
</script>

<template>
  <div class="bom-editor">
    <div v-if="loading" class="bom-editor__center">
      <ProgressSpinner style="width: 2rem; height: 2rem" />
    </div>

    <Message v-else-if="error" severity="error" :closable="false">
      Zutaten konnten nicht geladen werden.
    </Message>

    <template v-else>
      <p v-if="rows.length === 0" class="bom-editor__empty">
        Noch keine Zutaten in der Stückliste.
      </p>

      <div v-for="(row, index) in rows" :key="index" class="bom-editor__row">
        <Select
          v-model="row.ingredientId"
          :options="ingredients ?? []"
          option-label="name"
          option-value="id"
          filter
          placeholder="Zutat wählen"
          class="bom-editor__select"
        />
        <InputNumber
          v-model="row.quantityPerPerson"
          :min="0"
          :min-fraction-digits="0"
          :max-fraction-digits="3"
          class="bom-editor__qty"
        />
        <span class="bom-editor__unit">{{ unitFor(row.ingredientId) }} / Person</span>
        <Button
          icon="pi pi-trash"
          severity="danger"
          text
          rounded
          aria-label="Zeile entfernen"
          @click="removeRow(index)"
        />
      </div>

      <Button
        label="Zutat hinzufügen"
        icon="pi pi-plus"
        severity="secondary"
        outlined
        size="small"
        @click="addRow"
      />
    </template>
  </div>
</template>

<style scoped>
.bom-editor {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.bom-editor__center {
  display: flex;
  justify-content: center;
  padding: 1rem;
}

.bom-editor__empty {
  margin: 0;
  color: var(--p-text-muted-color);
}

.bom-editor__row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.bom-editor__select {
  flex: 1;
}

.bom-editor__qty {
  width: 7rem;
}

.bom-editor__unit {
  min-width: 7rem;
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}
</style>
