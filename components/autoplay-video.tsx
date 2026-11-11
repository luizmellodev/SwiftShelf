"use client"

import { useEffect, useRef, useState } from "react"

interface AutoplayVideoProps {
  src: string
  className?: string
  /**
   * When false the video stays paused (and is not even downloaded until it has
   * been active once). Lets callers gate playback on hover, reduced motion, etc.
   */
  active?: boolean
  /** How far outside the viewport the video starts loading / playing. */
  rootMargin?: string
  /** Shown only if the browser refuses to autoplay (e.g. iOS Low Power Mode). */
  fallbackPoster?: string
  onReady?: () => void
  /** Called when autoplay is refused; the fallback poster is shown instead. */
  onBlocked?: () => void
}

/**
 * Muted, looping, inline video that only downloads once it nears the viewport
 * and only plays while it is actually on screen.
 */
export function AutoplayVideo({
  src,
  className = "",
  active = true,
  rootMargin = "200px",
  fallbackPoster,
  onReady,
  onBlocked,
}: AutoplayVideoProps) {
  const ref = useRef<HTMLVideoElement>(null)
  const [inView, setInView] = useState(false)
  const [shouldLoad, setShouldLoad] = useState(false)
  const [blocked, setBlocked] = useState(false)

  useEffect(() => {
    const el = ref.current
    if (!el) return
    if (typeof IntersectionObserver === "undefined") {
      setInView(true)
      return
    }
    const io = new IntersectionObserver(
      ([entry]) => setInView(entry.isIntersecting),
      { rootMargin, threshold: 0 },
    )
    io.observe(el)
    return () => io.disconnect()
  }, [rootMargin])

  useEffect(() => {
    if (inView && active) setShouldLoad(true)
  }, [inView, active])

  useEffect(() => {
    const el = ref.current
    if (!el || !shouldLoad) return
    if (inView && active) {
      el.play().catch((err: unknown) => {
        // AbortError just means a pause() interrupted play(); not a real refusal.
        if (err instanceof DOMException && err.name === "AbortError") return
        setBlocked(true)
        onBlocked?.()
      })
    } else {
      el.pause()
    }
  }, [inView, active, shouldLoad])

  return (
    <video
      ref={ref}
      src={shouldLoad ? src : undefined}
      muted
      loop
      playsInline
      preload="none"
      disablePictureInPicture
      disableRemotePlayback
      poster={blocked ? fallbackPoster : undefined}
      aria-hidden="true"
      tabIndex={-1}
      className={className}
      onPlaying={onReady}
    />
  )
}
