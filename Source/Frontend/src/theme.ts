import { definePreset } from '@primeuix/themes'
import Aura from '@primeuix/themes/aura'

// CaterMate brand palette (see Doc / brand guide):
//   Avocado    #7AAA28  primary
//   Deep Teal  #20A090  accent
//   Rot-Orange #E84020  destructive
//   Espresso   #3E2818  text
//   Sand       #EAE0CC  surface
//   Basis hell #FBF7F1  app background
export const CaterMatePreset = definePreset(Aura, {
  semantic: {
    primary: {
      50: '#f3f8e8',
      100: '#e3eecb',
      200: '#d0e2a8',
      300: '#bcd683',
      400: '#9bc04f',
      500: '#7aaa28',
      600: '#6b9523',
      700: '#55751a',
      800: '#3f5713',
      900: '#2c3c0d',
      950: '#1a2407',
    },
  },
})
