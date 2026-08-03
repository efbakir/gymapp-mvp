import type { ReleaseRecord } from "./types"

export type ReleaseNoteBlock =
  | { kind: "paragraph"; text: string }
  | { kind: "list"; items: string[] }

const bulletPattern = /^\s*(?:[-*•])\s+(.+?)\s*$/

export function normalizeReleaseNotes(value: unknown): string | null {
  if (typeof value !== "string") return null
  const normalized = value
    .replace(/\r\n?/g, "\n")
    .replace(/\u0000/g, "")
    .split("\n")
    .map((line) => line.trimEnd())
    .join("\n")
    .trim()

  return normalized.length > 0 ? normalized : null
}

export function releaseNoteBlocks(value: string | null): ReleaseNoteBlock[] {
  if (!value) return []

  const blocks: ReleaseNoteBlock[] = []
  let paragraphLines: string[] = []
  let listItems: string[] = []

  const flushParagraph = () => {
    if (paragraphLines.length === 0) return
    blocks.push({ kind: "paragraph", text: paragraphLines.join("\n") })
    paragraphLines = []
  }

  const flushList = () => {
    if (listItems.length === 0) return
    blocks.push({ kind: "list", items: listItems })
    listItems = []
  }

  for (const line of value.split("\n")) {
    if (line.trim().length === 0) {
      flushParagraph()
      flushList()
      continue
    }

    const bullet = line.match(bulletPattern)
    if (bullet) {
      flushParagraph()
      listItems.push(bullet[1])
    } else {
      flushList()
      paragraphLines.push(line)
    }
  }

  flushParagraph()
  flushList()
  return blocks
}

export function formatReleaseDate(isoDate: string): string {
  return new Intl.DateTimeFormat("en-US", {
    month: "long",
    day: "numeric",
    year: "numeric",
    timeZone: "UTC",
  }).format(new Date(isoDate))
}

const versionCollator = new Intl.Collator("en", {
  numeric: true,
  sensitivity: "base",
})

export function compareReleasesNewestFirst(
  left: Pick<ReleaseRecord, "releasedAt" | "versionString">,
  right: Pick<ReleaseRecord, "releasedAt" | "versionString">,
): number {
  const byDate =
    new Date(right.releasedAt).getTime() - new Date(left.releasedAt).getTime()
  if (byDate !== 0) return byDate
  return versionCollator.compare(right.versionString, left.versionString)
}

export function compareVersionsAscending(left: string, right: string): number {
  return versionCollator.compare(left, right)
}
