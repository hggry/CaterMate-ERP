<script setup lang="ts">
import { onMounted, watch } from 'vue'
import { useRouter, useRoute, type RouteLocationRaw } from 'vue-router'
import Button from 'primevue/button'
import Badge from 'primevue/badge'
import { useAuthStore } from '@/stores/authStore'
import { useSuggestionsStore } from '@/stores/suggestionsStore'

interface NavItem {
  label: string
  icon: string
  to: RouteLocationRaw
  badge?: boolean
}

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const suggestions = useSuggestionsStore()

const navItems: NavItem[] = [
  { label: 'Dashboard', icon: 'pi pi-chart-bar', to: { name: 'dashboard' } },
  { label: 'Aufträge', icon: 'pi pi-list', to: { name: 'orders' } },
  { label: 'Eingangsrechnungen', icon: 'pi pi-file-import', to: { name: 'incoming-invoices' } },
  { label: 'Preisänderungsvorschläge', icon: 'pi pi-tags', to: { name: 'price-suggestions' }, badge: true },
  { label: 'Menüartikel', icon: 'pi pi-book', to: { name: 'menu-items' } },
  { label: 'Zutaten', icon: 'pi pi-shopping-cart', to: { name: 'ingredients' } },
  { label: 'Einstellungen', icon: 'pi pi-cog', to: { name: 'company-settings' } },
]

onMounted(() => suggestions.refresh())
watch(() => route.fullPath, () => suggestions.refresh())

function logout(): void {
  auth.logout()
  router.push({ name: 'login' })
}
</script>

<template>
  <aside class="app-sidebar">
    <div class="app-sidebar__brand">
      <img src="@/assets/logo.svg" alt="CaterMate Logo" class="app-sidebar__logo" />
      CaterMate ERP
    </div>

    <nav class="app-sidebar__nav">
      <RouterLink
        v-for="item in navItems"
        :key="item.label"
        :to="item.to"
        class="app-sidebar__link"
        active-class="app-sidebar__link--active"
      >
        <i :class="item.icon" />
        <span class="app-sidebar__label">{{ item.label }}</span>
        <Badge
          v-if="item.badge && suggestions.count > 0"
          :value="suggestions.count"
          severity="danger"
          class="app-sidebar__badge"
        />
      </RouterLink>
    </nav>

    <div class="app-sidebar__footer">
      <span class="app-sidebar__user">
        <i class="pi pi-user" />
        {{ auth.username ?? 'Unbekannt' }}
      </span>
      <Button
        label="Abmelden"
        icon="pi pi-sign-out"
        severity="secondary"
        text
        fluid
        @click="logout"
      />
    </div>
  </aside>
</template>

<style scoped>
.app-sidebar {
  display: flex;
  flex-direction: column;
  width: 18rem;
  height: 100vh;
  height: 100dvh;
  flex-shrink: 0;
  padding: 1rem;
  box-sizing: border-box;
  background: var(--p-content-background);
  border-right: 1px solid var(--p-content-border-color);
  overflow: hidden;
}

.app-sidebar__brand {
  display: flex;
  align-items: center;
  gap: 0.625rem;
  padding: 0.5rem;
  margin-bottom: 1rem;
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--p-primary-color);
}

.app-sidebar__logo {
  width: 2rem;
  height: 2rem;
  object-fit: contain;
  border-radius: 4px;
  flex-shrink: 0;
}

.app-sidebar__nav {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  flex: 1;
  min-height: 0;
  overflow-y: auto;
}

.app-sidebar__link {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.625rem 0.75rem;
  /* Reserve border space so hover doesn't cause layout shift */
  border: 1px solid transparent;
  border-radius: var(--p-border-radius, 6px);
  color: var(--p-text-color);
  text-decoration: none;
  font-size: 0.9rem;
  transition: color 0.15s ease, border-color 0.15s ease;
}

.app-sidebar__link i {
  flex-shrink: 0;
}

.app-sidebar__label {
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.app-sidebar__badge {
  margin-left: auto;
  flex-shrink: 0;
}

.app-sidebar__link:hover:not(.app-sidebar__link--active) {
  border-color: var(--p-primary-color);
  color: var(--p-primary-color);
}

.app-sidebar__link--active {
  background: var(--p-primary-color);
  border-color: var(--p-primary-color);
  color: var(--p-primary-contrast-color);
}

.app-sidebar__footer {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding-top: 1rem;
  border-top: 1px solid var(--p-content-border-color);
}

.app-sidebar__user {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0 0.5rem;
  font-size: 0.875rem;
  color: var(--p-text-muted-color);
}

@media (max-width: 48rem) {
  .app-sidebar {
    width: 100%;
    height: auto;
    max-height: 45vh;
    max-height: 45dvh;
    padding: 0.75rem;
    border-right: 0;
    border-bottom: 1px solid var(--p-content-border-color);
  }

  .app-sidebar__brand {
    margin-bottom: 0.5rem;
  }

  .app-sidebar__nav {
    flex: 0 1 auto;
    flex-direction: row;
    overflow-x: auto;
    overflow-y: hidden;
    padding-bottom: 0.25rem;
  }

  .app-sidebar__link {
    flex: 0 0 auto;
  }

  .app-sidebar__footer {
    flex-direction: row;
    align-items: center;
    padding-top: 0.75rem;
  }

  .app-sidebar__footer :deep(.p-button) {
    width: auto;
  }
}
</style>
