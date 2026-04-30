import { DEVELOPER_NAME } from "@/lib/contact"

// Editorial layout: photo left, prose right (stacked on mobile). Narrower
// max-width than the bento so reading rhythm shifts toward "letter from
// the founder," contrasting with the structured grid above.
export default function FounderStory() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-[260px_1fr] gap-unit-xl items-start">
      <div className="order-1">
        <div className="aspect-square w-full max-w-[260px] mx-auto md:mx-0 rounded-2xl bg-unit-muted overflow-hidden border border-unit-border">
          {/* Founder photo placeholder. Drop a 600×600 image at
              /public/founder.jpg and replace this block with <Image>. */}
          <div className="flex h-full w-full items-center justify-center">
            <span className="eyebrow">
              {DEVELOPER_NAME.split(" ")
                .map((part) => part[0])
                .join("")}
            </span>
          </div>
        </div>
      </div>

      <div className="order-2 max-w-[600px] space-y-unit-md">
        <p className="eyebrow">From the maker</p>
        <p className="text-lg leading-relaxed">
          I trained for years with a paper notebook before I tried any gym
          app. Every tracker I tested slowed me down — too many menus, too
          much typing, screens designed for a desk, not a deadlift platform.
        </p>
        <p className="text-lg leading-relaxed text-unit-text-secondary">
          So I built Unit. One tap per set. Ghost values pre-fill what you
          did last time. The rest timer follows you to the Lock Screen.
          Everything stays on your device. No social, no AI, no ceremony.
        </p>
        <p className="text-lg leading-relaxed text-unit-text-secondary">
          It&rsquo;s the app I wanted. If you already know your program and
          you&rsquo;re tired of fighting your tracker between sets, it might
          be the app you wanted too.
        </p>
        <p className="pt-unit-xs text-base font-semibold tracking-tight">
          — {DEVELOPER_NAME.split(" ")[0]}
        </p>
      </div>
    </div>
  )
}
