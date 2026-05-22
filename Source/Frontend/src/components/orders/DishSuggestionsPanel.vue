<script setup lang="ts">
import { onMounted } from 'vue'
import Panel from 'primevue/panel'
import Button from 'primevue/button'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import { ordersApi } from '@/services/ordersApi'
import { useApi } from '@/composables/useApi'

const props = defineProps<{ orderId: number }>()
const emit = defineEmits<{ assign: [menuItemId: number] }>()

const { data, loading, error, execute } = useApi(ordersApi.getSuggestions)

onMounted(() => execute(props.orderId))
</script>

<template>
  <Panel header="KI-Gerichtsvorschläge">
    <div v-if="loading" class="dish-suggestions__center">
      <ProgressSpinner style="width: 2.5rem; height: 2.5rem" />
    </div>

    <Message v-else-if="error" severity="warn" :closable="false">
      KI-Vorschläge sind derzeit nicht verfügbar.
    </Message>

    <p v-else-if="!data || data.suggestions.length === 0" class="dish-suggestions__empty">
      Keine Vorschläge vorhanden.
    </p>

    <ul v-else class="dish-suggestions__list">
      <li v-for="suggestion in data.suggestions" :key="suggestion.menuItemId">
        <div class="dish-suggestions__info">
          <strong>{{ suggestion.menuItemName }}</strong>
          <span class="dish-suggestions__reason">{{ suggestion.reason }}</span>
        </div>
        <Button
          label="Übernehmen"
          icon="pi pi-plus"
          size="small"
          @click="emit('assign', suggestion.menuItemId)"
        />
      </li>
    </ul>
  </Panel>
</template>

<style scoped>
.dish-suggestions__center {
  display: flex;
  justify-content: center;
  padding: 1rem;
}

.dish-suggestions__empty {
  color: var(--p-text-muted-color);
}

.dish-suggestions__list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin: 0;
  padding: 0;
  list-style: none;
}

.dish-suggestions__list li {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
}

.dish-suggestions__info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.dish-suggestions__reason {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}
</style>
