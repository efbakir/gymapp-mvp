"use client"

import { usePathname } from "next/navigation"
import { type ReactNode } from "react"

// Re-keying on pathname forces React to remount this subtree on every
// navigation, which restarts the .page-fade-in CSS animation. No JS
// orchestration, no layout shift, just a calm settle as the new route
// takes over.
export default function PageTransition({ children }: { children: ReactNode }) {
  const pathname = usePathname()
  return (
    <div key={pathname} className="page-fade-in">
      {children}
    </div>
  )
}
