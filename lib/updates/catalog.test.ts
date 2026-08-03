import { describe, expect, it } from "vitest"
import { mergeReleaseCatalog } from "./catalog"
import type { CatalogApp, IncomingRelease } from "./types"

const app: CatalogApp = {
  id: "6775008893",
  platform: "IOS",
  primaryLocale: "en-US",
}

function release(
  overrides: Partial<IncomingRelease> = {},
): IncomingRelease {
  return {
    appStoreVersionId: "version-2",
    versionString: "2.0",
    locale: "en-US",
    localizationId: "localization-2",
    releasedAt: "2026-07-21T10:19:41Z",
    releasedAtSource: "webhook",
    whatsNew: "A faster first run.",
    ...overrides,
  }
}

describe("mergeReleaseCatalog", () => {
  it("creates a catalog and makes replay a no-op", () => {
    const first = mergeReleaseCatalog(
      null,
      app,
      [release()],
      "2026-07-21T10:20:00Z",
    )
    const replay = mergeReleaseCatalog(
      first.catalog,
      app,
      [release()],
      "2026-07-22T10:20:00Z",
    )

    expect(first).toMatchObject({ changed: true, added: 1, updated: 0 })
    expect(replay).toMatchObject({ changed: false, added: 0, updated: 0 })
    expect(replay.catalog.updatedAt).toBe(first.catalog.updatedAt)
    expect(replay.catalog.releases).toHaveLength(1)
  })

  it("updates changed notes without losing publication identity", () => {
    const first = mergeReleaseCatalog(
      null,
      app,
      [release()],
      "2026-07-21T10:20:00Z",
    )
    const updated = mergeReleaseCatalog(
      first.catalog,
      app,
      [release({ whatsNew: "Updated App Store text." })],
      "2026-07-22T10:20:00Z",
    )

    expect(updated).toMatchObject({ changed: true, added: 0, updated: 1 })
    expect(updated.catalog.releases[0].whatsNew).toBe("Updated App Store text.")
    expect(updated.catalog.releases[0].firstPublishedAt).toBe(
      first.catalog.releases[0].firstPublishedAt,
    )
  })

  it("does not erase existing notes when Apple temporarily returns null", () => {
    const first = mergeReleaseCatalog(
      null,
      app,
      [release()],
      "2026-07-21T10:20:00Z",
    )
    const missing = mergeReleaseCatalog(
      first.catalog,
      app,
      [release({ whatsNew: null, localizationId: null })],
      "2026-07-22T10:20:00Z",
    )

    expect(missing.changed).toBe(false)
    expect(missing.catalog.releases[0].whatsNew).toBe("A faster first run.")
  })

  it("keeps a webhook date over a later lower-confidence date", () => {
    const first = mergeReleaseCatalog(
      null,
      app,
      [release()],
      "2026-07-21T10:20:00Z",
    )
    const reconciled = mergeReleaseCatalog(
      first.catalog,
      app,
      [
        release({
          releasedAt: "2026-07-21T07:00:00Z",
          releasedAtSource: "earliestReleaseDate",
        }),
      ],
      "2026-07-22T10:20:00Z",
    )

    expect(reconciled.changed).toBe(false)
    expect(reconciled.catalog.releases[0].releasedAt).toBe(
      "2026-07-21T10:19:41.000Z",
    )
  })

  it("records a higher-confidence date source even when the date is unchanged", () => {
    const first = mergeReleaseCatalog(
      null,
      app,
      [
        release({
          releasedAtSource: "earliestReleaseDate",
        }),
      ],
      "2026-07-21T10:20:00Z",
    )
    const webhook = mergeReleaseCatalog(
      first.catalog,
      app,
      [release()],
      "2026-07-22T10:20:00Z",
    )

    expect(webhook).toMatchObject({ changed: true, updated: 1 })
    expect(webhook.catalog.releases[0].releasedAtSource).toBe("webhook")
  })

  it("rejects two resource IDs claiming the same version", () => {
    const first = mergeReleaseCatalog(
      null,
      app,
      [release()],
      "2026-07-21T10:20:00Z",
    )

    expect(() =>
      mergeReleaseCatalog(
        first.catalog,
        app,
        [release({ appStoreVersionId: "different-id" })],
        "2026-07-22T10:20:00Z",
      ),
    ).toThrow("UPDATES_VERSION_COLLISION")
  })

  it("rejects a stored catalog that already contains a version collision", () => {
    const first = mergeReleaseCatalog(
      null,
      app,
      [release()],
      "2026-07-21T10:20:00Z",
    )
    const duplicate = {
      ...first.catalog.releases[0],
      key: `${app.id}:IOS:different-id`,
      appStoreVersionId: "different-id",
    }

    expect(() =>
      mergeReleaseCatalog(
        {
          ...first.catalog,
          releases: [...first.catalog.releases, duplicate],
        },
        app,
        [],
        "2026-07-22T10:20:00Z",
      ),
    ).toThrow("UPDATES_VERSION_COLLISION")
  })

  it("preserves older releases while sorting newest first", () => {
    const result = mergeReleaseCatalog(
      null,
      app,
      [
        release({
          appStoreVersionId: "version-1",
          versionString: "1.0",
          releasedAt: "2026-06-07T07:00:00Z",
          releasedAtSource: "appleLookupInitial",
        }),
        release(),
      ],
      "2026-07-21T10:20:00Z",
    )

    expect(result.catalog.releases.map((item) => item.versionString)).toEqual([
      "2.0",
      "1.0",
    ])
  })
})
