import { NextResponse } from "next/server"
import { addToWaitlist, isValidEmail } from "@/lib/waitlist"

export const runtime = "nodejs"
export const dynamic = "force-dynamic"

export async function POST(request: Request) {
  let body: unknown
  try {
    body = await request.json()
  } catch {
    return NextResponse.json(
      { ok: false, error: "Invalid request body." },
      { status: 400 }
    )
  }

  const email = (body as { email?: unknown })?.email
  if (!isValidEmail(email)) {
    return NextResponse.json(
      { ok: false, error: "Enter a valid email." },
      { status: 400 }
    )
  }

  const result = await addToWaitlist(email.trim().toLowerCase())
  if (!result.ok) {
    return NextResponse.json(
      { ok: false, error: result.error ?? "Couldn't sign you up." },
      { status: 502 }
    )
  }
  return NextResponse.json({ ok: true, alreadyOnList: !!result.alreadyOnList })
}
