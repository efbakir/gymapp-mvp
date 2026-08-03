import { revalidatePath } from "next/cache"
import {
  createUpdatesSyncService,
  logUpdatesEvent,
  unresolvedVersionDetails,
  updatesErrorCode,
} from "@/lib/updates/runtime"
import { verifyAppleSignature } from "@/lib/updates/security"
import { parseWebhookDecision } from "@/lib/updates/webhook"

export const runtime = "nodejs"
export const maxDuration = 30

export async function POST(request: Request): Promise<Response> {
  const startedAt = Date.now()
  const secret = process.env.APP_STORE_WEBHOOK_SECRET ?? ""
  if (!secret) {
    logUpdatesEvent("error", "webhook_configuration_error", {
      code: "UPDATES_CONFIG_MISSING_APP_STORE_WEBHOOK_SECRET",
    })
    return new Response("Service unavailable", { status: 503 })
  }

  const rawBody = new Uint8Array(await request.arrayBuffer())
  if (
    !verifyAppleSignature(
      rawBody,
      request.headers.get("x-apple-signature"),
      secret,
    )
  ) {
    logUpdatesEvent("warn", "webhook_rejected", {
      code: "UPDATES_WEBHOOK_SIGNATURE_INVALID",
    })
    return new Response("Unauthorized", { status: 401 })
  }

  let payload: unknown
  try {
    payload = JSON.parse(Buffer.from(rawBody).toString("utf8"))
  } catch {
    logUpdatesEvent("warn", "webhook_rejected", {
      code: "UPDATES_WEBHOOK_JSON_INVALID",
    })
    return new Response("Invalid JSON", { status: 400 })
  }

  const decision = parseWebhookDecision(payload)
  if (decision.kind === "ignored") {
    logUpdatesEvent("info", "webhook_ignored", {
      eventId: decision.eventId,
      reason: decision.reason,
      durationMs: Date.now() - startedAt,
    })
    return new Response(null, { status: 204 })
  }
  if (decision.kind === "rejected") {
    logUpdatesEvent("warn", "webhook_rejected", {
      code: decision.code,
      eventId: decision.eventId,
    })
    return new Response("Invalid webhook payload", { status: decision.status })
  }

  try {
    const result = await createUpdatesSyncService().syncVersion({
      versionId: decision.versionId,
      webhookTimestamp: decision.timestamp,
      attempts: 2,
    })
    if (result.changed) revalidatePath("/updates")
    logUpdatesEvent("info", "webhook_sync_succeeded", {
      trigger: "webhook",
      eventId: decision.eventId,
      versionId: decision.versionId,
      versionString: result.versionStrings[0],
      attemptLimit: 2,
      changed: result.changed,
      added: result.added,
      updated: result.updated,
      releaseCount: result.releaseCount,
      durationMs: Date.now() - startedAt,
    })
    return new Response(null, { status: 204 })
  } catch (error) {
    logUpdatesEvent("error", "webhook_sync_failed", {
      trigger: "webhook",
      eventId: decision.eventId,
      versionId: decision.versionId,
      attemptLimit: 2,
      code: updatesErrorCode(error),
      unresolvedVersions: unresolvedVersionDetails(error),
      durationMs: Date.now() - startedAt,
    })
    return new Response("Temporary sync failure", { status: 503 })
  }
}
