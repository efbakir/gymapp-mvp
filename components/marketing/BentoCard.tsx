import type { ReactNode } from "react"

type Span = "2x2" | "1x2" | "1x1" | "2x1"

const spanClasses: Record<Span, string> = {
  // Desktop: 3-col × 3-row asymmetric bento. Mobile collapses to 1-col by
  // ignoring spans (every card becomes one row stacked).
  "2x2": "md:col-span-2 md:row-span-2",
  "1x2": "md:col-span-1 md:row-span-2",
  "1x1": "md:col-span-1 md:row-span-1",
  "2x1": "md:col-span-2 md:row-span-1",
}

export default function BentoCard({
  eyebrow,
  title,
  body,
  media,
  span = "1x1",
  mediaPosition = "bottom",
}: {
  eyebrow?: string
  title: string
  body: string
  media?: ReactNode
  span?: Span
  mediaPosition?: "bottom" | "top" | "fill"
}) {
  return (
    <article
      className={`lift-hover relative flex h-full flex-col rounded-xl bg-unit-card overflow-hidden ${spanClasses[span]}`}
    >
      {mediaPosition === "top" && media && (
        <div className="relative">{media}</div>
      )}

      <div className="relative flex flex-col gap-unit-xs p-unit-lg md:p-unit-xl">
        {eyebrow && <p className="eyebrow">{eyebrow}</p>}
        <h3 className="text-xl font-bold tracking-tight leading-snug">
          {title}
        </h3>
        <p className="text-base leading-relaxed text-unit-text-secondary">
          {body}
        </p>
      </div>

      {(mediaPosition === "bottom" || mediaPosition === "fill") && media && (
        <div className="relative mt-auto">{media}</div>
      )}
    </article>
  )
}
