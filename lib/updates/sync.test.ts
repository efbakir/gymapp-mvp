import { describe, expect, it } from "vitest"
import { mergeReleaseCatalog } from "./catalog"
import { UpdatesSyncService } from "./sync"
import type {
  AppleApp,
  AppleLookupDates,
  AppleVersion,
  AppStoreClient,
  CatalogApp,
  CatalogMergeResult,
  IncomingRelease,
  ReleaseCatalog,
  ReleaseCatalogStore,
} from "./types"

const app: AppleApp = {
  id: "6775008893",
  name: "Unit",
  bundleId: "app.unit",
  primaryLocale: "en-US",
}

function version(
  overrides: Partial<AppleVersion> = {},
): AppleVersion {
  return {
    id: "version-2",
    appId: app.id,
    platform: "IOS",
    versionString: "2.0",
    appVersionState: "READY_FOR_DISTRIBUTION",
    earliestReleaseDate: "2026-07-21T10:19:41Z",
    localizations: [
      {
        id: "localization-en",
        locale: "en-US",
        whatsNew: "The public release notes.",
      },
      {
        id: "localization-tr",
        locale: "tr",
        whatsNew: "Yerelleştirilmiş notlar.",
      },
    ],
    ...overrides,
  }
}

class FakeClient implements AppStoreClient {
  constructor(
    public versions: AppleVersion[],
    public lookup: AppleLookupDates = {
      version: "2.0",
      currentVersionReleaseDate: "2026-07-21T10:19:41Z",
      releaseDate: "2026-06-07T07:00:00Z",
    },
  ) {}

  async getApp(): Promise<AppleApp> {
    return app
  }

  async getVersion(versionId: string): Promise<AppleVersion> {
    const match = this.versions.find((item) => item.id === versionId)
    if (!match) throw new Error("TEST_VERSION_MISSING")
    return match
  }

  async listVersions(): Promise<AppleVersion[]> {
    return this.versions
  }

  async getLookupDates(): Promise<AppleLookupDates> {
    return this.lookup
  }
}

class MemoryStore implements ReleaseCatalogStore {
  catalog: ReleaseCatalog | null = null
  writes = 0

  async readCatalog(): Promise<ReleaseCatalog | null> {
    return this.catalog
  }

  async mergeAndWrite(
    catalogApp: CatalogApp,
    incoming: IncomingRelease[],
    now: string,
  ): Promise<CatalogMergeResult> {
    const result = mergeReleaseCatalog(this.catalog, catalogApp, incoming, now)
    if (result.changed) this.writes += 1
    this.catalog = result.catalog
    return result
  }
}

describe("UpdatesSyncService", () => {
  it("uses the primary locale and remains idempotent", async () => {
    const store = new MemoryStore()
    const service = new UpdatesSyncService(
      new FakeClient([version()]),
      store,
      () => new Date("2026-07-21T10:20:00Z"),
    )

    const first = await service.syncAll()
    const replay = await service.syncAll()

    expect(first).toMatchObject({ changed: true, added: 1 })
    expect(replay).toMatchObject({ changed: false, added: 0, updated: 0 })
    expect(store.writes).toBe(1)
    expect(store.catalog?.releases[0]).toMatchObject({
      locale: "en-US",
      whatsNew: "The public release notes.",
    })
  })

  it("imports current and replaced public versions but excludes candidates", async () => {
    const store = new MemoryStore()
    const service = new UpdatesSyncService(
      new FakeClient([
        version({
          id: "version-1",
          versionString: "1.0",
          appVersionState: "REPLACED_WITH_NEW_VERSION",
          earliestReleaseDate: null,
        }),
        version(),
        version({
          id: "version-21",
          versionString: "2.1",
          appVersionState: "PREPARE_FOR_SUBMISSION",
          earliestReleaseDate: null,
        }),
      ]),
      store,
      () => new Date("2026-07-21T10:20:00Z"),
    )

    await service.syncAll()

    expect(store.catalog?.releases.map((item) => item.versionString)).toEqual([
      "2.0",
      "1.0",
    ])
    expect(store.catalog?.releases[1].releasedAtSource).toBe(
      "appleLookupInitial",
    )
  })

  it("uses the webhook timestamp and rejects an API state that is not public yet", async () => {
    const store = new MemoryStore()
    const client = new FakeClient([version()])
    const service = new UpdatesSyncService(client, store)

    await service.syncVersion({
      versionId: "version-2",
      webhookTimestamp: "2026-07-21T12:00:00Z",
    })
    expect(store.catalog?.releases[0]).toMatchObject({
      releasedAt: "2026-07-21T12:00:00.000Z",
      releasedAtSource: "webhook",
    })

    client.versions = [
      version({ appVersionState: "PROCESSING_FOR_DISTRIBUTION" }),
    ]
    await expect(
      service.syncVersion({
        versionId: "version-2",
        webhookTimestamp: "2026-07-21T12:00:00Z",
      }),
    ).rejects.toThrow("UPDATES_VERSION_NOT_PUBLIC_YET")
  })

  it("ignores a manually requested unreleased version", async () => {
    const service = new UpdatesSyncService(
      new FakeClient([
        version({ appVersionState: "PENDING_DEVELOPER_RELEASE" }),
      ]),
      new MemoryStore(),
    )

    await expect(
      service.syncVersion({ versionId: "version-2" }),
    ).resolves.toMatchObject({ changed: false, ignored: "not-public" })
  })

  it("fails the whole import when an official release date is unresolved", async () => {
    const store = new MemoryStore()
    const service = new UpdatesSyncService(
      new FakeClient(
        [
          version({
            id: "version-15",
            versionString: "1.5",
            appVersionState: "REPLACED_WITH_NEW_VERSION",
            earliestReleaseDate: null,
          }),
          version(),
        ],
        {
          version: "2.0",
          currentVersionReleaseDate: "2026-07-21T10:19:41Z",
          releaseDate: null,
        },
      ),
      store,
    )

    await expect(service.syncAll()).rejects.toThrow(
      "UPDATES_RELEASE_DATES_UNRESOLVED",
    )
    expect(store.writes).toBe(0)
  })

  it("rejects an unrelated app or platform before writing", async () => {
    const wrongApp = new UpdatesSyncService(
      new FakeClient([version({ appId: "other-app" })]),
      new MemoryStore(),
    )
    await expect(wrongApp.syncAll()).rejects.toThrow(
      "UPDATES_VERSION_APP_MISMATCH",
    )

    const wrongPlatform = new UpdatesSyncService(
      new FakeClient([version({ platform: "MAC_OS" })]),
      new MemoryStore(),
    )
    await expect(wrongPlatform.syncAll()).rejects.toThrow(
      "UPDATES_VERSION_PLATFORM_MISMATCH",
    )
  })
})
