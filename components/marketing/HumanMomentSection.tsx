import MarketingPhoto from "./MarketingPhoto"

const facts = [
  { value: "1", label: "next target" },
  { value: "1 tap", label: "to accept" },
  { value: "0", label: "automatic changes" },
]

export default function HumanMomentSection() {
  return (
    <section className="border-t border-unit-border py-unit-xxl md:py-unit-xxxl">
      <div className="mx-auto max-w-6xl px-unit-md md:px-unit-lg">
        <div className="grid items-center gap-unit-xl lg:grid-cols-[1.16fr_0.84fr] lg:gap-unit-xxxl">
          <MarketingPhoto
            src="/people/unit-between-sets.webp"
            alt="Lifter checking Unit on an iPhone between sets"
            slotLabel="unit-between-sets.webp"
            sizes="(min-width: 1024px) 58vw, 92vw"
            className="aspect-[3/2] rounded-2xl"
            imageClassName="grayscale"
            enabled
          />

          <div className="max-w-xl">
            <h2 className="h-campaign text-balance">
              Build reps.
              <span className="block">Then add weight.</span>
            </h2>
            <p className="mt-unit-lg text-base leading-snug text-unit-text-secondary">
              Choose a rep range and your smallest available weight increase.
              Unit uses the sets you completed to suggest the next step.
            </p>

            <dl className="mt-unit-xl grid grid-cols-3 gap-unit-md">
              {facts.map((fact) => (
                <div key={fact.label}>
                  <dt className="text-[22px] font-bold tracking-tight tabular-nums">
                    {fact.value}
                  </dt>
                  <dd className="mt-unit-xs text-sm text-unit-text-secondary">
                    {fact.label}
                  </dd>
                </div>
              ))}
            </dl>
          </div>
        </div>
      </div>
    </section>
  )
}
