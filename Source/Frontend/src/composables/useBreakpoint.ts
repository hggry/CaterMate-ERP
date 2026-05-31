import { onUnmounted, ref, type Ref } from 'vue'

// Unified responsive breakpoints (px). The desktop tier (>= 1024px) mirrors the
// original, deliberately untouched design; the tablet (768–1023px) and phone
// (< 768px) tiers drive every adaptive behaviour in the app.
export const BREAKPOINTS = {
  phone: 768,
  desktop: 1024,
} as const

// Reactive wrapper around a single matchMedia query. Returns a ref that stays in
// sync with the viewport and cleans up its listener on unmount.
function useMediaQuery(query: string): Ref<boolean> {
  const matches = ref(false)
  if (typeof window !== 'undefined' && typeof window.matchMedia === 'function') {
    const mql = window.matchMedia(query)
    matches.value = mql.matches
    const handler = (e: MediaQueryListEvent): void => {
      matches.value = e.matches
    }
    mql.addEventListener('change', handler)
    onUnmounted(() => mql.removeEventListener('change', handler))
  }
  return matches
}

// Shared reactive viewport state. The 0.02px offsets avoid an overlap gap
// between adjacent ranges at exact breakpoint widths.
export function useBreakpoint() {
  const isPhone = useMediaQuery(`(max-width: ${BREAKPOINTS.phone - 0.02}px)`)
  const isTablet = useMediaQuery(
    `(min-width: ${BREAKPOINTS.phone}px) and (max-width: ${BREAKPOINTS.desktop - 0.02}px)`,
  )
  const isDesktop = useMediaQuery(`(min-width: ${BREAKPOINTS.desktop}px)`)
  // True below the desktop tier — drives the off-canvas navigation drawer.
  const isCompactNav = useMediaQuery(`(max-width: ${BREAKPOINTS.desktop - 0.02}px)`)

  return { isPhone, isTablet, isDesktop, isCompactNav }
}
