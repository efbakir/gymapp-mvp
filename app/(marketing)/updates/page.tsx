import type { Metadata } from "next"
import { APP_STORE_URL } from "@/lib/launchState"
import { SITE_URL } from "@/lib/site"
import {
  formatReleaseDate,
  releaseNoteBlocks,
} from "@/lib/updates/format"
import { logUpdatesEvent } from "@/lib/updates/runtime"
import { BlobReleaseCatalogStore } from "@/lib/updates/store"
import type { ReleaseRecord } from "@/lib/updates/types"

export const revalidate = 3600

const description =
  "See every public Unit update, with version notes straight from the App Store."

export const metadata: Metadata = {
  title: "What’s New",
  description,
  alternates: { canonical: "/updates" },
  openGraph: {
    type: "website",
    url: `${SITE_URL}/updates`,
    title: "What’s New | Unit",
    description,
    images: [
      {
        url: "/opengraph-image",
        width: 1200,
        height: 630,
        alt: "Unit: Progressive Overload",
      },
    ],
  },
}

async function getReleases(): Promise<ReleaseRecord[]> {
  try {
    const catalog = await new BlobReleaseCatalogStore().readCatalog({
      useCache: false,
    })
    return catalog?.releases ?? []
  } catch (error) {
    logUpdatesEvent("error", "updates_page_catalog_unavailable", {
      code:
        error instanceof Error && /^[A-Z0-9_]+$/.test(error.message)
          ? error.message
          : "UPDATES_PAGE_CATALOG_UNAVAILABLE",
    })
    return []
  }
}

function ReleaseNotes({ release }: { release: ReleaseRecord }) {
  const blocks = releaseNoteBlocks(release.whatsNew)
  if (blocks.length === 0) {
    return (
      <p className="text-base leading-relaxed text-unit-text-secondary">
        No App Store release notes were provided.
      </p>
    )
  }

  return (
    <div className="space-y-unit-sm text-base leading-relaxed text-unit-text-secondary">
      {blocks.map((block, index) =>
        block.kind === "list" ? (
          <ul
            key={`list-${index}`}
            className="list-disc space-y-unit-xs pl-unit-lg"
          >
            {block.items.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ul>
        ) : (
          <p key={`paragraph-${index}`} className="whitespace-pre-line">
            {block.text}
          </p>
        ),
      )}
    </div>
  )
}

function ReleaseHeading({
  release,
  latest,
}: {
  release: ReleaseRecord
  latest: boolean
}) {
  return (
    <header className="mb-unit-md">
      <div className="mb-unit-xs flex flex-wrap items-center gap-unit-sm">
        {latest && (
          <span className="rounded-md bg-unit-accent px-unit-sm py-unit-xs font-mono text-[11px] font-bold uppercase tracking-[0.6px] text-unit-accent-foreground">
            Latest
          </span>
        )}
        <time className="eyebrow" dateTime={release.releasedAt}>
          {formatReleaseDate(release.releasedAt)}
        </time>
      </div>
      <h2
        className={
          latest
            ? "text-[26px] font-bold leading-tight tracking-tight text-unit-text-primary"
            : "text-xl font-bold leading-tight tracking-tight text-unit-text-primary"
        }
      >
        Version {release.versionString}
      </h2>
    </header>
  )
}

export default async function UpdatesPage() {
  const releases = await getReleases()
  const [latest, ...older] = releases

  return (
    <>
      <section className="pb-unit-xl pt-32 md:pb-unit-xxl md:pt-40">
        <div className="mx-auto max-w-3xl px-unit-md md:px-unit-lg">
          <p className="eyebrow mb-unit-sm">What&rsquo;s New</p>
          <h1 className="h-section mb-unit-md">What&rsquo;s New</h1>
          <p className="max-w-2xl text-lg leading-relaxed text-unit-text-secondary">
            Every public Unit update, exactly as it appears on the App Store.
          </p>
        </div>
      </section>

      <section
        className="pb-unit-xxl md:pb-unit-xxxxl"
        aria-label="Unit version history"
      >
        <div className="mx-auto max-w-3xl px-unit-md md:px-unit-lg">
          {latest ? (
            <>
              <article className="rounded-xl bg-unit-card p-unit-lg md:p-unit-xl">
                <ReleaseHeading release={latest} latest />
                <ReleaseNotes release={latest} />
                <div className="mt-unit-xl border-t border-unit-border pt-unit-lg">
                  <a
                    href={APP_STORE_URL}
                    target="_blank"
                    rel="noreferrer"
                    className="btn-primary min-h-[52px] px-unit-lg text-[13px] sm:text-[14px]"
                  >
                    Download or update on the App Store
                  </a>
                </div>
              </article>

              {older.length > 0 && (
                <div className="mt-unit-xxl" aria-label="Earlier updates">
                  {older.map((release) => (
                    <article
                      key={release.key}
                      className="border-t border-unit-border py-unit-xl first:pt-unit-lg"
                    >
                      <ReleaseHeading release={release} latest={false} />
                      <ReleaseNotes release={release} />
                    </article>
                  ))}
                </div>
              )}
            </>
          ) : (
            <div className="rounded-xl bg-unit-card p-unit-lg md:p-unit-xl">
              <h2 className="text-xl font-bold tracking-tight">
                Updates are syncing.
              </h2>
              <p className="mt-unit-sm max-w-xl text-base leading-relaxed text-unit-text-secondary">
                The public version history will appear here after the first
                App Store sync.
              </p>
            </div>
          )}
        </div>
      </section>
    </>
  )
}
