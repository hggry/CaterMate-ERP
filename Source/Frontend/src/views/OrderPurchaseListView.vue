<script setup lang="ts">
import { onMounted, ref } from 'vue'
import Button from 'primevue/button'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import PurchaseGroup from '@/components/purchase/PurchaseGroup.vue'
import { purchaseListApi } from '@/services/purchaseListApi'
import { useToast } from '@/composables/useToast'
import { useOrderContext } from '@/composables/useOrderContext'
import { ApiError, apiErrorMessage } from '@/types/api'
import type { PurchaseListDto } from '@/types/purchaseList'

const { orderId } = useOrderContext()
const toast = useToast()

const list = ref<PurchaseListDto | null>(null)
const loading = ref(false)
const loadError = ref(false)

async function loadList(): Promise<void> {
  loading.value = true
  loadError.value = false
  try {
    list.value = await purchaseListApi.get(orderId)
  } catch (e) {
    if (e instanceof ApiError && e.status === 404) {
      list.value = null
    } else {
      loadError.value = true
    }
  } finally {
    loading.value = false
  }
}

onMounted(loadList)

async function onToggle(itemId: number, isDone: boolean): Promise<void> {
  try {
    await purchaseListApi.updateItem(itemId, isDone)
    for (const group of list.value?.groups ?? []) {
      const item = group.items.find((i) => i.id === itemId)
      if (item) item.isDone = isDone
    }
  } catch (e) {
    toast.error(apiErrorMessage(e))
  }
}

async function downloadPdf(): Promise<void> {
  try {
    await purchaseListApi.downloadPdf(orderId)
  } catch (e) {
    toast.error(apiErrorMessage(e))
  }
}
</script>

<template>
  <div class="purchase-view">
    <div v-if="loading" class="purchase-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <Message v-else-if="loadError" severity="error" :closable="false">
      Einkaufsliste konnte nicht geladen werden.
    </Message>

    <Message v-else-if="!list" severity="info" :closable="false">
      Die Einkaufsliste wird erstellt, sobald der Auftrag bestätigt ist.
    </Message>

    <template v-else>
      <div class="purchase-view__groups">
        <PurchaseGroup
          v-for="group in list.groups"
          :key="group.category"
          :group="group"
          @toggle="onToggle"
        />
      </div>
      <div class="purchase-view__actions">
        <Button
          label="Einkaufsliste herunterladen"
          icon="pi pi-download"
          severity="secondary"
          outlined
          @click="downloadPdf"
        />
      </div>
    </template>
  </div>
</template>

<style scoped>
.purchase-view {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.purchase-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}

.purchase-view__groups {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.purchase-view__actions {
  display: flex;
  justify-content: flex-end;
}
</style>
