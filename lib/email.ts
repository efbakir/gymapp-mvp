// Single source of truth for email validation. Used by:
// - lib/waitlist.ts (server) before calling Resend
// - components/marketing/WaitlistForm.tsx (client) to gate the submit
//   button so the user sees instant feedback instead of a server error.
// Permissive RFC-5321-ish; good enough for a marketing waitlist input.
export function isValidEmail(value: unknown): value is string {
  if (typeof value !== "string") return false
  if (value.length < 5 || value.length > 254) return false
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
}
