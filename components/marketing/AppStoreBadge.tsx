// Apple "Download on the App Store" badge. Pre-launch this component
// is not rendered; WaitlistForm takes its place. Before public launch,
// swap this inline SVG for the official asset from Apple's Marketing
// Resources portal — Apple Brand Guidelines forbid recreating the badge.
// This stub matches the official 1:3.06 aspect ratio and 44px min height.
export default function AppStoreBadge({
  href,
  className = "",
}: {
  href: string
  className?: string
}) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noreferrer"
      aria-label="Download Unit on the App Store"
      className={`press-spring inline-flex items-center gap-3 px-5 rounded-md bg-unit-accent text-unit-accent-foreground ${className}`}
      style={{ height: "var(--button-height-lg)" }}
    >
      <svg
        width="22"
        height="26"
        viewBox="0 0 22 26"
        fill="currentColor"
        aria-hidden="true"
        className="shrink-0"
      >
        <path d="M18.7 13.5c-0.04-3.83 3.13-5.69 3.27-5.78-1.78-2.61-4.55-2.97-5.54-3.01-2.36-0.24-4.6 1.4-5.79 1.4-1.21 0-3.05-1.36-5.02-1.32-2.58 0.04-4.96 1.5-6.29 3.81-2.69 4.66-0.69 11.55 1.93 15.34 1.28 1.86 2.79 3.93 4.78 3.86 1.92-0.08 2.65-1.24 4.97-1.24 2.31 0 2.97 1.24 5 1.2 2.07-0.04 3.37-1.88 4.62-3.74 1.46-2.13 2.05-4.21 2.08-4.32-0.04-0.02-3.97-1.52-4.01-6.04zM14.94 2.36c1.06-1.29 1.78-3.06 1.58-4.83-1.53 0.06-3.39 1.02-4.49 2.3-0.98 1.13-1.85 2.95-1.62 4.69 1.71 0.13 3.46-0.87 4.53-2.16z" transform="translate(0,2)" />
      </svg>
      <span className="flex flex-col items-start leading-tight">
        <span className="text-[10px] font-medium tracking-wide uppercase opacity-80">
          Download on the
        </span>
        <span className="text-[19px] font-semibold tracking-tight">
          App Store
        </span>
      </span>
    </a>
  )
}
