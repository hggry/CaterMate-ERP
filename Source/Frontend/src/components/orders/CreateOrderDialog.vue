<script setup lang="ts">
import { reactive, ref, watch } from 'vue'
import Dialog from 'primevue/dialog'
import Button from 'primevue/button'
import OrderForm from './OrderForm.vue'
import { ordersApi } from '@/services/ordersApi'
import { useToast } from '@/composables/useToast'
import { apiErrorMessage } from '@/types/api'
import type { OrderDto } from '@/types/order'
import { emptyOrderForm, validateOrderForm, type OrderFormErrors } from './orderFormSchema'

const visible = defineModel<boolean>('visible', { required: true })
const emit = defineEmits<{ saved: [order: OrderDto] }>()

const toast = useToast()
const saving = ref(false)
const form = reactive(emptyOrderForm())
const errors = ref<OrderFormErrors>({})

watch(visible, (open) => {
  if (open) {
    Object.assign(form, emptyOrderForm())
    errors.value = {}
  }
})

async function onSubmit(): Promise<void> {
  const result = validateOrderForm(form, { requireFutureDate: true })
  errors.value = result.errors
  if (!result.valid || !result.request) return

  saving.value = true
  try {
    const order = await ordersApi.create(result.request)
    toast.success('Auftrag angelegt.')
    visible.value = false
    emit('saved', order)
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <Dialog v-model:visible="visible" header="Neuer Auftrag" modal :style="{ width: '40rem' }">
    <OrderForm :form="form" :errors="errors" />

    <div class="create-order-dialog__actions">
      <Button label="Abbrechen" severity="secondary" text type="button" @click="visible = false" />
      <Button label="Auftrag anlegen" icon="pi pi-save" :loading="saving" @click="onSubmit" />
    </div>
  </Dialog>
</template>

<style scoped>
.create-order-dialog__actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  padding-top: 1rem;
}
</style>
