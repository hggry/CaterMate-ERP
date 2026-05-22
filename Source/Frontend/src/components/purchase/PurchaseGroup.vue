<script setup lang="ts">
import Panel from 'primevue/panel'
import Checkbox from 'primevue/checkbox'
import type { PurchaseGroupDto } from '@/types/purchaseList'

defineProps<{ group: PurchaseGroupDto }>()
const emit = defineEmits<{ toggle: [itemId: number, isDone: boolean] }>()
</script>

<template>
  <Panel :header="group.category" toggleable>
    <ul class="purchase-group__list">
      <li v-for="item in group.items" :key="item.id" class="purchase-group__item">
        <Checkbox
          :model-value="item.isDone"
          binary
          :input-id="`pli-${item.id}`"
          @update:model-value="emit('toggle', item.id, $event)"
        />
        <label :for="`pli-${item.id}`" :class="{ 'purchase-group__done': item.isDone }">
          {{ item.ingredientName }} — {{ item.requiredQuantity }} {{ item.unit }}
        </label>
      </li>
    </ul>
  </Panel>
</template>

<style scoped>
.purchase-group__list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin: 0;
  padding: 0;
  list-style: none;
}

.purchase-group__item {
  display: flex;
  align-items: center;
  gap: 0.625rem;
}

.purchase-group__done {
  text-decoration: line-through;
  color: var(--p-text-muted-color);
}
</style>
