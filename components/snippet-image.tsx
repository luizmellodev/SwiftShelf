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
  const [isLoading, setIsLoading] = useState(true)

  if (hasError || !src || src === "/placeholder.svg") {
    return (
      <ImagePlaceholder className={`w-full h-full ${className}`} size="lg" />
    )
  }

  return (
    <div className="relative">
      {isLoading && (
        <div className={`absolute inset-0 flex items-center justify-center bg-gray-800 z-10 ${className}`}>
          <ImagePlaceholder size="lg" />
        </div>
      )}
      
      <Image
        src={src}
        alt={alt}
        fill={fill}
        width={width}
        height={height}
        className={`${className} ${isLoading ? 'opacity-0' : 'opacity-100'} transition-opacity duration-300`}
        priority={priority}
        onLoad={() => setIsLoading(false)}
        onError={() => {
          setHasError(true)
          setIsLoading(false)
        }}
      />
    </div>
  )
}
