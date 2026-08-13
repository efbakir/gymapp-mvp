import Image from "next/image"
import AppStoreBadge from "./AppStoreBadge"
import MarketingPhoto from "./MarketingPhoto"
import TrustBand from "./TrustBand"
import { APP_STORE_URL } from "@/lib/launchState"

export default function EditorialHero() {
  return (
    <section className="overflow-x-clip pb-[112px] pt-28 md:pb-[128px] md:pt-32">
      <div className="mx-auto max-w-[1360px] px-unit-md md:px-unit-lg xl:px-unit-xl">
        <div className="grid items-center gap-unit-xxl lg:grid-cols-[0.76fr_1.24fr] lg:gap-unit-xxxl">
          <div className="stagger-hero max-w-[480px]">
            <p className="eyebrow mb-unit-lg">Progressive overload made simple.</p>
            <h1 className="h-hero">Know what to lift next.</h1>
            <p className="mb-unit-xl mt-unit-lg max-w-lg text-lg leading-snug text-unit-text-secondary">
              Log every set in one tap. When the workout ends, Unit prepares one
              clear target for next time.
            </p>
            <AppStoreBadge href={APP_STORE_URL} />
            <div className="mt-unit-lg">
              <TrustBand />
            </div>
          </div>

          <div className="relative mx-auto w-full max-w-[760px] lg:justify-self-end">
            <MarketingPhoto
              src="/people/unit-hero-lifter-v2.webp"
              alt="Lifter between sets in a gym"
              slotLabel="unit-hero-lifter-v2.webp"
              sizes="(min-width: 1280px) 760px, (min-width: 1024px) 62vw, 92vw"
              priority
              enabled
              className="aspect-[4/5] rounded-2xl bg-black shadow-[0_32px_80px_rgba(10,10,10,0.16)]"
            />

            <div className="pointer-events-none absolute -bottom-unit-xl -left-unit-md z-10 w-[200px] drop-shadow-[0_24px_32px_rgba(10,10,10,0.22)] sm:-bottom-unit-xxl sm:-left-unit-lg sm:w-[260px] lg:-left-unit-xl lg:w-[296px]">
              <Image
                src="/screenshots/hero-ghost-values.png"
                alt="Unit workout screen with the last weight and reps ready"
                width={1658}
                height={2386}
                sizes="(min-width: 1024px) 296px, (min-width: 640px) 260px, 200px"
                className="block h-auto w-full"
              />
            </div>

            <div className="absolute right-unit-md top-unit-md rounded-full bg-unit-background px-unit-md py-unit-sm shadow-[0_12px_30px_rgba(10,10,10,0.1)]">
              <p className="text-sm font-semibold text-unit-text-primary">Next target ready</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
