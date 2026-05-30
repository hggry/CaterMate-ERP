<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import Button from 'primevue/button'
import Panel from 'primevue/panel'
import InputText from 'primevue/inputtext'
import ProgressSpinner from 'primevue/progressspinner'
import { companySettingsApi } from '@/services/companySettingsApi'
import { useToast } from '@/composables/useToast'
import { apiErrorMessage } from '@/types/api'
import type { UpdateCompanySettingsRequest } from '@/types/companySettings'

const toast = useToast()

const loading = ref(true)
const saving = ref(false)
const uploading = ref(false)
const hasLogo = ref(false)
const logoKey = ref(0) // bump to force <img> reload

const form = reactive<UpdateCompanySettingsRequest>({
  companyName: '',
  street: '',
  postalCode: '',
  city: '',
  country: 'Österreich',
  phone: '',
  email: '',
  website: '',
  vatId: '',
  taxNumber: '',
  iban: '',
  bic: '',
  bankName: '',
  commercialRegNo: '',
  commercialCourt: '',
})

onMounted(async () => {
  try {
    const dto = await companySettingsApi.get()
    Object.assign(form, {
      companyName:     dto.companyName,
      street:          dto.street          ?? '',
      postalCode:      dto.postalCode      ?? '',
      city:            dto.city            ?? '',
      country:         dto.country         ?? 'Österreich',
      phone:           dto.phone           ?? '',
      email:           dto.email           ?? '',
      website:         dto.website         ?? '',
      vatId:           dto.vatId           ?? '',
      taxNumber:       dto.taxNumber       ?? '',
      iban:            dto.iban            ?? '',
      bic:             dto.bic             ?? '',
      bankName:        dto.bankName        ?? '',
      commercialRegNo: dto.commercialRegNo ?? '',
      commercialCourt: dto.commercialCourt ?? '',
    })
    hasLogo.value = dto.hasLogo
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    loading.value = false
  }
})

async function save(): Promise<void> {
  if (!form.companyName.trim()) {
    toast.error('Firmenname ist erforderlich.')
    return
  }
  saving.value = true
  try {
    await companySettingsApi.update(form)
    toast.success('Einstellungen gespeichert.')
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    saving.value = false
  }
}

async function onLogoSelected(event: Event): Promise<void> {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  uploading.value = true
  try {
    const dto = await companySettingsApi.uploadLogo(file)
    hasLogo.value = dto.hasLogo
    logoKey.value++ // force <img> to reload
    toast.success('Logo hochgeladen.')
  } catch (e) {
    toast.error(apiErrorMessage(e))
  } finally {
    uploading.value = false
  }
}

function triggerLogoInput(): void {
  document.getElementById('logo-file-input')?.click()
}
</script>

<template>
  <div class="settings">
    <h1>Unternehmenseinstellungen</h1>

    <div v-if="loading" class="settings__center">
      <ProgressSpinner style="width: 3rem; height: 3rem" />
    </div>

    <template v-else>
      <div class="settings__grid">
        <!-- Firma -->
        <Panel header="Firma">
          <div class="settings__fields">
            <div class="settings__field settings__field--full">
              <label>Firmenname *</label>
              <InputText v-model="form.companyName" fluid placeholder="Muster GmbH" />
            </div>
            <div class="settings__field settings__field--full">
              <label>Straße</label>
              <InputText v-model="form.street" fluid placeholder="Musterstraße 1" />
            </div>
            <div class="settings__field">
              <label>PLZ</label>
              <InputText v-model="form.postalCode" fluid placeholder="1010" />
            </div>
            <div class="settings__field">
              <label>Ort</label>
              <InputText v-model="form.city" fluid placeholder="Wien" />
            </div>
            <div class="settings__field settings__field--full">
              <label>Land</label>
              <InputText v-model="form.country" fluid />
            </div>
          </div>
        </Panel>

        <!-- Kontakt -->
        <Panel header="Kontakt">
          <div class="settings__fields">
            <div class="settings__field settings__field--full">
              <label>Telefon</label>
              <InputText v-model="form.phone" fluid placeholder="+43 1 234 5678" />
            </div>
            <div class="settings__field settings__field--full">
              <label>E-Mail</label>
              <InputText v-model="form.email" fluid type="email" placeholder="office@firma.at" />
            </div>
            <div class="settings__field settings__field--full">
              <label>Website</label>
              <InputText v-model="form.website" fluid placeholder="https://www.firma.at" />
            </div>
          </div>
        </Panel>

        <!-- Steuer -->
        <Panel header="Steuer">
          <div class="settings__fields">
            <div class="settings__field settings__field--full">
              <label>UID-Nummer</label>
              <InputText v-model="form.vatId" fluid placeholder="ATU12345678" />
            </div>
            <div class="settings__field settings__field--full">
              <label>Steuernummer</label>
              <InputText v-model="form.taxNumber" fluid placeholder="12 345/6789" />
            </div>
          </div>
        </Panel>

        <!-- Bank -->
        <Panel header="Bankverbindung">
          <div class="settings__fields">
            <div class="settings__field settings__field--full">
              <label>IBAN</label>
              <InputText v-model="form.iban" fluid placeholder="AT12 3456 7890 1234 5678" />
            </div>
            <div class="settings__field">
              <label>BIC</label>
              <InputText v-model="form.bic" fluid placeholder="BKAUATWW" />
            </div>
            <div class="settings__field">
              <label>Bankname</label>
              <InputText v-model="form.bankName" fluid placeholder="Musterbank AG" />
            </div>
          </div>
        </Panel>

        <!-- Rechtliches -->
        <Panel header="Rechtliches">
          <div class="settings__fields">
            <div class="settings__field settings__field--full">
              <label>Firmenbuchnummer</label>
              <InputText v-model="form.commercialRegNo" fluid placeholder="123456a" />
            </div>
            <div class="settings__field settings__field--full">
              <label>Handelsgericht</label>
              <InputText v-model="form.commercialCourt" fluid placeholder="Handelsgericht Wien" />
            </div>
          </div>
        </Panel>

        <!-- Logo -->
        <Panel header="Firmenlogo">
          <div class="settings__logo">
            <div v-if="hasLogo" class="settings__logo-preview">
              <img
                :key="logoKey"
                :src="`${companySettingsApi.logoUrl()}?t=${logoKey}`"
                alt="Firmenlogo"
                class="settings__logo-img"
              />
            </div>
            <div v-else class="settings__logo-placeholder">
              <i class="pi pi-image" />
              <span>Noch kein Logo hinterlegt</span>
            </div>

            <input
              id="logo-file-input"
              type="file"
              accept=".png,.jpg,.jpeg,.webp"
              class="settings__logo-input"
              @change="onLogoSelected"
            />
            <Button
              :label="uploading ? 'Wird hochgeladen…' : (hasLogo ? 'Logo ersetzen' : 'Logo hochladen')"
              icon="pi pi-upload"
              severity="secondary"
              outlined
              :loading="uploading"
              @click="triggerLogoInput"
            />
            <p class="settings__logo-hint">PNG, JPG oder WebP · max. 2 MB</p>
          </div>
        </Panel>
      </div>

      <!-- Save button -->
      <div class="settings__actions">
        <Button
          label="Änderungen speichern"
          icon="pi pi-save"
          :loading="saving"
          @click="save"
        />
      </div>
    </template>
  </div>
</template>

<style scoped>
.settings {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.settings h1 {
  margin: 0;
}

.settings__center {
  display: flex;
  justify-content: center;
  padding: 3rem;
}

.settings__grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  align-items: start;
}

@media (max-width: 900px) {
  .settings__grid {
    grid-template-columns: 1fr;
  }
}

.settings__fields {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.875rem;
}

.settings__field {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.settings__field label {
  font-size: 0.8125rem;
  color: var(--p-text-muted-color);
}

.settings__field--full {
  grid-column: 1 / -1;
}

/* Logo panel */
.settings__logo {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 0.75rem;
}

.settings__logo-preview {
  width: 100%;
  max-width: 180px;
  border: 1px solid var(--p-content-border-color);
  border-radius: var(--p-border-radius, 6px);
  padding: 0.5rem;
  background: var(--p-content-background);
}

.settings__logo-img {
  width: 100%;
  height: auto;
  object-fit: contain;
  display: block;
}

.settings__logo-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  width: 180px;
  height: 120px;
  border: 1px dashed var(--p-content-border-color);
  border-radius: var(--p-border-radius, 6px);
  color: var(--p-text-muted-color);
  font-size: 0.875rem;
}

.settings__logo-placeholder i {
  font-size: 2rem;
}

.settings__logo-input {
  display: none;
}

.settings__logo-hint {
  margin: 0;
  font-size: 0.75rem;
  color: var(--p-text-muted-color);
}

.settings__actions {
  display: flex;
  justify-content: flex-end;
  padding-top: 0.5rem;
}
</style>
