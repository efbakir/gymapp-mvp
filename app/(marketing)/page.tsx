import type { Metadata } from "next"
import FAQItem from "@/components/marketing/FAQItem"
import BentoCard from "@/components/marketing/BentoCard"
import BentoGrid from "@/components/marketing/BentoGrid"
import DeviceFrame from "@/components/marketing/DeviceFrame"
import WaitlistForm from "@/components/marketing/WaitlistForm"
import AppStoreBadge from "@/components/marketing/AppStoreBadge"
import TrustBand from "@/components/marketing/TrustBand"
import FounderStory from "@/components/marketing/FounderStory"
import KW from "@/components/marketing/KW"
import { isLaunched, APP_STORE_URL } from "@/lib/launchState"
import { getWaitlistCount } from "@/lib/waitlist"

export const metadata: Metadata = {
  description:
    "Unit is a fast, local-first iOS gym tracker and workout log. Log a set in under 3 seconds — ghost values pre-fill from your last session. No AI, no social, no account.",
  alternates: { canonical: "/" },
}

// Revalidate the page (and the waitlist count it shows) every minute so the
// counter stays roughly fresh without hammering Resend.
export const revalidate = 60

const faqs = [
  {
    question: "How do ghost values work?",
    answer:
      "When you start a session, Unit pre-fills weight and reps from your most recent session for each exercise. Just tap Done to log the same values, or adjust them before tapping.",
  },
  {
    question: "Does Unit work offline?",
    answer:
      "Yes. All your data is stored locally on your device. No internet connection needed, no account required.",
  },
  {
    question: "How do I import my program?",
    answer:
      "During onboarding, choose 'Paste text' and paste your routine from Notes or WhatsApp. Unit reads exercise names, sets, reps, and weights automatically. You can also take a photo of your program or build from scratch.",
  },
  {
    question: "What programs does Unit support?",
    answer:
      "Any program with a fixed split. PPL, Upper/Lower, Full Body, or custom splits. You define the exercises and days; Unit doesn't impose structure.",
  },
  {
    question: "Is Unit free?",
    answer:
      "Core logging — sets, ghost values, rest timer, full history, PR detection, all templates — is free forever, with no ads. Unit Pro adds CSV/Markdown export, Apple Health sync, and custom app icons for $4.99/month or $29.99/year, with a 7-day free trial.",
  },
  {
    question: "When does Unit launch?",
    answer:
      "Unit is in App Store review now. Join the waitlist above and I'll email you once at launch; no marketing follow-up.",
  },
]

const softwareLd = {
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  name: "Unit",
  applicationCategory: "HealthApplication",
  operatingSystem: "iOS",
  description:
    "Fast iOS gym tracker and workout log. Log a set in under 3 seconds. Ghost values pre-fill from your last session. Local-first, no account, no AI.",
  url: "https://unitlift.app/",
  offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
}

const faqLd = {
  "@context": "https://schema.org",
  "@type": "FAQPage",
  mainEntity: faqs.map((f) => ({
    "@type": "Question",
    name: f.question,
    acceptedAnswer: { "@type": "Answer", text: f.answer },
  })),
}

export default async function LandingPage() {
  const fetchedCount = await getWaitlistCount()
  const waitlistCount = fetchedCount ?? undefined

  const PrimaryCTA = (
    <div className="space-y-unit-sm">
      {isLaunched ? (
        <AppStoreBadge href={APP_STORE_URL} />
      ) : (
        <WaitlistForm
          size="lg"
          caption="I'll email you once. No spam, no marketing list."
        />
      )}
    </div>
  )

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(softwareLd) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(faqLd) }}
      />

      {/* ── Hero ── */}
      <section className="pt-32 md:pt-40 pb-unit-xxl md:pb-unit-xxxl">
        <div className="max-w-6xl mx-auto px-unit-md md:px-unit-lg">
          <div className="grid grid-cols-1 lg:grid-cols-[1fr_minmax(0,360px)] xl:grid-cols-[1fr_minmax(0,400px)] gap-unit-xxl items-center">
            {/* Copy column */}
            <div className="stagger-hero max-w-2xl">
              <h1 className="h-display mb-unit-lg text-balance">
                <KW>Faster</KW> than paper.
              </h1>
              <p className="text-xl leading-snug mb-unit-xl max-w-xl text-unit-text-secondary">
                Log a set in one tap. Ghost values pre-fill from your last
                session. No typing. No menus. Under three seconds.
              </p>
              {PrimaryCTA}
              <div className="mt-unit-lg">
                <TrustBand count={waitlistCount} />
              </div>
            </div>

            {/* Mockup column */}
            <div className="relative w-full max-w-[360px] mx-auto lg:mx-0 lg:justify-self-end">
              {/* Drop the hero screenshot at /public/screens/hero-today.png
                  and pass src="/screens/hero-today.png" to swap the
                  placeholder out. Keep width/height — they lock the aspect. */}
              <DeviceFrame
                alt="The Unit Today screen"
                width={1206}
                height={2622}
                priority
                sizes="(min-width: 1024px) 400px, 360px"
              />
            </div>
          </div>
        </div>
      </section>

      {/* ── Bento feature grid ── */}
      <section
        id="how-it-works"
        className="py-unit-xxl md:py-unit-xxxl border-t border-unit-border"
      >
        <div className="max-w-6xl mx-auto px-unit-md md:px-unit-lg">
          <div className="mb-unit-xl md:mb-unit-xxl max-w-2xl">
            <p className="eyebrow mb-unit-xs">How it works</p>
            <h2 className="h-section">
              Designed for the bench, not your desk.
            </h2>
          </div>

          <BentoGrid>
            {/* Hero cell — One Tap Per Set */}
            <BentoCard
              span="2x2"
              eyebrow="One tap per set"
              title="Ghost values do the typing."
              body="Weight and reps pre-fill from your last session. Tap Done. Move on. Average set logs in under three seconds."
              mediaPosition="bottom"
              media={
                <div className="relative px-unit-lg md:px-unit-xl pt-unit-md pb-unit-lg md:pb-unit-xl overflow-hidden">
                  <div className="mx-auto max-w-[260px]">
                    <DeviceFrame
                      alt="Active workout view in Unit"
                      width={1206}
                      height={2622}
                      sizes="260px"
                    />
                  </div>
                </div>
              }
            />

            {/* Vertical 1×2 — Program Import */}
            <BentoCard
              span="1x2"
              eyebrow="Bring your program"
              title="Paste from Notes. Done."
              body="Paste your routine from Apple Notes or WhatsApp and Unit reads exercises, sets, reps, and weights automatically. Or build from scratch in under two minutes."
              mediaPosition="bottom"
              media={
                <div className="relative px-unit-md pt-unit-md pb-unit-lg md:pb-unit-xl overflow-hidden">
                  <div className="mx-auto max-w-[200px]">
                    <DeviceFrame
                      alt="Program view in Unit"
                      width={1206}
                      height={2622}
                      sizes="200px"
                    />
                  </div>
                </div>
              }
            />

            {/* Square 1×1 — History + PRs (progression proof) */}
            <BentoCard
              span="1x1"
              eyebrow="History · PRs"
              title="Every set. Every PR."
              body="Calendar of every session. PRs detected automatically. You decide when to add weight — Unit just remembers what you did."
            />

            {/* Square 1×1 — Rest Timer */}
            <BentoCard
              span="1x1"
              eyebrow="Rest timer"
              title="Follows you to the Lock Screen."
              body="Auto-starts on Done. Lives in the Dynamic Island. No need to reopen the app between sets."
            />

            {/* Square 1×1 — Offline + Local-first */}
            <BentoCard
              span="1x1"
              eyebrow="Offline · Local-first"
              title="Always works. Stays on your phone."
              body="No account. No sync. No internet. Your full workout history and PRs live on-device."
            />
          </BentoGrid>
        </div>
      </section>

      {/* ── Positioning ── */}
      <section className="py-unit-xxl md:py-unit-xxxl border-t border-unit-border">
        <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg">
          <h2 className="h-section mb-unit-md">
            Built for lifters who already know their program.
          </h2>
          <p className="text-xl leading-snug text-unit-text-secondary max-w-xl">
            Your data stays on your device. Always works offline. No social,
            no AI, no ceremony.
          </p>
        </div>
      </section>

      {/* ── What Unit is not ── */}
      <section className="py-unit-xxl md:py-unit-xxxl border-t border-unit-border">
        <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg">
          <p className="eyebrow mb-unit-md">What Unit is not</p>

          <div className="divide-y divide-unit-border">
            {[
              {
                title: "Not an AI coach.",
                body: "Unit doesn't tell you what to lift. You bring the program; Unit makes logging instant.",
              },
              {
                title: "Not a social platform.",
                body: "No feed. No followers. No likes. Training is personal.",
              },
              {
                title: "Not for beginners.",
                body: "Unit assumes you know your way around a barbell. That's a feature, not a limitation.",
              },
              {
                title: "Not subscription-locked.",
                body: "Core logging is free. Your workout data is never held hostage.",
              },
            ].map((item) => (
              <div
                key={item.title}
                className="py-unit-lg md:py-unit-xl flex flex-col md:flex-row md:items-baseline md:gap-unit-xl"
              >
                <h3 className="text-xl font-bold tracking-tight leading-snug md:flex-1">
                  {item.title}
                </h3>
                <p className="mt-unit-xs md:mt-0 text-base leading-relaxed text-unit-text-secondary md:flex-1 md:max-w-md">
                  {item.body}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Founder Story ── */}
      <section className="py-unit-xxl md:py-unit-xxxl border-t border-unit-border">
        <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg">
          <FounderStory />
        </div>
      </section>

      {/* ── FAQ ── */}
      <section
        id="faq"
        className="py-unit-xxl md:py-unit-xxxl border-t border-unit-border"
      >
        <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg">
          <h2 className="h-section mb-unit-xl">
            Common questions
          </h2>
          <div>
            {faqs.map((f, i) => (
              <FAQItem
                key={f.question}
                question={f.question}
                answer={f.answer}
                isLast={i === faqs.length - 1}
              />
            ))}
          </div>
        </div>
      </section>

      {/* ── Final CTA ── */}
      <section
        id="download"
        className="py-unit-xxxl md:py-unit-xxxxl border-t border-unit-border"
      >
        <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg text-center">
          <h2 className="h-section mb-unit-md">
            Stop fighting your tracker.
          </h2>
          <p className="text-xl leading-snug mb-unit-xl text-unit-text-secondary max-w-xl mx-auto">
            Log faster than paper. Keep your data. Train.
          </p>
          <div className="flex justify-center">
            {isLaunched ? (
              <AppStoreBadge href={APP_STORE_URL} />
            ) : (
              <WaitlistForm size="lg" />
            )}
          </div>
          {isLaunched && (
            <p className="eyebrow mt-unit-md">
              Founding members lock in $29.99/year forever.
            </p>
          )}
        </div>
      </section>
    </>
  )
}
