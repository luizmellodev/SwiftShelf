"use client"

import { useState, useEffect, useRef } from "react"
import { Github, ChevronUp, ChevronDown } from "lucide-react"
import { SnippetImage } from "./snippet-image"
import type { Snippet } from "@/lib/snippets-data"

interface SnippetReelsProps {
  snippets: Snippet[]
}

export function SnippetReels({ snippets }: SnippetReelsProps) {
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isTransitioning, setIsTransitioning] = useState(false)
  const [touchStart, setTouchStart] = useState<number | null>(null)
  const [touchEnd, setTouchEnd] = useState<number | null>(null)
  const containerRef = useRef<HTMLDivElement>(null)

  const currentSnippet = snippets[currentIndex]

  const goToNext = () => {
    if (isTransitioning) return
    setIsTransitioning(true)
    setCurrentIndex((prev) => (prev + 1) % snippets.length)
    setTimeout(() => setIsTransitioning(false), 300)
  }

  const goToPrevious = () => {
    if (isTransitioning) return
    setIsTransitioning(true)
    setCurrentIndex((prev) => (prev - 1 + snippets.length) % snippets.length)
    setTimeout(() => setIsTransitioning(false), 300)
  }

  const handleTouchStart = (e: React.TouchEvent) => {
    setTouchEnd(null)
    setTouchStart(e.targetTouches[0].clientY)
  }

  const handleTouchMove = (e: React.TouchEvent) => {
    setTouchEnd(e.targetTouches[0].clientY)
  }

  const handleTouchEnd = () => {
    if (!touchStart || !touchEnd) return
    
    const distance = touchStart - touchEnd
    const isUpSwipe = distance > 50
    const isDownSwipe = distance < -50

    if (isUpSwipe) {
      goToNext()
    } else if (isDownSwipe) {
      goToPrevious()
    }
  }

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "ArrowDown") {
        e.preventDefault()
        goToNext()
      } else if (e.key === "ArrowUp") {
        e.preventDefault()
        goToPrevious()
      }
    }

    window.addEventListener("keydown", handleKeyDown)
    return () => window.removeEventListener("keydown", handleKeyDown)
  }, [isTransitioning])

  return (
    <div className="flex h-screen w-full items-center justify-center bg-black">
      <div className="hidden md:block">
        <div className="relative h-[900px] w-[400px] overflow-hidden rounded-[40px] border-[8px] border-gray-800 bg-black shadow-2xl">
          <div 
            ref={containerRef}
            className="relative h-full w-full overflow-hidden"
            onTouchStart={handleTouchStart}
            onTouchMove={handleTouchMove}
            onTouchEnd={handleTouchEnd}
          >
            <div className="relative h-full w-full">
              <div className="relative h-full w-full">
                <SnippetImage
                  src={currentSnippet.screenshot || ""}
                  alt={currentSnippet.title}
                  fill
                  className="object-cover"
                  priority
                />
                
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-black/40" />
              </div>

              <div className="absolute bottom-0 left-0 right-0 p-6 text-white">
                <div className="mb-4 flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white/20 backdrop-blur-sm">
                    <Github className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="font-semibold">{currentSnippet.author}</p>
                    <p className="text-sm text-white/70">@{currentSnippet.githubUsername}</p>
                  </div>
                </div>

                <div className="mb-4">
                  <h2 className="mb-2 text-2xl font-bold">{currentSnippet.title}</h2>
                  <p className="text-white/90 leading-relaxed">{currentSnippet.description}</p>
                </div>

                <div className="flex flex-wrap gap-2">
                  {currentSnippet.tags.map((tag) => (
                    <span
                      key={tag}
                      className="rounded-full bg-white/20 px-3 py-1 text-sm font-medium backdrop-blur-sm"
                    >
                      #{tag}
                    </span>
                  ))}
                </div>
              </div>

              <div 
                className="absolute inset-0 cursor-pointer"
                onClick={() => window.open(`/snippet/${currentSnippet.id}`, '_blank')}
              />

              <div className="absolute top-0 left-0 right-0 h-1 bg-white/20">
                <div 
                  className="h-full bg-white transition-all duration-300"
                  style={{ width: `${((currentIndex + 1) / snippets.length) * 100}%` }}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div className="absolute top-1/2 z-20 hidden flex -translate-y-1/2 flex-col gap-4 md:flex" style={{ left: 'calc(50% + 200px)' }}>
        <button
          onClick={goToPrevious}
          disabled={isTransitioning}
          className="rounded-full bg-white/20 p-3 backdrop-blur-sm transition-all hover:bg-white/30 disabled:opacity-50"
        >
          <ChevronUp className="h-6 w-6 text-white" />
        </button>
        
        <button
          onClick={goToNext}
          disabled={isTransitioning}
          className="rounded-full bg-white/20 p-3 backdrop-blur-sm transition-all hover:bg-white/30 disabled:opacity-50"
        >
          <ChevronDown className="h-6 w-6 text-white" />
        </button>
      </div>

      <div 
        ref={containerRef}
        className="relative h-screen w-full overflow-hidden bg-black md:hidden"
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        style={{ touchAction: 'pan-y' }}
      >
        <div className="relative h-full w-full">
          <div className="relative h-full w-full">
            <SnippetImage
              src={currentSnippet.screenshot || ""}
              alt={currentSnippet.title}
              fill
              className="object-cover"
              priority
            />
            
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-black/40" />
          </div>

          <div className="absolute bottom-0 left-0 right-0 p-6 text-white">
            <div className="mb-4 flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white/20 backdrop-blur-sm">
                <Github className="h-5 w-5" />
              </div>
              <div>
                <p className="font-semibold">{currentSnippet.author}</p>
                <p className="text-sm text-white/70">@{currentSnippet.githubUsername}</p>
              </div>
            </div>

            <div className="mb-4">
              <h2 className="mb-2 text-2xl font-bold">{currentSnippet.title}</h2>
              <p className="text-white/90 leading-relaxed">{currentSnippet.description}</p>
            </div>

            <div className="flex flex-wrap gap-2">
              {currentSnippet.tags.map((tag) => (
                <span
                  key={tag}
                  className="rounded-full bg-white/20 px-3 py-1 text-sm font-medium backdrop-blur-sm"
                >
                  #{tag}
                </span>
              ))}
            </div>
          </div>

          <div className="absolute top-0 left-0 right-0 h-1 bg-white/20">
            <div 
              className="h-full bg-white transition-all duration-300"
              style={{ width: `${((currentIndex + 1) / snippets.length) * 100}%` }}
            />
          </div>
          
          <div 
            className="absolute inset-0 cursor-pointer"
            onClick={() => window.open(`/snippet/${currentSnippet.id}`, '_blank')}
          />
        </div>

        <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 text-center text-white/60 pointer-events-none">
          <div className="mb-2 text-sm">Swipe up/down</div>
          <div className="text-xs">to navigate between snippets</div>
        </div>
      </div>
    </div>
  )
}
