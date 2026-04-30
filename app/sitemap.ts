import type { MetadataRoute } from "next"
import { compareSlugList } from "./(marketing)/compare/data"
import { programSlugList } from "./(marketing)/programs/data"

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = "https://unitlift.app"
  const lastModified = new Date()

  const compareEntries: MetadataRoute.Sitemap = compareSlugList.map((slug) => ({
    url: `${baseUrl}/compare/${slug}`,
    lastModified,
    changeFrequency: "monthly",
    priority: 0.8,
  }))

  const programEntries: MetadataRoute.Sitemap = programSlugList.map((slug) => ({
    url: `${baseUrl}/programs/${slug}`,
    lastModified,
    changeFrequency: "monthly",
    priority: 0.6,
  }))

  return [
    { url: `${baseUrl}/`, lastModified, changeFrequency: "weekly", priority: 1 },
    { url: `${baseUrl}/changelog`, lastModified, changeFrequency: "weekly", priority: 0.7 },
    { url: `${baseUrl}/support`, lastModified, changeFrequency: "monthly", priority: 0.7 },
    { url: `${baseUrl}/privacy`, lastModified, changeFrequency: "yearly", priority: 0.3 },
    { url: `${baseUrl}/terms`, lastModified, changeFrequency: "yearly", priority: 0.3 },
    ...compareEntries,
    ...programEntries,
  ]
}
