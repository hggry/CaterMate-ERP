<script setup lang="ts">
import type { OrderStatus } from '@/types/order'
import { useOrderStatus } from '@/composables/useOrderStatus'

const props = defineProps<{ status: OrderStatus }>()

const { labelFor, tagStyleFor } = useOrderStatus()
</script>

<template>
  <span class="status-tag" :style="tagStyleFor(props.status)">
    {{ labelFor(props.status) }}
  </span>
</template>

<style scoped>
.status-tag {
  display: inline-flex;
  align-items: center;
  padding: 0.2rem 0.625rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
  white-space: nowrap;
  line-height: 1.4;
}
</style>
