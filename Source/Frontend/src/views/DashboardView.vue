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
const guestValues = computed(() =>
  mapToWindow(monthWindow, data.value?.guestsByMonth ?? [], 'guests'),
)

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

      <Card>
        <template #title>Event-Kalender</template>
        <template #content>
          <EventHeatmap :orders="orders ?? []" />
        </template>
      </Card>

      <div class="dashboard__grid">
        <Card>
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

        <Card>
          <template #title>Gäste pro Monat</template>
          <template #content>
            <MonthlyBarChart
              :labels="monthLabels"
              :values="guestValues"
              label="Personen"
              color="#3b82f6"
            />
          </template>
        </Card>

        <Card>
          <template #title>Pipeline</template>
          <template #content>
            <PipelineFunnel :orders-by-status="data?.ordersByStatus ?? {}" @select="openOrders" />
          </template>
        </Card>

        <Card>
          <template #title>Anstehende Events</template>
          <template #content>
            <UpcomingEvents :orders="orders ?? []" @select="openOrder" />
          </template>
        </Card>

        <Card class="dashboard__wide">
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
      </div>
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

.dashboard__grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 24rem), 1fr));
  gap: 1rem;
  align-items: start;
}

/* Span the full row when the grid has two columns. */
.dashboard__wide {
  grid-column: 1 / -1;
}

@media (max-width: 640px) {
  .dashboard__grid {
    grid-template-columns: 1fr;
  }
}
</style>
