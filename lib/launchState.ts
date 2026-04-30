// Single source of truth for whether Unit has launched on the App Store.
// Pre-launch: hero CTA is the waitlist email form, post-launch swaps to the
// App Store badge. The page reads `isLaunched` and chooses what to render.
export const APP_STORE_URL = process.env.NEXT_PUBLIC_APP_STORE_URL ?? ""
export const isLaunched = APP_STORE_URL.length > 0

// Trust band counter visibility. Below this threshold the band shows the
// founder line instead of "X lifters waiting" to avoid the "12 people on
// the waitlist" cringe.
export const COUNTER_VISIBILITY_THRESHOLD = 50
