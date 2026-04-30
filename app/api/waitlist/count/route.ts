import { NextResponse } from "next/server"
import { getWaitlistCount } from "@/lib/waitlist"

export const runtime = "nodejs"
// Cache the count for 60s so the trust band doesn't hammer Resend on every
// page request. Trust band is presentational; a minute of staleness is fine.
export const revalidate = 60

export async function GET() {
  const count = await getWaitlistCount()
  return NextResponse.json({ count })
}
