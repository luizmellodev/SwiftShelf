"use client"

import Link from "next/link"
import { useState } from "react"
import { AutoplayVideo } from "@/components/autoplay-video"
import { useReducedMotion } from "@/lib/use-reduced-motion"

export interface MarqueeItem {
  id: string
  title: string
  videoUrl: string
  screenshot: string
}

function DemoTile({ item, hidden }: { item: MarqueeItem; hidden?: boolean }) {
  const [ready, setReady] = useState(false)
  const reduced = useReducedMotion()
  return (
    <Link
      href={`/snippet/${item.id}`}
      aria-hidden={hidden || undefined}
      tabIndex={hidden ? -1 : undefined}
      className="demo-tile group relative block w-28 shrink-0 sm:w-36 md:w-44"
    >
      <div className="relative aspect-[400/870] overflow-hidden rounded-[14%/6.5%] border border-white/10 bg-card shadow-[0_10px_40px_-12px_rgba(0,0,0,0.8)] ring-1 ring-black/40 transition-[transform,border-color] duration-300 group-hover:-translate-y-1 group-hover:border-white/30">
        <div
          className={`absolute inset-0 bg-gradient-to-b from-white/[0.06] to-transparent transition-opacity duration-500 ${
            ready ? "opacity-0" : "animate-pulse"
          }`}
        />
        {reduced ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            src={item.screenshot}
            alt=""
            loading="lazy"
            decoding="async"
            onLoad={() => setReady(true)}
            className="absolute inset-0 h-full w-full object-cover"
          />
        ) : (
        <AutoplayVideo
          src={item.videoUrl}
          fallbackPoster={item.screenshot}
          rootMargin="300px"
          onReady={() => setReady(true)}
          onBlocked={() => setReady(true)}
          className={`absolute inset-0 h-full w-full object-cover transition-opacity duration-500 ${
            ready ? "opacity-100" : "opacity-0"
          }`}
        />
        )}
        <div className="absolute inset-x-0 bottom-0 translate-y-1 bg-gradient-to-t from-black/85 via-black/40 to-transparent p-2 pt-8 opacity-0 transition-all duration-300 group-hover:translate-y-0 group-hover:opacity-100 group-focus-visible:translate-y-0 group-focus-visible:opacity-100">
          <p className="line-clamp-2 text-[11px] font-medium leading-tight text-white sm:text-xs">{item.title}</p>
        </div>
      </div>
    </Link>
  )
}

function MarqueeRow({ items, reverse, duration }: { items: MarqueeItem[]; reverse?: boolean; duration: number }) {
  return (
    <div className="marquee-row group/row flex overflow-hidden [--gap:0.75rem] sm:[--gap:1rem]">
      {[0, 1].map((copy) => (
        <div
          key={copy}
          className={`marquee-track flex shrink-0 gap-[var(--gap)] pr-[var(--gap)] ${reverse ? "marquee-reverse" : ""}`}
          style={{ animationDuration: `${duration}s` }}
        >
          {items.map((item) => (
            <DemoTile key={`${copy}-${item.id}`} item={item} hidden={copy === 1} />
          ))}
        </div>
      ))}
    </div>
  )
}

export function DemoMarquee({ items }: { items: MarqueeItem[] }) {
  const half = Math.ceil(items.length / 2)
  const rows = [items.slice(0, half), items.slice(half)]

  return (
    <div className="marquee relative flex flex-col gap-3 py-2 sm:gap-4">
      <MarqueeRow items={rows[0]} duration={rows[0].length * 3.2} />
      <MarqueeRow items={rows[1]} duration={rows[1].length * 3.2} reverse />
    </div>
  )
}
