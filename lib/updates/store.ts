import {
  BlobPreconditionFailedError,
  get,
  put,
  type GetBlobResult,
  type PutBlobResult,
  type PutCommandOptions,
} from "@vercel/blob"
import { mergeReleaseCatalog } from "./catalog"
import {
  parseReleaseCatalog,
  type CatalogApp,
  type CatalogMergeResult,
  type IncomingRelease,
  type ReleaseCatalog,
  type ReleaseCatalogStore,
} from "./types"

export type BlobOperations = {
  get: (
    pathname: string,
    options: { access: "private"; useCache: boolean },
  ) => Promise<GetBlobResult | null>
  put: (
    pathname: string,
    body: string,
    options: PutCommandOptions,
  ) => Promise<PutBlobResult>
}

type CatalogSnapshot = {
  catalog: ReleaseCatalog | null
  etag: string | null
  raw: string | null
}

const defaultOperations: BlobOperations = { get, put }

function catalogPath(): string {
  return process.env.UPDATES_BLOB_PATH?.trim() || "updates/releases.json"
}

function requireBlobToken(): void {
  if (!process.env.BLOB_READ_WRITE_TOKEN?.trim()) {
    throw new Error("UPDATES_CONFIG_MISSING_BLOB_READ_WRITE_TOKEN")
  }
}

function backupPath(pathname: string, etag: string): string {
  const slash = pathname.lastIndexOf("/")
  const prefix = slash >= 0 ? pathname.slice(0, slash) : "updates"
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-")
  const safeEtag = etag.replace(/[^a-zA-Z0-9_-]/g, "")
  return `${prefix}/backups/${timestamp}-${safeEtag}.json`
}

function isCreateConflict(error: unknown): boolean {
  if (error instanceof BlobPreconditionFailedError) return true
  const message = error instanceof Error ? error.message.toLowerCase() : ""
  return (
    message.includes("already exists") ||
    message.includes("overwrite") ||
    message.includes("conflict")
  )
}

async function streamToText(stream: ReadableStream<Uint8Array>): Promise<string> {
  return new Response(stream).text()
}

export class BlobReleaseCatalogStore implements ReleaseCatalogStore {
  constructor(
    private readonly operations: BlobOperations = defaultOperations,
    private readonly pathname: string = catalogPath(),
  ) {}

  private async readSnapshot(useCache = false): Promise<CatalogSnapshot> {
    requireBlobToken()
    const result = await this.operations.get(this.pathname, {
      access: "private",
      useCache,
    })
    if (!result) return { catalog: null, etag: null, raw: null }
    if (result.statusCode !== 200) {
      throw new Error("UPDATES_BLOB_READ_FAILED")
    }
    const raw = await streamToText(result.stream)
    let parsed: unknown
    try {
      parsed = JSON.parse(raw)
    } catch {
      throw new Error("UPDATES_CATALOG_INVALID_JSON")
    }
    return {
      catalog: parseReleaseCatalog(parsed),
      etag: result.blob.etag,
      raw,
    }
  }

  async readCatalog(options?: {
    useCache?: boolean
  }): Promise<ReleaseCatalog | null> {
    const snapshot = await this.readSnapshot(options?.useCache ?? false)
    return snapshot.catalog
  }

  async mergeAndWrite(
    app: CatalogApp,
    incoming: IncomingRelease[],
    now: string,
  ): Promise<CatalogMergeResult> {
    for (let attempt = 1; attempt <= 3; attempt += 1) {
      const snapshot = await this.readSnapshot(false)
      const merged = mergeReleaseCatalog(snapshot.catalog, app, incoming, now)
      if (!merged.changed) return merged

      if (snapshot.raw && snapshot.etag) {
        await this.operations.put(
          backupPath(this.pathname, snapshot.etag),
          snapshot.raw,
          {
            access: "private",
            addRandomSuffix: true,
            allowOverwrite: false,
            contentType: "application/json",
            cacheControlMaxAge: 60,
          },
        )
      }

      const body = `${JSON.stringify(merged.catalog, null, 2)}\n`
      try {
        await this.operations.put(this.pathname, body, {
          access: "private",
          allowOverwrite: snapshot.etag !== null,
          ifMatch: snapshot.etag ?? undefined,
          contentType: "application/json",
          cacheControlMaxAge: 60,
        })
        return merged
      } catch (error) {
        if (attempt < 3 && isCreateConflict(error)) continue
        if (isCreateConflict(error)) {
          throw new Error("UPDATES_BLOB_CONFLICT_EXHAUSTED")
        }
        throw error
      }
    }

    throw new Error("UPDATES_BLOB_CONFLICT_EXHAUSTED")
  }
}
