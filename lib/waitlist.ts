import { Resend } from "resend"

export { isValidEmail } from "@/lib/email"

const RESEND_API_KEY = process.env.RESEND_API_KEY ?? ""
const RESEND_AUDIENCE_ID = process.env.RESEND_AUDIENCE_ID ?? ""

export const isResendConfigured =
  RESEND_API_KEY.length > 0 && RESEND_AUDIENCE_ID.length > 0

const resend = isResendConfigured ? new Resend(RESEND_API_KEY) : null

export async function addToWaitlist(email: string): Promise<{
  ok: boolean
  alreadyOnList?: boolean
  error?: string
}> {
  if (!resend) {
    // Stub mode: log and accept until Resend keys are added. Lets the form
    // work end-to-end in local dev without a Resend account.
    console.log(`[waitlist:stub] ${email}`)
    return { ok: true }
  }
  try {
    const result = await resend.contacts.create({
      audienceId: RESEND_AUDIENCE_ID,
      email,
      unsubscribed: false,
    })
    if (result.error) {
      // Resend returns "already_exists" when the email is already a contact.
      const message = (result.error.message ?? "").toLowerCase()
      if (message.includes("already") || message.includes("exists")) {
        return { ok: true, alreadyOnList: true }
      }
      return { ok: false, error: result.error.message ?? "Resend error" }
    }
    return { ok: true }
  } catch (err) {
    const message = err instanceof Error ? err.message : "Unknown error"
    return { ok: false, error: message }
  }
}

export async function getWaitlistCount(): Promise<number | null> {
  if (!resend) return null
  try {
    const result = await resend.contacts.list({ audienceId: RESEND_AUDIENCE_ID })
    if (result.error || !result.data) return null
    return result.data.data?.length ?? 0
  } catch {
    return null
  }
}
