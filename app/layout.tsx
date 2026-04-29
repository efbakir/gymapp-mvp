import type { Metadata, Viewport } from "next"
import { Geist, Geist_Mono } from "next/font/google"
import "./globals.css"

const geistSans = Geist({
  subsets: ["latin"],
  variable: "--font-sans",
  weight: ["400", "500", "600", "700"],
  display: "swap",
})

const geistMono = Geist_Mono({
  subsets: ["latin"],
  variable: "--font-mono",
  weight: ["500", "700"],
  display: "swap",
})

export const metadata: Metadata = {
  title: { default: "Unit — Your Gym Notebook, Upgraded", template: "%s | Unit" },
  description:
    "Log sets in one tap. Ghost values pre-fill your last session. No AI, no social, no typing. Built for lifters who already know their program.",
  metadataBase: new URL("https://unitgym.app"),
  openGraph: {
    type: "website",
    locale: "en_US",
    siteName: "Unit",
  },
  twitter: {
    card: "summary_large_image",
  },
  robots: { index: true, follow: true },
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
      <body className="font-sans antialiased">{children}</body>
    </html>
  )
}
