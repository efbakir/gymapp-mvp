import { createHash } from "node:crypto"
import { compareReleasesNewestFirst, normalizeReleaseNotes } from "./format"
import {
  UPDATES_SCHEMA_VERSION,
  type CatalogApp,
  type CatalogMergeResult,
  type IncomingRelease,
  type ReleaseCatalog,
  type ReleaseRecord,
  type ReleasedAtSource,
} from "./types"

const sourcePriority: Record<ReleasedAtSource, number> = {
  earliestReleaseDate: 1,
  appleLookupInitial: 2,
  appleLookupCurrent: 2,
  ascHistoryBootstrap: 3,
  webhook: 4,
}

function releaseKey(appId: string, appStoreVersionId: string): string {
  return `${appId}:IOS:${appStoreVersionId}`
}

function contentHash(record: {
  versionString: string
  locale: string
  localizationId: string | null
  releasedAt: string
  releasedAtSource: ReleasedAtSource
  whatsNew: string | null
}): string {
  return createHash("sha256")
    .update(
      JSON.stringify({
        versionString: record.versionString,
        locale: record.locale,
        localizationId: record.localizationId,
        releasedAt: record.releasedAt,
        releasedAtSource: record.releasedAtSource,
        whatsNew: record.whatsNew,
      }),
    )
    .digest("hex")
}

function normalizeIsoDate(value: string): string {
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) throw new Error("RELEASE_DATE_INVALID")
  return date.toISOString()
}

function mergeRecord(
  appId: string,
  incoming: IncomingRelease,
  existing: ReleaseRecord | undefined,
  now: string,
): { record: ReleaseRecord; changed: boolean } {
  const normalizedNotes = normalizeReleaseNotes(incoming.whatsNew)
  const keepExistingDate =
    existing &&
    sourcePriority[existing.releasedAtSource] >
      sourcePriority[incoming.releasedAtSource]

  const releasedAt = normalizeIsoDate(
    keepExistingDate ? existing.releasedAt : incoming.releasedAt,
  )
  const releasedAtSource = keepExistingDate
    ? existing.releasedAtSource
    : incoming.releasedAtSource
  const whatsNew =
    normalizedNotes === null && existing?.whatsNew
      ? existing.whatsNew
      : normalizedNotes
  const localizationId =
    incoming.localizationId ?? existing?.localizationId ?? null
  const hash = contentHash({
    versionString: incoming.versionString,
    locale: incoming.locale,
    localizationId,
    releasedAt,
    releasedAtSource,
    whatsNew,
  })
  const changed = !existing || existing.contentHash !== hash

  return {
    changed,
    record: {
      key: releaseKey(appId, incoming.appStoreVersionId),
      appStoreVersionId: incoming.appStoreVersionId,
      versionString: incoming.versionString,
      locale: incoming.locale,
      localizationId,
      releasedAt,
      releasedAtSource,
      whatsNew,
      contentHash: hash,
      firstPublishedAt: existing?.firstPublishedAt ?? now,
      lastChangedAt: changed ? now : existing.lastChangedAt,
    },
  }
}

function assertNoVersionCollision(
  releases: ReleaseRecord[],
  incoming: IncomingRelease[],
): void {
  const idsByVersion = new Map<string, string>()
  for (const release of releases) {
    const existingId = idsByVersion.get(release.versionString)
    if (existingId && existingId !== release.appStoreVersionId) {
      throw new Error("UPDATES_VERSION_COLLISION")
    }
    idsByVersion.set(release.versionString, release.appStoreVersionId)
  }
  for (const release of incoming) {
    const existingId = idsByVersion.get(release.versionString)
    if (existingId && existingId !== release.appStoreVersionId) {
      throw new Error("UPDATES_VERSION_COLLISION")
    }
    idsByVersion.set(release.versionString, release.appStoreVersionId)
  }
}

export function mergeReleaseCatalog(
  current: ReleaseCatalog | null,
  app: CatalogApp,
  incoming: IncomingRelease[],
  nowValue: string,
): CatalogMergeResult {
  const now = normalizeIsoDate(nowValue)
  if (
    current &&
    (current.app.id !== app.id ||
      current.app.platform !== app.platform ||
      current.app.primaryLocale !== app.primaryLocale)
  ) {
    throw new Error("UPDATES_CATALOG_APP_MISMATCH")
  }

  assertNoVersionCollision(current?.releases ?? [], incoming)

  const byKey = new Map(
    (current?.releases ?? []).map((release) => [release.key, release]),
  )
  let added = 0
  let updated = 0

  for (const candidate of incoming) {
    const key = releaseKey(app.id, candidate.appStoreVersionId)
    const existing = byKey.get(key)
    const merged = mergeRecord(app.id, candidate, existing, now)
    byKey.set(key, merged.record)
    if (!existing) added += 1
    else if (merged.changed) updated += 1
  }

  const releases = [...byKey.values()].sort(compareReleasesNewestFirst)
  const appChanged =
    !current ||
    current.app.id !== app.id ||
    current.app.platform !== app.platform ||
    current.app.primaryLocale !== app.primaryLocale
  const changed = appChanged || added > 0 || updated > 0

  return {
    changed,
    added,
    updated,
    catalog: {
      schemaVersion: UPDATES_SCHEMA_VERSION,
      app,
      updatedAt: changed ? now : (current?.updatedAt ?? now),
      releases,
    },
  }
}
