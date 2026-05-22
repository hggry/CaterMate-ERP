<script setup lang="ts">
import { onMounted, ref } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Button from 'primevue/button'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import { useConfirm } from 'primevue/useconfirm'
import MenuItemDialog from '@/components/masterdata/MenuItemDialog.vue'
import { menuItemsApi } from '@/services/menuItemsApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import { useToast } from '@/composables/useToast'
import { apiErrorMessage } from '@/types/api'
import type { MenuItemDto } from '@/types/menuItem'

const { data: menuItems, loading, error, execute } = useApi(menuItemsApi.list)
const { formatCurrency } = useFormat()
const toast = useToast()
const confirm = useConfirm()

const dialogVisible = ref(false)
const editing = ref<MenuItemDto | null>(null)

onMounted(() => execute())

function openCreate(): void {
  editing.value = null
  dialogVisible.value = true
}

async function openEdit(item: MenuItemDto): Promise<void> {
  try {
    // Fetch the full item so the bill of materials is populated.
    editing.value = await menuItemsApi.getById(item.id)
    dialogVisible.value = true
  } catch (e) {
    toast.error(apiErrorMessage(e))
  }
}

function confirmDelete(item: MenuItemDto): void {
  confirm.require({
    header: 'Löschen bestätigen',
    message: `Menüartikel „${item.name}" wirklich löschen?`,
    icon: 'pi pi-exclamation-triangle',
    acceptLabel: 'Löschen',
    rejectLabel: 'Abbrechen',
    acceptProps: { severity: 'danger' },
    accept: async () => {
      try {
        await menuItemsApi.remove(item.id)
        toast.success('Menüartikel gelöscht.')
        execute()
      } catch (e) {
        toast.error(apiErrorMessage(e))
      }
    },
  })
}

function onSaved(): void {
  execute()
}
</script>

<template>
  <div class="menu-items-view">
    <header class="menu-items-view__header">
      <h1>Menüartikel</h1>
      <Button label="Neuer Menüartikel" icon="pi pi-plus" @click="openCreate" />
    </header>

    <Message v-if="error" severity="error" :closable="false">
      Menüartikel konnten nicht geladen werden.
    </Message>

    <div v-if="loading" class="menu-items-view__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <DataTable v-else :value="menuItems ?? []" paginator :rows="15" data-key="id">
      <template #empty>Keine Menüartikel vorhanden.</template>
      <Column field="name" header="Bezeichnung" />
      <Column field="category" header="Kategorie" style="width: 12rem" />
      <Column header="VK-Preis/Person" style="width: 11rem">
        <template #body="{ data }">{{ formatCurrency(data.salesPricePerPerson) }}</template>
      </Column>
      <Column header="EK-Kosten/Person" style="width: 11rem">
        <template #body="{ data }">{{ formatCurrency(data.purchaseCostPerPerson) }}</template>
      </Column>
      <Column header="Allergene">
        <template #body="{ data }">{{ data.allergens || '—' }}</template>
      </Column>
      <Column style="width: 8rem">
        <template #body="{ data }">
          <Button
            icon="pi pi-pencil"
            severity="secondary"
            text
            rounded
            aria-label="Bearbeiten"
            @click="openEdit(data)"
          />
          <Button
            icon="pi pi-trash"
            severity="danger"
            text
            rounded
            aria-label="Löschen"
            @click="confirmDelete(data)"
          />
        </template>
      </Column>
    </DataTable>

    <MenuItemDialog
      v-model:visible="dialogVisible"
      :menu-item="editing"
      @saved="onSaved"
    />
  </div>
</template>

<style scoped>
.menu-items-view__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.menu-items-view__header h1 {
  margin: 0;
}

.menu-items-view__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}
</style>
