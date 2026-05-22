<script setup lang="ts">
import Toast from 'primevue/toast'
import ConfirmDialog from 'primevue/confirmdialog'
</script>

<template>
  <Toast />
  <ConfirmDialog />
  <RouterView />
</template>

<style>
:root {
  --catermate-bg: #fbf7f1;
}

body {
  margin: 0;
  font-family: system-ui, -apple-system, 'Segoe UI', sans-serif;
  background: var(--catermate-bg);
}

#app {
  min-height: 100vh;
}
</style>
