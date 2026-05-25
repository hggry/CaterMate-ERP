<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import Dialog from 'primevue/dialog'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import { ordersApi } from '@/services/ordersApi'
import { menuItemsApi } from '@/services/menuItemsApi'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import { useFormat } from '@/composables/useFormat'
import { apiErrorMessage } from '@/types/api'

const props = defineProps<{ orderId: number; assignedIds: number[] }>()
const emit = defineEmits<{ changed: [] }>()
const visible = defineModel<boolean>('visible', { required: true })

const toast = useToast()
const { formatCurrency } = useFormat()

const localIds = ref<number[]>([])
const toggling = ref(false)
const filterText = ref('')

const suggestions = useApi(ordersApi.getSuggestions)
const catalog = useApi(menuItemsApi.list)

watch(visible, (open) => {
  if (open) {
    localIds.value = [...props.assignedIds]
    filterText.value = ''
    suggestions.execute(props.orderId)
    catalog.execute()
  }
})

const filteredCatalog = computed(() => {
  const q = filterText.value.toLowerCase().trim()
  if (!q) return catalog.data.value ?? []
  return (catalog.data.value ?? []).filter(
    (item) =>
      item.name.toLowerCase().includes(q) || item.category.toLowerCase().includes(q),
  )
})

async function toggleItem(id: number, add: boolean): Promise<void> {
  if (toggling.value) return
  const newIds = add ? [...localIds.value, id] : localIds.value.filter((x) => x !== id)
  localIds.value = newIds
  toggling.value = true
  try {
    await ordersApi.update(props.orderId, { assignedMenuItemIds: newIds })
    emit('changed')
  } catch (e) {
    localIds.value = [...props.assignedIds]
    toast.error(apiErrorMessage(e))
  } finally {
    toggling.value = false
  }
}
</script>

<template>
  <Dialog
    v-model:visible="visible"
    header="Menüartikel hinzufügen"
    modal
    :style="{ width: '48rem' }"
  >
    <div class="picker-dialog">
      <section class="picker-dialog__section">
        <div class="picker-dialog__section-title">Gerichtsvorschläge</div>

        <div v-if="suggestions.loading.value" class="picker-dialog__center">
          <ProgressSpinner style="width: 2rem; height: 2rem" />
        </div>
        <Message v-else-if="suggestions.error.value" severity="warn" :closable="false">
          Vorschläge konnten nicht geladen werden.
        </Message>
        <p
          v-else-if="!suggestions.data.value || suggestions.data.value.suggestions.length === 0"
          class="picker-dialog__empty"
        >
          Keine Vorschläge vorhanden.
        </p>
        <ul v-else class="picker-dialog__suggestion-list">
          <li
            v-for="s in suggestions.data.value.suggestions"
            :key="s.menuItemId"
            class="picker-dialog__suggestion-item"
          >
            <div class="picker-dialog__suggestion-info">
              <span class="picker-dialog__name">{{ s.menuItemName }}</span>
              <span class="picker-dialog__meta">{{ s.reason }}</span>
            </div>
            <Button
              :icon="localIds.includes(s.menuItemId) ? 'pi pi-check' : 'pi pi-plus'"
              :severity="localIds.includes(s.menuItemId) ? 'success' : 'secondary'"
              :disabled="localIds.includes(s.menuItemId) || toggling"
              size="small"
              @click="toggleItem(s.menuItemId, true)"
            />
          </li>
        </ul>
      </section>

      <section class="picker-dialog__section">
        <div class="picker-dialog__section-title">Alle Menüartikel</div>

        <InputText
          v-model="filterText"
          placeholder="Suchen..."
          class="picker-dialog__search"
          fluid
        />

        <div v-if="catalog.loading.value" class="picker-dialog__center">
          <ProgressSpinner style="width: 2rem; height: 2rem" />
        </div>
        <Message v-else-if="catalog.error.value" severity="error" :closable="false">
          Menüartikel konnten nicht geladen werden.
        </Message>
        <div v-else class="picker-dialog__catalog">
          <div
            v-for="item in filteredCatalog"
            :key="item.id"
            class="picker-dialog__catalog-item"
            :class="{ 'picker-dialog__catalog-item--selected': localIds.includes(item.id) }"
            @click="toggleItem(item.id, !localIds.includes(item.id))"
          >
            <i
              class="picker-dialog__check-icon"
              :class="localIds.includes(item.id) ? 'pi pi-check' : 'pi pi-circle'"
            />
            <div class="picker-dialog__item-info">
              <span class="picker-dialog__name">{{ item.name }}</span>
              <span class="picker-dialog__meta">
                {{ item.category }} · {{ formatCurrency(item.salesPricePerPerson) }}/Person
              </span>
            </div>
          </div>
          <p v-if="filteredCatalog.length === 0" class="picker-dialog__empty">
            Kein Treffer.
          </p>
        </div>
      </section>
    </div>
  </Dialog>
</template>

<style scoped>
.picker-dialog {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.picker-dialog__section {
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
}

.picker-dialog__section-title {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--p-text-muted-color);
}

.picker-dialog__center {
  display: flex;
  justify-content: center;
  padding: 1rem;
}

.picker-dialog__empty {
  color: var(--p-text-muted-color);
  margin: 0;
}

.picker-dialog__suggestion-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin: 0;
  padding: 0;
  list-style: none;
  max-height: 10rem;
  overflow-y: auto;
}

.picker-dialog__suggestion-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}

.picker-dialog__suggestion-info {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.picker-dialog__search {
  margin-bottom: 0.25rem;
}

.picker-dialog__catalog {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  max-height: 14rem;
  overflow-y: auto;
}

.picker-dialog__catalog-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem 0.625rem;
  border-radius: var(--p-border-radius, 6px);
  cursor: pointer;
  transition: background 0.15s;
}

.picker-dialog__catalog-item:hover {
  background: var(--p-content-hover-background);
}

.picker-dialog__catalog-item--selected {
  background: color-mix(in srgb, var(--p-primary-color) 12%, transparent);
  color: var(--p-primary-color);
}

.picker-dialog__catalog-item--selected:hover {
  background: color-mix(in srgb, var(--p-primary-color) 18%, transparent);
}

.picker-dialog__check-icon {
  font-size: 0.875rem;
  width: 1rem;
  flex-shrink: 0;
}

.picker-dialog__item-info {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.picker-dialog__name {
  font-weight: 500;
}

.picker-dialog__meta {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.picker-dialog__catalog-item--selected .picker-dialog__meta {
  color: inherit;
  opacity: 0.75;
}
</style>
