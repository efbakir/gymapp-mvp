import MarketingPhoto from "./MarketingPhoto"

const audiences = [
  {
    label: "Bodybuilders",
    src: "/people/lifter-bodybuilder.webp",
    file: "lifter-bodybuilder.webp",
    rotation: "-rotate-2",
    enabled: true,
  },
  {
    label: "Powerlifters",
    src: "/people/lifter-powerlifter.webp",
    file: "lifter-powerlifter.webp",
    rotation: "rotate-2",
    enabled: true,
  },
  {
    label: "New lifters",
    src: "/people/lifter-beginner.webp",
    file: "lifter-beginner.webp",
    rotation: "-rotate-1",
    enabled: true,
  },
  {
    label: "Strength athletes",
    src: "/people/lifter-strength.webp",
    file: "lifter-strength.webp",
    rotation: "rotate-1",
    enabled: true,
  },
  {
    label: "Hypertrophy lifters",
    src: "/people/lifter-hypertrophy.webp",
    file: "lifter-hypertrophy.webp",
    rotation: "rotate-2",
    enabled: true,
  },
  {
    label: "Home gym lifters",
    src: "/people/lifter-home-gym.webp",
    file: "lifter-home-gym.webp",
    rotation: "-rotate-2",
    enabled: true,
  },
  {
    label: "Program followers",
    src: "/people/lifter-program-follower.webp",
    file: "lifter-program-follower.webp",
    rotation: "rotate-1",
    enabled: true,
  },
  {
    label: "Routine builders",
    src: "/people/lifter-routine-builder.webp",
    file: "lifter-routine-builder.webp",
    rotation: "-rotate-1",
    enabled: true,
  },
]

export default function AudienceStrip() {
  return (
    <section
      id="for-lifters"
      className="scroll-mt-20 border-t border-unit-border py-unit-xxl md:py-unit-xxxl"
    >
      <div className="mx-auto max-w-6xl px-unit-md md:px-unit-lg">
        <div className="mx-auto mb-unit-xxl max-w-3xl text-center">
          <h2 className="h-campaign text-balance">
            Progression for every kind of lifter.
          </h2>
          <p className="mx-auto mt-unit-md max-w-xl text-base leading-snug text-unit-text-secondary">
            Your program stays yours, whether you train for strength, muscle, or both.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-unit-lg sm:grid-cols-2 lg:grid-cols-4">
          {audiences.map((audience) => (
            <div
              key={audience.label}
              className="flex items-center gap-unit-sm"
            >
              <MarketingPhoto
                src={audience.src}
                alt={`${audience.label} training`}
                slotLabel={audience.file}
                sizes="72px"
                className={`h-[72px] w-[72px] shrink-0 rounded-2xl shadow-[0_12px_28px_rgba(10,10,10,0.1)] ${audience.rotation}`}
                enabled={audience.enabled}
              />
              <p className="text-sm font-bold tracking-tight">{audience.label}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
