export const UPDATES_SCHEMA_VERSION = 1 as const
export const UPDATES_PLATFORM = "IOS" as const

export const PUBLIC_APP_VERSION_STATES = new Set([
  "READY_FOR_DISTRIBUTION",
  "REPLACED_WITH_NEW_VERSION",
])

export type ReleasedAtSource =
  | "webhook"
  | "earliestReleaseDate"
  | "appleLookupInitial"
  | "appleLookupCurrent"
  | "ascHistoryBootstrap"

export type ReleaseRecord = {
  key: string
  appStoreVersionId: string
  versionString: string
  locale: string
  localizationId: string | null
  releasedAt: string
  releasedAtSource: ReleasedAtSource
  whatsNew: string | null
  contentHash: string
  firstPublishedAt: string
  lastChangedAt: string
}

export type ReleaseCatalog = {
  schemaVersion: typeof UPDATES_SCHEMA_VERSION
  app: {
    id: string
    platform: typeof UPDATES_PLATFORM
    primaryLocale: string
  }
  updatedAt: string
  releases: ReleaseRecord[]
}

export type IncomingRelease = Omit<
  ReleaseRecord,
  "key" | "contentHash" | "firstPublishedAt" | "lastChangedAt"
>

export type CatalogApp = ReleaseCatalog["app"]

export type CatalogMergeResult = {
  catalog: ReleaseCatalog
  changed: boolean
  added: number
  updated: number
}

export type SyncResult = {
  changed: boolean
  added: number
  updated: number
  releaseCount: number
  versionStrings: string[]
  ignored?: "not-public"
}

export type AppleApp = {
  id: string
  name: string
  bundleId: string
  primaryLocale: string
}

export type AppleVersionLocalization = {
  id: string
  locale: string
  whatsNew: string | null
}

export type AppleVersion = {
  id: string
  appId: string
  platform: string
  versionString: string
  appVersionState: string
  earliestReleaseDate: string | null
  localizations: AppleVersionLocalization[]
}

export type AppleLookupDates = {
  version: string | null
  currentVersionReleaseDate: string | null
  releaseDate: string | null
}

export interface AppStoreClient {
  getApp(attempts?: number): Promise<AppleApp>
  getVersion(versionId: string, attempts?: number): Promise<AppleVersion>
  listVersions(attempts?: number): Promise<AppleVersion[]>
  getLookupDates(attempts?: number): Promise<AppleLookupDates>
}

export interface ReleaseCatalogStore {
  readCatalog(options?: { useCache?: boolean }): Promise<ReleaseCatalog | null>
  mergeAndWrite(
    app: CatalogApp,
    incoming: IncomingRelease[],
    now: string,
  ): Promise<CatalogMergeResult>
}

const releasedAtSources = new Set<ReleasedAtSource>([
  "webhook",
  "earliestReleaseDate",
  "appleLookupInitial",
  "appleLookupCurrent",
  "ascHistoryBootstrap",
])

function isString(value: unknown): value is string {
  return typeof value === "string"
}

function isNullableString(value: unknown): value is string | null {
  return value === null || isString(value)
}

function isIsoDate(value: string): boolean {
  const date = new Date(value)
  return !Number.isNaN(date.getTime()) && date.toISOString() === value
}

function isReleaseRecord(value: unknown): value is ReleaseRecord {
  if (!value || typeof value !== "object") return false
  const record = value as Partial<ReleaseRecord>
  return (
    isString(record.key) &&
    isString(record.appStoreVersionId) &&
    isString(record.versionString) &&
    isString(record.locale) &&
    isNullableString(record.localizationId) &&
    isString(record.releasedAt) &&
    releasedAtSources.has(record.releasedAtSource as ReleasedAtSource) &&
    isNullableString(record.whatsNew) &&
    isString(record.contentHash) &&
    isString(record.firstPublishedAt) &&
    isString(record.lastChangedAt)
  )
}

export function parseReleaseCatalog(value: unknown): ReleaseCatalog {
  if (!value || typeof value !== "object") {
    throw new Error("UPDATES_CATALOG_INVALID")
  }

  const catalog = value as Partial<ReleaseCatalog>
  const app = catalog.app as Partial<CatalogApp> | undefined
  if (
    catalog.schemaVersion !== UPDATES_SCHEMA_VERSION ||
    !app ||
    !isString(app.id) ||
    app.platform !== UPDATES_PLATFORM ||
    !isString(app.primaryLocale) ||
    !isString(catalog.updatedAt) ||
    !Array.isArray(catalog.releases) ||
    !catalog.releases.every(isReleaseRecord)
  ) {
    throw new Error("UPDATES_CATALOG_INVALID")
  }

  const parsed = catalog as ReleaseCatalog
  if (
    parsed.app.id.length === 0 ||
    parsed.app.primaryLocale.length === 0 ||
    !isIsoDate(parsed.updatedAt)
  ) {
    throw new Error("UPDATES_CATALOG_INVALID")
  }

  const keys = new Set<string>()
  const idsByVersion = new Map<string, string>()
  for (const release of parsed.releases) {
    const expectedKey = `${parsed.app.id}:IOS:${release.appStoreVersionId}`
    const existingId = idsByVersion.get(release.versionString)
    if (
      release.key !== expectedKey ||
      release.locale !== parsed.app.primaryLocale ||
      !/^[a-f0-9]{64}$/.test(release.contentHash) ||
      !isIsoDate(release.releasedAt) ||
      !isIsoDate(release.firstPublishedAt) ||
      !isIsoDate(release.lastChangedAt) ||
      keys.has(release.key) ||
      (existingId !== undefined &&
        existingId !== release.appStoreVersionId)
    ) {
      throw new Error("UPDATES_CATALOG_INVALID")
    }
    keys.add(release.key)
    idsByVersion.set(release.versionString, release.appStoreVersionId)
  }

  return parsed
}
