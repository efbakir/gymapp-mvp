/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  poweredByHeader: false,
  // Serve AVIF/WebP automatically when the browser advertises support.
  // Falls through to the original format otherwise.
  images: {
    formats: ['image/avif', 'image/webp'],
  },
  async headers() {
    // Public assets in /public are not hashed by Next, so cap immutability
    // at one day with a week of stale-while-revalidate. Visitors get fresh
    // assets within 24h of an asset replacement; the CDN keeps serving the
    // old copy in the background until the next revalidation window.
    const publicAsset = [
      { key: 'Cache-Control', value: 'public, max-age=86400, stale-while-revalidate=604800' },
    ]
    return [
      { source: '/screens/:path*', headers: publicAsset },
      { source: '/badges/:path*', headers: publicAsset },
      { source: '/fonts/:path*', headers: publicAsset },
    ]
  },
}

module.exports = nextConfig
