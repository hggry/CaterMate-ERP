<script setup lang="ts">
import { computed, onMounted, provide, ref } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import Button from 'primevue/button'
import ProgressSpinner from 'primevue/progressspinner'
import Message from 'primevue/message'
import { useConfirm } from 'primevue/useconfirm'
import StatusTag from '@/components/common/StatusTag.vue'
import OrderStatusStepper from '@/components/orders/OrderStatusStepper.vue'
import { ordersApi } from '@/services/ordersApi'
import { quotesApi } from '@/services/quotesApi'
import { useOrderStatus, type OrderAction } from '@/composables/useOrderStatus'
import { useToast } from '@/composables/useToast'
import { ORDER_CONTEXT } from '@/composables/useOrderContext'
import { apiErrorMessage } from '@/types/api'
import type { OrderDto, OrderStatus } from '@/types/order'

const props = defineProps<{ id: string }>()
const orderId = Number(props.id)

const route = useRoute()
const router = useRouter()
const confirm = useConfirm()
const toast = useToast()
const { indexOf, primaryActionFor, tabForStatus, labelFor, isCancelled } = useOrderStatus()

const order = ref<OrderDto | null>(null)
const loading = ref(false)
const loadError = ref(false)
const busy = ref(false)

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

const primaryAction = computed<OrderAction | null>(() => {
  if (!order.value) return null
  const o = order.value
  // A new order needs a menu before it can be qualified — guide the user to the
  // Menü tab first; only once dishes are assigned does "Als geprüft markieren" appear.
  if (o.status === 'Neu' && o.assignedMenuItems.length === 0) {
    return { label: 'Menü zusammenstellen', kind: 'navigate', targetRoute: 'order-menu', icon: 'pi pi-book' }
  }
  return primaryActionFor(o.status)
})

// Navigate actions are hidden once the user is already on the target tab.
const showPrimaryAction = computed(() => {
  const action = primaryAction.value
  if (!action) return false
  if (order.value && isCancelled(order.value.status)) return false
  if (action.kind === 'navigate' || action.kind === 'create-quote') return route.name !== action.targetRoute
  return true
})

// Reopen: released/confirmed offer or a cancelled order back to editable 'Geprüft'.
const REOPENABLE = ['AngebotErstellt', 'InBeschaffung', 'Storniert']
const canReopen = computed(() => !!order.value && REOPENABLE.includes(order.value.status))

// Cancel: any open phase up to and including preparation.
const CANCELLABLE = ['Neu', 'Geprüft', 'AngebotErstellt', 'Bestätigt', 'InBeschaffung', 'InVorbereitung']
const canCancel = computed(() => !!order.value && CANCELLABLE.includes(order.value.status))

async function runStatusChange(targetStatus: OrderStatus): Promise<void> {
  busy.value = true
  try {
    await ordersApi.update(orderId, { status: targetStatus })
    await reload()
    if (order.value) {
      router.push({ name: tabForStatus(order.value.status), params: { id: props.id } })
      toast.success(`Auftrag ist jetzt: ${labelFor(order.value.status)}`)
    }
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    busy.value = false
  }
}

async function createQuoteAndNavigate(targetRoute: string): Promise<void> {
  busy.value = true
  try {
    await quotesApi.create(orderId)
    toast.success('Angebot wurde erstellt.')
    router.push({ name: targetRoute, params: { id: props.id } })
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    busy.value = false
  }
}

function executeAction(action: OrderAction): void {
  if (action.kind === 'navigate' && action.targetRoute) {
    router.push({ name: action.targetRoute, params: { id: props.id } })
    return
  }
  if (action.kind === 'create-quote' && action.targetRoute) {
    createQuoteAndNavigate(action.targetRoute)
    return
  }
  if (action.kind === 'status' && action.targetStatus) {
    const target = action.targetStatus
    if (action.confirm) {
      confirm.require({
        message: action.confirm,
        header: 'Bestätigung',
        icon: 'pi pi-exclamation-triangle',
        accept: () => runStatusChange(target),
      })
    } else {
      runStatusChange(target)
    }
  }
}

function confirmDelete(): void {
  confirm.require({
    message: `Auftrag #${orderId} wirklich löschen? Dies kann nicht rückgängig gemacht werden.`,
    header: 'Auftrag löschen',
    icon: 'pi pi-trash',
    acceptProps: { label: 'Löschen', severity: 'danger' },
    rejectProps: { label: 'Abbrechen', severity: 'secondary', outlined: true },
    accept: async () => {
      busy.value = true
      try {
        await ordersApi.remove(orderId)
        toast.success('Auftrag gelöscht.')
        router.push({ name: 'orders' })
      } catch (e) {
        toast.error(apiErrorMessage(e))
      } finally {
        busy.value = false
      }
    },
  })
}

function confirmReopen(): void {
  confirm.require({
    message:
      'Auftrag wieder auf „Geprüft" öffnen? Menü und Stammdaten werden wieder bearbeitbar. Das bestehende Angebot bleibt erhalten und wird beim erneuten Generieren überschrieben.',
    header: 'Auftrag wiedereröffnen',
    icon: 'pi pi-undo',
    accept: async () => {
      busy.value = true
      try {
        await ordersApi.reopen(orderId)
        await reload()
        toast.success('Auftrag wurde wiedereröffnet.')
      } catch (e) {
        toast.error(apiErrorMessage(e))
      } finally {
        busy.value = false
      }
    },
  })
}

function confirmCancel(): void {
  confirm.require({
    message: 'Auftrag wirklich stornieren? Er wird aus der aktiven Liste ausgeblendet, kann aber wiedereröffnet werden.',
    header: 'Auftrag stornieren',
    icon: 'pi pi-ban',
    acceptProps: { label: 'Stornieren', severity: 'danger' },
    rejectProps: { label: 'Abbrechen', severity: 'secondary', outlined: true },
    accept: async () => {
      busy.value = true
      try {
        await ordersApi.cancel(orderId)
        await reload()
        toast.success('Auftrag wurde storniert.')
      } catch (e) {
        toast.error(apiErrorMessage(e))
      } finally {
        busy.value = false
      }
    },
  })
}

interface TabDef {
  label: string
  routeName: string
  minStatusIndex: number
}

const tabs: TabDef[] = [
  { label: 'Übersicht', routeName: 'order-detail', minStatusIndex: 0 },
  { label: 'Menü', routeName: 'order-menu', minStatusIndex: 0 },
  { label: 'Angebot', routeName: 'order-quote', minStatusIndex: indexOf('Geprüft') },
  { label: 'Einkaufsliste', routeName: 'order-purchase-list', minStatusIndex: indexOf('AngebotErstellt') },
  { label: 'Rechnung', routeName: 'order-invoice', minStatusIndex: indexOf('Durchgeführt') },
]

function tabEnabled(tab: TabDef): boolean {
  // Cancelled orders (statusIndex -1) keep the always-on tabs (Übersicht, Menü) readable.
  if (order.value && isCancelled(order.value.status)) return tab.minStatusIndex === 0
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
        <div class="order-detail__title">
          <h1>Auftrag #{{ order.id }} — {{ order.customerName }}</h1>
          <StatusTag :status="order.status" />
        </div>
        <div class="order-detail__actions">
          <Button
            v-if="order.status === 'Neu'"
            label="Löschen"
            icon="pi pi-trash"
            severity="danger"
            text
            :disabled="busy"
            @click="confirmDelete"
          />
          <Button
            v-if="canCancel"
            label="Stornieren"
            icon="pi pi-ban"
            severity="danger"
            text
            :disabled="busy"
            @click="confirmCancel"
          />
          <Button
            v-if="canReopen"
            label="Wiedereröffnen"
            icon="pi pi-undo"
            severity="secondary"
            outlined
            :loading="busy"
            @click="confirmReopen"
          />
          <Button
            v-if="showPrimaryAction && primaryAction"
            :label="primaryAction.label"
            :icon="primaryAction.icon"
            :loading="busy"
            @click="executeAction(primaryAction)"
          />
        </div>
      </header>

      <OrderStatusStepper :status="order.status" />

      <nav class="order-tabs">
        <template v-for="tab in tabs" :key="tab.routeName">
          <RouterLink
            v-if="tabEnabled(tab)"
            :to="{ name: tab.routeName, params: { id: props.id } }"
            class="order-tabs__tab"
            exact-active-class="order-tabs__tab--active"
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
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
}

.order-detail__title {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.order-detail__title h1 {
  margin: 0;
  font-size: 1.5rem;
}

.order-detail__actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
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
