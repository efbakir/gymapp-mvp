import Link from "next/link"

export default function Footer() {
  return (
    <footer className="border-t border-unit-border">
      <div className="max-w-3xl mx-auto px-unit-md md:px-unit-lg py-unit-xl">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-unit-md">
          <p className="text-sm text-unit-text-secondary">
            &copy; {new Date().getFullYear()} Unit
          </p>
          <div className="flex items-center gap-unit-lg">
            <Link
              href="/privacy"
              className="text-sm text-unit-text-secondary hover:text-unit-text-primary transition-colors"
            >
              Privacy
            </Link>
            <Link
              href="/terms"
              className="text-sm text-unit-text-secondary hover:text-unit-text-primary transition-colors"
            >
              Terms
            </Link>
            <Link
              href="/support"
              className="text-sm text-unit-text-secondary hover:text-unit-text-primary transition-colors"
            >
              Support
            </Link>
          </div>
        </div>
      </div>
    </footer>
  )
}
