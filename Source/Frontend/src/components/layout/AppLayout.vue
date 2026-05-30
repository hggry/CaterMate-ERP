<script setup lang="ts">
import AppSidebar from './AppSidebar.vue'
</script>

<template>
  <div class="app-layout">
    <AppSidebar />
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

@media (max-width: 48rem) {
  .app-layout {
    flex-direction: column;
  }

  .app-layout__content {
    padding: 1rem;
  }
}
</style>
