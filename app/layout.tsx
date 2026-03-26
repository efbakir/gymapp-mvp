import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  weight: ["400", "500", "600", "700"],
  display: "swap",
})

export const metadata: Metadata = {
  title: { default: "Unit — Adaptive Gym Logger", template: "%s | Unit" },
  description:
    "The only gym logger that auto-adjusts your 8-week plan when you fail. One-time purchase. No subscription.",
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

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="font-sans antialiased">
        {children}
        <script
          src="https://mcp.figma.com/mcp/html-to-design/capture.js"
          async
        />
      </body>
    </html>
  )
}
