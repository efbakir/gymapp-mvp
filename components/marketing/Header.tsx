"use client"

import { useState, useEffect } from "react"
import Link from "next/link"

export default function Header() {
  const [scrolled, setScrolled] = useState(false)
  const [menuOpen, setMenuOpen] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 16)
    window.addEventListener("scroll", onScroll, { passive: true })
    return () => window.removeEventListener("scroll", onScroll)
  }, [])

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-colors duration-200 ${
        scrolled || menuOpen
          ? "bg-unit-background border-b border-unit-border"
          : "bg-transparent"
      }`}
    >
      <nav className="max-w-3xl mx-auto px-unit-md md:px-unit-lg flex items-center justify-between h-16">
        <Link href="/" className="text-lg font-bold tracking-tight">
          Unit
        </Link>

        {/* Desktop nav */}
        <div className="hidden md:flex items-center gap-unit-lg">
          <Link
            href="/support"
            className="text-sm text-unit-text-secondary transition-colors hover:text-unit-text-primary"
          >
            Support
          </Link>
          <a
            href="#download"
            className="text-sm font-bold font-mono px-4 py-2 rounded-lg transition-opacity hover:opacity-80 bg-unit-accent text-unit-accent-foreground"
          >
            Coming soon
          </a>
        </div>

        {/* Mobile hamburger */}
        <button
          onClick={() => setMenuOpen(!menuOpen)}
          className="md:hidden flex flex-col gap-[5px] p-2"
          aria-label="Toggle menu"
        >
          <span
            className={`block w-5 h-[1.5px] bg-unit-text-primary transition-transform duration-200 ${
              menuOpen ? "rotate-45 translate-y-[6.5px]" : ""
            }`}
          />
          <span
            className={`block w-5 h-[1.5px] bg-unit-text-primary transition-opacity duration-200 ${
              menuOpen ? "opacity-0" : ""
            }`}
          />
          <span
            className={`block w-5 h-[1.5px] bg-unit-text-primary transition-transform duration-200 ${
              menuOpen ? "-rotate-45 -translate-y-[6.5px]" : ""
            }`}
          />
        </button>
      </nav>

      {/* Mobile menu */}
      {menuOpen && (
        <div className="md:hidden border-t border-unit-border bg-unit-background">
          <div className="max-w-3xl mx-auto px-unit-md py-unit-lg flex flex-col gap-unit-md">
            <Link
              href="/support"
              onClick={() => setMenuOpen(false)}
              className="text-base py-1 text-unit-text-secondary"
            >
              Support
            </Link>
            <a
              href="#download"
              className="text-base font-bold font-mono px-4 py-3 rounded-lg text-center mt-2 bg-unit-accent text-unit-accent-foreground"
            >
              Coming soon
            </a>
          </div>
        </div>
      )}
    </header>
  )
}
