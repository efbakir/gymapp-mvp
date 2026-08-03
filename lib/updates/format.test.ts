import { describe, expect, it } from "vitest"
import {
  compareReleasesNewestFirst,
  formatReleaseDate,
  normalizeReleaseNotes,
  releaseNoteBlocks,
} from "./format"

describe("release note formatting", () => {
  it("normalizes line endings without rewriting copy", () => {
    expect(normalizeReleaseNotes("  First\r\n• Second  \r\n")).toBe(
      "First\n• Second",
    )
  })

  it("separates paragraphs and consecutive bullet lists", () => {
    expect(
      releaseNoteBlocks(
        "A short introduction.\n\n• First change\n- Second change\n\nClosing line.",
      ),
    ).toEqual([
      { kind: "paragraph", text: "A short introduction." },
      { kind: "list", items: ["First change", "Second change"] },
      { kind: "paragraph", text: "Closing line." },
    ])
  })

  it("formats dates in UTC", () => {
    expect(formatReleaseDate("2026-07-21T23:45:00Z")).toBe("July 21, 2026")
  })

  it("sorts newest date first and versions numerically on ties", () => {
    const releases = [
      { releasedAt: "2026-07-01T00:00:00Z", versionString: "2.9" },
      { releasedAt: "2026-07-01T00:00:00Z", versionString: "2.10" },
      { releasedAt: "2026-08-01T00:00:00Z", versionString: "3.0" },
    ]
    expect(releases.sort(compareReleasesNewestFirst).map((item) => item.versionString)).toEqual([
      "3.0",
      "2.10",
      "2.9",
    ])
  })
})
