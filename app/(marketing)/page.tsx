import type { Metadata } from "next"
import FAQItem from "@/components/marketing/FAQItem"

export const metadata: Metadata = {
  title: "Unit — Simple Gym Logger",
  description:
    "Log sets fast, keep your program organized, and actually use your training history—without a bloated fitness app.",
}

export default function LandingPage() {
  return (
    <>
      {/* ── Hero ── */}
      <section className="pt-40 pb-unit-xxl md:pt-48 md:pb-[96px]">
        <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg text-center">
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight leading-[1.08] mb-unit-lg">
            Gym logging, stripped to what matters.
          </h1>
          <p className="text-lg md:text-xl leading-relaxed mb-unit-xl max-w-xl mx-auto text-unit-text-secondary">
            Your split, your sets, your history—fast to log, easy to trust. No clutter.
          </p>
          <a
            href="#PLACEHOLDER_APP_STORE_URL"
            className="inline-flex items-center justify-center px-8 py-3.5 rounded-xl text-base font-semibold transition-opacity hover:opacity-80 bg-unit-accent text-unit-accent-foreground"
          >
            Download for iOS
          </a>
        </div>
      </section>

      {/* ── How it works ── */}
      <section id="how-it-works" className="py-unit-xxl md:py-[96px]">
        <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-unit-xl md:gap-unit-xxl">
            <div>
              <p className="text-sm font-semibold text-unit-text-secondary mb-unit-xxs">
                Log in seconds
              </p>
              <p className="text-base leading-relaxed">
                Big targets, sensible defaults, one-tap flow—built for tired hands at the rack.
              </p>
            </div>
            <div>
              <p className="text-sm font-semibold text-unit-text-secondary mb-unit-xxs">
                Program stays organized
              </p>
              <p className="text-base leading-relaxed">
                Days, exercises, and sessions in one place so you’re not hunting notes between sets.
              </p>
            </div>
            <div>
              <p className="text-sm font-semibold text-unit-text-secondary mb-unit-xxs">
                Optional progression
              </p>
              <p className="text-base leading-relaxed">
                Working in a cycle? Targets and hit/miss rules can steer what you lift next—including automatic deloads when you stall.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* ── Positioning ── */}
      <section className="py-unit-xxl md:py-[96px]">
        <div className="max-w-2xl mx-auto px-unit-md md:px-unit-lg text-center">
          <p className="text-xl md:text-2xl font-semibold leading-relaxed">
            Built for lifters who already have a plan.
            <br />
            <span className="text-unit-text-secondary">
              Designed for fast logging under fatigue.
            </span>
            <br />
            <span className="text-unit-text-secondary">
              Buy once; use it for years.
            </span>
          </p>
        </div>
      </section>

      {/* ── FAQ ── */}
      <section id="faq" className="py-unit-xxl md:py-[96px]">
        <div className="max-w-2xl mx-auto px-unit-md md:px-unit-lg">
          <h2 className="text-2xl font-bold tracking-tight mb-unit-xl">
            FAQ
          </h2>
          <div>
            <FAQItem
              question="Is Unit a subscription?"
              answer="No. Unit is a one-time purchase. No recurring fees, no premium tiers, no ads."
            />
            <FAQItem
              question="Does Unit work offline?"
              answer="Yes. All your data is stored locally on your device. No internet connection needed to log workouts."
            />
            <FAQItem
              question="How does progression work?"
              answer="When you train inside an active cycle, exercises can follow simple rules: hit your target and weight may move up next time; miss and it can repeat; three misses in a row can trigger a 10% deload so you’re not stuck grinding failure. You can still use Unit as a focused logger—the cycle layer is there when you want that structure."
            />
            <FAQItem
              question="What programs does Unit support?"
              answer="Any program with a fixed split. PPL, Upper/Lower, Full Body, or custom splits. You define the exercises and days."
            />
            <FAQItem
              question="Can I restore my purchase?"
              answer="Yes. Open Unit, go to Settings, and tap Restore Purchase. Your unlock is tied to your Apple ID."
            />
          </div>
        </div>
      </section>

      {/* ── Bottom CTA ── */}
      <section className="py-unit-xxl md:py-[96px]">
        <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg text-center">
          <p className="text-xl md:text-2xl font-semibold mb-unit-lg">
            Start logging your next session.
          </p>
          <a
            href="#PLACEHOLDER_APP_STORE_URL"
            className="inline-flex items-center justify-center px-8 py-3.5 rounded-xl text-base font-semibold transition-opacity hover:opacity-80 bg-unit-accent text-unit-accent-foreground"
          >
            Download for iOS
          </a>
        </div>
      </section>
    </>
  )
}
