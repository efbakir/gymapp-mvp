import Header from "@/components/marketing/Header"
import Footer from "@/components/marketing/Footer"
import ConsoleSignature from "@/components/marketing/ConsoleSignature"
import PageTransition from "@/components/marketing/PageTransition"

export default function MarketingLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <>
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:fixed focus:top-unit-md focus:left-unit-md focus:z-[60] focus:px-unit-md focus:py-unit-xs focus:rounded-lg focus:bg-unit-accent focus:text-unit-accent-foreground focus:text-sm focus:font-bold"
      >
        Skip to content
      </a>
      <Header />
      <main id="main" className="min-h-screen">
        <PageTransition>{children}</PageTransition>
      </main>
      <Footer />
      <ConsoleSignature />
    </>
  )
}
