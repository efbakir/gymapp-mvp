"use client"

import { useId, useState, type ReactNode } from "react"

// Animated disclosure. Body uses the grid-template-rows 0fr → 1fr trick so
// height interpolates smoothly without measuring DOM, and pairs with an
// opacity fade so the text doesn't pop in at half height. Chevron rotation
// runs on the same easing for a unified "open" gesture.
export default function FAQItem({
  question,
  answer,
  isLast = false,
}: {
  question: string
  answer: ReactNode
  isLast?: boolean
}) {
  const [open, setOpen] = useState(false)
  const panelId = useId()

  return (
    <div className={isLast ? undefined : "border-b border-unit-border"}>
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
        aria-controls={panelId}
        className="w-full flex items-center justify-between gap-unit-md py-unit-lg text-left"
      >
        <span className="text-base font-semibold">{question}</span>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          aria-hidden="true"
          className={`shrink-0 transition-transform duration-300 text-unit-text-secondary ${
            open ? "rotate-180" : ""
          }`}
          style={{ transitionTimingFunction: "var(--ease-out-expo)" }}
        >
          <path
            d="M4 6L8 10L12 6"
            stroke="currentColor"
            strokeWidth="1.25"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </button>
      <div
        id={panelId}
        role="region"
        className="grid transition-[grid-template-rows,opacity] duration-300"
        style={{
          gridTemplateRows: open ? "1fr" : "0fr",
          opacity: open ? 1 : 0,
          transitionTimingFunction: "var(--ease-out-expo)",
        }}
      >
        <div className="overflow-hidden">
          <p className="pb-unit-lg text-base leading-relaxed text-unit-text-secondary">
            {answer}
          </p>
        </div>
      </div>
    </div>
  )
}
