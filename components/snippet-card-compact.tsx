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
      className="group relative block outline-offset-4"
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
    >
      <div className="relative aspect-[9/16] overflow-hidden rounded-xl border border-white/[0.08] bg-card transition-colors group-hover:border-white/20">
        <SnippetImage
          src={snippet.screenshot || ""}
          alt={snippet.title}
          fill
          className="object-cover object-top"
        />
        {snippet.hasVideo && snippet.videoUrl && (
          <>
            <AutoplayVideo
              src={snippet.videoUrl}
              active={!reduced || hovering}
              onReady={() => setVideoReady(true)}
              className={`absolute inset-0 h-full w-full object-cover object-top transition-opacity duration-500 ${
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

      <h3 className="mt-2 line-clamp-1 px-0.5 text-xs font-medium text-muted-foreground transition-colors group-hover:text-foreground">
        {snippet.title}
      </h3>
    </Link>
  )
}
