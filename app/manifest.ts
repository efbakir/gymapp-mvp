import type { MetadataRoute } from "next"

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Unit: Gym Logger & Workout Tracker",
    short_name: "Unit",
    description:
      "Simple progressive overload tracker. Log in one tap and know what to do next.",
    start_url: "/",
    display: "standalone",
    background_color: "#F5F5F5",
    theme_color: "#F5F5F5",
    icons: [{ src: "/icon.svg", sizes: "any", type: "image/svg+xml" }],
  }
}
