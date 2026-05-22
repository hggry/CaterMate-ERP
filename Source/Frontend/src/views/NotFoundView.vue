<script setup lang="ts">
import { useRouter } from 'vue-router'
import Button from 'primevue/button'

const router = useRouter()
</script>

<template>
  <div class="not-found-view">
    <h1>404</h1>
    <p>Diese Seite wurde nicht gefunden.</p>
    <Button label="Zum Dashboard" icon="pi pi-home" @click="router.push({ name: 'dashboard' })" />
  </div>
</template>

<style scoped>
.not-found-view {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  padding: 4rem 1rem;
}

.not-found-view h1 {
  margin: 0;
  font-size: 4rem;
  color: var(--p-primary-color);
}
</style>
