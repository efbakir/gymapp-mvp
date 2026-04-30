import Image from "next/image"

// Minimal iPhone-style frame: thin dark bezel, rounded corners, soft elevation.
// When `src` is provided, renders that screenshot inside the bezel. When
// omitted, renders a neutral Pumice-toned placeholder at the same aspect —
// so layout is locked while real Figma assets are dropped in later.
export default function DeviceFrame({
  src,
  alt,
  width,
  height,
  priority = false,
  sizes,
  className = "",
}: {
  src?: string
  alt: string
  width: number
  height: number
  priority?: boolean
  sizes?: string
  className?: string
}) {
  return (
    <div className={`relative ${className}`}>
      <div className="rounded-[2.75rem] bg-[#1d1d1f] p-[8px] shadow-[0_30px_80px_-30px_rgba(10,10,10,0.35),0_8px_24px_-12px_rgba(10,10,10,0.18)]">
        <div className="relative overflow-hidden rounded-[2.25rem] bg-unit-muted">
          {src ? (
            <Image
              src={src}
              alt={alt}
              width={width}
              height={height}
              priority={priority}
              sizes={sizes}
              className="block h-auto w-full"
            />
          ) : (
            <div
              aria-hidden="true"
              className="block w-full bg-unit-muted"
              style={{ aspectRatio: `${width} / ${height}` }}
            />
          )}
        </div>
      </div>
    </div>
  )
}
