import fs from "node:fs"

const markdown = fs.readFileSync("docs/app-store-copy.md", "utf8")
const failures = []

function value(heading) {
  const escaped = heading.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
  return markdown.match(
    new RegExp(`^## ${escaped}[^\\n]*\\n[\\s\\S]*?^` + "```\\n([\\s\\S]*?)\\n```", "m"),
  )?.[1]
}

function check(condition, message) {
  if (!condition) failures.push(message)
}

const fields = {
  name: value("App name"),
  subtitle: value("Subtitle"),
  promotionalText: value("Promotional text"),
  description: value("Description"),
  keywords: value("Keywords"),
  whatsNew: value("What's New — v2.1") ?? value("What’s New — v2.1"),
}

for (const [key, fieldValue] of Object.entries(fields)) {
  check(Boolean(fieldValue), `Missing canonical ${key} field`)
}

check([...fields.name ?? ""].length <= 30, "App name exceeds 30 characters")
check([...fields.subtitle ?? ""].length <= 30, "Subtitle exceeds 30 characters")
check([...fields.promotionalText ?? ""].length <= 170, "Promotional text exceeds 170 characters")
check([...fields.description ?? ""].length <= 4000, "Description exceeds 4000 characters")
check([...fields.whatsNew ?? ""].length <= 4000, "What's New exceeds 4000 characters")

const keywordBytes = Buffer.byteLength((fields.keywords ?? "").normalize("NFC"), "utf8")
check(keywordBytes <= 100, `Keywords exceed 100 UTF-8 bytes (${keywordBytes})`)
check(!/\s/.test(fields.keywords ?? ""), "Keywords contain whitespace")

const indexedWords = new Set(
  `${fields.name ?? ""} ${fields.subtitle ?? ""}`.toLowerCase().match(/[a-z0-9]+/g) ?? [],
)
for (const keyword of (fields.keywords ?? "").toLowerCase().split(",")) {
  check(!indexedWords.has(keyword), `Keyword duplicates name/subtitle: ${keyword}`)
}

for (const required of [
  "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",
  "https://unitlift.app/privacy",
  "Raw workout details stay on your iPhone",
  "not linked to your identity",
  "not used for tracking",
  "disabled in Settings",
]) {
  check((fields.description ?? "").includes(required), `Description is missing: ${required}`)
}

check((markdown.match(/^\d\. `.+` —/gm) ?? []).length === 6, "Screenshot plan must contain exactly six ordered messages")

console.table({
  name: `${[...fields.name ?? ""].length}/30 chars`,
  subtitle: `${[...fields.subtitle ?? ""].length}/30 chars`,
  promotionalText: `${[...fields.promotionalText ?? ""].length}/170 chars`,
  description: `${[...fields.description ?? ""].length}/4000 chars`,
  keywords: `${keywordBytes}/100 bytes`,
  whatsNew: `${[...fields.whatsNew ?? ""].length}/4000 chars`,
})

if (failures.length) {
  failures.forEach((failure) => console.error(`ERROR ${failure}`))
  process.exit(1)
}

console.log("Canonical English App Store metadata passed limits, disclosure, keyword, and screenshot-order checks.")
