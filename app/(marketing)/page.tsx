import type { Metadata } from "next"
import FAQItem from "@/components/marketing/FAQItem"

export const metadata: Metadata = {
  title: "Unit — Your Gym Notebook, Upgraded",
  description:
    "Log sets in one tap. Ghost values pre-fill your last session. No AI, no social, no typing. Built for lifters who already know their program.",
}

export default function LandingPage() {
  return (
    <>
      {/* ── Hero ── */}
      <section className="pt-40 pb-unit-xxl md:pt-48 md:pb-[96px]">
        <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg text-center">
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold tracking-tight leading-[1.08] mb-unit-lg">
            Your tracker is slower than paper.
            <br />
            <span className="text-unit-text-secondary">Unit isn't.</span>
          </h1>
          <p className="text-lg md:text-xl leading-relaxed mb-unit-xl max-w-xl mx-auto text-unit-text-secondary">
            Log a set in one tap. Ghost values pre-fill from your last session.
            No typing. No menus. Under 3 seconds.
          </p>
          <a
            href="#download"
            className="inline-flex items-center justify-center px-8 py-3.5 rounded-xl text-base font-semibold transition-all hover:opacity-80 active:scale-[0.96] bg-unit-accent text-unit-accent-foreground"
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
              <p className="text-sm font-semibold text-unit-text-secondary mb-unit-xxs tracking-wide uppercase">
                One tap per set
              </p>
              <p className="text-base leading-relaxed">
                Ghost values pre-fill your weight and reps. See what you did last time. Tap Done. That's it.
              </p>
            </div>
            <div>
              <p className="text-sm font-semibold text-unit-text-secondary mb-unit-xxs tracking-wide uppercase">
                Your program, your way
              </p>
              <p className="text-base leading-relaxed">
                Import from Notes, paste from WhatsApp, or build from scratch. Under 2 minutes to set up.
              </p>
            </div>
            <div>
              <p className="text-sm font-semibold text-unit-text-secondary mb-unit-xxs tracking-wide uppercase">
                Rest timer follows you
              </p>
              <p className="text-base leading-relaxed">
                Timer auto-starts on Done. Shows on your Lock Screen and Dynamic Island. No need to reopen the app.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* ── Positioning ── */}
      <section className="py-unit-xxl md:py-[96px]">
        <div className="max-w-2xl mx-auto px-unit-md md:px-unit-lg text-center">
          <p className="text-xl md:text-2xl font-semibold leading-relaxed">
            Built for lifters who already know their program.
            <br />
            <span className="text-unit-text-secondary">
              No AI coach. No social feed. No subscription on logging.
            </span>
            <br />
            <span className="text-unit-text-secondary">
              Your data stays on your device. Always works offline.
            </span>
          </p>
        </div>
      </section>

      {/* ── What Unit is not ── */}
      <section className="py-unit-xxl md:py-[96px]">
        <div className="max-w-2xl mx-auto px-unit-md md:px-unit-lg">
          <h2 className="text-2xl font-bold tracking-tight mb-unit-xl">
            What Unit is not
          </h2>
          <div className="space-y-unit-lg">
            <p className="text-base leading-relaxed">
              <span className="font-semibold">Not an AI coach.</span>{" "}
              <span className="text-unit-text-secondary">
                We don't tell you what to lift. You bring the program, we make logging instant.
              </span>
            </p>
            <p className="text-base leading-relaxed">
              <span className="font-semibold">Not a social platform.</span>{" "}
              <span className="text-unit-text-secondary">
                No feed. No followers. No likes. Training is personal.
              </span>
            </p>
            <p className="text-base leading-relaxed">
              <span className="font-semibold">Not for beginners.</span>{" "}
              <span className="text-unit-text-secondary">
                We assume you know your way around a barbell. That's a feature, not a limitation.
              </span>
            </p>
            <p className="text-base leading-relaxed">
              <span className="font-semibold">Not subscription-locked.</span>{" "}
              <span className="text-unit-text-secondary">
                Core logging is free. Your workout data is never held hostage.
              </span>
            </p>
          </div>
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
              question="How do ghost values work?"
              answer="When you start a session, Unit pre-fills weight and reps from your most recent session for each exercise. Just tap Done to log the same values, or adjust them before tapping."
            />
            <FAQItem
              question="Does Unit work offline?"
              answer="Yes. All your data is stored locally on your device. No internet connection needed, no account required."
            />
            <FAQItem
              question="How do I import my program?"
              answer="During onboarding, choose 'Paste text' and paste your routine from Notes or WhatsApp. Unit reads exercise names, sets, reps, and weights automatically. You can also take a photo of your program or build from scratch."
            />
            <FAQItem
              question="What programs does Unit support?"
              answer="Any program with a fixed split. PPL, Upper/Lower, Full Body, or custom splits. You define the exercises and days — Unit doesn't impose structure."
            />
            <FAQItem
              question="Is Unit free?"
              answer="Yes. Core workout logging is free with no ads. Premium features may be added in the future, but logging will always be free."
            />
          </div>
        </div>
      </section>

    </>
  )
}
