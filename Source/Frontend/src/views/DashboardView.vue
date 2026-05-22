<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Chart from 'primevue/chart'
import Card from 'primevue/card'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import { dashboardApi } from '@/services/dashboardApi'
import { useApi } from '@/composables/useApi'
import { useFormat } from '@/composables/useFormat'
import { useOrderStatus } from '@/composables/useOrderStatus'
import { ORDER_STATUSES, type OrderStatus } from '@/types/order'

const router = useRouter()
const { formatCurrency } = useFormat()
const { labelFor } = useOrderStatus()

const { data, loading, error, execute } = useApi(dashboardApi.get)

onMounted(() => execute())

const kpis = computed(() =>
  ORDER_STATUSES.map((status) => ({
    status,
    label: labelFor(status),
    count: data.value?.ordersByStatus[status] ?? 0,
  })),
)

const chartData = computed(() => ({
  labels: data.value?.revenueByMonth.map((m) => m.month) ?? [],
  datasets: [
    {
      label: 'Umsatz (Brutto)',
      data: data.value?.revenueByMonth.map((m) => m.totalGross) ?? [],
      backgroundColor: '#7aaa28',
    },
  ],
}))

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false } },
}

function openOrders(status: OrderStatus): void {
  router.push({ name: 'orders', query: { status } })
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
      <section class="dashboard__kpis">
        <button
          v-for="kpi in kpis"
          :key="kpi.status"
          type="button"
          class="dashboard__kpi"
          @click="openOrders(kpi.status)"
        >
          <span class="dashboard__kpi-count">{{ kpi.count }}</span>
          <span class="dashboard__kpi-label">{{ kpi.label }}</span>
        </button>
      </section>

      <div class="dashboard__grid">
        <Card>
          <template #title>Umsatz pro Monat</template>
          <template #content>
            <div v-if="data && data.revenueByMonth.length" class="dashboard__chart">
              <Chart type="bar" :data="chartData" :options="chartOptions" />
            </div>
            <p v-else class="dashboard__placeholder">Keine Umsatzdaten vorhanden.</p>
          </template>
        </Card>

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

.dashboard__kpis {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(10rem, 1fr));
  gap: 0.75rem;
}

.dashboard__kpi {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  padding: 1rem;
  border: 1px solid var(--p-content-border-color);
  border-radius: var(--p-border-radius, 6px);
  background: var(--p-content-background);
  cursor: pointer;
  text-align: left;
}

.dashboard__kpi:hover {
  border-color: var(--p-primary-color);
}

.dashboard__kpi-count {
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--p-primary-color);
}

.dashboard__kpi-label {
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

.dashboard__grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(22rem, 1fr));
  gap: 1rem;
  align-items: start;
}

.dashboard__chart {
  height: 18rem;
}

.dashboard__placeholder {
  margin: 0;
  color: var(--p-text-muted-color);
}
</style>
