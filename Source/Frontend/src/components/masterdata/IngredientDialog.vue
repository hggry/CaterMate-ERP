<script setup lang="ts">
import { computed, ref } from 'vue'
import Dialog from 'primevue/dialog'
import InputText from 'primevue/inputtext'
import InputNumber from 'primevue/inputnumber'
import Select from 'primevue/select'
import Button from 'primevue/button'
import Message from 'primevue/message'
import { Form, FormField, type FormSubmitEvent } from '@primevue/forms'
import { zodResolver } from '@primevue/forms/resolvers/zod'
import { z } from 'zod'
import { ingredientsApi } from '@/services/ingredientsApi'
import { useToast } from '@/composables/useToast'
import { apiErrorMessage } from '@/types/api'
import type { CreateIngredientRequest, IngredientDto } from '@/types/ingredient'

const visible = defineModel<boolean>('visible', { required: true })
const props = defineProps<{ ingredient: IngredientDto | null }>()
const emit = defineEmits<{ saved: [] }>()

const toast = useToast()
const saving = ref(false)

const isEdit = computed(() => props.ingredient !== null)

const unitOptions = ['g', 'ml', 'Stück', 'kg', 'l', 'Packung']

const schema = z.object({
  name: z.string().min(1, 'Name ist erforderlich.'),
  unit: z.string().min(1, 'Einheit ist erforderlich.'),
  purchasePricePerUnit: z
    .number({ message: 'Einkaufspreis ist erforderlich.' })
    .min(0, 'Preis darf nicht negativ sein.'),
  category: z.string().nullish(),
})
const resolver = zodResolver(schema)

function initialValues(): Record<string, unknown> {
  return {
    name: props.ingredient?.name ?? '',
    unit: props.ingredient?.unit ?? 'g',
    purchasePricePerUnit: props.ingredient?.purchasePricePerUnit ?? 0,
    category: props.ingredient?.category ?? '',
  }
}

async function onSubmit(event: FormSubmitEvent): Promise<void> {
  if (!event.valid) return
  const values = event.values as {
    name: string
    unit: string
    purchasePricePerUnit: number
    category?: string
  }
  const payload: CreateIngredientRequest = {
    name: values.name,
    unit: values.unit,
    purchasePricePerUnit: values.purchasePricePerUnit,
    category: values.category?.trim() ? values.category.trim() : undefined,
  }
  saving.value = true
  try {
    if (isEdit.value && props.ingredient) {
      await ingredientsApi.update(props.ingredient.id, payload)
      toast.success('Zutat aktualisiert.')
    } else {
      await ingredientsApi.create(payload)
      toast.success('Zutat angelegt.')
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
    :header="isEdit ? 'Zutat bearbeiten' : 'Neue Zutat'"
    modal
    :style="{ width: '28rem' }"
    :breakpoints="{ '767px': '95vw' }"
  >
    <Form
      v-if="visible"
      :resolver="resolver"
      :initial-values="initialValues()"
      class="ingredient-dialog__form"
      @submit="onSubmit"
    >
      <FormField v-slot="$field" name="name" class="ingredient-dialog__field">
        <label for="ing-name">Name</label>
        <InputText id="ing-name" name="name" fluid />
        <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
          {{ $field.error?.message }}
        </Message>
      </FormField>

      <FormField v-slot="$field" name="unit" class="ingredient-dialog__field">
        <label for="ing-unit">Einheit</label>
        <Select id="ing-unit" name="unit" :options="unitOptions" fluid />
        <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
          {{ $field.error?.message }}
        </Message>
      </FormField>

      <FormField v-slot="$field" name="purchasePricePerUnit" class="ingredient-dialog__field">
        <label for="ing-price">Einkaufspreis pro Einheit</label>
        <InputNumber
          input-id="ing-price"
          name="purchasePricePerUnit"
          mode="currency"
          currency="EUR"
          locale="de-AT"
          :min-fraction-digits="2"
          :max-fraction-digits="4"
          :min="0"
          fluid
        />
        <Message v-if="$field?.invalid" severity="error" size="small" variant="simple">
          {{ $field.error?.message }}
        </Message>
      </FormField>

      <FormField name="category" class="ingredient-dialog__field">
        <label for="ing-category">Warengruppe</label>
        <InputText id="ing-category" name="category" fluid />
      </FormField>

      <div class="ingredient-dialog__actions">
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
.ingredient-dialog__form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.ingredient-dialog__field {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.ingredient-dialog__actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}
</style>
