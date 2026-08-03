import { createHmac } from "node:crypto"
import { describe, expect, it } from "vitest"
import { verifyAppleSignature, verifyBearerSecret } from "./security"

describe("verifyAppleSignature", () => {
  const secret = "test-webhook-secret"
  const body = Buffer.from('{"data":{"type":"ping"}}')
  const signature = createHmac("sha256", secret).update(body).digest("hex")

  it("accepts a valid Apple signature", () => {
    expect(
      verifyAppleSignature(body, `hmacsha256=${signature}`, secret),
    ).toBe(true)
  })

  it("rejects missing, malformed, and wrong signatures", () => {
    expect(verifyAppleSignature(body, null, secret)).toBe(false)
    expect(verifyAppleSignature(body, signature, secret)).toBe(false)
    expect(
      verifyAppleSignature(body, `hmacsha256=${"0".repeat(64)}`, secret),
    ).toBe(false)
  })

  it("signs the exact raw bytes", () => {
    const changedBody = Buffer.from(`${body.toString("utf8")} `)
    expect(
      verifyAppleSignature(
        changedBody,
        `hmacsha256=${signature}`,
        secret,
      ),
    ).toBe(false)
  })
})

describe("verifyBearerSecret", () => {
  it("compares the complete bearer value", () => {
    expect(verifyBearerSecret("Bearer secret", "secret")).toBe(true)
    expect(verifyBearerSecret("Bearer secret ", "secret")).toBe(false)
    expect(verifyBearerSecret(null, "secret")).toBe(false)
  })
})
