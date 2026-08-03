import { describe, expect, it } from "vitest"
import { parseWebhookDecision } from "./webhook"

function payload(newValue: string) {
  return {
    data: {
      type: "appStoreVersionAppVersionStateUpdated",
      id: "event-1",
      version: 1,
      attributes: {
        newValue,
        oldValue: "IN_REVIEW",
        timestamp: "2026-07-21T10:19:41Z",
      },
      relationships: {
        instance: {
          data: { type: "appStoreVersions", id: "version-2" },
        },
      },
    },
  }
}

describe("parseWebhookDecision", () => {
  it("publishes only READY_FOR_DISTRIBUTION", () => {
    expect(parseWebhookDecision(payload("READY_FOR_DISTRIBUTION"))).toEqual({
      kind: "publish",
      eventId: "event-1",
      versionId: "version-2",
      timestamp: "2026-07-21T10:19:41Z",
    })
  })

  it.each([
    "PREPARE_FOR_SUBMISSION",
    "READY_FOR_REVIEW",
    "WAITING_FOR_REVIEW",
    "IN_REVIEW",
    "PENDING_DEVELOPER_RELEASE",
    "PENDING_APPLE_RELEASE",
    "PROCESSING_FOR_DISTRIBUTION",
    "REJECTED",
  ])("ignores the non-public state %s", (state) => {
    expect(parseWebhookDecision(payload(state))).toMatchObject({
      kind: "ignored",
      reason: "state_not_public",
    })
  })

  it("accepts signed ping and unrelated event shapes as ignored", () => {
    expect(
      parseWebhookDecision({ data: { type: "webhookPings", id: "ping-1" } }),
    ).toMatchObject({ kind: "ignored", reason: "unrelated_event" })
  })

  it("rejects unsupported schemas and incomplete public events", () => {
    const unsupported = payload("READY_FOR_DISTRIBUTION")
    unsupported.data.version = 2
    expect(parseWebhookDecision(unsupported)).toMatchObject({
      kind: "rejected",
      status: 422,
    })

    const incomplete = payload("READY_FOR_DISTRIBUTION")
    incomplete.data.relationships.instance.data.id = ""
    expect(parseWebhookDecision(incomplete)).toMatchObject({
      kind: "rejected",
      status: 400,
    })

    const invalidTimestamp = payload("READY_FOR_DISTRIBUTION")
    invalidTimestamp.data.attributes.timestamp = "not-a-date"
    expect(parseWebhookDecision(invalidTimestamp)).toMatchObject({
      kind: "rejected",
      status: 400,
    })
  })
})
