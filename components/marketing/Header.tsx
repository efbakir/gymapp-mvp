"use client"

import { useState, useEffect, useRef } from "react"
import Link from "next/link"
import Image from "next/image"
import { compareSlugs, compareSlugList } from "@/app/(marketing)/compare/data"
import { programSlugs, programSlugList } from "@/app/(marketing)/programs/data"

type DropdownKey = "compare" | "programs" | null

const compareItems = compareSlugList.map((slug) => ({
  href: `/compare/${slug}`,
  label: `vs ${compareSlugs[slug].competitor}`,
}))

const programItems = programSlugList.map((slug) => ({
  href: `/programs/${slug}`,
  label: programSlugs[slug].title,
}))

export default function Header() {
  const [menuOpen, setMenuOpen] = useState(false)
  const [openDropdown, setOpenDropdown] = useState<DropdownKey>(null)
  const dropdownRef = useRef<HTMLDivElement | null>(null)

  useEffect(() => {
    if (!openDropdown) return
    const onClick = (e: MouseEvent) => {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(e.target as Node)
      ) {
        setOpenDropdown(null)
      }
    }
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpenDropdown(null)
    }
    window.addEventListener("mousedown", onClick)
    window.addEventListener("keydown", onKey)
    return () => {
      window.removeEventListener("mousedown", onClick)
      window.removeEventListener("keydown", onKey)
    }
  }, [openDropdown])

  const toggleDropdown = (key: DropdownKey) =>
    setOpenDropdown((prev) => (prev === key ? null : key))

  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-unit-background border-b border-unit-border">
      <nav className="max-w-6xl mx-auto px-unit-md md:px-unit-lg flex items-center justify-between h-16">
        <Link
          href="/"
          aria-label="Unit — home"
          className="flex items-center"
        >
          <Image
            src="/app-icon.png"
            alt="Unit"
            width={32}
            height={32}
            priority
            className="h-8 w-8 rounded-md"
          />
        </Link>

        {/* Desktop nav */}
        <div
          ref={dropdownRef}
          className="hidden md:flex items-center gap-unit-lg"
        >
          <DesktopDropdown
            label="Compare"
            isOpen={openDropdown === "compare"}
            onToggle={() => toggleDropdown("compare")}
            items={compareItems}
            onItemClick={() => setOpenDropdown(null)}
          />
          <DesktopDropdown
            label="Programs"
            isOpen={openDropdown === "programs"}
            onToggle={() => toggleDropdown("programs")}
            items={programItems}
            onItemClick={() => setOpenDropdown(null)}
          />
          <Link href="/support" className="eyebrow-link">
            Support
          </Link>
          <a
            href="#download"
            className="press-spring inline-flex items-center h-11 px-unit-md rounded-md eyebrow !text-unit-accent-foreground bg-unit-accent"
          >
            Join waitlist
          </a>
        </div>

        {/* Mobile hamburger */}
        <button
          onClick={() => setMenuOpen(!menuOpen)}
          className="md:hidden flex flex-col gap-[5px] p-3 -mr-3"
          aria-label="Toggle menu"
          aria-expanded={menuOpen}
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
          <div className="max-w-6xl mx-auto px-unit-md py-unit-lg flex flex-col gap-unit-lg">
            <MobileSection label="Compare" items={compareItems} onItemClick={() => setMenuOpen(false)} />
            <MobileSection label="Programs" items={programItems} onItemClick={() => setMenuOpen(false)} />
            <Link
              href="/support"
              onClick={() => setMenuOpen(false)}
              className="eyebrow-link py-2"
            >
              Support
            </Link>
            <a
              href="#download"
              onClick={() => setMenuOpen(false)}
              className="press-spring inline-flex items-center justify-center rounded-md eyebrow !text-unit-accent-foreground mt-unit-xs bg-unit-accent"
              style={{ height: "var(--button-height-lg)" }}
            >
              Join waitlist
            </a>
          </div>
        </div>
      )}
    </header>
  )
}

type NavItem = { href: string; label: string }

function DesktopDropdown({
  label,
  isOpen,
  onToggle,
  items,
  onItemClick,
}: {
  label: string
  isOpen: boolean
  onToggle: () => void
  items: NavItem[]
  onItemClick: () => void
}) {
  return (
    <div className="relative">
      <button
        type="button"
        onClick={onToggle}
        aria-expanded={isOpen}
        aria-haspopup="true"
        className="eyebrow-link inline-flex items-center gap-1.5 py-2"
      >
        {label}
        <Caret open={isOpen} />
      </button>
      {isOpen && (
        <div
          role="menu"
          className="absolute right-0 top-full mt-unit-xs min-w-[200px] rounded-md border border-unit-border bg-unit-background py-unit-xs shadow-sm"
        >
          {items.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              role="menuitem"
              onClick={onItemClick}
              className="block px-unit-md py-2 text-sm text-unit-text-secondary transition-colors hover:text-unit-text-primary hover:bg-unit-muted"
            >
              {item.label}
            </Link>
          ))}
        </div>
      )}
    </div>
  )
}

function MobileSection({
  label,
  items,
  onItemClick,
}: {
  label: string
  items: NavItem[]
  onItemClick: () => void
}) {
  return (
    <div className="flex flex-col gap-unit-sm">
      <p className="eyebrow">{label}</p>
      {items.map((item) => (
        <Link
          key={item.href}
          href={item.href}
          onClick={onItemClick}
          className="text-base text-unit-text-secondary py-1"
        >
          {item.label}
        </Link>
      ))}
    </div>
  )
}

function Caret({ open }: { open: boolean }) {
  return (
    <svg
      width="9"
      height="9"
      viewBox="0 0 10 10"
      fill="none"
      aria-hidden="true"
      className={`transition-transform duration-150 ${open ? "rotate-180" : ""}`}
    >
      <path
        d="M2 4l3 3 3-3"
        stroke="currentColor"
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}
