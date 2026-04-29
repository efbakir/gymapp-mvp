"use client"

import { useState, type ReactNode } from "react"

export default function FAQItem({
  question,
  answer,
}: {
  question: string
  answer: ReactNode
}) {
  const [open, setOpen] = useState(false)

  return (
    <div className="border-b border-unit-border py-unit-lg">
      <button
        onClick={() => setOpen(!open)}
        className="w-full flex items-center justify-between text-left gap-unit-md"
        aria-expanded={open}
      >
        <span className="text-base font-semibold">{question}</span>
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          aria-hidden="true"
          className={`shrink-0 transition-transform duration-200 text-unit-text-secondary ${
            open ? "rotate-180" : ""
          }`}
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
        className={`grid transition-[grid-template-rows] duration-200 ease-out ${
          open ? "grid-rows-[1fr] mt-unit-sm" : "grid-rows-[0fr]"
        }`}
      >
        <div className="overflow-hidden">
          <p className="text-[15px] leading-relaxed text-unit-text-secondary">
            {answer}
          </p>
        </div>
      </div>
    </div>
  )
}
