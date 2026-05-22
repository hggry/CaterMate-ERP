<script setup lang="ts">
import Tag from 'primevue/tag'
import type { OrderStatus } from '@/types/order'
import { useOrderStatus } from '@/composables/useOrderStatus'

const props = defineProps<{ status: OrderStatus }>()

const { labelFor, severityFor } = useOrderStatus()
</script>

<template>
  <Tag :value="labelFor(props.status)" :severity="severityFor(props.status)" />
</template>
