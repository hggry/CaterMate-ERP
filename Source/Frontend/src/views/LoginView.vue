<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { z } from 'zod'
import { Form, FormField, type FormSubmitEvent } from '@primevue/forms'
import { zodResolver } from '@primevue/forms/resolvers/zod'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import Button from 'primevue/button'
import Message from 'primevue/message'
import Card from 'primevue/card'
import { useAuthStore } from '@/stores/authStore'
import { useToast } from '@/composables/useToast'
import { ApiError } from '@/types/api'

const router = useRouter()
const auth = useAuthStore()
const toast = useToast()

const loading = ref(false)

const schema = z.object({
  username: z.string().min(1, 'Benutzername ist erforderlich.'),
  password: z.string().min(1, 'Passwort ist erforderlich.'),
})

const resolver = zodResolver(schema)
const initialValues = { username: '', password: '' }

async function onSubmit(event: FormSubmitEvent): Promise<void> {
  if (!event.valid) return
  loading.value = true
  try {
    const values = event.values as { username: string; password: string }
    await auth.login(values.username, values.password)
    await router.push({ name: 'dashboard' })
  } catch (e) {
    const message = e instanceof ApiError ? e.detail || e.title : 'Anmeldung fehlgeschlagen.'
    toast.error(message, 'Anmeldung fehlgeschlagen')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-view">
    <Card class="login-card">
      <template #title>
        <div class="login-card__brand">CaterMate ERP</div>
      </template>
      <template #subtitle>Bitte melden Sie sich an</template>
      <template #content>
        <Form
          :resolver="resolver"
          :initial-values="initialValues"
          class="login-form"
          @submit="onSubmit"
        >
          <FormField v-slot="$field" name="username" class="login-form__field">
            <label for="username">Benutzername</label>
            <InputText id="username" name="username" fluid autocomplete="username" />
            <Message
              v-if="$field?.invalid"
              severity="error"
              size="small"
              variant="simple"
            >
              {{ $field.error?.message }}
            </Message>
          </FormField>

          <FormField v-slot="$field" name="password" class="login-form__field">
            <label for="password">Passwort</label>
            <Password
              input-id="password"
              name="password"
              :feedback="false"
              toggle-mask
              fluid
              autocomplete="current-password"
            />
            <Message
              v-if="$field?.invalid"
              severity="error"
              size="small"
              variant="simple"
            >
              {{ $field.error?.message }}
            </Message>
          </FormField>

          <Button type="submit" label="Anmelden" icon="pi pi-sign-in" :loading="loading" fluid />
        </Form>
      </template>
    </Card>
  </div>
</template>

<style scoped>
.login-view {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 1rem;
}

.login-card {
  width: 100%;
  max-width: 24rem;
}

.login-card__brand {
  color: var(--p-primary-color);
  font-weight: 700;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.login-form__field {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}
</style>
