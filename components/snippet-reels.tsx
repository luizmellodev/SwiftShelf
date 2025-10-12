"use client"

import { useState, useEffect, useRef } from "react"
import { Github, ChevronUp, ChevronDown } from "lucide-react"
import { SnippetImage } from "./snippet-image"
import type { Snippet } from "@/lib/snippets-loader"

interface SnippetReelsProps {
  snippets: Snippet[]
}

export function SnippetReels({ snippets }: SnippetReelsProps) {
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isTransitioning, setIsTransitioning] = useState(false)
  const [touchStart, setTouchStart] = useState<number | null>(null)
  const [touchEnd, setTouchEnd] = useState<number | null>(null)
  const [slideDirection, setSlideDirection] = useState<'up' | 'down' | null>(null)
  const [isSafari, setIsSafari] = useState(false)
  const containerRef = useRef<HTMLDivElement>(null)
  const transitionSnippetsRef = useRef<{ prev: Snippet; current: Snippet; next: Snippet } | null>(null)

  const currentSnippet = snippets[currentIndex]
  const prevSnippet = snippets[(currentIndex - 1 + snippets.length) % snippets.length]
  const nextSnippet = snippets[(currentIndex + 1) % snippets.length]

  const displayPrevSnippet = isTransitioning && transitionSnippetsRef.current 
    ? transitionSnippetsRef.current.prev 
    : prevSnippet
  const displayCurrentSnippet = isTransitioning && transitionSnippetsRef.current 
    ? transitionSnippetsRef.current.current 
    : currentSnippet
  const displayNextSnippet = isTransitioning && transitionSnippetsRef.current 
    ? transitionSnippetsRef.current.next 
    : nextSnippet

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const ua = window.navigator.userAgent
      const iOS = /iPad|iPhone|iPod/.test(ua)
      const webkit = /WebKit/.test(ua)
      const iOSSafari = iOS && webkit && !/CriOS|FxiOS|OPiOS|mercury/.test(ua)
      setIsSafari(iOSSafari)
    }
  }, [])

  useEffect(() => {
    if (typeof window !== 'undefined' && window.innerWidth < 768 && isSafari) {
      document.body.style.overflow = 'hidden'
      document.body.style.position = 'fixed'
      document.body.style.width = '100%'
      document.body.style.height = '100%'
      document.documentElement.style.overflow = 'hidden'
      
      return () => {
        document.body.style.overflow = ''
        document.body.style.position = ''
        document.body.style.width = ''
        document.body.style.height = ''
        document.documentElement.style.overflow = ''
      }
    }
  }, [isSafari])

  const goToNext = () => {
    if (isTransitioning) return
    
    // Armazenar snippets antes de mudar o índice
    transitionSnippetsRef.current = {
      prev: prevSnippet,
      current: currentSnippet,
      next: nextSnippet
    }
    
    setIsTransitioning(true)
    setSlideDirection('up')
    setCurrentIndex((prev) => (prev + 1) % snippets.length)
    setTimeout(() => {
      setIsTransitioning(false)
      setSlideDirection(null)
      transitionSnippetsRef.current = null
    }, 400)
  }

  const goToPrevious = () => {
    if (isTransitioning) return
    
    // Armazenar snippets antes de mudar o índice
    transitionSnippetsRef.current = {
      prev: prevSnippet,
      current: currentSnippet,
      next: nextSnippet
    }
    
    setIsTransitioning(true)
    setSlideDirection('down')
    setCurrentIndex((prev) => (prev - 1 + snippets.length) % snippets.length)
    setTimeout(() => {
      setIsTransitioning(false)
      setSlideDirection(null)
      transitionSnippetsRef.current = null
    }, 400)
  }

  const handleTouchStart = (e: React.TouchEvent) => {
    setTouchEnd(null)
    setTouchStart(e.targetTouches[0].clientY)
  }

  const handleTouchMove = (e: React.TouchEvent) => {
    if (isSafari) {
      e.preventDefault() // Prevenir scroll do navegador apenas no Safari
    }
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
    <div className="flex h-screen w-full items-center justify-center bg-black overflow-hidden">
      <div className="hidden md:block">
        <div className="relative h-[873px] w-[388px] overflow-hidden rounded-[40px] border-[8px] border-gray-800 bg-black shadow-2xl">
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
                  src={displayCurrentSnippet.screenshot || ""}
                  alt={displayCurrentSnippet.title}
                  fill
                  className="object-cover"
                  priority
                />
                
                <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent" />
                <div className="absolute inset-x-0 top-0 h-20 bg-gradient-to-b from-black/60 via-transparent to-transparent" />
              </div>

              <div className="absolute bottom-0 left-0 right-0 p-6 text-white">
                <div className="mb-4 flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white/20 backdrop-blur-sm">
                    <Github className="h-5 w-5" />
                  </div>
                  <div>
                    <p className="font-semibold">{displayCurrentSnippet.author}</p>
                    <p className="text-sm text-white/70">@{displayCurrentSnippet.githubUsername}</p>
                  </div>
                </div>

                <div className="mb-4">
                  <h2 className="mb-2 text-2xl font-bold">{displayCurrentSnippet.title}</h2>
                  <p className="text-white/90 leading-relaxed">{displayCurrentSnippet.description}</p>
                </div>

                <div className="flex flex-wrap gap-2">
                  {displayCurrentSnippet.tags.map((tag) => (
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
                onClick={() => window.open(`/snippet/${displayCurrentSnippet.id}`, '_blank')}
              />

              <div className="absolute left-8 right-8 h-1 bg-white/20 rounded-full" style={{ top: '5px' }}>
                <div 
                  className="h-full bg-white transition-all duration-300 rounded-full"
                  style={{ width: `${((currentIndex + 1) / snippets.length) * 100}%` }}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div className="absolute top-1/2 z-20 hidden flex -translate-y-1/2 flex-col gap-4 md:flex" style={{ left: 'calc(50% + 194px)' }}>
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
        className={`w-full overflow-hidden bg-black md:hidden ${isSafari ? 'fixed inset-0' : 'relative'}`}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        style={{ 
          height: '100dvh',
          touchAction: isSafari ? 'none' : 'pan-y',
          WebkitOverflowScrolling: 'touch',
          ...(isSafari && { overscrollBehavior: 'none' })
        }}
      >
        <div className="relative h-full w-full">
          {slideDirection === 'down' && (
            <div className="absolute inset-0 w-full h-full animate-slide-in-from-top">
              <SnippetImage
                src={displayPrevSnippet.screenshot || ""}
                alt={displayPrevSnippet.title}
                fill
                className="object-cover"
                priority
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent" />
              <div className="absolute inset-x-0 top-0 h-24 bg-gradient-to-b from-black/60 via-transparent to-transparent" />
            </div>
          )}

          <div 
            className={`absolute inset-0 w-full h-full transition-transform duration-400 ease-out ${
              slideDirection === 'up' ? 'animate-slide-out-to-top' : 
              slideDirection === 'down' ? 'animate-slide-out-to-bottom' : ''
            }`}
          >
            <SnippetImage
              src={displayCurrentSnippet.screenshot || ""}
              alt={displayCurrentSnippet.title}
              fill
              className="object-cover"
              priority
            />
            
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent" />
            <div className="absolute inset-x-0 top-0 h-24 bg-gradient-to-b from-black/60 via-transparent to-transparent" />
          </div>

          {slideDirection === 'up' && (
            <div className="absolute inset-0 w-full h-full animate-slide-in-from-bottom">
              <SnippetImage
                src={displayNextSnippet.screenshot || ""}
                alt={displayNextSnippet.title}
                fill
                className="object-cover"
                priority
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent" />
              <div className="absolute inset-x-0 top-0 h-24 bg-gradient-to-b from-black/60 via-transparent to-transparent" />
            </div>
          )}

          <div className="absolute bottom-0 left-0 right-0 p-4 pb-safe text-white" style={{ paddingBottom: 'max(1rem, env(safe-area-inset-bottom))' }}>
            <div className="mb-3 flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white/20 backdrop-blur-sm">
                <Github className="h-5 w-5" />
              </div>
              <div>
                <p className="font-semibold text-sm">{displayCurrentSnippet.author}</p>
                <p className="text-xs text-white/70">@{displayCurrentSnippet.githubUsername}</p>
              </div>
            </div>

            <div className="mb-3">
              <h2 className="mb-1.5 text-xl font-bold">{displayCurrentSnippet.title}</h2>
              <p className="text-sm text-white/90 leading-relaxed line-clamp-3">{displayCurrentSnippet.description}</p>
            </div>

            <div className="flex flex-wrap gap-1.5">
              {displayCurrentSnippet.tags.slice(0, 4).map((tag) => (
                <span
                  key={tag}
                  className="rounded-full bg-white/20 px-2.5 py-1 text-xs font-medium backdrop-blur-sm"
                >
                  #{tag}
                </span>
              ))}
            </div>
          </div>

          <div className="absolute left-4 right-4 h-1 bg-white/20 rounded-full" style={{ top: 'calc(5px + env(safe-area-inset-top, 0px))' }}>
            <div 
              className="h-full bg-white transition-all duration-300 rounded-full"
              style={{ width: `${((currentIndex + 1) / snippets.length) * 100}%` }}
            />
          </div>
          
          <div 
            className="absolute inset-0 cursor-pointer"
            onClick={() => window.open(`/snippet/${displayCurrentSnippet.id}`, '_blank')}
          />
        </div>

        <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 text-center text-white/50 pointer-events-none animate-fade-in-out">
          <div className="mb-1.5 text-sm font-medium">Swipe up/down</div>
          <div className="text-xs">to navigate between snippets</div>
        </div>
      </div>
    </div>
  )
}
