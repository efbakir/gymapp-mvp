import { compareVersionsAscending, normalizeReleaseNotes } from "./format"
import {
  PUBLIC_APP_VERSION_STATES,
  UPDATES_PLATFORM,
  type AppleApp,
  type AppleLookupDates,
  type AppleVersion,
  type AppStoreClient,
  type IncomingRelease,
  type ReleaseCatalog,
  type ReleaseCatalogStore,
  type ReleaseRecord,
  type ReleasedAtSource,
  type SyncResult,
} from "./types"

type ReleaseDate = {
  releasedAt: string
  releasedAtSource: ReleasedAtSource
}

function parseReleaseDateOverrides(): Record<string, string> {
  const raw = process.env.APP_STORE_RELEASE_DATE_OVERRIDES_JSON?.trim()
  if (!raw) return {}
  let value: unknown
  try {
    value = JSON.parse(raw)
  } catch {
    throw new Error("UPDATES_RELEASE_DATE_OVERRIDES_INVALID")
  }
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error("UPDATES_RELEASE_DATE_OVERRIDES_INVALID")
  }

  const result: Record<string, string> = {}
  for (const [version, dateValue] of Object.entries(value)) {
    if (typeof dateValue !== "string") {
      throw new Error("UPDATES_RELEASE_DATE_OVERRIDES_INVALID")
    }
    const parsed = new Date(dateValue)
    if (Number.isNaN(parsed.getTime())) {
      throw new Error("UPDATES_RELEASE_DATE_OVERRIDES_INVALID")
    }
    result[version] = parsed.toISOString()
  }
  return result
}

function normalizedDate(value: string, code: string): string {
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) throw new Error(code)
  return date.toISOString()
}

function assertVersionBelongsToApp(version: AppleVersion, app: AppleApp): void {
  if (version.appId !== app.id) throw new Error("UPDATES_VERSION_APP_MISMATCH")
  if (version.platform !== UPDATES_PLATFORM) {
    throw new Error("UPDATES_VERSION_PLATFORM_MISMATCH")
  }
}

function releaseFromExisting(record: ReleaseRecord | undefined): ReleaseDate | null {
  if (!record) return null
  return {
    releasedAt: record.releasedAt,
    releasedAtSource: record.releasedAtSource,
  }
}

function resolveReleaseDate({
  version,
  existing,
  webhookTimestamp,
  lookup,
  oldestVersion,
  overrides,
}: {
  version: AppleVersion
  existing?: ReleaseRecord
  webhookTimestamp?: string
  lookup: AppleLookupDates | null
  oldestVersion: string | null
  overrides: Record<string, string>
}): ReleaseDate | null {
  if (webhookTimestamp) {
    return {
      releasedAt: normalizedDate(
        webhookTimestamp,
        "UPDATES_WEBHOOK_TIMESTAMP_INVALID",
      ),
      releasedAtSource: "webhook",
    }
  }
  if (version.earliestReleaseDate) {
    return {
      releasedAt: normalizedDate(
        version.earliestReleaseDate,
        "UPDATES_EARLIEST_RELEASE_DATE_INVALID",
      ),
      releasedAtSource: "earliestReleaseDate",
    }
  }
  if (
    lookup?.version === version.versionString &&
    lookup.currentVersionReleaseDate
  ) {
    return {
      releasedAt: normalizedDate(
        lookup.currentVersionReleaseDate,
        "UPDATES_LOOKUP_DATE_INVALID",
      ),
      releasedAtSource: "appleLookupCurrent",
    }
  }
  if (
    oldestVersion === version.versionString &&
    lookup?.releaseDate
  ) {
    return {
      releasedAt: normalizedDate(
        lookup.releaseDate,
        "UPDATES_LOOKUP_DATE_INVALID",
      ),
      releasedAtSource: "appleLookupInitial",
    }
  }
  if (overrides[version.versionString]) {
    return {
      releasedAt: overrides[version.versionString],
      releasedAtSource: "ascHistoryBootstrap",
    }
  }
  return releaseFromExisting(existing)
}

function incomingRelease(
  version: AppleVersion,
  app: AppleApp,
  releaseDate: ReleaseDate,
): IncomingRelease {
  const localization = version.localizations.find(
    (item) => item.locale === app.primaryLocale,
  )
  return {
    appStoreVersionId: version.id,
    versionString: version.versionString,
    locale: app.primaryLocale,
    localizationId: localization?.id ?? null,
    releasedAt: releaseDate.releasedAt,
    releasedAtSource: releaseDate.releasedAtSource,
    whatsNew: normalizeReleaseNotes(localization?.whatsNew),
  }
}

function oldestVersionString(versions: AppleVersion[]): string | null {
  return (
    [...versions]
      .map((version) => version.versionString)
      .sort(compareVersionsAscending)[0] ?? null
  )
}

export class UpdatesSyncService {
  constructor(
    private readonly client: AppStoreClient,
    private readonly store: ReleaseCatalogStore,
    private readonly now: () => Date = () => new Date(),
  ) {}

  private async existingCatalog(): Promise<ReleaseCatalog | null> {
    return this.store.readCatalog({ useCache: false })
  }

  async syncVersion({
    versionId,
    webhookTimestamp,
    attempts = 2,
  }: {
    versionId: string
    webhookTimestamp?: string
    attempts?: number
  }): Promise<SyncResult> {
    const [app, version, current] = await Promise.all([
      this.client.getApp(attempts),
      this.client.getVersion(versionId, attempts),
      this.existingCatalog(),
    ])
    assertVersionBelongsToApp(version, app)

    if (!PUBLIC_APP_VERSION_STATES.has(version.appVersionState)) {
      if (webhookTimestamp) throw new Error("UPDATES_VERSION_NOT_PUBLIC_YET")
      return {
        changed: false,
        added: 0,
        updated: 0,
        releaseCount: current?.releases.length ?? 0,
        versionStrings: [],
        ignored: "not-public",
      }
    }

    const existing = current?.releases.find(
      (release) => release.appStoreVersionId === version.id,
    )
    let lookup: AppleLookupDates | null = null
    let oldestVersion: string | null = null
    const needsFallbackDate =
      !webhookTimestamp && !version.earliestReleaseDate && !existing

    if (needsFallbackDate) {
      const [lookupResult, versions] = await Promise.all([
        this.client.getLookupDates(attempts),
        this.client.listVersions(attempts),
      ])
      lookup = lookupResult
      oldestVersion = oldestVersionString(
        versions.filter((item) =>
          PUBLIC_APP_VERSION_STATES.has(item.appVersionState),
        ),
      )
    }

    const releaseDate = resolveReleaseDate({
      version,
      existing,
      webhookTimestamp,
      lookup,
      oldestVersion,
      overrides: parseReleaseDateOverrides(),
    })
    if (!releaseDate) {
      throw new Error(`UPDATES_RELEASE_DATE_UNRESOLVED:${version.versionString}`)
    }

    const merged = await this.store.mergeAndWrite(
      {
        id: app.id,
        platform: UPDATES_PLATFORM,
        primaryLocale: app.primaryLocale,
      },
      [incomingRelease(version, app, releaseDate)],
      this.now().toISOString(),
    )
    return {
      changed: merged.changed,
      added: merged.added,
      updated: merged.updated,
      releaseCount: merged.catalog.releases.length,
      versionStrings: [version.versionString],
    }
  }

  async syncAll({ attempts = 3 }: { attempts?: number } = {}): Promise<SyncResult> {
    const [app, allVersions, current] = await Promise.all([
      this.client.getApp(attempts),
      this.client.listVersions(attempts),
      this.existingCatalog(),
    ])
    const publicVersions = allVersions.filter((version) =>
      PUBLIC_APP_VERSION_STATES.has(version.appVersionState),
    )
    for (const version of publicVersions) {
      assertVersionBelongsToApp(version, app)
    }

    const existingById = new Map(
      (current?.releases ?? []).map((release) => [
        release.appStoreVersionId,
        release,
      ]),
    )
    const needsLookup = publicVersions.some(
      (version) =>
        !version.earliestReleaseDate && !existingById.has(version.id),
    )
    const lookup = needsLookup
      ? await this.client.getLookupDates(attempts)
      : null
    const oldestVersion = oldestVersionString(publicVersions)
    const overrides = parseReleaseDateOverrides()
    const unresolved: string[] = []
    const incoming: IncomingRelease[] = []

    for (const version of publicVersions) {
      const releaseDate = resolveReleaseDate({
        version,
        existing: existingById.get(version.id),
        lookup,
        oldestVersion,
        overrides,
      })
      if (!releaseDate) {
        unresolved.push(version.versionString)
        continue
      }
      incoming.push(incomingRelease(version, app, releaseDate))
    }

    if (unresolved.length > 0) {
      throw new Error(
        `UPDATES_RELEASE_DATES_UNRESOLVED:${unresolved.sort(compareVersionsAscending).join(",")}`,
      )
    }

    const merged = await this.store.mergeAndWrite(
      {
        id: app.id,
        platform: UPDATES_PLATFORM,
        primaryLocale: app.primaryLocale,
      },
      incoming,
      this.now().toISOString(),
    )
    return {
      changed: merged.changed,
      added: merged.added,
      updated: merged.updated,
      releaseCount: merged.catalog.releases.length,
      versionStrings: publicVersions.map((version) => version.versionString),
    }
  }
}
