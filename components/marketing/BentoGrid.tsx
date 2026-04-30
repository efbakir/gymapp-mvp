import type { ReactNode } from "react"

// Asymmetric 3-col × 3-row bento on md+, single column stacked on mobile.
// Gap matches the section's interior rhythm (unit-md = 16px).
export default function BentoGrid({ children }: { children: ReactNode }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 md:auto-rows-[minmax(220px,auto)] gap-unit-md">
      {children}
    </div>
  )
}
