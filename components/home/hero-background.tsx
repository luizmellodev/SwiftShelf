"use client"

import { useEffect, useRef } from "react"

/**
 * Dot grid that lights up in Swift orange around the pointer (desktop) or
 * along a slow drifting path (touch / no pointer). Pure CSS painting; JS only
 * writes two custom properties, throttled to one write per frame.
 */
export function HeroBackground() {
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const el = ref.current
    if (!el) return
    const finePointer = window.matchMedia("(hover: hover) and (pointer: fine)")
    const reduced = window.matchMedia("(prefers-reduced-motion: reduce)")
    if (!finePointer.matches || reduced.matches) return

    let frame = 0
    const onMove = (e: PointerEvent) => {
      cancelAnimationFrame(frame)
      frame = requestAnimationFrame(() => {
        const rect = el.getBoundingClientRect()
        el.style.setProperty("--spot-x", `${e.clientX - rect.left}px`)
        el.style.setProperty("--spot-y", `${e.clientY - rect.top}px`)
        el.dataset.pointer = "true"
      })
    }
    window.addEventListener("pointermove", onMove, { passive: true })
    return () => {
      cancelAnimationFrame(frame)
      window.removeEventListener("pointermove", onMove)
    }
  }, [])

  return (
    <div ref={ref} aria-hidden="true" className="hero-bg pointer-events-none absolute inset-0 -z-10 overflow-hidden">
      <div className="hero-dots absolute inset-0" />
      <div className="hero-dots-lit absolute inset-0" />
      <div className="absolute inset-x-0 bottom-0 h-40 bg-gradient-to-b from-transparent to-background" />
    </div>
  )
}
