"use client"

import Link from "next/link"
import { useState } from "react"
import { Play } from "lucide-react"
import type { Snippet } from "@/lib/snippets-loader"
import { SnippetImage } from "./snippet-image"

interface SnippetCardCompactProps {
  snippet: Snippet
}

export function SnippetCardCompact({ snippet }: SnippetCardCompactProps) {
  const [showVideo, setShowVideo] = useState(false)

  return (
    <Link 
      href={`/snippet/${snippet.id}`}
      className="group relative block overflow-hidden rounded-lg border bg-card transition-all hover:border-primary/50 hover:shadow-lg"
      onMouseEnter={() => snippet.hasVideo && setShowVideo(true)}
      onMouseLeave={() => setShowVideo(false)}
    >
      <div className="relative aspect-[9/16] overflow-hidden bg-muted">
        {snippet.hasVideo && showVideo ? (
          <video
            key={snippet.videoUrl}
            src={snippet.videoUrl}
            autoPlay
            loop
            muted
            playsInline
            preload="auto"
            className="h-full w-full object-cover"
            onLoadStart={(e) => {
              const video = e.currentTarget
              video.play().catch(() => {})
            }}
          />
        ) : (
          <>
            <SnippetImage
              src={snippet.screenshot || ""}
              alt={snippet.title}
              fill
              className="object-cover transition-transform duration-300 group-hover:scale-105"
            />
            
            {snippet.hasVideo && (
              <div className="absolute inset-0 flex items-center justify-center bg-black/0 transition-colors group-hover:bg-black/20">
                <div className="opacity-0 transition-opacity group-hover:opacity-100">
                  <div className="rounded-full bg-white/90 p-2 shadow-lg backdrop-blur-sm">
                    <Play className="h-4 w-4 text-gray-700 fill-gray-700" />
                  </div>
                </div>
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
