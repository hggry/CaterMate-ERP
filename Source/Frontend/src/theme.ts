import { definePreset } from '@primeuix/themes'
import Aura from '@primeuix/themes/aura'

// CaterMate brand palette (see Doc / code-guidelines.md):
//   Basis hell  #FBF7F1  app background
//   Sand        #EAE0CC  surface / alternate row
//   Caramel     #C2A87C  mid-tone warm accent
//   Espresso    #3E2818  primary dark text / headings
//   Avocado     #7AAA28  primary brand green (maps to --p-primary-color)
//   Deep Teal   #20A090  secondary accent
//   Rot-Orange  #E84020  destructive / alert
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
    colorScheme: {
      // Dark mode uses a cool-neutral dark grey scale — readable, settled, not brown.
      dark: {
        surface: {
          0:   '#ffffff',
          50:  '#f4f4f6',
          100: '#e2e2e8',
          200: '#c4c4ce',
          300: '#9898a6',
          400: '#6e6e7e',
          500: '#4e4e5a',
          600: '#3a3a44',
          700: '#2a2a32',  // primary card/panel surface
          800: '#202026',
          900: '#18181e',  // page background
          950: '#111116',
        },
      },
    },
  },
})
