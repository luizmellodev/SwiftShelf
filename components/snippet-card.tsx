"use client"

import Link from "next/link"
import { useState } from "react"
import { Github } from "lucide-react"
import type { Snippet } from "@/lib/snippets-loader"
import { SnippetImage } from "./snippet-image"
import { AutoplayVideo } from "./autoplay-video"
import { useReducedMotion } from "@/lib/use-reduced-motion"

interface SnippetCardProps {
  snippet: Snippet
}

export function SnippetCard({ snippet }: SnippetCardProps) {
  const [isExpanded, setIsExpanded] = useState(false)
  const [hovering, setHovering] = useState(false)
  const [videoReady, setVideoReady] = useState(false)
  const reduced = useReducedMotion()

  return (
    <div 
      className="group overflow-hidden rounded-lg border bg-card transition-all hover:border-primary/50 hover:shadow-lg"
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
    >
      <Link href={`/snippet/${snippet.id}`} className="block">
        <div className="relative aspect-[9/16] overflow-hidden bg-muted">
          <SnippetImage
            src={snippet.screenshot || ""}
            alt={snippet.title}
            fill
            className="object-cover transition-transform duration-300 group-hover:scale-105"
          />
          {snippet.hasVideo && snippet.videoUrl && (
            <AutoplayVideo
              src={snippet.videoUrl}
              active={!reduced || hovering}
              onReady={() => setVideoReady(true)}
              className={`absolute inset-0 h-full w-full object-cover transition-opacity duration-500 ${
                videoReady ? "opacity-100" : "opacity-0"
              }`}
            />
          )}
        </div>

        <div className="p-4">
          <h3 className="mb-2 text-xl font-semibold">{snippet.title}</h3>
          <div className="mb-3 flex items-center gap-2">
            <p className="text-sm text-muted-foreground">by {snippet.author}</p>
            <button
              onClick={(e) => {
                e.preventDefault()
                e.stopPropagation()
                window.open(`https://github.com/${snippet.githubUsername}`, '_blank', 'noopener,noreferrer')
              }}
              className="inline-flex items-center gap-1 text-sm text-muted-foreground transition-colors hover:text-foreground"
            >
              <Github className="h-3.5 w-3.5" />
            </button>
          </div>

          <p className={`mb-3 text-sm leading-relaxed ${isExpanded ? "" : "line-clamp-2"}`}>{snippet.description}</p>

          {snippet.description.length > 100 && (
            <button
              onClick={(e) => {
                e.preventDefault()
                setIsExpanded(!isExpanded)
              }}
              className="mb-3 text-xs text-primary hover:underline"
            >
              {isExpanded ? "Show less" : "Show more"}
            </button>
          )}

          <div className="flex flex-wrap gap-2">
            {snippet.tags.map((tag) => (
              <span
                key={tag}
                className="rounded-full bg-secondary px-3 py-1 text-xs font-medium text-secondary-foreground"
              >
                {tag}
              </span>
            ))}
          </div>
        </div>
      </Link>
    </div>
  )
}
