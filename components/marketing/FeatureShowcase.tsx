import type { ReactNode } from "react"
import DeviceFrame from "./DeviceFrame"

type FeatureShowcaseItem = {
  eyebrow?: string
  title: string
  body: string
  microStat?: string
  mockup?: {
    src?: string
    alt: string
    width: number
    height: number
    sizes?: string
    className?: string
    clipOverflow?: boolean
  }
  children?: ReactNode
}

export default function FeatureShowcase({
  title,
  body,
  items,
}: {
  title: string
  body?: string
  items: FeatureShowcaseItem[]
}) {
  return (
    <div>
      <div className="mx-auto mb-unit-xxl max-w-3xl text-center">
        <h2 className="h-section text-balance">{title}</h2>
        {body && (
          <p className="mx-auto mt-unit-md max-w-2xl text-base leading-snug text-unit-text-secondary">
            {body}
          </p>
        )}
      </div>

      <div className="divide-y divide-unit-border border-y border-unit-border">
        {items.map((item, index) => (
          <article
            key={item.title}
            className="grid items-center gap-unit-xl py-unit-xl md:grid-cols-2 md:gap-unit-xxl md:py-unit-xxl"
          >
            <div className={index % 2 === 1 ? "md:order-2" : undefined}>
              {item.eyebrow && (
                <p className="mb-unit-sm text-sm font-semibold text-unit-text-secondary">
                  {item.eyebrow}
                </p>
              )}
              <h3 className="text-[22px] font-bold leading-[1.12] tracking-tight text-unit-text-primary">
                {item.title}
              </h3>
              <p className="mt-unit-sm max-w-xl text-base leading-relaxed text-unit-text-secondary">
                {item.body}
              </p>
              {item.microStat && (
                <p className="mt-unit-md text-sm font-semibold">{item.microStat}</p>
              )}
              {item.children}
            </div>

            {item.mockup && (
              <div
                className={`rounded-2xl bg-unit-card px-unit-lg py-unit-lg ${
                  item.mockup.clipOverflow ? "overflow-hidden" : ""
                } ${index % 2 === 1 ? "md:order-1" : ""}`}
              >
                <div className="mx-auto max-w-[var(--marketing-feature-device-width)]">
                  <DeviceFrame
                    src={item.mockup.src}
                    alt={item.mockup.alt}
                    width={item.mockup.width}
                    height={item.mockup.height}
                    sizes={item.mockup.sizes}
                    className={item.mockup.className}
                  />
                </div>
              </div>
            )}
          </article>
        ))}
      </div>
    </div>
  )
}
