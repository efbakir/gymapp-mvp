export type WebhookDecision =
  | { kind: "ignored"; reason: "unrelated_event" | "state_not_public"; eventId?: string }
  | { kind: "rejected"; code: string; status: 400 | 422; eventId?: string }
  | {
      kind: "publish"
      eventId?: string
      versionId: string
      timestamp: string
    }

export function parseWebhookDecision(payload: unknown): WebhookDecision {
  if (!payload || typeof payload !== "object") {
    return {
      kind: "rejected",
      code: "UPDATES_WEBHOOK_PAYLOAD_INVALID",
      status: 400,
    }
  }

  const data = (payload as { data?: unknown }).data
  if (!data || typeof data !== "object") {
    return { kind: "ignored", reason: "unrelated_event" }
  }
  const event = data as {
    type?: unknown
    id?: unknown
    version?: unknown
    attributes?: {
      newValue?: unknown
      timestamp?: unknown
    }
    relationships?: {
      instance?: {
        data?: {
          type?: unknown
          id?: unknown
        }
      }
    }
  }
  const eventId = typeof event.id === "string" ? event.id : undefined
  if (event.type !== "appStoreVersionAppVersionStateUpdated") {
    return { kind: "ignored", reason: "unrelated_event", eventId }
  }
  if (event.version !== 1) {
    return {
      kind: "rejected",
      code: "UPDATES_WEBHOOK_SCHEMA_UNSUPPORTED",
      status: 422,
      eventId,
    }
  }
  if (event.attributes?.newValue !== "READY_FOR_DISTRIBUTION") {
    return { kind: "ignored", reason: "state_not_public", eventId }
  }

  const instance = event.relationships?.instance?.data
  const versionId =
    instance?.type === "appStoreVersions" && typeof instance.id === "string"
      ? instance.id
      : null
  const timestamp =
    typeof event.attributes.timestamp === "string"
      ? event.attributes.timestamp
      : null
  if (
    !versionId ||
    versionId.trim() !== versionId ||
    !timestamp ||
    Number.isNaN(new Date(timestamp).getTime())
  ) {
    return {
      kind: "rejected",
      code: "UPDATES_WEBHOOK_PAYLOAD_INVALID",
      status: 400,
      eventId,
    }
  }

  return { kind: "publish", eventId, versionId, timestamp }
}
