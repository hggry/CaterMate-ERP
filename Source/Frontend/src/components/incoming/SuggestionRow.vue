<script setup lang="ts">
import SelectButton from 'primevue/selectbutton'
import { useFormat } from '@/composables/useFormat'
import type { PriceSuggestionDto } from '@/types/incomingInvoice'

defineProps<{ suggestion: PriceSuggestionDto }>()
const decision = defineModel<boolean | null>({ default: null })

const { formatCurrency } = useFormat()

const options = [
  { label: 'Akzeptieren', value: true },
  { label: 'Ablehnen', value: false },
]
</script>

<template>
  <div class="suggestion-row">
    <span class="suggestion-row__name">{{ suggestion.ingredientName }}</span>
    <span class="suggestion-row__price">
      Aktuell: {{ formatCurrency(suggestion.currentPrice) }}
    </span>
    <span class="suggestion-row__price suggestion-row__price--new">
      Vorschlag: {{ formatCurrency(suggestion.suggestedPrice) }}
    </span>
    <SelectButton
      v-model="decision"
      :options="options"
      option-label="label"
      option-value="value"
      :allow-empty="false"
    />
  </div>
</template>

<style scoped>
.suggestion-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem 0;
  border-bottom: 1px solid var(--p-content-border-color);
}

.suggestion-row__name {
  flex: 1;
  min-width: 10rem;
  font-weight: 600;
}

.suggestion-row__price {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.suggestion-row__price--new {
  color: var(--p-primary-color);
  font-weight: 600;
}
</style>
