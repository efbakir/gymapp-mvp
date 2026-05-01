import type { Config } from "tailwindcss"

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        unit: {
          background: "var(--unit-background)",
          card: "var(--unit-card)",
          surface: "var(--unit-surface)",
          "text-primary": "var(--unit-text-primary)",
          "text-secondary": "var(--unit-text-secondary)",
          border: "var(--unit-border)",
          muted: "var(--unit-muted)",
          disabled: "var(--unit-disabled)",
          accent: "var(--unit-accent)",
          "accent-foreground": "var(--unit-accent-foreground)",
          success: "var(--unit-success)",
          error: "var(--unit-error)",
        },
      },
      borderRadius: {
        // Mirrors iOS AppRadius (DESIGN.md): sm 10, md 14, lg 22.
        // --radius is 14px = AppRadius.md (button); xl extends to 22px = AppRadius.lg (cards).
        // All radii rendered with iOS-native squircle smoothing (≈60% Figma) via
        // the `corner-shape: squircle` progressive enhancement in app/globals.css.
        sm: "calc(var(--radius) - 4px)",
        md: "var(--radius)",
        lg: "var(--radius)",
        xl: "calc(var(--radius) + 8px)",
      },
      fontFamily: {
        sans: ["var(--font-sans)", "-apple-system", "system-ui", "sans-serif"],
        mono: ["var(--font-mono)", "ui-monospace", "SFMono-Regular", "monospace"],
      },
      spacing: {
        "unit-xxs": "4px",
        "unit-xs": "8px",
        "unit-sm": "12px",
        "unit-md": "16px",
        "unit-lg": "24px",
        "unit-xl": "32px",
        "unit-xxl": "48px",
        "unit-xxxl": "64px",
        "unit-xxxxl": "96px",
      },
    },
  },
  plugins: [],
}
export default config
