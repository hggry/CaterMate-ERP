<script setup lang="ts">
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import InputNumber from 'primevue/inputnumber'
import { useFormat } from '@/composables/useFormat'
import type { QuotePositionDto } from '@/types/quote'

// Shared by the quote and invoice views. When editable, quantity and unit
// price can be changed; net/VAT/gross stay as last returned by the backend
// until the change is saved (all calculation happens server-side).
defineProps<{ positions: QuotePositionDto[]; editable?: boolean }>()

const { formatCurrency } = useFormat()

function vatPercent(rate: number): string {
  return `${Math.round(rate * 100)} %`
}
</script>

<template>
  <DataTable :value="positions" data-key="menuItemId">
    <template #empty>Keine Positionen.</template>
    <Column field="menuItemName" header="Gericht" />
    <Column header="Menge" style="width: 9rem">
      <template #body="{ data }">
        <InputNumber
          v-if="editable"
          v-model="data.quantity"
          :min="0"
          fluid
        />
        <span v-else>{{ data.quantity }}</span>
      </template>
    </Column>
    <Column header="Einzelpreis" style="width: 11rem">
      <template #body="{ data }">
        <InputNumber
          v-if="editable"
          v-model="data.unitPrice"
          mode="currency"
          currency="EUR"
          locale="de-AT"
          :min="0"
          fluid
        />
        <span v-else>{{ formatCurrency(data.unitPrice) }}</span>
      </template>
    </Column>
    <Column header="Netto">
      <template #body="{ data }">{{ formatCurrency(data.totalNet) }}</template>
    </Column>
    <Column header="USt.-Satz" style="width: 7rem">
      <template #body="{ data }">{{ vatPercent(data.vatRate) }}</template>
    </Column>
    <Column header="USt.">
      <template #body="{ data }">{{ formatCurrency(data.vatAmount) }}</template>
    </Column>
    <Column header="Brutto">
      <template #body="{ data }">{{ formatCurrency(data.totalGross) }}</template>
    </Column>
  </DataTable>
</template>
