import { COUNTER_VISIBILITY_THRESHOLD } from "@/lib/launchState"

export default function TrustBand({ count }: { count?: number }) {
  const showCounter =
    typeof count === "number" && count >= COUNTER_VISIBILITY_THRESHOLD

  return (
    <div className="flex flex-wrap items-center justify-center gap-x-unit-sm gap-y-unit-xxs">
      <span className="inline-flex items-center gap-unit-xxs">
        <span className="block h-[6px] w-[6px] rounded-full bg-unit-success" aria-hidden="true" />
        <span className="eyebrow">Built by one lifter</span>
      </span>
      <span className="text-unit-text-secondary opacity-50" aria-hidden="true">·</span>
      {showCounter ? (
        <span className="eyebrow">
          {count!.toLocaleString()} on the waitlist
        </span>
      ) : (
        <span className="eyebrow">Coming soon to iOS</span>
      )}
    </div>
  )
}
