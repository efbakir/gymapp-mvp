import { createAppleConnectClientFromEnv } from "./apple"
import { BlobReleaseCatalogStore } from "./store"
import { UpdatesSyncService } from "./sync"

export function createUpdatesSyncService(): UpdatesSyncService {
  return new UpdatesSyncService(
    createAppleConnectClientFromEnv(),
    new BlobReleaseCatalogStore(),
  )
}

export function updatesErrorCode(error: unknown): string {
  if (!(error instanceof Error)) return "UPDATES_UNKNOWN_ERROR"
  const code = error.message.split(":")[0]
  return /^[A-Z0-9_]+$/.test(code) ? code : "UPDATES_UNKNOWN_ERROR"
}

export function unresolvedVersionDetails(error: unknown): string | undefined {
  if (!(error instanceof Error)) return undefined
  const [code, versions] = error.message.split(":", 2)
  if (
    ![
      "UPDATES_RELEASE_DATE_UNRESOLVED",
      "UPDATES_RELEASE_DATES_UNRESOLVED",
    ].includes(code) ||
    !versions ||
    !/^[a-zA-Z0-9._,-]+$/.test(versions)
  ) {
    return undefined
  }
  return versions
}

export function logUpdatesEvent(
  level: "info" | "warn" | "error",
  event: string,
  details: Record<string, string | number | boolean | undefined>,
): void {
  const payload = JSON.stringify({
    scope: "updates",
    event,
    ...details,
  })
  if (level === "error") console.error(payload)
  else if (level === "warn") console.warn(payload)
  else console.info(payload)
}
