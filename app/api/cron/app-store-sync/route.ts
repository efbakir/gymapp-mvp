import { revalidatePath } from "next/cache"
import {
  createUpdatesSyncService,
  logUpdatesEvent,
  unresolvedVersionDetails,
  updatesErrorCode,
} from "@/lib/updates/runtime"
import { verifyBearerSecret } from "@/lib/updates/security"

export const runtime = "nodejs"
export const maxDuration = 60

export async function GET(request: Request): Promise<Response> {
  const startedAt = Date.now()
  const secret = process.env.CRON_SECRET ?? ""
  if (!secret) {
    logUpdatesEvent("error", "cron_sync_configuration_error", {
      code: "UPDATES_CONFIG_MISSING_CRON_SECRET",
    })
    return Response.json({ ok: false, error: "Service unavailable" }, { status: 503 })
  }
  if (!verifyBearerSecret(request.headers.get("authorization"), secret)) {
    return Response.json({ ok: false, error: "Unauthorized" }, { status: 401 })
  }

  try {
    const result = await createUpdatesSyncService().syncAll({ attempts: 3 })
    if (result.changed) revalidatePath("/updates")
    logUpdatesEvent("info", "cron_sync_succeeded", {
      trigger: "cron",
      versionStrings: result.versionStrings.join(","),
      attemptLimit: 3,
      changed: result.changed,
      added: result.added,
      updated: result.updated,
      releaseCount: result.releaseCount,
      durationMs: Date.now() - startedAt,
    })
    return Response.json({
      ok: true,
      changed: result.changed,
      added: result.added,
      updated: result.updated,
      releaseCount: result.releaseCount,
    })
  } catch (error) {
    const code = updatesErrorCode(error)
    logUpdatesEvent("error", "cron_sync_failed", {
      trigger: "cron",
      attemptLimit: 3,
      code,
      unresolvedVersions: unresolvedVersionDetails(error),
      durationMs: Date.now() - startedAt,
    })
    return Response.json({ ok: false, error: code }, { status: 503 })
  }
}
