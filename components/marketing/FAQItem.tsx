import type { ReactNode } from "react"

// Native <details>/<summary> disclosure — server component, zero client JS.
// `group-open:` rotates the chevron when the disclosure is expanded.
// `list-none` + `::-webkit-details-marker` hide the default disclosure
// triangle in Firefox and older Safari respectively.
export default function FAQItem({
  question,
  answer,
}: {
  question: string
  answer: ReactNode
}) {
  return (
    <details className="group border-b border-unit-border py-unit-lg">
      <summary className="flex items-center justify-between gap-unit-md cursor-pointer list-none [&::-webkit-details-marker]:hidden">
        <span className="text-base font-semibold">{question}</span>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          aria-hidden="true"
          className="shrink-0 transition-transform duration-200 text-unit-text-secondary group-open:rotate-180"
        >
          <path
            d="M4 6L8 10L12 6"
            stroke="currentColor"
            strokeWidth="1.25"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </summary>
      <p className="mt-unit-sm text-base leading-relaxed text-unit-text-secondary">
        {answer}
      </p>
    </details>
  )
}
