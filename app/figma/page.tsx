const lightColors = [
  { name: "background", value: "#F2F2F7", note: "Page background" },
  { name: "surface", value: "#FFFFFF", note: "Grouped list surface" },
  { name: "cardBackground", value: "#FFFFFF", note: "Cards and panels" },
  { name: "elevatedSurface", value: "#FBFBFD", note: "Raised utility areas" },
  { name: "textPrimary", value: "#000000", note: "Primary text" },
  { name: "textSecondary", value: "#8E8E93", note: "Secondary text" },
  { name: "mutedText", value: "#8E8E93", note: "Muted labels" },
  { name: "accent", value: "#000000", note: "Primary actions" },
  { name: "accentSoft", value: "rgba(0,0,0,0.06)", note: "Quiet emphasis" },
  { name: "programHighlight", value: "#C96A16", note: "Program-specific highlight" },
  { name: "programHighlightSoft", value: "rgba(201,106,22,0.10)", note: "Soft program tint" },
  { name: "onboardingAccent", value: "#FF8A1F", note: "Onboarding accent" },
  { name: "border", value: "#F2F2F7", note: "Hairlines and strokes" },
  { name: "disabled", value: "#8E8E93", note: "Disabled fill/text" },
  { name: "success", value: "#34C759", note: "Success state" },
  { name: "warning", value: "#FF9500", note: "Warning state" },
  { name: "error", value: "#FF3B30", note: "Failure state" },
]

const darkColors = [
  { name: "background", value: "#000000" },
  { name: "surface", value: "#1C1C1E" },
  { name: "cardBackground", value: "#1C1C1E" },
  { name: "elevatedSurface", value: "#151517" },
  { name: "textPrimary", value: "#FFFFFF" },
  { name: "textSecondary", value: "#8E8E93" },
  { name: "mutedText", value: "#636366" },
  { name: "accent", value: "#FFFFFF" },
  { name: "accentSoft", value: "rgba(255,255,255,0.08)" },
  { name: "programHighlight", value: "#F3A14D" },
  { name: "programHighlightSoft", value: "rgba(242,161,77,0.18)" },
  { name: "onboardingAccent", value: "#FF8A1F" },
  { name: "border", value: "#38383A" },
  { name: "disabled", value: "#636366" },
  { name: "success", value: "#30D158" },
  { name: "warning", value: "#FF9F0A" },
  { name: "error", value: "#FF453A" },
]

const spacing = [
  { name: "xs", value: 4 },
  { name: "sm", value: 8 },
  { name: "smd", value: 12 },
  { name: "md", value: 16 },
  { name: "lg", value: 24 },
  { name: "xl", value: 32 },
  { name: "xxl", value: 48 },
]

const radii = [
  { name: "sm", value: 8 },
  { name: "md", value: 12 },
  { name: "lg", value: 16 },
  { name: "xl", value: 24 },
]

const typography = [
  { name: "heroDisplay", size: "52", weight: "900", sample: "Unit" },
  { name: "screenHeader", size: "32", weight: "700", sample: "Today" },
  { name: "largeTitle", size: "22", weight: "700", sample: "Workout complete" },
  { name: "title", size: "20", weight: "600", sample: "Next week target" },
  { name: "sectionHeader", size: "17", weight: "600", sample: "History" },
  { name: "body", size: "16", weight: "400", sample: "Targets are recalculated after misses." },
  { name: "caption", size: "12", weight: "400", sample: "Quiet metadata and helper text" },
  { name: "numericDisplay", size: "36", weight: "700", sample: "100.0" },
  { name: "numericLarge", size: "28", weight: "700", sample: "2:00" },
]

function Section({
  eyebrow,
  title,
  description,
  children,
}: {
  eyebrow: string
  title: string
  description: string
  children: React.ReactNode
}) {
  return (
    <section className="rounded-[32px] border border-black/8 bg-white p-8 shadow-[0_24px_80px_rgba(15,23,42,0.08)]">
      <div className="mb-8 flex items-end justify-between gap-6">
        <div className="max-w-2xl">
          <div className="mb-3 text-[11px] font-semibold uppercase tracking-[0.24em] text-black/45">
            {eyebrow}
          </div>
          <h2 className="text-[32px] font-bold tracking-[-0.04em] text-black">{title}</h2>
          <p className="mt-3 max-w-xl text-[15px] leading-6 text-black/58">{description}</p>
        </div>
      </div>
      {children}
    </section>
  )
}

function ToneFrame({
  mode,
  background,
  card,
  text,
  textSecondary,
  accent,
  accentSoft,
  border,
}: {
  mode: string
  background: string
  card: string
  text: string
  textSecondary: string
  accent: string
  accentSoft: string
  border: string
}) {
  return (
    <div className="rounded-[28px] p-6" style={{ background }}>
      <div className="mb-6 flex items-center justify-between">
        <div>
          <div className="text-[11px] font-semibold uppercase tracking-[0.24em]" style={{ color: textSecondary }}>
            {mode}
          </div>
          <div className="mt-2 text-[28px] font-bold tracking-[-0.04em]" style={{ color: text }}>
            Component Tone
          </div>
        </div>
        <div
          className="rounded-full px-3 py-1 text-[12px] font-semibold"
          style={{ color: accent, background: accentSoft }}
        >
          AppTag
        </div>
      </div>

      <div className="rounded-[24px] p-5 shadow-[0_10px_30px_rgba(15,23,42,0.05)]" style={{ background: card }}>
        <div className="flex items-center justify-between">
          <div>
            <div className="text-[17px] font-semibold" style={{ color: text }}>
              Day 2 • Pull
            </div>
            <div className="mt-1 text-[13px]" style={{ color: textSecondary }}>
              Targets ready for today
            </div>
          </div>
          <div className="text-[28px] font-bold tabular-nums" style={{ color: text }}>
            100
          </div>
        </div>

        <div className="my-5 h-px w-full" style={{ background: border }} />

        <div className="grid grid-cols-[1fr_auto] items-center gap-4">
          <div>
            <div className="text-[12px] font-semibold uppercase tracking-[0.18em]" style={{ color: textSecondary }}>
              Next target
            </div>
            <div className="mt-2 text-[20px] font-semibold" style={{ color: text }}>
              Bench Press
            </div>
          </div>
          <button
            className="rounded-[12px] px-4 py-3 text-[16px] font-semibold"
            style={{ background: accent, color: mode === "Dark" ? "#000" : "#FFF" }}
          >
            Start
          </button>
        </div>
      </div>
    </div>
  )
}

function SurfaceCard({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="rounded-[24px] border border-black/8 bg-[#fbfbfd] p-5">
      <div className="mb-4 text-[12px] font-semibold uppercase tracking-[0.18em] text-black/45">{title}</div>
      {children}
    </div>
  )
}

function ColorSwatch({ name, value, note }: { name: string; value: string; note?: string }) {
  return (
    <div className="rounded-[20px] border border-black/8 bg-white p-4">
      <div className="h-16 rounded-[14px] border border-black/8" style={{ background: value }} />
      <div className="mt-4 text-[14px] font-semibold text-black">{name}</div>
      <div className="mt-1 font-mono text-[12px] text-black/48">{value}</div>
      {note ? <div className="mt-2 text-[12px] leading-5 text-black/58">{note}</div> : null}
    </div>
  )
}

function TokenBar({ label, size }: { label: string; size: number }) {
  return (
    <div className="rounded-[20px] border border-black/8 bg-white p-4">
      <div className="flex items-center justify-between text-[13px] font-medium text-black/62">
        <span>{label}</span>
        <span>{size}px</span>
      </div>
      <div className="mt-4 flex items-center gap-4">
        <div className="h-3 rounded-full bg-black" style={{ width: size * 6 }} />
        <div className="h-8 w-px bg-black/10" />
      </div>
    </div>
  )
}

function RadiusCard({ label, size }: { label: string; size: number }) {
  return (
    <div className="rounded-[20px] border border-black/8 bg-white p-4">
      <div className="flex items-center justify-between text-[13px] font-medium text-black/62">
        <span>{label}</span>
        <span>{size}px</span>
      </div>
      <div className="mt-4 h-24 border border-black/10 bg-[#f2f2f7]" style={{ borderRadius: size }} />
    </div>
  )
}

function ComponentPanel({
  name,
  layer,
  children,
}: {
  name: string
  layer: string
  children: React.ReactNode
}) {
  return (
    <div className="rounded-[24px] border border-black/8 bg-white p-5 shadow-[0_18px_40px_rgba(15,23,42,0.06)]">
      <div className="mb-5 flex items-center justify-between gap-4">
        <div>
          <div className="text-[11px] font-semibold uppercase tracking-[0.2em] text-black/42">{layer}</div>
          <div className="mt-2 text-[18px] font-semibold tracking-[-0.03em] text-black">{name}</div>
        </div>
      </div>
      {children}
    </div>
  )
}

export default function FigmaExportPage() {
  return (
    <main className="min-h-screen bg-[linear-gradient(180deg,#f5f5f8_0%,#ececf2_100%)] text-black">
      <div className="mx-auto flex w-[1600px] max-w-full flex-col gap-8 px-8 py-8">
        <section className="relative overflow-hidden rounded-[40px] border border-black/8 bg-white px-10 py-10 shadow-[0_32px_90px_rgba(15,23,42,0.1)]">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(201,106,22,0.16),transparent_26%),radial-gradient(circle_at_top_right,rgba(0,0,0,0.06),transparent_22%)]" />
          <div className="relative flex items-end justify-between gap-8">
            <div className="max-w-3xl">
              <div className="text-[11px] font-semibold uppercase tracking-[0.28em] text-black/45">
                Unit iOS Design System
              </div>
              <h1 className="mt-4 text-[64px] font-black tracking-[-0.08em] text-black">
                Shared components pulled from the live codebase.
              </h1>
              <p className="mt-5 max-w-2xl text-[18px] leading-8 text-black/58">
                Figma-ready board based on the current SwiftUI system in
                {" "}
                <span className="font-semibold text-black">Atoms</span>,
                {" "}
                <span className="font-semibold text-black">Molecules</span>,
                {" "}
                <span className="font-semibold text-black">Organisms</span>, and
                {" "}
                <span className="font-semibold text-black">Templates</span>.
              </p>
            </div>

            <div className="grid grid-cols-2 gap-3">
              {[
                "AppColor",
                "AppFont",
                "AppSpacing",
                "AppRadius",
                "AppListRow",
                "AppStepper",
                "AppTag",
                "AppScreen",
              ].map((item) => (
                <div
                  key={item}
                  className="rounded-full border border-black/10 bg-black/[0.03] px-4 py-2 text-[13px] font-semibold text-black/72"
                >
                  {item}
                </div>
              ))}
            </div>
          </div>
        </section>

        <Section
          eyebrow="Modes"
          title="Light-first system with native dark parity"
          description="The codebase uses adaptive semantic tokens. These two frames show the actual role mapping rather than a separate visual brand system."
        >
          <div className="grid grid-cols-2 gap-6">
            <ToneFrame
              mode="Light"
              background="#F2F2F7"
              card="#FFFFFF"
              text="#000000"
              textSecondary="#8E8E93"
              accent="#000000"
              accentSoft="rgba(0,0,0,0.06)"
              border="#F2F2F7"
            />
            <ToneFrame
              mode="Dark"
              background="#000000"
              card="#1C1C1E"
              text="#FFFFFF"
              textSecondary="#8E8E93"
              accent="#FFFFFF"
              accentSoft="rgba(255,255,255,0.08)"
              border="#38383A"
            />
          </div>
        </Section>

        <Section
          eyebrow="Tokens"
          title="Foundations"
          description="Exact color roles and scale values mirrored from the SwiftUI source."
        >
          <div className="grid grid-cols-[1.4fr_1fr] gap-6">
            <SurfaceCard title="AppColor / Light">
              <div className="grid grid-cols-3 gap-4">
                {lightColors.map((color) => (
                  <ColorSwatch key={color.name} {...color} />
                ))}
              </div>
            </SurfaceCard>

            <div className="grid gap-6">
              <SurfaceCard title="AppColor / Dark">
                <div className="grid grid-cols-2 gap-4">
                  {darkColors.map((color) => (
                    <ColorSwatch key={color.name} {...color} />
                  ))}
                </div>
              </SurfaceCard>

              <SurfaceCard title="AppSpacing">
                <div className="grid gap-3">
                  {spacing.map((item) => (
                    <TokenBar key={item.name} label={item.name} size={item.value} />
                  ))}
                </div>
              </SurfaceCard>

              <SurfaceCard title="AppRadius">
                <div className="grid grid-cols-2 gap-3">
                  {radii.map((item) => (
                    <RadiusCard key={item.name} label={item.name} size={item.value} />
                  ))}
                </div>
              </SurfaceCard>
            </div>
          </div>
        </Section>

        <Section
          eyebrow="Typography"
          title="Compact hierarchy"
          description="The system is restrained and metric-friendly. Numeric styles intentionally use tabular spacing."
        >
          <div className="grid grid-cols-3 gap-4">
            {typography.map((item) => (
              <div key={item.name} className="rounded-[24px] border border-black/8 bg-white p-5">
                <div className="text-[11px] font-semibold uppercase tracking-[0.2em] text-black/42">{item.name}</div>
                <div
                  className="mt-5 break-all tracking-[-0.04em] text-black"
                  style={{
                    fontSize: `${item.size}px`,
                    fontWeight: Number(item.weight),
                    fontVariantNumeric: item.name.startsWith("numeric") ? "tabular-nums" : undefined,
                  }}
                >
                  {item.sample}
                </div>
                <div className="mt-4 text-[12px] text-black/55">
                  {item.size}px / {item.weight}
                </div>
              </div>
            ))}
          </div>
        </Section>

        <Section
          eyebrow="Components"
          title="Shared UI inventory"
          description="These are the reusable building blocks currently defined in the shared SwiftUI design system."
        >
          <div className="grid grid-cols-3 gap-5">
            <ComponentPanel name="AppPrimaryButton" layer="Molecule">
              <button className="w-full rounded-[12px] bg-black px-4 py-[15px] text-[16px] font-semibold text-white">
                Start Workout
              </button>
            </ComponentPanel>

            <ComponentPanel name="AppSecondaryButton" layer="Molecule">
              <button className="w-full rounded-[12px] border border-[#F2F2F7] bg-white px-4 py-[15px] text-[16px] font-semibold text-black">
                Skip for now
              </button>
            </ComponentPanel>

            <ComponentPanel name="AppTag" layer="Molecule">
              <div className="flex flex-wrap gap-2">
                <span className="rounded-full bg-black/6 px-3 py-1 text-[12px] font-semibold text-black">Default</span>
                <span className="rounded-full bg-black px-3 py-1 text-[12px] font-semibold text-white">Accent</span>
                <span className="rounded-full bg-[#34C759]/[0.12] px-3 py-1 text-[12px] font-semibold text-[#34C759]">Success</span>
                <span className="rounded-full bg-[#FF9500]/[0.12] px-3 py-1 text-[12px] font-semibold text-[#FF9500]">Warning</span>
                <span className="rounded-full bg-[#FF3B30]/[0.12] px-3 py-1 text-[12px] font-semibold text-[#FF3B30]">Error</span>
                <span className="rounded-full bg-[#F2F2F7] px-3 py-1 text-[12px] font-semibold text-[#8E8E93]">Muted</span>
              </div>
            </ComponentPanel>

            <ComponentPanel name="AppStepper" layer="Molecule">
              <div className="inline-flex items-center gap-2 rounded-[12px] bg-[#F2F2F7] px-2 py-1">
                <button className="flex h-11 min-h-[44px] min-w-[44px] items-center justify-center rounded-full bg-white text-[18px] font-semibold">
                  −
                </button>
                <div className="min-w-8 text-center text-[16px] font-semibold tabular-nums text-black">2.5</div>
                <button className="flex h-11 min-h-[44px] min-w-[44px] items-center justify-center rounded-full bg-white text-[18px] font-semibold">
                  +
                </button>
              </div>
            </ComponentPanel>

            <ComponentPanel name="AppListRow" layer="Molecule">
              <div className="overflow-hidden rounded-[16px] bg-[#FBFBFD]">
                <div className="flex items-center gap-3 px-4 py-2">
                  <div className="flex h-6 w-6 items-center justify-center rounded-full bg-black/5 text-[12px]">◌</div>
                  <div>
                    <div className="text-[16px] text-black">Weekly Increase</div>
                    <div className="text-[12px] text-black/48">Applied to all lifts</div>
                  </div>
                  <div className="ml-auto text-[14px] font-medium text-black/72">+2.5 kg</div>
                </div>
              </div>
            </ComponentPanel>

            <ComponentPanel name="AppDivider" layer="Atom">
              <div className="space-y-4">
                <div className="text-[14px] text-black/62">Tokenized hairline divider</div>
                <div className="h-px w-full bg-[#F2F2F7]" />
              </div>
            </ComponentPanel>

            <ComponentPanel name="AppCard / appCardStyle()" layer="Organism">
              <div className="rounded-[12px] bg-white p-4 shadow-[0_12px_30px_rgba(15,23,42,0.05)]">
                <div className="text-[17px] font-semibold text-black">Today’s Session</div>
                <div className="mt-1 text-[13px] text-black/48">Contrast-based separation, no heavy shadow language.</div>
              </div>
            </ComponentPanel>

            <ComponentPanel name="SettingsSection" layer="Organism">
              <div className="rounded-[12px] bg-white p-4">
                <div className="text-[17px] font-semibold text-black">Weights</div>
                <div className="mt-4 space-y-3">
                  <div className="flex items-center justify-between text-[15px] text-black">
                    <span>Bench Press</span>
                    <span className="text-black/55">100 kg</span>
                  </div>
                  <div className="h-px bg-[#F2F2F7]" />
                  <div className="flex items-center justify-between text-[15px] text-black">
                    <span>Squat</span>
                    <span className="text-black/55">140 kg</span>
                  </div>
                </div>
              </div>
            </ComponentPanel>

            <ComponentPanel name="AppTabHeader + AppHeaderIconButton" layer="Organism">
              <div className="flex min-h-[52px] items-center gap-4">
                <div className="flex-1 text-[32px] font-bold tracking-[-0.04em] text-black">Program</div>
                <button className="flex h-12 w-12 items-center justify-center rounded-full bg-white text-[18px] shadow-[0_8px_20px_rgba(15,23,42,0.05)]">
                  ⚙
                </button>
              </div>
            </ComponentPanel>

            <ComponentPanel name="AppNavBar" layer="Molecule">
              <div className="flex h-11 items-center justify-between rounded-[14px] bg-[#FBFBFD] px-2">
                <button className="flex h-11 w-11 items-center justify-center text-[16px] text-black">←</button>
                <div className="text-[17px] font-semibold text-black">History</div>
                <button className="flex h-11 w-11 items-center justify-center text-[16px] text-black">✕</button>
              </div>
            </ComponentPanel>

            <ComponentPanel name="AppNavBarWithTextTrailing" layer="Molecule">
              <div className="flex h-11 items-center justify-between rounded-[14px] bg-[#FBFBFD] px-2">
                <button className="flex h-11 w-11 items-center justify-center text-[16px] text-black">←</button>
                <div className="text-[17px] font-semibold text-black">Week</div>
                <button className="min-h-[44px] min-w-[44px] px-2 text-[16px] font-semibold text-black">Done</button>
              </div>
            </ComponentPanel>

            <ComponentPanel name="ScaleButtonStyle" layer="Molecule">
              <button className="rounded-[12px] bg-black px-5 py-3 text-[16px] font-semibold text-white transition-transform duration-150 hover:scale-[0.985] active:scale-[0.97]">
                Press Feedback
              </button>
            </ComponentPanel>
          </div>
        </Section>

        <Section
          eyebrow="Template"
          title="AppScreen shell"
          description="The standard page wrapper combines large-title header, optional collapsed nav state, scroll content, and sticky primary CTA."
        >
          <div className="rounded-[32px] bg-[#F2F2F7] p-6">
            <div className="mx-auto max-w-[430px] overflow-hidden rounded-[32px] border border-black/8 bg-[#F2F2F7] shadow-[0_28px_60px_rgba(15,23,42,0.14)]">
              <div className="px-4 pt-4">
                <div className="flex h-11 items-center justify-between">
                  <button className="flex h-11 w-11 items-center justify-center text-[16px] text-black">←</button>
                  <button className="min-h-[44px] min-w-[44px] px-2 text-[16px] font-semibold text-black">Done</button>
                </div>
                <div className="pb-4 pt-2 text-[22px] font-bold tracking-[-0.04em] text-black">Week Detail</div>
              </div>

              <div className="space-y-4 px-4 pb-28">
                <div className="rounded-[12px] bg-white p-4">
                  <div className="text-[17px] font-semibold text-black">Projected target</div>
                  <div className="mt-2 text-[13px] text-black/48">Based on the progression engine</div>
                </div>
                <div className="rounded-[12px] bg-white p-4">
                  <div className="text-[17px] font-semibold text-black">Exercise list</div>
                  <div className="mt-4 space-y-3">
                    <div className="flex items-center justify-between text-[15px] text-black">
                      <span>Bench Press</span>
                      <span className="text-black/55">100 × 5</span>
                    </div>
                    <div className="h-px bg-[#F2F2F7]" />
                    <div className="flex items-center justify-between text-[15px] text-black">
                      <span>Incline Press</span>
                      <span className="text-black/55">70 × 8</span>
                    </div>
                  </div>
                </div>
              </div>

              <div className="absolute" />
              <div className="relative">
                <div className="pointer-events-none h-6 bg-[linear-gradient(180deg,rgba(242,242,247,0),#F2F2F7)]" />
                <div className="bg-[#F2F2F7] px-4 pb-6">
                  <button className="w-full rounded-[12px] bg-black px-4 py-[15px] text-[16px] font-semibold text-white">
                    Save Changes
                  </button>
                </div>
              </div>
            </div>
          </div>
        </Section>
      </div>
    </main>
  )
}
