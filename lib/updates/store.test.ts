import { BlobPreconditionFailedError } from "@vercel/blob"
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import { BlobReleaseCatalogStore, type BlobOperations } from "./store"
import type { CatalogApp, IncomingRelease } from "./types"

const pathname = "updates-test/releases.json"
const app: CatalogApp = {
  id: "6775008893",
  platform: "IOS",
  primaryLocale: "en-US",
}
const incoming: IncomingRelease = {
  appStoreVersionId: "version-2",
  versionString: "2.0",
  locale: "en-US",
  localizationId: "localization-2",
  releasedAt: "2026-07-21T10:19:41Z",
  releasedAtSource: "webhook",
  whatsNew: "Release notes.",
}

function blobResult(raw: string, etag: string) {
  return {
    statusCode: 200 as const,
    stream: new Response(raw).body!,
    headers: new Headers(),
    blob: {
      url: "https://private.blob/example",
      downloadUrl: "https://private.blob/example?download=1",
      pathname,
      contentDisposition: "inline",
      cacheControl: "public, max-age=60",
      uploadedAt: new Date(),
      etag,
      contentType: "application/json",
      size: raw.length,
    },
  }
}

function putResult() {
  return {
    url: "https://private.blob/example",
    downloadUrl: "https://private.blob/example?download=1",
    pathname,
    contentType: "application/json",
    contentDisposition: "inline",
    etag: "put-etag",
  }
}

describe("BlobReleaseCatalogStore", () => {
  const originalToken = process.env.BLOB_READ_WRITE_TOKEN

  beforeEach(() => {
    process.env.BLOB_READ_WRITE_TOKEN = "test-token"
  })

  afterEach(() => {
    if (originalToken === undefined) delete process.env.BLOB_READ_WRITE_TOKEN
    else process.env.BLOB_READ_WRITE_TOKEN = originalToken
  })

  it("creates once, skips an idempotent replay, and backs up changes", async () => {
    let raw: string | null = null
    let etag = "etag-1"
    const puts: Array<{ path: string; body: string }> = []
    const operations: BlobOperations = {
      get: vi.fn(async () => (raw ? blobResult(raw, etag) : null)),
      put: vi.fn(async (path, body) => {
        puts.push({ path, body })
        if (path === pathname) {
          raw = body
          etag = `etag-${puts.length + 1}`
        }
        return putResult()
      }),
    }
    const store = new BlobReleaseCatalogStore(operations, pathname)

    const first = await store.mergeAndWrite(
      app,
      [incoming],
      "2026-07-21T10:20:00Z",
    )
    const replay = await store.mergeAndWrite(
      app,
      [incoming],
      "2026-07-22T10:20:00Z",
    )
    const changed = await store.mergeAndWrite(
      app,
      [{ ...incoming, whatsNew: "Changed notes." }],
      "2026-07-23T10:20:00Z",
    )

    expect(first.changed).toBe(true)
    expect(replay.changed).toBe(false)
    expect(changed.updated).toBe(1)
    expect(puts.filter((item) => item.path === pathname)).toHaveLength(2)
    expect(
      puts.some((item) => item.path.startsWith("updates-test/backups/")),
    ).toBe(true)
  })

  it("rereads and retries an ETag conflict", async () => {
    let raw: string | null = null
    let etag = "etag-1"
    let currentWrites = 0
    const operations: BlobOperations = {
      get: vi.fn(async () => (raw ? blobResult(raw, etag) : null)),
      put: vi.fn(async (path, body) => {
        if (path === pathname) {
          currentWrites += 1
          if (currentWrites === 1) throw new BlobPreconditionFailedError()
          raw = body
          etag = "etag-2"
        }
        return putResult()
      }),
    }
    const store = new BlobReleaseCatalogStore(operations, pathname)

    await expect(
      store.mergeAndWrite(app, [incoming], "2026-07-21T10:20:00Z"),
    ).resolves.toMatchObject({ changed: true, added: 1 })
    expect(currentWrites).toBe(2)
  })

  it("fails closed after three ETag conflicts", async () => {
    const operations: BlobOperations = {
      get: vi.fn(async () => null),
      put: vi.fn(async () => {
        throw new BlobPreconditionFailedError()
      }),
    }
    const store = new BlobReleaseCatalogStore(operations, pathname)

    await expect(
      store.mergeAndWrite(app, [incoming], "2026-07-21T10:20:00Z"),
    ).rejects.toThrow("UPDATES_BLOB_CONFLICT_EXHAUSTED")
    expect(operations.get).toHaveBeenCalledTimes(3)
    expect(operations.put).toHaveBeenCalledTimes(3)
  })

  it("writes immutable backups before conditionally overwriting", async () => {
    const initialStore = new BlobReleaseCatalogStore(
      {
        get: vi.fn(async () => null),
        put: vi.fn(async () => putResult()),
      },
      pathname,
    )
    const initial = await initialStore.mergeAndWrite(
      app,
      [incoming],
      "2026-07-21T10:20:00Z",
    )
    const raw = `${JSON.stringify(initial.catalog, null, 2)}\n`
    const puts: Array<{
      path: string
      options: Parameters<BlobOperations["put"]>[2]
    }> = []
    const operations: BlobOperations = {
      get: vi.fn(async () => blobResult(raw, "etag-original")),
      put: vi.fn(async (path, _body, options) => {
        puts.push({ path, options })
        return putResult()
      }),
    }
    const store = new BlobReleaseCatalogStore(operations, pathname)

    await store.mergeAndWrite(
      app,
      [{ ...incoming, whatsNew: "Changed." }],
      "2026-07-22T10:20:00Z",
    )

    expect(puts[0].path).toContain("/backups/")
    expect(puts[0].options).toMatchObject({
      access: "private",
      addRandomSuffix: true,
      allowOverwrite: false,
    })
    expect(puts[1]).toMatchObject({
      path: pathname,
      options: {
        access: "private",
        allowOverwrite: true,
        ifMatch: "etag-original",
      },
    })
  })
})
