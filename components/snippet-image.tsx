import Image from "next/image"
import { useState } from "react"
import { ImagePlaceholder } from "./image-placeholder"

interface SnippetImageProps {
  src: string
  alt: string
  fill?: boolean
  width?: number
  height?: number
  className?: string
  priority?: boolean
}

export function SnippetImage({ 
  src, 
  alt, 
  fill = false, 
  width, 
  height, 
  className = "", 
  priority = false 
}: SnippetImageProps) {
  const [hasError, setHasError] = useState(false)

  if (hasError || !src || src === "" || src === "/placeholder.svg") {
    return (
      <ImagePlaceholder className={`w-full h-full ${className}`} size="lg" />
    )
  }

  if (fill) {
    return (
      <div className="relative">
        <img
          src={src}
          alt={alt}
          className={`w-full h-full object-cover ${className}`}
          onError={() => {
            setHasError(true)
          }}
        />
      </div>
    )
  }

  return (
    <div className="relative">
      <Image
        src={src}
        alt={alt}
        fill={fill}
        width={width}
        height={height}
        className={`object-cover ${className}`}
        priority={priority}
        onError={() => {
          setHasError(true)
        }}
      />
    </div>
  )
}
