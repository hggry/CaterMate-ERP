<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Select from 'primevue/select'
import Button from 'primevue/button'
import Message from 'primevue/message'
import { Form, FormField, type FormSubmitEvent } from '@primevue/forms'
import { zodResolver } from '@primevue/forms/resolvers/zod'
import { z } from 'zod'
import BillOfMaterialsEditor from './BillOfMaterialsEditor.vue'
import { menuItemsApi } from '@/services/menuItemsApi'
import { useToast } from '@/composables/useToast'
import { apiErrorMessage } from '@/types/api'
import type {
  BillOfMaterialsItemRequest,
  CreateMenuItemRequest,
  MenuItemDto,
} from '@/types/menuItem'

const visible = defineModel<boolean>('visible', { required: true })
const props = defineProps<{ menuItem: MenuItemDto | null }>()
const emit = defineEmits<{ saved: [] }>()

const toast = useToast()
const saving = ref(false)
const bom = ref<BillOfMaterialsItemRequest[]>([])

const isEdit = computed(() => props.menuItem !== null)

const categoryOptions = [
  'Vorspeise',
  'Hauptgang',
  'Dessert',
  'Getränk',
  'Getränk (alkoholisch)',
]

const schema = z.object({
  name: z.string().min(1, 'Name ist erforderlich.'),
  category: z.string().min(1, 'Kategorie ist erforderlich.'),
  salesPricePerPerson: z
    .number({ message: 'Verkaufspreis ist erforderlich.' })
    .gt(0, 'Verkaufspreis muss größer als 0 sein.'),
  purchaseCostPerPerson: z
    .number({ message: 'Einkaufskosten sind erforderlich.' })
    .min(0, 'Einkaufskosten dürfen nicht negativ sein.'),
  allergens: z.string().nullish(),
})
const resolver = zodResolver(schema)

// The bill of materials is managed outside the Zod-validated form (arrays do
// not map cleanly onto the form resolver). Reset it whenever the dialog opens.
watch(visible, (open) => {
  if (open) {
    bom.value =
      props.menuItem?.billOfMaterials.map((b) => ({
        ingredientId: b.ingredientId,
        quantityPerPerson: b.quantityPerPerson,
      })) ?? []
  }
})

function initialValues(): Record<string, unknown> {
  return {
    name: props.menuItem?.name ?? '',
    category: props.menuItem?.category ?? '',
    salesPricePerPerson: props.menuItem?.salesPricePerPerson ?? 0,
    purchaseCostPerPerson: props.menuItem?.purchaseCostPerPerson ?? 0,
    allergens: props.menuItem?.allergens ?? '',
  }
}

async function onSubmit(event: FormSubmitEvent): Promise<void> {
  if (!event.valid) return
  if (bom.value.some((b) => b.ingredientId === 0)) {
    toast.error('Bitte für jede Stücklisten-Zeile eine Zutat wählen.')
    return
  }
  const values = event.values as {
    name: string
    category: string
    salesPricePerPerson: number
    purchaseCostPerPerson: number
    allergens?: string
  }
  const payload: CreateMenuItemRequest = {
    name: values.name,
    category: values.category,
    salesPricePerPerson: values.salesPricePerPerson,
    purchaseCostPerPerson: values.purchaseCostPerPerson,
    allergens: values.allergens?.trim() ? values.allergens.trim() : undefined,
    billOfMaterials: bom.value,
  }
  saving.value = true
  try {
    if (isEdit.value && props.menuItem) {
      await menuItemsApi.update(props.menuItem.id, payload)
      toast.success('Menüartikel aktualisiert.')
    } else {
      await menuItemsApi.create(payload)
      toast.success('Menüartikel angelegt.')
    }
    visible.value = false
    emit('saved')
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <Dialog
    v-model:visible="visible"
    :header="isEdit ? 'Menüartikel bearbeiten' : 'Neuer Menüartikel'"
    modal
    :style="{ width: '40rem' }"
  >
    <Form
      v-if="visible"
      :resolver="resolver"
      :initial-values="initialValues()"
      class="menu-dialog__form"
      @submit="onSubmit"
    >
      <FormField v-slot="$field" name="name" class="menu-dialog__field">
        <label for="mi-name">Bezeichnung</label>
        <InputText id="mi-name" name="name" fluid />
        <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
          {{ $field.error?.message }}
        </Message>
      </FormField>

      <FormField v-slot="$field" name="category" class="menu-dialog__field">
        <label for="mi-category">Kategorie</label>
        <Select id="mi-category" name="category" :options="categoryOptions" fluid />
        <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
          {{ $field.error?.message }}
        </Message>
      </FormField>

      <div class="menu-dialog__grid">
        <FormField v-slot="$field" name="salesPricePerPerson" class="menu-dialog__field">
          <label for="mi-sales">Verkaufspreis pro Person</label>
          <InputNumber
            input-id="mi-sales"
            name="salesPricePerPerson"
            mode="currency"
            currency="EUR"
            locale="de-AT"
            :min="0"
            fluid
          />
          <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
            {{ $field.error?.message }}
          </Message>
        </FormField>

        <FormField v-slot="$field" name="purchaseCostPerPerson" class="menu-dialog__field">
          <label for="mi-cost">Einkaufskosten pro Person</label>
          <InputNumber
            input-id="mi-cost"
            name="purchaseCostPerPerson"
            mode="currency"
            currency="EUR"
            locale="de-AT"
            :min="0"
            fluid
          />
          <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
            {{ $field.error?.message }}
          </Message>
        </FormField>
      </div>

      <FormField name="allergens" class="menu-dialog__field">
        <label for="mi-allergens">Allergene</label>
        <InputText id="mi-allergens" name="allergens" placeholder="z. B. Gluten, Ei, Milch" fluid />
      </FormField>

      <div class="menu-dialog__field">
        <label>Stückliste</label>
        <BillOfMaterialsEditor v-model="bom" />
      </div>

      <div class="menu-dialog__actions">
        <Button
          label="Abbrechen"
          severity="secondary"
          text
          type="button"
          @click="visible = false"
        />
        <Button label="Speichern" icon="pi pi-save" type="submit" :loading="saving" />
      </div>
    </Form>
  </Dialog>
</template>

<style scoped>
.menu-dialog__form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.menu-dialog__field {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.menu-dialog__grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.menu-dialog__actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}
</style>
