import { importPKCS8, SignJWT } from "jose"
import type {
  AppleApp,
  AppleLookupDates,
  AppleVersion,
  AppleVersionLocalization,
  AppStoreClient,
} from "./types"

const APP_STORE_API_BASE = "https://api.appstoreconnect.apple.com"
const APPLE_LOOKUP_BASE = "https://itunes.apple.com/lookup"
const DEFAULT_TIMEOUT_MS = 6_000

type FetchLike = typeof fetch

type AppleClientConfig = {
  appId: string
  issuerId: string
  keyId: string
  privateKeyBase64: string
  fetchImpl?: FetchLike
  timeoutMs?: number
}

type JsonApiResource = {
  id: string
  type: string
  attributes?: Record<string, unknown>
  relationships?: Record<
    string,
    { data?: { id: string; type: string } | Array<{ id: string; type: string }> }
  >
}

type JsonApiDocument = {
  data: JsonApiResource | JsonApiResource[]
  included?: JsonApiResource[]
  links?: { next?: string | null }
}

export class AppleApiError extends Error {
  constructor(
    public readonly code: string,
    public readonly status?: number,
  ) {
    super(code)
  }
}

function requiredEnv(name: string): string {
  const value = process.env[name]?.trim()
  if (!value) throw new Error(`UPDATES_CONFIG_MISSING_${name}`)
  return value
}

function nullableString(value: unknown): string | null {
  return typeof value === "string" && value.trim().length > 0 ? value : null
}

function requiredString(
  value: unknown,
  errorCode: string,
): string {
  if (typeof value !== "string" || value.length === 0) {
    throw new AppleApiError(errorCode)
  }
  return value
}

function retryAfterMs(response: Response): number | null {
  const header = response.headers.get("retry-after")
  if (!header) return null
  const seconds = Number(header)
  if (Number.isFinite(seconds)) {
    return Math.min(Math.max(seconds * 1_000, 0), 3_000)
  }
  const at = new Date(header).getTime()
  if (Number.isNaN(at)) return null
  return Math.min(Math.max(at - Date.now(), 0), 3_000)
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

export async function fetchJsonWithRetry<T>({
  url,
  fetchImpl,
  attempts,
  timeoutMs,
  headers,
}: {
  url: string
  fetchImpl: FetchLike
  attempts: number
  timeoutMs: number
  headers?: HeadersInit
}): Promise<T> {
  let lastError: unknown

  for (let attempt = 1; attempt <= attempts; attempt += 1) {
    const controller = new AbortController()
    const timer = setTimeout(() => controller.abort(), timeoutMs)
    try {
      const response = await fetchImpl(url, {
        headers,
        signal: controller.signal,
        cache: "no-store",
      })

      if (response.ok) {
        try {
          return (await response.json()) as T
        } catch {
          throw new AppleApiError("APPLE_RESPONSE_INVALID_JSON", response.status)
        }
      }

      const retryable = response.status === 429 || response.status >= 500
      if (!retryable) {
        throw new AppleApiError("APPLE_REQUEST_REJECTED", response.status)
      }
      lastError = new AppleApiError("APPLE_REQUEST_RETRYABLE", response.status)
      if (attempt < attempts) {
        const backoff =
          retryAfterMs(response) ??
          Math.min(250 * 2 ** (attempt - 1) + Math.floor(Math.random() * 100), 2_000)
        await delay(backoff)
      }
    } catch (error) {
      if (error instanceof AppleApiError && error.code !== "APPLE_REQUEST_RETRYABLE") {
        throw error
      }
      lastError =
        error instanceof Error && error.name === "AbortError"
          ? new AppleApiError("APPLE_REQUEST_TIMEOUT")
          : error
      if (attempt < attempts) {
        await delay(
          Math.min(250 * 2 ** (attempt - 1) + Math.floor(Math.random() * 100), 2_000),
        )
      }
    } finally {
      clearTimeout(timer)
    }
  }

  if (lastError instanceof Error) throw lastError
  throw new AppleApiError("APPLE_REQUEST_FAILED")
}

function relationshipId(
  resource: JsonApiResource,
  relationship: string,
): string | null {
  const data = resource.relationships?.[relationship]?.data
  return data && !Array.isArray(data) ? data.id : null
}

function mapLocalization(resource: JsonApiResource): AppleVersionLocalization {
  return {
    id: resource.id,
    locale: requiredString(
      resource.attributes?.locale,
      "APPLE_LOCALIZATION_LOCALE_MISSING",
    ),
    whatsNew: nullableString(resource.attributes?.whatsNew),
  }
}

function mapVersion(
  resource: JsonApiResource,
  included: JsonApiResource[],
  fallbackAppId?: string,
): AppleVersion {
  const localizationRelationship = resource.relationships
    ?.appStoreVersionLocalizations?.data
  const localizationIds = new Set(
    Array.isArray(localizationRelationship)
      ? localizationRelationship.map((item) => item.id)
      : [],
  )

  const localizations = included
    .filter((item) => {
      if (item.type !== "appStoreVersionLocalizations") return false
      const ownerId = relationshipId(item, "appStoreVersion")
      return (
        localizationIds.has(item.id) ||
        ownerId === resource.id ||
        (!ownerId && localizationIds.size === 0)
      )
    })
    .map(mapLocalization)

  return {
    id: resource.id,
    appId:
      relationshipId(resource, "app") ??
      included.find((item) => item.type === "apps")?.id ??
      fallbackAppId ??
      "",
    platform: requiredString(
      resource.attributes?.platform,
      "APPLE_VERSION_PLATFORM_MISSING",
    ),
    versionString: requiredString(
      resource.attributes?.versionString,
      "APPLE_VERSION_STRING_MISSING",
    ),
    appVersionState: requiredString(
      resource.attributes?.appVersionState,
      "APPLE_VERSION_STATE_MISSING",
    ),
    earliestReleaseDate: nullableString(
      resource.attributes?.earliestReleaseDate,
    ),
    localizations,
  }
}

export class AppleConnectClient implements AppStoreClient {
  private readonly fetchImpl: FetchLike
  private readonly timeoutMs: number
  private token:
    | {
        value: string
        expiresAt: number
      }
    | undefined
  private keyPromise: ReturnType<typeof importPKCS8> | undefined

  constructor(private readonly config: AppleClientConfig) {
    this.fetchImpl = config.fetchImpl ?? fetch
    this.timeoutMs = config.timeoutMs ?? DEFAULT_TIMEOUT_MS
  }

  private async authorizationHeader(): Promise<string> {
    const now = Math.floor(Date.now() / 1_000)
    if (this.token && this.token.expiresAt - now > 60) {
      return `Bearer ${this.token.value}`
    }

    if (!this.keyPromise) {
      let pem: string
      try {
        pem = Buffer.from(this.config.privateKeyBase64, "base64").toString("utf8")
      } catch {
        throw new Error("UPDATES_PRIVATE_KEY_INVALID")
      }
      if (!pem.includes("BEGIN PRIVATE KEY")) {
        throw new Error("UPDATES_PRIVATE_KEY_INVALID")
      }
      this.keyPromise = importPKCS8(pem, "ES256")
    }

    const expiresAt = now + 10 * 60
    const value = await new SignJWT({})
      .setProtectedHeader({
        alg: "ES256",
        kid: this.config.keyId,
        typ: "JWT",
      })
      .setIssuer(this.config.issuerId)
      .setIssuedAt(now)
      .setExpirationTime(expiresAt)
      .setAudience("appstoreconnect-v1")
      .sign(await this.keyPromise)

    this.token = { value, expiresAt }
    return `Bearer ${value}`
  }

  private async connectRequest<T>(
    pathOrUrl: string,
    attempts: number,
  ): Promise<T> {
    const url = pathOrUrl.startsWith("http")
      ? pathOrUrl
      : `${APP_STORE_API_BASE}${pathOrUrl}`
    return fetchJsonWithRetry<T>({
      url,
      fetchImpl: this.fetchImpl,
      attempts,
      timeoutMs: this.timeoutMs,
      headers: {
        Accept: "application/json",
        Authorization: await this.authorizationHeader(),
      },
    })
  }

  async getApp(attempts = 3): Promise<AppleApp> {
    const query = new URLSearchParams({
      "fields[apps]": "name,bundleId,primaryLocale",
    })
    const document = await this.connectRequest<JsonApiDocument>(
      `/v1/apps/${encodeURIComponent(this.config.appId)}?${query}`,
      attempts,
    )
    if (Array.isArray(document.data)) {
      throw new AppleApiError("APPLE_APP_RESPONSE_INVALID")
    }

    return {
      id: document.data.id,
      name: requiredString(document.data.attributes?.name, "APPLE_APP_NAME_MISSING"),
      bundleId: requiredString(
        document.data.attributes?.bundleId,
        "APPLE_APP_BUNDLE_ID_MISSING",
      ),
      primaryLocale: requiredString(
        document.data.attributes?.primaryLocale,
        "APPLE_APP_PRIMARY_LOCALE_MISSING",
      ),
    }
  }

  async getVersion(versionId: string, attempts = 2): Promise<AppleVersion> {
    const query = new URLSearchParams({
      include: "app,appStoreVersionLocalizations",
      "fields[appStoreVersions]":
        "platform,versionString,appVersionState,earliestReleaseDate,app,appStoreVersionLocalizations",
      "fields[appStoreVersionLocalizations]":
        "locale,whatsNew,appStoreVersion",
      "fields[apps]": "name,bundleId,primaryLocale",
      "limit[appStoreVersionLocalizations]": "50",
    })
    const document = await this.connectRequest<JsonApiDocument>(
      `/v1/appStoreVersions/${encodeURIComponent(versionId)}?${query}`,
      attempts,
    )
    if (Array.isArray(document.data)) {
      throw new AppleApiError("APPLE_VERSION_RESPONSE_INVALID")
    }
    return mapVersion(document.data, document.included ?? [])
  }

  async listVersions(attempts = 3): Promise<AppleVersion[]> {
    const query = new URLSearchParams({
      "filter[platform]": "IOS",
      include: "appStoreVersionLocalizations",
      "fields[appStoreVersions]":
        "platform,versionString,appVersionState,earliestReleaseDate,app,appStoreVersionLocalizations",
      "fields[appStoreVersionLocalizations]":
        "locale,whatsNew,appStoreVersion",
      limit: "200",
      "limit[appStoreVersionLocalizations]": "50",
    })
    let next: string | null =
      `/v1/apps/${encodeURIComponent(this.config.appId)}/appStoreVersions?${query}`
    const versions: AppleVersion[] = []
    let pageCount = 0

    while (next) {
      pageCount += 1
      if (pageCount > 10) throw new AppleApiError("APPLE_PAGINATION_LIMIT")
      const document: JsonApiDocument =
        await this.connectRequest<JsonApiDocument>(next, attempts)
      if (!Array.isArray(document.data)) {
        throw new AppleApiError("APPLE_VERSION_LIST_RESPONSE_INVALID")
      }
      const included = document.included ?? []
      versions.push(
        ...document.data.map((resource) =>
          mapVersion(resource, included, this.config.appId),
        ),
      )
      next = document.links?.next ?? null
    }

    return versions
  }

  async getLookupDates(attempts = 2): Promise<AppleLookupDates> {
    const query = new URLSearchParams({
      id: this.config.appId,
      country: "us",
    })
    const response = await fetchJsonWithRetry<{
      resultCount?: number
      results?: Array<Record<string, unknown>>
    }>({
      url: `${APPLE_LOOKUP_BASE}?${query}`,
      fetchImpl: this.fetchImpl,
      attempts,
      timeoutMs: this.timeoutMs,
    })
    const result = response.results?.[0]
    return {
      version: nullableString(result?.version),
      currentVersionReleaseDate: nullableString(
        result?.currentVersionReleaseDate,
      ),
      releaseDate: nullableString(result?.releaseDate),
    }
  }
}

export function createAppleConnectClientFromEnv(): AppleConnectClient {
  return new AppleConnectClient({
    appId: requiredEnv("APP_STORE_APP_ID"),
    issuerId: requiredEnv("APP_STORE_CONNECT_ISSUER_ID"),
    keyId: requiredEnv("APP_STORE_CONNECT_KEY_ID"),
    privateKeyBase64: requiredEnv(
      "APP_STORE_CONNECT_PRIVATE_KEY_BASE64",
    ),
  })
}
