import type { ReactNode } from "react"

export default function KW({ children }: { children: ReactNode }) {
  return (
    <>
      <span aria-hidden="true" className="kw-mark">_</span>
      {children}
      <span aria-hidden="true" className="kw-mark">_</span>
    </>
  )
}
