<script setup lang="ts">
import { onMounted } from 'vue'
import Panel from 'primevue/panel'
import Listbox from 'primevue/listbox'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import { menuItemsApi } from '@/services/menuItemsApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'

const selectedIds = defineModel<number[]>({ default: () => [] })

const { data, loading, error, execute } = useApi(menuItemsApi.list)
const { formatCurrency } = useFormat()

onMounted(() => execute())
</script>

<template>
  <Panel header="Menüartikel zuordnen">
    <div v-if="loading" class="menu-picker__center">
      <ProgressSpinner style="width: 2.5rem; height: 2.5rem" />
    </div>

    <Message v-else-if="error" severity="error" :closable="false">
      Menüartikel konnten nicht geladen werden.
    </Message>

    <Listbox
      v-else
      v-model="selectedIds"
      :options="data ?? []"
      option-label="name"
      option-value="id"
      multiple
      filter
      filter-placeholder="Suchen"
      empty-message="Keine Menüartikel vorhanden."
      empty-filter-message="Kein Treffer."
      list-style="max-height: 18rem"
    >
      <template #option="{ option }">
        <div class="menu-picker__option">
          <span>{{ option.name }}</span>
          <span class="menu-picker__meta">
            {{ option.category }} · {{ formatCurrency(option.salesPricePerPerson) }}/Person
          </span>
        </div>
      </template>
    </Listbox>
  </Panel>
</template>

<style scoped>
.menu-picker__center {
  display: flex;
  justify-content: center;
  padding: 1rem;
}

.menu-picker__option {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.menu-picker__meta {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}
</style>
