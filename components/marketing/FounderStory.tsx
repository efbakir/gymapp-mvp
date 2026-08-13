import Image from "next/image"
import { DEVELOPER_NAME } from "@/lib/contact"

// Editorial layout: photo left, prose right (stacked on mobile). Narrower
// max-width than the bento so reading rhythm shifts toward "letter from
// the founder," contrasting with the structured grid above.
export default function FounderStory() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-[260px_1fr] gap-unit-xl items-start">
      <div className="order-1">
        <div className="aspect-square w-full max-w-[260px] mx-auto md:mx-0 rounded-2xl bg-unit-muted overflow-hidden">
          <Image
            src="/founder.jpg"
            alt={`${DEVELOPER_NAME}, maker of Unit, at his desk`}
            width={600}
            height={600}
            unoptimized
            className="h-full w-full object-cover"
          />
        </div>
      </div>

      <div className="order-2 max-w-[600px] space-y-unit-md">
        <p className="text-sm font-semibold text-unit-text-secondary">From the maker</p>
        <p className="text-base leading-relaxed">
          I trained with a paper notebook for years. It showed what I did last
          time, but it still left me deciding what to do next.
        </p>
        <p className="text-base leading-relaxed text-unit-text-secondary">
          I built Unit to keep notebook speed and add one thing paper cannot: a
          clear next target. Unit shows the reason and waits for you to accept it.
        </p>
        <p className="pt-unit-xs text-base font-semibold tracking-tight">
          {DEVELOPER_NAME.split(" ")[0]}
        </p>
      </div>
    </div>
  )
}
