import type { Metadata, Viewport } from "next"
import { Geist, Geist_Mono } from "next/font/google"
import { Analytics } from "@vercel/analytics/next"
import { SpeedInsights } from "@vercel/speed-insights/next"
import { SITE_URL } from "@/lib/site"
import "./globals.css"

// Sans is the LCP font (hero h1, body copy). Preload, weights 500-700 only.
// DESIGN.md medium-floor rule means 400 is unused.
const geistSans = Geist({
  subsets: ["latin"],
  variable: "--font-sans",
  weight: ["500", "600", "700"],
  display: "swap",
  preload: true,
  fallback: ["-apple-system", "system-ui", "sans-serif"],
})

// Mono is below-the-fold initially (eyebrows, numerics in non-hero sections).
// Skip the preload to free a render-blocking request; falls back to the
// system mono via swap until loaded.
const geistMono = Geist_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
  weight: ["500", "700"],
  display: "swap",
  preload: false,
  fallback: ["ui-monospace", "SFMono-Regular", "monospace"],
})

export const metadata: Metadata = {
  title: { default: "Unit: Progressive Overload for iPhone", template: "%s | Unit" },
  description:
    "Know what to lift next. Unit logs each set in one tap, then prepares one clear progressive overload target for your next workout.",
  metadataBase: new URL(SITE_URL),
  alternates: { canonical: "/" },
  openGraph: {
    type: "website",
    locale: "en_US",
    siteName: "Unit",
    url: `${SITE_URL}/`,
    title: "Unit: Progressive Overload for iPhone",
    description:
      "Know what to lift next. Log each set in one tap, then get one clear target for your next workout.",
    images: [
      { url: "/opengraph-image", width: 1200, height: 630, alt: "Unit: Progressive Overload" },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Unit: Progressive Overload for iPhone",
    description: "Know what to lift next. Log in one tap, then get one clear target for your next workout.",
    images: ["/opengraph-image"],
  },
  robots: { index: true, follow: true },
  // Smart App Banner. iOS Safari shows a native install/open strip for the
  // live App Store listing (id 6775008893).
  itunes: { appId: "6775008893" },
}

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#F5F5F5",
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={`${geistSans.variable} ${geistMono.variable}`}>
      <body className="font-sans antialiased">
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  )
}
