<script setup lang="ts">
import { useRouter, type RouteLocationRaw } from 'vue-router'
import Button from 'primevue/button'
import { useAuthStore } from '@/stores/authStore'

interface NavItem {
  label: string
  icon: string
  to: RouteLocationRaw
}

const router = useRouter()
const auth = useAuthStore()

const navItems: NavItem[] = [
  { label: 'Dashboard', icon: 'pi pi-chart-bar', to: { name: 'dashboard' } },
  { label: 'Aufträge', icon: 'pi pi-list', to: { name: 'orders' } },
  { label: 'Eingangsrechnungen', icon: 'pi pi-file-import', to: { name: 'incoming-invoices' } },
  { label: 'Menüartikel', icon: 'pi pi-book', to: { name: 'menu-items' } },
  { label: 'Zutaten', icon: 'pi pi-shopping-cart', to: { name: 'ingredients' } },
]

function logout(): void {
  auth.logout()
  router.push({ name: 'login' })
}
</script>

<template>
  <aside class="app-sidebar">
    <div class="app-sidebar__brand">CaterMate ERP</div>

    <nav class="app-sidebar__nav">
      <RouterLink
        v-for="item in navItems"
        :key="item.label"
        :to="item.to"
        class="app-sidebar__link"
        active-class="app-sidebar__link--active"
      >
        <i :class="item.icon" />
        <span>{{ item.label }}</span>
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
  width: 16rem;
  height: 100vh;
  padding: 1rem;
  box-sizing: border-box;
  background: var(--p-content-background);
  border-right: 1px solid var(--p-content-border-color);
}

.app-sidebar__brand {
  padding: 0.5rem;
  margin-bottom: 1rem;
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--p-primary-color);
}

.app-sidebar__nav {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  flex: 1;
}

.app-sidebar__link {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.625rem 0.75rem;
  border-radius: var(--p-border-radius, 6px);
  color: var(--p-text-color);
  text-decoration: none;
}

.app-sidebar__link:hover {
  background: var(--p-content-hover-background);
}

.app-sidebar__link--active {
  background: var(--p-primary-color);
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
</style>
