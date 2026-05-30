<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue'
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Select from 'primevue/select'
import ToggleButton from 'primevue/togglebutton'
import Message from 'primevue/message'
import ProgressSpinner from 'primevue/progressspinner'
import { ordersApi } from '@/services/ordersApi'
import { menuItemsApi } from '@/services/menuItemsApi'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import { useFormat } from '@/composables/useFormat'
import { useOrderStatus } from '@/composables/useOrderStatus'
import { useOrderContext } from '@/composables/useOrderContext'
import { apiErrorMessage } from '@/types/api'
import type { MenuItemDto } from '@/types/menuItem'

const { order, orderId, reload } = useOrderContext()
const toast = useToast()
const { formatCurrency } = useFormat()
const { indexOf } = useOrderStatus()

const { data: catalog, loading, error, execute } = useApi(menuItemsApi.list)
onMounted(() => execute())

const menuBusy = ref(false)
const search = ref('')
const categoryFilter = ref<string | null>(null)
const hideUnsuitable = ref(false)

// Editing is locked once the offer is released (mirrors OrderOverviewView).
const locked = computed(() =>
  order.value ? indexOf(order.value.status) >= indexOf('AngebotErstellt') : false,
)

const guestCount = computed(() => order.value?.guestCount ?? 0)
const assignedIds = computed(() => order.value?.assignedMenuItems.map((m) => m.id) ?? [])

// Course ordering for grouping both catalog and menu card.
const COURSE_ORDER = ['Vorspeise', 'Hauptgang', 'Dessert', 'Beilage', 'Getränk', 'Getränk (alkoholisch)']
function courseRank(category: string): number {
  const i = COURSE_ORDER.indexOf(category)
  return i === -1 ? COURSE_ORDER.length : i
}

const categoryOptions = computed(() => {
  const cats = [...new Set((catalog.value ?? []).map((m) => m.category))]
  return cats.sort((a, b) => courseRank(a) - courseRank(b)).map((c) => ({ label: c, value: c }))
})

// Allergen tokens of the order, for the suitability check.
const orderAllergens = computed(() =>
  (order.value?.allergies ?? '')
    .split(/[,;]+|\s+/)
    .map((a) => a.trim().toLowerCase())
    .filter(Boolean),
)

function allergenConflict(item: MenuItemDto): boolean {
  if (!item.allergens || orderAllergens.value.length === 0) return false
  const itemTokens = item.allergens
    .split(/[,;]+|\s+/)
    .map((a) => a.trim().toLowerCase())
    .filter(Boolean)
  return orderAllergens.value.some((a) => itemTokens.includes(a))
}

// A single-dish menu of this item already exceeds the customer's budget.
function overBudget(item: MenuItemDto): boolean {
  return order.value?.budget != null && item.salesPricePerPerson * guestCount.value > order.value.budget
}

function isUnsuitable(item: MenuItemDto): boolean {
  return allergenConflict(item) || overBudget(item)
}

function unsuitableReason(item: MenuItemDto): string {
  const reasons: string[] = []
  if (allergenConflict(item)) reasons.push('Allergen-Konflikt')
  if (overBudget(item)) reasons.push('über Budget')
  return reasons.join(' · ')
}

const filteredCatalog = computed(() => {
  const q = search.value.toLowerCase().trim()
  return (catalog.value ?? []).filter((item) => {
    if (categoryFilter.value && item.category !== categoryFilter.value) return false
    if (hideUnsuitable.value && isUnsuitable(item)) return false
    if (!q) return true
    return item.name.toLowerCase().includes(q) || item.category.toLowerCase().includes(q)
  })
})

// Catalog grouped by course for structured browsing.
const groupedCatalog = computed(() => {
  const groups = new Map<string, MenuItemDto[]>()
  for (const item of filteredCatalog.value) {
    const list = groups.get(item.category) ?? []
    list.push(item)
    groups.set(item.category, list)
  }
  return [...groups.entries()]
    .sort((a, b) => courseRank(a[0]) - courseRank(b[0]))
    .map(([category, items]) => ({ category, items }))
})

// Selected items resolved against the catalog (gives purchaseCost for the margin).
const selectedItems = computed(() =>
  (catalog.value ?? []).filter((m) => assignedIds.value.includes(m.id)),
)

const groupedSelection = computed(() => {
  const groups = new Map<string, MenuItemDto[]>()
  for (const item of selectedItems.value) {
    const list = groups.get(item.category) ?? []
    list.push(item)
    groups.set(item.category, list)
  }
  return [...groups.entries()]
    .sort((a, b) => courseRank(a[0]) - courseRank(b[0]))
    .map(([category, items]) => ({ category, items }))
})

const netValue = computed(() =>
  selectedItems.value.reduce((sum, m) => sum + m.salesPricePerPerson * guestCount.value, 0),
)
const contributionMargin = computed(() =>
  selectedItems.value.reduce(
    (sum, m) => sum + (m.salesPricePerPerson - m.purchaseCostPerPerson) * guestCount.value,
    0,
  ),
)
const budget = computed(() => order.value?.budget ?? null)
const budgetDelta = computed(() => (budget.value != null ? budget.value - netValue.value : null))

async function setMenuItems(ids: number[]): Promise<void> {
  menuBusy.value = true
  try {
    await ordersApi.update(orderId, { assignedMenuItemIds: ids })
    await reload()
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    menuBusy.value = false
  }
}

function toggle(id: number): void {
  if (locked.value || menuBusy.value) return
  const ids = assignedIds.value.includes(id)
    ? assignedIds.value.filter((x) => x !== id)
    : [...assignedIds.value, id]
  void setMenuItems(ids)
}

watch(categoryOptions, () => {
  if (categoryFilter.value && !categoryOptions.value.some((o) => o.value === categoryFilter.value)) {
    categoryFilter.value = null
  }
})
</script>

<template>
  <div v-if="order" class="menu-view">
    <Message v-if="locked" severity="info" :closable="false">
      Auftrag ist freigegeben — die Menüzusammenstellung ist gesperrt.
    </Message>

    <div class="menu-view__grid">
      <!-- Catalog -->
      <section class="menu-view__catalog">
        <div class="menu-view__filters">
          <InputText v-model="search" placeholder="Gericht suchen…" fluid />
          <Select
            v-model="categoryFilter"
            :options="categoryOptions"
            option-label="label"
            option-value="value"
            placeholder="Alle Gänge"
            show-clear
          />
          <ToggleButton
            v-model="hideUnsuitable"
            on-label="Ungeeignete aus"
            off-label="Ungeeignete an"
            on-icon="pi pi-filter-slash"
            off-icon="pi pi-filter"
          />
        </div>

        <div v-if="loading" class="menu-view__center">
          <ProgressSpinner style="width: 2rem; height: 2rem" />
        </div>
        <Message v-else-if="error" severity="error" :closable="false">
          Menüartikel konnten nicht geladen werden.
        </Message>
        <div v-else class="menu-view__catalog-list">
          <p v-if="groupedCatalog.length === 0" class="menu-view__empty">Kein Treffer.</p>
          <template v-for="group in groupedCatalog" :key="group.category">
            <div class="menu-view__group-title">{{ group.category }}</div>
            <button
              v-for="item in group.items"
              :key="item.id"
              type="button"
              class="menu-view__item"
              :class="{ 'menu-view__item--selected': assignedIds.includes(item.id) }"
              :disabled="locked"
              @click="toggle(item.id)"
            >
              <i
                class="menu-view__check"
                :class="assignedIds.includes(item.id) ? 'pi pi-check-circle' : 'pi pi-circle'"
              />
              <span class="menu-view__item-main">
                <span class="menu-view__item-name">{{ item.name }}</span>
                <span
                  v-if="isUnsuitable(item)"
                  class="menu-view__badge menu-view__badge--unsuitable"
                  :title="`Ungeeignet: ${unsuitableReason(item)}`"
                >
                  <i class="pi pi-exclamation-triangle" /> Ungeeignet
                </span>
              </span>
              <span class="menu-view__item-price">
                {{ formatCurrency(item.salesPricePerPerson) }}
              </span>
            </button>
          </template>
        </div>
      </section>

      <!-- Live menu card -->
      <aside class="menu-view__card">
        <div class="menu-view__card-head">
          <h3>Menükarte</h3>
          <span class="menu-view__card-count">{{ selectedItems.length }} Gericht(e)</span>
        </div>

        <div class="menu-view__menu">
          <p v-if="selectedItems.length === 0" class="menu-view__empty">
            Wähle links Gerichte aus — sie erscheinen hier.
          </p>
          <template v-for="group in groupedSelection" :key="group.category">
            <div class="menu-view__menu-course">{{ group.category }}</div>
            <div v-for="item in group.items" :key="item.id" class="menu-view__menu-item">
              <span class="menu-view__menu-name">{{ item.name }}</span>
              <span class="menu-view__menu-price">{{ formatCurrency(item.salesPricePerPerson) }}</span>
              <Button
                v-if="!locked"
                icon="pi pi-times"
                severity="danger"
                text
                rounded
                size="small"
                :disabled="menuBusy"
                @click="toggle(item.id)"
              />
            </div>
          </template>
        </div>

        <div class="menu-view__calc">
          <div class="menu-view__calc-row">
            <span>Warenwert netto · {{ guestCount }} Pers.</span>
            <span>{{ formatCurrency(netValue) }}</span>
          </div>
          <div v-if="budget != null" class="menu-view__calc-row">
            <span>Budget</span>
            <span>{{ formatCurrency(budget) }}</span>
          </div>
          <div
            v-if="budgetDelta != null"
            class="menu-view__calc-row menu-view__calc-row--delta"
            :class="budgetDelta < 0 ? 'menu-view__calc-row--over' : 'menu-view__calc-row--ok'"
          >
            <span>Differenz</span>
            <span>{{ formatCurrency(budgetDelta) }}</span>
          </div>
          <p class="menu-view__hint">zzgl. Verwaltungspauschale &amp; USt im Angebot</p>

          <div class="menu-view__calc-row menu-view__calc-row--margin">
            <span>Deckungsbeitrag (intern)</span>
            <span>{{ formatCurrency(contributionMargin) }}</span>
          </div>
        </div>
      </aside>
    </div>
  </div>
</template>

<style scoped>
.menu-view {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.menu-view__grid {
  display: grid;
  grid-template-columns: 1fr 22rem;
  gap: 1.5rem;
  align-items: start;
}

@media (max-width: 900px) {
  .menu-view__grid {
    grid-template-columns: 1fr;
  }
}

/* Catalog — flows with the page; no nested scrollbar. */
.menu-view__filters {
  display: grid;
  grid-template-columns: 1fr 12rem auto;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

@media (max-width: 600px) {
  .menu-view__filters {
    grid-template-columns: 1fr;
  }
}

.menu-view__center {
  display: flex;
  justify-content: center;
  padding: 2rem;
}

.menu-view__empty {
  color: var(--p-text-muted-color);
  margin: 0.5rem 0;
}

.menu-view__catalog-list {
  display: flex;
  flex-direction: column;
  gap: 0.125rem;
}

.menu-view__group-title {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--p-text-muted-color);
  padding: 0.75rem 0 0.25rem;
}

.menu-view__item {
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem 0.625rem;
  border: none;
  border-radius: var(--p-border-radius, 6px);
  background: none;
  cursor: pointer;
  text-align: left;
  transition: background 0.15s;
}

.menu-view__item:hover:not(:disabled) {
  background: var(--p-content-hover-background);
}

.menu-view__item:disabled {
  cursor: not-allowed;
  opacity: 0.7;
}

.menu-view__item--selected {
  background: color-mix(in srgb, var(--p-primary-color) 12%, transparent);
}

.menu-view__check {
  font-size: 1.1rem;
  color: var(--p-primary-color);
}

.menu-view__item-main {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 0;
  flex-wrap: wrap;
}

.menu-view__item-name {
  font-weight: 500;
}

.menu-view__badge {
  display: inline-flex;
  align-items: center;
  gap: 0.2rem;
  font-size: 0.6875rem;
  font-weight: 600;
  padding: 0.05rem 0.35rem;
  border-radius: 999px;
}

.menu-view__badge--unsuitable {
  color: var(--p-red-500, #ef4444);
  background: color-mix(in srgb, var(--p-red-500, #ef4444) 14%, transparent);
}

.menu-view__item-price {
  font-variant-numeric: tabular-nums;
  color: var(--p-text-muted-color);
  font-size: 0.875rem;
}

/* Menu card — sticky so the running total stays visible while browsing. */
.menu-view__card {
  position: sticky;
  top: 1rem;
  max-height: calc(100vh - 2rem);
  overflow-y: auto;
  border: 1px solid var(--p-content-border-color);
  border-radius: var(--p-border-radius, 6px);
  padding: 1.25rem;
  background: var(--p-content-background);
}

.menu-view__card-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 0.75rem;
}

.menu-view__card-head h3 {
  margin: 0;
  font-size: 1rem;
}

.menu-view__card-count {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.menu-view__menu {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  margin-bottom: 1rem;
}

.menu-view__menu-course {
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--p-primary-color);
  padding: 0.5rem 0 0.125rem;
}

.menu-view__menu-item {
  display: grid;
  grid-template-columns: 1fr auto auto;
  align-items: center;
  gap: 0.5rem;
}

.menu-view__menu-name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.menu-view__menu-price {
  font-variant-numeric: tabular-nums;
  color: var(--p-text-muted-color);
  font-size: 0.875rem;
}

.menu-view__calc {
  border-top: 1px solid var(--p-content-border-color);
  padding-top: 0.75rem;
}

.menu-view__calc-row {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.2rem 0;
}

.menu-view__calc-row--delta {
  font-weight: 700;
}

.menu-view__calc-row--ok {
  color: var(--p-green-600, #16a34a);
}

.menu-view__calc-row--over {
  color: var(--p-red-500, #ef4444);
}

.menu-view__hint {
  margin: 0.25rem 0 0.75rem;
  font-size: 0.75rem;
  color: var(--p-text-muted-color);
}

.menu-view__calc-row--margin {
  border-top: 1px dashed var(--p-content-border-color);
  margin-top: 0.5rem;
  padding-top: 0.625rem;
  color: var(--p-text-muted-color);
  font-size: 0.875rem;
}
</style>
