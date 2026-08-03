import { generateKeyPairSync } from "node:crypto"
import { describe, expect, it, vi } from "vitest"
import {
  AppleApiError,
  AppleConnectClient,
  fetchJsonWithRetry,
} from "./apple"

describe("fetchJsonWithRetry", () => {
  it("honors a retryable response and then succeeds", async () => {
    const fetchImpl = vi
      .fn()
      .mockResolvedValueOnce(
        new Response("busy", {
          status: 429,
          headers: { "Retry-After": "0" },
        }),
      )
      .mockResolvedValueOnce(
        Response.json({ ok: true }, { status: 200 }),
      ) as typeof fetch

    await expect(
      fetchJsonWithRetry<{ ok: boolean }>({
        url: "https://example.com",
        fetchImpl,
        attempts: 2,
        timeoutMs: 100,
      }),
    ).resolves.toEqual({ ok: true })
    expect(fetchImpl).toHaveBeenCalledTimes(2)
  })

  it("retries a server error and then succeeds", async () => {
    const fetchImpl = vi
      .fn()
      .mockResolvedValueOnce(new Response("busy", { status: 503 }))
      .mockResolvedValueOnce(
        Response.json({ ok: true }, { status: 200 }),
      ) as typeof fetch

    await expect(
      fetchJsonWithRetry<{ ok: boolean }>({
        url: "https://example.com",
        fetchImpl,
        attempts: 2,
        timeoutMs: 100,
      }),
    ).resolves.toEqual({ ok: true })
    expect(fetchImpl).toHaveBeenCalledTimes(2)
  })

  it("does not retry a permanent 4xx response", async () => {
    const fetchImpl = vi
      .fn()
      .mockResolvedValue(new Response("forbidden", { status: 403 })) as typeof fetch

    await expect(
      fetchJsonWithRetry({
        url: "https://example.com",
        fetchImpl,
        attempts: 3,
        timeoutMs: 100,
      }),
    ).rejects.toMatchObject({
      code: "APPLE_REQUEST_REJECTED",
      status: 403,
    } satisfies Partial<AppleApiError>)
    expect(fetchImpl).toHaveBeenCalledTimes(1)
  })

  it("retries timeouts and returns a stable error", async () => {
    const fetchImpl = vi.fn((_url, init) => {
      return new Promise<Response>((_resolve, reject) => {
        init?.signal?.addEventListener("abort", () => {
          reject(new DOMException("Aborted", "AbortError"))
        })
      })
    }) as typeof fetch

    await expect(
      fetchJsonWithRetry({
        url: "https://example.com",
        fetchImpl,
        attempts: 2,
        timeoutMs: 5,
      }),
    ).rejects.toMatchObject({
      code: "APPLE_REQUEST_TIMEOUT",
    } satisfies Partial<AppleApiError>)
    expect(fetchImpl).toHaveBeenCalledTimes(2)
  })

  it("rejects malformed successful JSON", async () => {
    const fetchImpl = vi
      .fn()
      .mockResolvedValue(
        new Response("not json", {
          status: 200,
          headers: { "Content-Type": "application/json" },
        }),
      ) as typeof fetch

    await expect(
      fetchJsonWithRetry({
        url: "https://example.com",
        fetchImpl,
        attempts: 1,
        timeoutMs: 100,
      }),
    ).rejects.toMatchObject({
      code: "APPLE_RESPONSE_INVALID_JSON",
    } satisfies Partial<AppleApiError>)
  })
})

describe("AppleConnectClient pagination", () => {
  it("follows App Store Connect pagination links", async () => {
    const { privateKey } = generateKeyPairSync("ec", {
      namedCurve: "P-256",
    })
    const privateKeyBase64 = Buffer.from(
      privateKey.export({ format: "pem", type: "pkcs8" }),
    ).toString("base64")
    const page = (id: string, next: string | null) =>
      Response.json({
        data: [
          {
            type: "appStoreVersions",
            id,
            attributes: {
              platform: "IOS",
              versionString: id === "version-1" ? "1.0" : "2.0",
              appVersionState:
                id === "version-1"
                  ? "REPLACED_WITH_NEW_VERSION"
                  : "READY_FOR_DISTRIBUTION",
              earliestReleaseDate: "2026-07-21T10:19:41Z",
            },
            relationships: {
              appStoreVersionLocalizations: {
                data: [
                  {
                    type: "appStoreVersionLocalizations",
                    id: `localization-${id}`,
                  },
                ],
              },
            },
          },
        ],
        included: [
          {
            type: "appStoreVersionLocalizations",
            id: `localization-${id}`,
            attributes: {
              locale: "en-US",
              whatsNew: `Notes for ${id}`,
            },
          },
        ],
        links: { next },
      })
    const fetchImpl = vi
      .fn()
      .mockResolvedValueOnce(
        page(
          "version-1",
          "https://api.appstoreconnect.apple.com/v1/next-page",
        ),
      )
      .mockResolvedValueOnce(page("version-2", null)) as typeof fetch
    const client = new AppleConnectClient({
      appId: "6775008893",
      issuerId: "issuer",
      keyId: "key",
      privateKeyBase64,
      fetchImpl,
    })

    await expect(client.listVersions(1)).resolves.toMatchObject([
      { id: "version-1", appId: "6775008893", versionString: "1.0" },
      { id: "version-2", appId: "6775008893", versionString: "2.0" },
    ])
    expect(fetchImpl).toHaveBeenCalledTimes(2)
  })
})
