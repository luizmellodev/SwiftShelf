"use client"

import Link from "next/link"
import { useState } from "react"
import type { Snippet } from "@/lib/snippets-loader"
import { SnippetImage } from "./snippet-image"
import { AutoplayVideo } from "./autoplay-video"
import { useReducedMotion } from "@/lib/use-reduced-motion"

interface SnippetCardProps {
  snippet: Snippet
}

export function SnippetCard({ snippet }: SnippetCardProps) {
  const [hovering, setHovering] = useState(false)
  const [videoReady, setVideoReady] = useState(false)
  const reduced = useReducedMotion()

  return (
    <Link
      href={`/snippet/${snippet.id}`}
      className="group block rounded-2xl outline-offset-4"
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
    >
      <div className="relative aspect-[9/16] overflow-hidden rounded-2xl border border-white/[0.08] bg-card transition-[border-color,transform] duration-300 group-hover:-translate-y-0.5 group-hover:border-white/20">
        <SnippetImage
          src={snippet.screenshot || ""}
          alt={snippet.title}
          fill
          className="object-cover object-top"
        />
        {snippet.hasVideo && snippet.videoUrl && (
          <AutoplayVideo
            src={snippet.videoUrl}
            active={!reduced || hovering}
            onReady={() => setVideoReady(true)}
            className={`absolute inset-0 h-full w-full object-cover object-top transition-opacity duration-500 ${
              videoReady ? "opacity-100" : "opacity-0"
            }`}
          />
        )}
      </div>

      <div className="px-0.5 pt-3">
        <h3 className="text-[15px] font-semibold leading-snug tracking-tight transition-colors group-hover:text-swift">
          {snippet.title}
        </h3>
        <p className="mt-1 line-clamp-2 text-[13px] leading-snug text-muted-foreground">{snippet.description}</p>
        <p className="mt-2 truncate font-mono text-[11px] text-muted-foreground/70">
          {snippet.tags.slice(0, 3).map((t) => `#${t}`).join("  ")}
        </p>
      </div>
    </Link>
  )
}
