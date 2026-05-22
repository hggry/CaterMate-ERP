<script setup lang="ts">
import { computed, onMounted, provide, ref } from 'vue'
import { RouterLink, RouterView, useRouter } from 'vue-router'
import Button from 'primevue/button'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import StatusTag from '@/components/common/StatusTag.vue'
import { ordersApi } from '@/services/ordersApi'
import { useOrderStatus } from '@/composables/useOrderStatus'
import { ORDER_CONTEXT } from '@/composables/useOrderContext'
import type { OrderDto } from '@/types/order'

const props = defineProps<{ id: string }>()
const orderId = Number(props.id)

const router = useRouter()
const { indexOf } = useOrderStatus()

const order = ref<OrderDto | null>(null)
const loading = ref(false)
const loadError = ref(false)

async function reload(): Promise<void> {
  loading.value = true
  loadError.value = false
  try {
    order.value = await ordersApi.getById(orderId)
  } catch {
    loadError.value = true
  } finally {
    loading.value = false
  }
}

onMounted(reload)

provide(ORDER_CONTEXT, { order, orderId, reload })

const statusIndex = computed(() => (order.value ? indexOf(order.value.status) : -1))

interface TabDef {
  label: string
  routeName: string
  minStatusIndex: number
}

const tabs: TabDef[] = [
  { label: 'Übersicht', routeName: 'order-detail', minStatusIndex: 0 },
  { label: 'Angebot', routeName: 'order-quote', minStatusIndex: indexOf('Geprüft') },
  { label: 'Einkaufsliste', routeName: 'order-purchase-list', minStatusIndex: indexOf('AngebotErstellt') },
  { label: 'Rechnung', routeName: 'order-invoice', minStatusIndex: indexOf('Durchgeführt') },
]

function tabEnabled(tab: TabDef): boolean {
  return statusIndex.value >= tab.minStatusIndex
}
</script>

<template>
  <div class="order-detail">
    <Button
      label="Zurück zur Liste"
      icon="pi pi-arrow-left"
      severity="secondary"
      text
      @click="router.push({ name: 'orders' })"
    />

    <div v-if="loading && !order" class="order-detail__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <Message v-else-if="loadError || !order" severity="error" :closable="false">
      Auftrag konnte nicht geladen werden.
    </Message>

    <template v-else>
      <header class="order-detail__header">
        <h1>Auftrag #{{ order.id }} — {{ order.customerName }}</h1>
        <StatusTag :status="order.status" />
      </header>

      <nav class="order-tabs">
        <template v-for="tab in tabs" :key="tab.routeName">
          <RouterLink
            v-if="tabEnabled(tab)"
            :to="{ name: tab.routeName, params: { id: props.id } }"
            class="order-tabs__tab"
            active-class="order-tabs__tab--active"
          >
            {{ tab.label }}
          </RouterLink>
          <span v-else class="order-tabs__tab order-tabs__tab--disabled">
            {{ tab.label }}
          </span>
        </template>
      </nav>

      <RouterView />
    </template>
  </div>
</template>

<style scoped>
.order-detail {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.order-detail__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}

.order-detail__header {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.order-detail__header h1 {
  margin: 0;
  font-size: 1.5rem;
}

.order-tabs {
  display: flex;
  gap: 0.25rem;
  border-bottom: 1px solid var(--p-content-border-color);
}

.order-tabs__tab {
  padding: 0.625rem 1rem;
  text-decoration: none;
  color: var(--p-text-color);
  border-bottom: 2px solid transparent;
}

.order-tabs__tab--active {
  color: var(--p-primary-color);
  border-bottom-color: var(--p-primary-color);
  font-weight: 600;
}

.order-tabs__tab--disabled {
  color: var(--p-text-muted-color);
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
