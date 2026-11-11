"use client"

import Link from "next/link"
import { useEffect, useRef, useState } from "react"
import { ArrowUpRight, ChevronLeft, ChevronRight } from "lucide-react"
import { DeviceFrame } from "@/components/device-frame"
import { useReducedMotion } from "@/lib/use-reduced-motion"
import type { MarqueeItem } from "./demo-marquee"

/**
 * One iPhone playing a curated set of demos back to back, story style.
 * Only the current and the next clip are ever downloaded.
 */
export function HeroShowcase({ items }: { items: MarqueeItem[] }) {
  const [index, setIndex] = useState(0)
  const [progress, setProgress] = useState(0)
  const [visible, setVisible] = useState(true)
  const [blocked, setBlocked] = useState(false)
  const reduced = useReducedMotion()
  const rootRef = useRef<HTMLDivElement>(null)
  const videoRefs = useRef<(HTMLVideoElement | null)[]>([])

  const count = items.length
  const next = (index + 1) % count
  const go = (i: number) => {
    setProgress(0)
    setIndex(((i % count) + count) % count)
  }

  useEffect(() => {
    const el = rootRef.current
    if (!el || typeof IntersectionObserver === "undefined") return
    const io = new IntersectionObserver(([e]) => setVisible(e.isIntersecting), { threshold: 0.2 })
    io.observe(el)
    return () => io.disconnect()
  }, [])

  useEffect(() => {
    videoRefs.current.forEach((v, i) => {
      if (!v) return
      if (i === index && visible && !reduced) {
        v.currentTime = 0
        v.play().catch((err: unknown) => {
          if (err instanceof DOMException && err.name === "AbortError") return
          setBlocked(true)
        })
      } else {
        v.pause()
      }
    })
  }, [index, visible, reduced])

  if (count === 0) return null
  const current = items[index]

  return (
    <div ref={rootRef} className="relative mx-auto flex w-full max-w-[300px] flex-col items-center">
      <div aria-hidden="true" className="hero-phone-glow absolute -bottom-10 left-1/2 h-40 w-[140%] -translate-x-1/2" />

      <DeviceFrame className="relative w-[230px] sm:w-[270px]">
        {items.map((item, i) => {
          const shouldLoad = i === index || i === next
          return reduced ? (
            i === index && (
              // eslint-disable-next-line @next/next/no-img-element
              <img key={item.id} src={item.screenshot} alt="" className="absolute inset-0 h-full w-full object-cover" />
            )
          ) : (
            <video
              key={item.id}
              ref={(el) => {
                videoRefs.current[i] = el
              }}
              src={shouldLoad ? item.videoUrl : undefined}
              muted
              playsInline
              preload={shouldLoad ? "auto" : "none"}
              poster={blocked ? item.screenshot : undefined}
              aria-hidden="true"
              onTimeUpdate={(e) => {
                if (i !== index) return
                const v = e.currentTarget
                if (v.duration) setProgress(v.currentTime / v.duration)
              }}
              onEnded={() => i === index && go(index + 1)}
              className={`absolute inset-0 h-full w-full object-cover transition-opacity duration-500 ${
                i === index ? "opacity-100" : "opacity-0"
              }`}
            />
          )
        })}
      </DeviceFrame>

      <div className="relative mt-6 w-full">
        <div className="flex gap-1" role="tablist" aria-label="Featured components">
          {items.map((item, i) => (
            <button
              key={item.id}
              role="tab"
              aria-selected={i === index}
              aria-label={item.title}
              onClick={() => go(i)}
              className="story-bar h-[3px] flex-1 overflow-hidden rounded-full bg-white/15 text-white/90"
              style={{ ["--p" as string]: i < index ? 1 : i === index ? (reduced ? 1 : progress) : 0 }}
            >
              <span />
            </button>
          ))}
        </div>

        <div className="mt-3 flex items-center justify-between gap-3">
          <button
            onClick={() => go(index - 1)}
            aria-label="Previous component"
            className="inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-muted-foreground transition-colors hover:bg-white/5 hover:text-foreground"
          >
            <ChevronLeft className="h-4 w-4" />
          </button>
          <Link
            href={`/snippet/${current.id}`}
            className="group inline-flex min-w-0 items-center gap-1 text-sm font-medium"
            aria-live="polite"
          >
            <span className="truncate">{current.title}</span>
            <ArrowUpRight className="h-3.5 w-3.5 shrink-0 text-muted-foreground transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5 group-hover:text-swift" />
          </Link>
          <button
            onClick={() => go(index + 1)}
            aria-label="Next component"
            className="inline-flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-muted-foreground transition-colors hover:bg-white/5 hover:text-foreground"
          >
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  )
}
