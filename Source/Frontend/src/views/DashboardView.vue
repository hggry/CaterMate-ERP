<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Card from 'primevue/card'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import StatusKpis from '@/components/dashboard/StatusKpis.vue'
import KpiCards from '@/components/dashboard/KpiCards.vue'
import MonthlyBarChart from '@/components/dashboard/MonthlyBarChart.vue'
import PipelineFunnel from '@/components/dashboard/PipelineFunnel.vue'
import UpcomingEvents from '@/components/dashboard/UpcomingEvents.vue'
import EventHeatmap from '@/components/dashboard/EventHeatmap.vue'
import { dashboardApi } from '@/services/dashboardApi'
import { ordersApi } from '@/services/ordersApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import { useMonthWindow } from '@/composables/useMonthWindow'
import type { OrderStatus } from '@/types/order'

const router = useRouter()
const { formatCurrency } = useFormat()
const { buildMonthWindow, mapToWindow } = useMonthWindow()

const { data, loading, error, execute } = useApi(dashboardApi.get)
const { data: orders, execute: loadOrders } = useApi(ordersApi.list)

onMounted(() => {
  execute()
  loadOrders({})
})

// Fixed 12-month window (10 past + current + next) so months stay comparable.
const monthWindow = buildMonthWindow(10, 1)
const monthLabels = monthWindow.map((b) => b.label)
const revenueValues = computed(() =>
  mapToWindow(monthWindow, data.value?.revenueByMonth ?? [], 'totalGross'),
)
const personValues = computed(() =>
  mapToWindow(monthWindow, data.value?.guestsByMonth ?? [], 'guests'),
)

// Cancelled orders are excluded from the calendar and upcoming-events widgets.
const activeOrders = computed(() => (orders.value ?? []).filter((o) => o.status !== 'Storniert'))

function openOrders(status: OrderStatus): void {
  router.push({ name: 'orders', query: { status } })
}

function openOrder(orderId: number): void {
  router.push({ name: 'order-detail', params: { id: String(orderId) } })
}
</script>

<template>
  <div class="dashboard">
    <h1>Dashboard</h1>

    <Message v-if="error" severity="error" :closable="false">
      Dashboard-Daten konnten nicht geladen werden.
    </Message>

    <div v-if="loading" class="dashboard__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <template v-else>
      <KpiCards :kpis="data?.kpis" />

      <StatusKpis :orders-by-status="data?.ordersByStatus ?? {}" @select="openOrders" />

      <!-- Equal-height row: both charts and the pipeline share the same height. -->
      <div class="dashboard__charts">
        <Card class="dashboard__panel">
          <template #title>Umsatz pro Monat</template>
          <template #content>
            <MonthlyBarChart
              :labels="monthLabels"
              :values="revenueValues"
              label="Umsatz (Brutto)"
              :value-formatter="formatCurrency"
            />
          </template>
        </Card>

        <Card class="dashboard__panel">
          <template #title>Personen pro Monat</template>
          <template #content>
            <MonthlyBarChart
              :labels="monthLabels"
              :values="personValues"
              label="Personen"
              color="#20a090"
            />
          </template>
        </Card>

        <Card class="dashboard__panel">
          <template #title>Pipeline (offen)</template>
          <template #content>
            <PipelineFunnel :orders-by-status="data?.ordersByStatus ?? {}" @select="openOrders" />
          </template>
        </Card>
      </div>

      <div class="dashboard__row">
        <Card>
          <template #title>Event-Kalender</template>
          <template #content>
            <EventHeatmap :orders="activeOrders" :weeks="24" />
          </template>
        </Card>

        <Card>
          <template #title>Anstehende Events</template>
          <template #content>
            <UpcomingEvents :orders="activeOrders" :limit="4" @select="openOrder" />
          </template>
        </Card>
      </div>

      <Card>
        <template #title>Top-Kunden</template>
        <template #content>
          <DataTable :value="data?.topCustomers ?? []" data-key="customerName">
            <template #empty>Keine Daten vorhanden.</template>
            <Column field="customerName" header="Kunde" />
            <Column field="orderCount" header="Aufträge" style="width: 8rem" />
            <Column header="Umsatz">
              <template #body="{ data: row }">{{ formatCurrency(row.totalRevenue) }}</template>
            </Column>
          </DataTable>
        </template>
      </Card>
    </template>
  </div>
</template>

<style scoped>
.dashboard {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.dashboard h1 {
  margin: 0;
}

.dashboard__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}

/* Three equal-height panels: revenue chart, persons chart, pipeline. */
.dashboard__charts {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
  grid-auto-rows: 22rem;
}

.dashboard__panel {
  height: 100%;
}

.dashboard__panel :deep(.p-card-body) {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.dashboard__panel :deep(.p-card-content) {
  flex: 1;
  min-height: 0;
}

/* Heatmap + upcoming events: same height, heatmap fills available width. */
.dashboard__row {
  display: grid;
  grid-template-columns: 3fr 2fr;
  gap: 1rem;
  align-items: stretch;
}

.dashboard__row :deep(.p-card) {
  height: 100%;
}

.dashboard__row :deep(.p-card-body) {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.dashboard__row :deep(.p-card-content) {
  flex: 1;
  min-height: 0;
}

@media (max-width: 1100px) {
  .dashboard__charts {
    grid-template-columns: 1fr;
    grid-auto-rows: 20rem;
  }
}

@media (max-width: 900px) {
  .dashboard__row {
    grid-template-columns: 1fr;
  }
}
</style>
