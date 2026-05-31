<script setup lang="ts">
import { ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import AppSidebar from './AppSidebar.vue'
import { useBreakpoint } from '@/composables/useBreakpoint'

const route = useRoute()
const { isCompactNav } = useBreakpoint()

// Off-canvas drawer state — only relevant below the desktop tier.
const drawerOpen = ref(false)

// Close the drawer after any navigation (e.g. tapping a nav link).
watch(() => route.fullPath, () => { drawerOpen.value = false })
// Reset state when growing back to the desktop layout so no scrim lingers.
watch(isCompactNav, (compact) => { if (!compact) drawerOpen.value = false })

function toggleDrawer(): void { drawerOpen.value = !drawerOpen.value }
function closeDrawer(): void { drawerOpen.value = false }
</script>

<template>
  <div class="app-layout">
    <!-- Mobile/tablet top bar: hidden on desktop, holds the hamburger + brand. -->
    <header class="app-topbar">
      <button
        type="button"
        class="app-topbar__burger"
        aria-label="Menü öffnen"
        :aria-expanded="drawerOpen"
        @click="toggleDrawer"
      >
        <i class="pi pi-bars" />
      </button>
      <div class="app-topbar__brand">
        <img src="@/assets/logo.svg" alt="" class="app-topbar__logo" />
        CaterMate
      </div>
    </header>

    <!-- Scrim behind the open drawer (mobile only). -->
    <div v-if="drawerOpen" class="app-layout__scrim" @click="closeDrawer" />

    <AppSidebar
      class="app-layout__sidebar"
      :class="{ 'app-layout__sidebar--open': drawerOpen }"
      @navigate="closeDrawer"
    />

    <main class="app-layout__content">
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
.app-layout {
  display: flex;
  height: 100vh;
  height: 100dvh;
  overflow: hidden;
}

.app-layout__content {
  flex: 1;
  min-width: 0;
  min-height: 0;
  box-sizing: border-box;
  padding: 1.5rem;
  overflow: auto;
}

/* Top bar + scrim only exist below the desktop tier. */
.app-topbar {
  display: none;
}

.app-layout__scrim {
  display: none;
}

/* ── Below desktop (< 1024px): hamburger + off-canvas drawer ─────────────── */
@media (max-width: 1023.98px) {
  .app-layout {
    flex-direction: column;
  }

  .app-topbar {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-shrink: 0;
    height: 3.5rem;
    padding: 0 0.75rem;
    background: var(--p-content-background);
    border-bottom: 1px solid var(--p-content-border-color);
  }

  .app-topbar__burger {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 2.5rem;
    height: 2.5rem;
    padding: 0;
    border: none;
    border-radius: var(--p-border-radius, 6px);
    background: none;
    color: var(--p-text-color);
    font-size: 1.25rem;
    cursor: pointer;
  }

  .app-topbar__burger:hover {
    background: var(--p-content-hover-background, var(--cm-sand));
  }

  .app-topbar__brand {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-weight: 700;
    color: var(--p-primary-color);
  }

  .app-topbar__logo {
    width: 1.5rem;
    height: 1.5rem;
    object-fit: contain;
    border-radius: 4px;
  }

  .app-layout__content {
    padding: 1rem;
  }

  /* Sidebar becomes an off-canvas drawer, slid in from the left. */
  .app-layout__sidebar {
    position: fixed;
    top: 0;
    left: 0;
    z-index: 1000;
    width: min(18rem, 85vw);
    height: 100dvh;
    transform: translateX(-100%);
    transition: transform 0.25s ease;
    box-shadow: 0 0 2rem rgba(0, 0, 0, 0.25);
  }

  .app-layout__sidebar--open {
    transform: translateX(0);
  }

  .app-layout__scrim {
    display: block;
    position: fixed;
    inset: 0;
    z-index: 999;
    background: rgba(0, 0, 0, 0.45);
  }
}
</style>
