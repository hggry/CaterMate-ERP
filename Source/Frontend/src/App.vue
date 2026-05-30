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

/* ── Dark Mode Token Overrides ──────────────────────────────────────────── */
/* Applied when <html class="app-dark"> is set by themeStore.               */
/* Cool-neutral dark scale — greys with a slight blue-grey undertone.       */
.app-dark {
  --catermate-bg:   #18181e;   /* Page background — deep neutral dark      */
  --cm-basis-hell:  #eeeef2;   /* Primary text — cool near-white           */
  --cm-sand:        #2a2a32;   /* Elevated surface / alt-rows              */
  --cm-caramel:     #b8a882;   /* Muted accent text — still warm but subtle */
  --cm-espresso:    #eeeef2;   /* Repurposed as light text in dark mode    */
  --cm-avocado:     #8cc42e;   /* Avocado (brighter for dark bg contrast)  */
  --cm-teal:        #25b5a3;   /* Teal (brighter)                          */
  --cm-teal-light:  #6dd0c6;   /* Light teal (brighter)                    */
  --cm-orange:      #f04828;   /* Rot-Orange (slightly brighter)           */
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
