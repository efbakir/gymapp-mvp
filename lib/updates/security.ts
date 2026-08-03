import { createHmac, timingSafeEqual } from "node:crypto"

const appleSignaturePattern = /^hmacsha256=([a-f0-9]{64})$/i

function safeCompare(left: Buffer, right: Buffer): boolean {
  if (left.length !== right.length) return false
  return timingSafeEqual(left, right)
}

export function verifyAppleSignature(
  rawBody: Uint8Array,
  signatureHeader: string | null,
  secret: string,
): boolean {
  if (!signatureHeader || secret.length === 0) return false
  const match = signatureHeader.trim().match(appleSignaturePattern)
  if (!match) return false

  const expected = createHmac("sha256", secret).update(rawBody).digest()
  const received = Buffer.from(match[1], "hex")
  return safeCompare(expected, received)
}

export function verifyBearerSecret(
  authorizationHeader: string | null,
  expectedSecret: string,
): boolean {
  if (!authorizationHeader || expectedSecret.length === 0) return false
  const expected = Buffer.from(`Bearer ${expectedSecret}`, "utf8")
  const received = Buffer.from(authorizationHeader, "utf8")
  return safeCompare(expected, received)
}
