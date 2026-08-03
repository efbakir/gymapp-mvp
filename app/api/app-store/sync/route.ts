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

type SyncRequest =
  | { mode: "full" }
  | { mode: "version"; versionId: string }
  | { mode: "revalidate" }

function parseSyncRequest(value: unknown): SyncRequest | null {
  if (!value || typeof value !== "object") return null
  const request = value as { mode?: unknown; versionId?: unknown }
  if (request.mode === "full") return { mode: "full" }
  if (request.mode === "revalidate") return { mode: "revalidate" }
  if (
    request.mode === "version" &&
    typeof request.versionId === "string" &&
    request.versionId.length > 0 &&
    request.versionId.length <= 200
  ) {
    return { mode: "version", versionId: request.versionId }
  }
  return null
}

export async function POST(request: Request): Promise<Response> {
  const startedAt = Date.now()
  const secret = process.env.UPDATES_SYNC_SECRET ?? ""
  if (!secret) {
    logUpdatesEvent("error", "manual_sync_configuration_error", {
      code: "UPDATES_CONFIG_MISSING_UPDATES_SYNC_SECRET",
    })
    return Response.json({ ok: false, error: "Service unavailable" }, { status: 503 })
  }
  if (!verifyBearerSecret(request.headers.get("authorization"), secret)) {
    return Response.json({ ok: false, error: "Unauthorized" }, { status: 401 })
  }

  let body: unknown
  try {
    body = await request.json()
  } catch {
    return Response.json({ ok: false, error: "Invalid JSON" }, { status: 400 })
  }
  const syncRequest = parseSyncRequest(body)
  if (!syncRequest) {
    return Response.json({ ok: false, error: "Invalid sync request" }, { status: 400 })
  }

  try {
    if (syncRequest.mode === "revalidate") {
      revalidatePath("/updates")
      logUpdatesEvent("info", "manual_revalidation_succeeded", {
        durationMs: Date.now() - startedAt,
      })
      return Response.json({ ok: true, revalidated: true })
    }

    const service = createUpdatesSyncService()
    const attemptLimit = syncRequest.mode === "full" ? 3 : 2
    const result =
      syncRequest.mode === "full"
        ? await service.syncAll({ attempts: 3 })
        : await service.syncVersion({
            versionId: syncRequest.versionId,
            attempts: 2,
          })
    if (result.changed) revalidatePath("/updates")
    logUpdatesEvent("info", "manual_sync_succeeded", {
      trigger: "manual",
      mode: syncRequest.mode,
      versionId:
        syncRequest.mode === "version" ? syncRequest.versionId : undefined,
      versionStrings: result.versionStrings.join(","),
      attemptLimit,
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
      ignored: result.ignored,
    })
  } catch (error) {
    const code = updatesErrorCode(error)
    logUpdatesEvent("error", "manual_sync_failed", {
      trigger: "manual",
      mode: syncRequest.mode,
      versionId:
        syncRequest.mode === "version" ? syncRequest.versionId : undefined,
      attemptLimit: syncRequest.mode === "full" ? 3 : 2,
      code,
      unresolvedVersions: unresolvedVersionDetails(error),
      durationMs: Date.now() - startedAt,
    })
    return Response.json(
      {
        ok: false,
        error: code,
        unresolvedVersions: unresolvedVersionDetails(error)?.split(","),
      },
      { status: 503 },
    )
  }
}
