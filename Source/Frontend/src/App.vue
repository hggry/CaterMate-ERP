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
/* ── CaterMate Brand Token ───────────────────────────────────────────────── */
:root {
  --cm-basis-hell:  #fbf7f1;   /* App background                */
  --cm-sand:        #eae0cc;   /* Surface / alternate row       */
  --cm-caramel:     #c2a87c;   /* Mid-tone warm accent          */
  --cm-espresso:    #3e2818;   /* Primary dark text / headings  */
  --cm-avocado:     #7aaa28;   /* Primary brand green           */
  --cm-teal:        #20a090;   /* Secondary accent              */
  --cm-teal-light:  #5bc4b8;   /* Light teal — quote/procurement stage */
  --cm-orange:      #e84020;   /* Destructive / alert           */

  --catermate-bg: var(--cm-basis-hell);
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
