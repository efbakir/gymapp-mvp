"use client"

import { useState } from "react"
import Image from "next/image"

export default function MarketingPhoto({
  src,
  alt,
  slotLabel,
  sizes,
  className = "",
  imageClassName = "",
  priority = false,
  enabled = false,
}: {
  src: string
  alt: string
  slotLabel: string
  sizes: string
  className?: string
  imageClassName?: string
  priority?: boolean
  enabled?: boolean
}) {
  const [failed, setFailed] = useState(false)
  const showFallback = !enabled || failed

  return (
    <div className={`relative overflow-hidden bg-unit-card ${className}`}>
      {showFallback && (
        <div className="absolute inset-0 flex items-center justify-center px-unit-lg text-center">
          <div>
            <p className="text-sm font-semibold text-unit-text-secondary">
              Image unavailable
            </p>
            <p className="mt-unit-xs font-mono text-xs text-unit-text-secondary">
              {slotLabel}
            </p>
          </div>
        </div>
      )}
      {enabled && !failed && (
        <Image
          src={src}
          alt={alt}
          fill
          priority={priority}
          sizes={sizes}
          onError={() => setFailed(true)}
          className={`object-cover ${imageClassName}`}
        />
      )}
    </div>
  )
}
