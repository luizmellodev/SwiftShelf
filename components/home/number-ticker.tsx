"use client"

import { useEffect, useRef, useState } from "react"

interface NumberTickerProps {
  value: number
  duration?: number
  delay?: number
}

const format = (n: number) => n.toLocaleString("en-US")

/** Counts up from 0 the first time it scrolls into view. */
export function NumberTicker({ value, duration = 1600, delay = 0 }: NumberTickerProps) {
  const ref = useRef<HTMLSpanElement>(null)
  const [display, setDisplay] = useState(0)

  useEffect(() => {
    const el = ref.current
    if (!el) return
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches || typeof IntersectionObserver === "undefined") {
      setDisplay(value)
      return
    }

    let frame = 0
    let timeout: ReturnType<typeof setTimeout>
    const run = () => {
      const start = performance.now()
      const tick = (now: number) => {
        const t = Math.min(1, (now - start) / duration)
        const eased = t === 1 ? 1 : 1 - Math.pow(2, -10 * t)
        setDisplay(Math.round(value * eased))
        if (t < 1) frame = requestAnimationFrame(tick)
      }
      frame = requestAnimationFrame(tick)
    }

    const io = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return
        io.disconnect()
        timeout = setTimeout(run, delay)
      },
      { threshold: 0.4 },
    )
    io.observe(el)
    return () => {
      io.disconnect()
      clearTimeout(timeout)
      cancelAnimationFrame(frame)
    }
  }, [value, duration, delay])

  return (
    <>
      <span className="sr-only">{format(value)}</span>
      <span ref={ref} aria-hidden="true" className="tabular-nums">
        {format(display)}
      </span>
    </>
  )
}
