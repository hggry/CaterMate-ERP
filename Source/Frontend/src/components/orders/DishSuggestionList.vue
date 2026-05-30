<script setup lang="ts">
import { watch } from 'vue'
import Button from 'primevue/button'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import { ordersApi } from '@/services/ordersApi'
import { useApi } from '@/composables/useApi'

const props = defineProps<{
  orderId: number
  assignedIds: number[]
  disabled?: boolean
}>()

const emit = defineEmits<{ add: [menuItemId: number] }>()

const { data, loading, error, execute } = useApi(ordersApi.getSuggestions)

watch(() => props.orderId, (id) => id && execute(id), { immediate: true })
</script>

<template>
  <div class="dish-suggestions">
    <div class="dish-suggestions__title">Gerichtsvorschläge</div>

    <div v-if="loading" class="dish-suggestions__center">
      <ProgressSpinner style="width: 2rem; height: 2rem" />
    </div>
    <Message v-else-if="error" severity="warn" :closable="false">
      Vorschläge konnten nicht geladen werden.
    </Message>
    <p v-else-if="!data || data.suggestions.length === 0" class="dish-suggestions__empty">
      Keine Vorschläge vorhanden.
    </p>
    <ul v-else class="dish-suggestions__list">
      <li v-for="s in data.suggestions" :key="s.menuItemId" class="dish-suggestions__item">
        <div class="dish-suggestions__info">
          <span class="dish-suggestions__name">{{ s.menuItemName }}</span>
          <span class="dish-suggestions__meta">{{ s.reason }}</span>
        </div>
        <Button
          :icon="assignedIds.includes(s.menuItemId) ? 'pi pi-check' : 'pi pi-plus'"
          :severity="assignedIds.includes(s.menuItemId) ? 'success' : 'secondary'"
          :disabled="disabled || assignedIds.includes(s.menuItemId)"
          size="small"
          @click="emit('add', s.menuItemId)"
        />
      </li>
    </ul>
  </div>
</template>

<style scoped>
.dish-suggestions {
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
}

.dish-suggestions__title {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--p-text-muted-color);
}

.dish-suggestions__center {
  display: flex;
  justify-content: center;
  padding: 1rem;
}

.dish-suggestions__empty {
  color: var(--p-text-muted-color);
  margin: 0;
}

.dish-suggestions__list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin: 0;
  padding: 0;
  list-style: none;
  max-height: 12rem;
  overflow-y: auto;
}

.dish-suggestions__item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}

.dish-suggestions__info {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.dish-suggestions__name {
  font-weight: 500;
}

.dish-suggestions__meta {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}
</style>
