"use client"

import { useState, useEffect } from "react"
import Image from "next/image"
import { X, ZoomIn } from "lucide-react"

interface ImageModalProps {
  src: string
  alt: string
  isOpen: boolean
  onClose: () => void
}

export function ImageModal({ src, alt, isOpen, onClose }: ImageModalProps) {
  const [isZoomed, setIsZoomed] = useState(false)

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden"
    } else {
      document.body.style.overflow = "auto"
    }
    
    return () => {
      document.body.style.overflow = "auto"
    }
  }, [isOpen])

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        onClose()
      } else if (e.key === " " || e.key === "Enter") {
        e.preventDefault()
        setIsZoomed(!isZoomed)
      }
    }

    if (isOpen) {
      document.addEventListener("keydown", handleKeyDown)
    }

    return () => {
      document.removeEventListener("keydown", handleKeyDown)
    }
  }, [isOpen, onClose, isZoomed])

  if (!isOpen) return null

  return (
    <div 
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/90 backdrop-blur-sm"
      onClick={onClose}
    >
      <div className="relative max-h-[90vh] max-w-[90vw] md:max-h-[80vh] md:max-w-[80vw]">
        <Image
          src={src}
          alt={alt}
          width={1200}
          height={800}
          className={`max-h-[95vh] max-w-[95vw] md:max-h-[80vh] md:max-w-[80vw] object-contain transition-transform duration-300 cursor-zoom-in ${
            isZoomed ? "scale-150 cursor-zoom-out" : "scale-100"
          }`}
          onClick={(e) => {
            e.stopPropagation()
            setIsZoomed(!isZoomed)
          }}
        />
        
        <button
          onClick={onClose}
          className="absolute right-2 top-2 md:right-4 md:top-4 rounded-full bg-black/50 p-1.5 md:p-2 text-white transition-colors hover:bg-black/70"
        >
          <X className="h-4 w-4 md:h-6 md:w-6" />
        </button>
        
        <div className="absolute left-2 top-2 md:left-4 md:top-4 rounded-full bg-black/50 px-2 py-1 md:px-3 md:py-2 text-white">
          <div className="flex items-center gap-1 md:gap-2">
            <ZoomIn className="h-3 w-3 md:h-4 md:w-4" />
            <span className="text-xs md:text-sm">
              {isZoomed ? "Tap to zoom out" : "Tap to zoom in"}
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}
