export default function TrustBand({ inverse = false }: { inverse?: boolean }) {
  const labelColor = inverse ? "text-white/70" : ""

  return (
    <div className="flex flex-col items-start gap-unit-xs sm:flex-row sm:items-center sm:gap-unit-md">
      <span className="inline-flex items-center gap-unit-xs">
        <span className="block h-[6px] w-[6px] rounded-full bg-unit-success" aria-hidden="true" />
        <span className={`text-sm font-semibold ${labelColor || "text-unit-text-secondary"}`}>
          Built by a lifter
        </span>
      </span>
      <span className={`text-sm font-semibold ${labelColor || "text-unit-text-secondary"}`}>
        Available on the App Store
      </span>
    </div>
  )
}
