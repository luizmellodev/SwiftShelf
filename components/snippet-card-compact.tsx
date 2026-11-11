"use client"

import Link from "next/link"
import { useState } from "react"
import { Play } from "lucide-react"
import type { Snippet } from "@/lib/snippets-loader"
import { SnippetImage } from "./snippet-image"
import { AutoplayVideo } from "./autoplay-video"
import { useReducedMotion } from "@/lib/use-reduced-motion"

interface SnippetCardCompactProps {
  snippet: Snippet
}

export function SnippetCardCompact({ snippet }: SnippetCardCompactProps) {
  const [hovering, setHovering] = useState(false)
  const [videoReady, setVideoReady] = useState(false)
  const reduced = useReducedMotion()

  return (
    <Link 
      href={`/snippet/${snippet.id}`}
      className="group relative block overflow-hidden rounded-lg border bg-card transition-all hover:border-primary/50 hover:shadow-lg"
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
    >
      <div className="relative aspect-[9/16] overflow-hidden bg-muted">
        <SnippetImage
          src={snippet.screenshot || ""}
          alt={snippet.title}
          fill
          className="object-cover transition-transform duration-300 group-hover:scale-105"
        />
        {snippet.hasVideo && snippet.videoUrl && (
          <>
            <AutoplayVideo
              src={snippet.videoUrl}
              active={!reduced || hovering}
              onReady={() => setVideoReady(true)}
              className={`absolute inset-0 h-full w-full object-cover transition-opacity duration-500 ${
                videoReady ? "opacity-100" : "opacity-0"
              }`}
            />
            {reduced && !hovering && (
              <div className="pointer-events-none absolute right-2 top-2 rounded-full bg-black/50 p-1.5 backdrop-blur-sm">
                <Play className="h-3 w-3 fill-white text-white" />
              </div>
            )}
          </>
        )}
      </div>

      <div className="p-2">
        <h3 className="text-xs font-semibold line-clamp-2 mb-1">{snippet.title}</h3>
        <p className="text-[10px] text-muted-foreground">by {snippet.author}</p>
      </div>
    </Link>
  )
}
