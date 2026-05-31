<script setup lang="ts">
import { computed, ref, watch, onMounted } from 'vue'
import Button from 'primevue/button'
import InputNumber from 'primevue/inputnumber'
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
import type { MenuItemWithCount } from '@/types/order'

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

const locked = computed(() =>
  order.value ? indexOf(order.value.status) >= indexOf('AngebotErstellt') : false,
)

const guestCount = computed(() => order.value?.guestCount ?? 0)

// Per-item counts: null = use full guestCount.
const localCounts = ref<Map<number, number | null>>(new Map())

watch(
  () => order.value?.assignedMenuItems,
  (items) => {
    if (!items) return
    const next = new Map<number, number | null>()
    for (const item of items) next.set(item.id, item.count ?? null)
    localCounts.value = next
  },
  { immediate: true },
)

const assignedIds = computed(() => order.value?.assignedMenuItems.map((m) => m.id) ?? [])

function effectiveCount(menuItemId: number): number {
  const c = localCounts.value.get(menuItemId)
  return c != null && c > 0 ? c : guestCount.value
}

// ── Course ordering ────────────────────────────────────────────────────────
const COURSE_ORDER = ['Vorspeise', 'Hauptgang', 'Dessert', 'Beilage', 'Getränk', 'Getränk (alkoholisch)']
function courseRank(category: string): number {
  const i = COURSE_ORDER.indexOf(category)
  return i === -1 ? COURSE_ORDER.length : i
}

const categoryOptions = computed(() => {
  const cats = [...new Set((catalog.value ?? []).map((m) => m.category))]
  return cats.sort((a, b) => courseRank(a) - courseRank(b)).map((c) => ({ label: c, value: c }))
})

// ── Suitability ────────────────────────────────────────────────────────────
const orderAllergens = computed(() =>
  (order.value?.allergies ?? '')
    .split(/[,;]+|\s+/)
    .map((a) => a.trim().toLowerCase())
    .filter(Boolean),
)

function allergenConflict(item: MenuItemDto): boolean {
  if (!item.allergens || orderAllergens.value.length === 0) return false
  const tokens = item.allergens.split(/[,;]+|\s+/).map((a) => a.trim().toLowerCase()).filter(Boolean)
  return orderAllergens.value.some((a) => tokens.includes(a))
}

function overBudget(item: MenuItemDto): boolean {
  return order.value?.budget != null && item.salesPricePerPerson * guestCount.value > order.value.budget
}

function isUnsuitable(item: MenuItemDto): boolean {
  return allergenConflict(item) || overBudget(item)
}

function unsuitableReason(item: MenuItemDto): string {
  const r: string[] = []
  if (allergenConflict(item)) r.push('Allergen-Konflikt')
  if (overBudget(item)) r.push('über Budget')
  return r.join(' · ')
}

// ── Filtering ──────────────────────────────────────────────────────────────
const filteredItems = computed(() => {
  const q = search.value.toLowerCase().trim()
  return (catalog.value ?? []).filter((item) => {
    if (categoryFilter.value && item.category !== categoryFilter.value) return false
    if (hideUnsuitable.value && isUnsuitable(item)) return false
    if (q && !item.name.toLowerCase().includes(q) && !item.category.toLowerCase().includes(q)) return false
    return true
  })
})

// ── Per-section collapsible state ──────────────────────────────────────────
// Initialised once when the catalog first loads: sections that contain at
// least one already-selected item open automatically. After that the state
// is purely user-controlled — toggling a dish never forces a section open
// or closed (the watch on assignedMenuItems was the culprit).
const openSections = ref<string[]>([])

watch(
  catalog,
  (cat) => {
    if (!cat) return
    const selectedCategories = new Set(
      cat.filter((m) => assignedIds.value.includes(m.id)).map((m) => m.category),
    )
    openSections.value = [...selectedCategories]
  },
  { immediate: true },
)

function isSectionOpen(cat: string): boolean {
  return openSections.value.includes(cat)
}

function toggleSection(cat: string): void {
  if (isSectionOpen(cat)) {
    openSections.value = openSections.value.filter((c) => c !== cat)
  } else {
    openSections.value = [...openSections.value, cat]
  }
}

// ── Per-section sorting ────────────────────────────────────────────────────
type SortKey = 'name-asc' | 'name-desc' | 'price-asc' | 'price-desc'
const sectionSorts = ref<Record<string, SortKey>>({})

function getSort(cat: string): SortKey {
  return sectionSorts.value[cat] ?? 'name-asc'
}

function setSort(cat: string, key: SortKey): void {
  sectionSorts.value = { ...sectionSorts.value, [cat]: key }
}

function cycleName(cat: string): void {
  setSort(cat, getSort(cat) === 'name-asc' ? 'name-desc' : 'name-asc')
}

function cyclePrice(cat: string): void {
  setSort(cat, getSort(cat) === 'price-asc' ? 'price-desc' : 'price-asc')
}

function sortIcon(cat: string, type: 'name' | 'price'): string {
  const s = getSort(cat)
  if (type === 'name') {
    if (s === 'name-asc') return 'pi pi-sort-alpha-down'
    if (s === 'name-desc') return 'pi pi-sort-alpha-up-alt'
    return 'pi pi-sort-alpha-down'
  }
  if (s === 'price-asc') return 'pi pi-sort-amount-down-alt'
  if (s === 'price-desc') return 'pi pi-sort-amount-up-alt'
  return 'pi pi-sort-amount-down-alt'
}

function isActiveSortType(cat: string, type: 'name' | 'price'): boolean {
  const s = getSort(cat)
  return type === 'name' ? s.startsWith('name') : s.startsWith('price')
}

function sortedItems(items: MenuItemDto[], cat: string): MenuItemDto[] {
  const s = getSort(cat)
  return [...items].sort((a, b) => {
    switch (s) {
      case 'name-asc':   return a.name.localeCompare(b.name, 'de')
      case 'name-desc':  return b.name.localeCompare(a.name, 'de')
      case 'price-asc':  return a.salesPricePerPerson - b.salesPricePerPerson
      case 'price-desc': return b.salesPricePerPerson - a.salesPricePerPerson
      default: return 0
    }
  })
}

// ── Grouped catalog (for rendering) ───────────────────────────────────────
const groupedCatalog = computed(() => {
  const groups = new Map<string, MenuItemDto[]>()
  for (const item of filteredItems.value) {
    const list = groups.get(item.category) ?? []
    list.push(item)
    groups.set(item.category, list)
  }
  return [...groups.entries()]
    .sort((a, b) => courseRank(a[0]) - courseRank(b[0]))
    .map(([category, items]) => ({ category, items }))
})

function selectedCountInSection(cat: string): number {
  return (catalog.value ?? []).filter((m) => m.category === cat && assignedIds.value.includes(m.id)).length
}

// ── Menu card ──────────────────────────────────────────────────────────────
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
  selectedItems.value.reduce((sum, m) => sum + m.salesPricePerPerson * effectiveCount(m.id), 0),
)
const contributionMargin = computed(() =>
  selectedItems.value.reduce(
    (sum, m) => sum + (m.salesPricePerPerson - m.purchaseCostPerPerson) * effectiveCount(m.id),
    0,
  ),
)
const budget = computed(() => order.value?.budget ?? null)
const budgetDelta = computed(() => (budget.value != null ? budget.value - netValue.value : null))

// ── Persistence ────────────────────────────────────────────────────────────
function buildPayload(ids: number[]): MenuItemWithCount[] {
  return ids.map((id) => ({ menuItemId: id, count: localCounts.value.get(id) ?? null }))
}

async function persist(ids: number[]): Promise<void> {
  menuBusy.value = true
  try {
    await ordersApi.update(orderId, { assignedMenuItemsWithCounts: buildPayload(ids) })
    await reload()
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    menuBusy.value = false
  }
}

function toggle(id: number): void {
  if (locked.value || menuBusy.value) return
  const cur = assignedIds.value
  if (cur.includes(id)) {
    localCounts.value.delete(id)
    void persist(cur.filter((x) => x !== id))
    // Deselecting never closes the section — state remains as-is.
  } else {
    localCounts.value.set(id, null)
    // Open the section of the newly selected item if it was closed.
    const item = catalog.value?.find((m) => m.id === id)
    if (item && !openSections.value.includes(item.category)) {
      openSections.value = [...openSections.value, item.category]
    }
    void persist([...cur, id])
  }
}

async function updateCount(id: number, raw: number | null): Promise<void> {
  if (locked.value || menuBusy.value) return
  localCounts.value.set(id, raw && raw > 0 ? raw : null)
  await persist(assignedIds.value)
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
      <!-- ── Catalog ── -->
      <section class="menu-view__catalog">
        <!-- Global filters -->
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

        <div v-else class="menu-view__sections">
          <p v-if="groupedCatalog.length === 0" class="menu-view__empty">Kein Treffer.</p>

          <div
            v-for="group in groupedCatalog"
            :key="group.category"
            class="menu-view__section"
          >
            <!-- Section header — always visible -->
            <div class="menu-view__section-head" @click="toggleSection(group.category)">
              <span class="menu-view__section-toggle">
                <i :class="isSectionOpen(group.category) ? 'pi pi-chevron-down' : 'pi pi-chevron-right'" />
              </span>
              <span class="menu-view__section-name">{{ group.category }}</span>
              <span class="menu-view__section-meta">
                {{ selectedCountInSection(group.category) }}/{{ group.items.length }}
              </span>

              <!-- Sort controls inside header (stop propagation so they don't toggle the section) -->
              <span class="menu-view__sort-btns" @click.stop>
                <button
                  class="menu-view__sort-btn"
                  :class="{ 'menu-view__sort-btn--active': isActiveSortType(group.category, 'name') }"
                  :title="getSort(group.category).startsWith('name') ? 'Name umkehren' : 'Nach Name sortieren'"
                  @click="cycleName(group.category)"
                >
                  <i :class="sortIcon(group.category, 'name')" />
                  <span>Name</span>
                </button>
                <button
                  class="menu-view__sort-btn"
                  :class="{ 'menu-view__sort-btn--active': isActiveSortType(group.category, 'price') }"
                  :title="getSort(group.category).startsWith('price') ? 'Preis umkehren' : 'Nach Preis sortieren'"
                  @click="cyclePrice(group.category)"
                >
                  <i :class="sortIcon(group.category, 'price')" />
                  <span>Preis</span>
                </button>
              </span>
            </div>

            <!-- Section body — collapsible -->
            <div v-if="isSectionOpen(group.category)" class="menu-view__section-body">
              <button
                v-for="item in sortedItems(group.items, group.category)"
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
                <span class="menu-view__item-name">{{ item.name }}</span>
                <span
                  v-if="isUnsuitable(item)"
                  class="menu-view__badge menu-view__badge--unsuitable"
                  :title="`Ungeeignet: ${unsuitableReason(item)}`"
                  @click.stop
                >
                  <i class="pi pi-exclamation-triangle" /> Ungeeignet
                </span>
                <span class="menu-view__item-price">
                  {{ formatCurrency(item.salesPricePerPerson) }}
                </span>
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- ── Live menu card ── -->
      <aside class="menu-view__card">
        <div class="menu-view__card-head">
          <h3>Menükarte</h3>
          <span class="menu-view__card-count">{{ selectedItems.length }} Gericht(e)</span>
        </div>

        <div class="menu-view__menu">
          <p v-if="selectedItems.length === 0" class="menu-view__empty">
            Wähle links Gerichte aus.
          </p>
          <template v-for="group in groupedSelection" :key="group.category">
            <div class="menu-view__menu-course">{{ group.category }}</div>
            <div v-for="item in group.items" :key="item.id" class="menu-view__menu-item">
              <span class="menu-view__menu-name">{{ item.name }}</span>
              <InputNumber
                v-if="!locked"
                :model-value="localCounts.get(item.id) ?? guestCount"
                :min="1"
                :max="9999"
                :use-grouping="false"
                style="width: 3.25rem"
                :input-style="{ width: '3.25rem', padding: '0.2rem 0.3rem', fontSize: '0.8125rem', textAlign: 'right' }"
                :disabled="menuBusy"
                @update:model-value="(v) => updateCount(item.id, v)"
              />
              <span v-else class="menu-view__count-readonly">
                {{ localCounts.get(item.id) ?? guestCount }}
              </span>
              <span class="menu-view__menu-price">
                {{ formatCurrency(item.salesPricePerPerson * effectiveCount(item.id)) }}
              </span>
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
          <div class="menu-view__calc-row menu-view__calc-row--hint">
            <span>Basis</span>
            <span>{{ guestCount }} Pers.</span>
          </div>
          <div class="menu-view__calc-row">
            <span>Warenwert netto</span>
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

@media (max-width: 1023.98px) {
  .menu-view__grid {
    grid-template-columns: 1fr;
  }
}

/* ── Global filters ─────────────────────────────────────────────────────── */
.menu-view__filters {
  display: grid;
  grid-template-columns: 1fr 11rem auto;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

@media (max-width: 767.98px) {
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

/* ── Sections ───────────────────────────────────────────────────────────── */
.menu-view__sections {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.menu-view__section {
  border: 1px solid var(--p-content-border-color);
  border-radius: var(--p-border-radius, 6px);
  overflow: hidden;
}

.menu-view__section-head {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: var(--p-content-hover-background);
  cursor: pointer;
  user-select: none;
}

.menu-view__section-head:hover {
  background: color-mix(in srgb, var(--p-primary-color) 8%, transparent);
}

.menu-view__section-toggle {
  color: var(--p-text-muted-color);
  font-size: 0.75rem;
  flex-shrink: 0;
  width: 1rem;
}

.menu-view__section-name {
  font-size: 0.8125rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--p-text-muted-color);
  flex: 1;
}

.menu-view__section-meta {
  font-size: 0.75rem;
  color: var(--p-text-muted-color);
  margin-right: 0.25rem;
}

/* Sort buttons */
.menu-view__sort-btns {
  display: flex;
  gap: 0.25rem;
}

.menu-view__sort-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.2rem;
  padding: 0.15rem 0.4rem;
  font-size: 0.6875rem;
  border: 1px solid var(--p-content-border-color);
  border-radius: 4px;
  background: var(--p-content-background);
  color: var(--p-text-muted-color);
  cursor: pointer;
  transition: all 0.15s;
}

.menu-view__sort-btn:hover {
  border-color: var(--p-primary-color);
  color: var(--p-primary-color);
}

.menu-view__sort-btn--active {
  border-color: var(--p-primary-color);
  color: var(--p-primary-color);
  background: color-mix(in srgb, var(--p-primary-color) 10%, transparent);
}

/* Section body items */
.menu-view__section-body {
  display: flex;
  flex-direction: column;
  gap: 0;
  padding: 0.25rem 0;
}

.menu-view__item {
  display: grid;
  grid-template-columns: 1.5rem 1fr auto auto;
  align-items: center;
  gap: 0.625rem;
  padding: 0.4rem 0.75rem;
  border: none;
  background: none;
  cursor: pointer;
  text-align: left;
  transition: background 0.12s;
}

.menu-view__item:hover:not(:disabled) {
  background: var(--p-content-hover-background);
}

.menu-view__item:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.menu-view__item--selected {
  background: color-mix(in srgb, var(--p-primary-color) 10%, transparent);
}

.menu-view__check {
  font-size: 1rem;
  color: var(--p-primary-color);
}

.menu-view__item-name {
  font-size: 0.9rem;
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.menu-view__badge {
  display: inline-flex;
  align-items: center;
  gap: 0.2rem;
  font-size: 0.6875rem;
  font-weight: 600;
  padding: 0.05rem 0.35rem;
  border-radius: 999px;
  white-space: nowrap;
}

.menu-view__badge--unsuitable {
  color: var(--cm-orange);
  background: color-mix(in srgb, var(--cm-orange) 14%, transparent);
}

.menu-view__item-price {
  font-variant-numeric: tabular-nums;
  color: var(--p-text-muted-color);
  font-size: 0.8125rem;
  white-space: nowrap;
}

/* ── Menu card ──────────────────────────────────────────────────────────── */
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
  gap: 0.125rem;
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
  /* name | count-input | subtotal | remove */
  grid-template-columns: 1fr auto auto auto;
  align-items: center;
  gap: 0.375rem;
  padding: 0.2rem 0;
}

.menu-view__menu-name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 0.875rem;
}

.menu-view__count-readonly {
  font-size: 0.8125rem;
  min-width: 2rem;
  text-align: right;
  color: var(--p-text-muted-color);
}

.menu-view__menu-price {
  font-variant-numeric: tabular-nums;
  font-size: 0.8125rem;
  text-align: right;
  min-width: 4rem;
}

/* ── Calculation ─────────────────────────────────────────────────────────── */
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

.menu-view__calc-row--hint {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
  padding-bottom: 0.375rem;
}

.menu-view__calc-row--delta {
  font-weight: 700;
}

.menu-view__calc-row--ok {
  color: var(--cm-avocado);
}

.menu-view__calc-row--over {
  color: var(--cm-orange);
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
