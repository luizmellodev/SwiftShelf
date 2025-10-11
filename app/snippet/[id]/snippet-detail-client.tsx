"use client"

import Link from "next/link"
import { useState } from "react"
import { ArrowLeft, Github, ZoomIn } from "lucide-react"
import { ImageModal } from "@/components/image-modal"
import { SnippetImage } from "@/components/snippet-image"
import { CodeViewer } from "@/components/code-viewer"
import type { Snippet } from "@/lib/snippets-data"

interface SnippetDetailClientProps {
  snippet: Snippet
}

export function SnippetDetailClient({ snippet }: SnippetDetailClientProps) {
  const [isImageModalOpen, setIsImageModalOpen] = useState(false)

  return (
    <div className="min-h-screen bg-background">
      <div className="container mx-auto px-4 py-4 sm:py-8 max-w-7xl">
        <Link
          href="/library"
          className="mb-4 inline-flex items-center gap-2 text-sm text-muted-foreground transition-colors hover:text-foreground sm:mb-6"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to Library
        </Link>

        <div className="grid gap-6 lg:grid-cols-2 lg:gap-8">
          <div className="flex flex-col gap-4">
            <div className="group relative aspect-[1/1] overflow-hidden rounded-lg border bg-muted sm:aspect-[3/4] md:aspect-[9/16] lg:sticky lg:top-8">
              <SnippetImage 
                src={snippet.screenshot || ""} 
                alt={snippet.title} 
                fill 
                className="object-contain transition-transform duration-300 group-hover:scale-105" 
              />
              
              <div className="absolute inset-0 flex items-center justify-center bg-black/0 transition-colors group-hover:bg-black/20">
                <button
                  onClick={() => setIsImageModalOpen(true)}
                  className="opacity-0 transition-opacity group-hover:opacity-100"
                >
                  <div className="rounded-full bg-white/90 p-3 shadow-lg backdrop-blur-sm">
                    <ZoomIn className="h-6 w-6 text-gray-700" />
                  </div>
                </button>
              </div>
            </div>
          </div>

          <div className="flex flex-col gap-4 sm:gap-6">
            <div>
              <h1 className="mb-2 text-xl font-bold sm:text-2xl lg:text-3xl xl:text-4xl break-words">{snippet.title}</h1>
              <div className="flex flex-col gap-1 sm:flex-row sm:items-center sm:gap-2">
                <p className="text-sm text-muted-foreground sm:text-base lg:text-lg">by {snippet.author}</p>
                <a
                  href={`https://github.com/${snippet.githubUsername}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 text-xs text-muted-foreground transition-colors hover:text-foreground sm:text-sm"
                >
                  <Github className="h-3 w-3 sm:h-4 sm:w-4" />
                  <span>@{snippet.githubUsername}</span>
                </a>
              </div>
            </div>

            <div className="flex flex-wrap gap-2">
              {snippet.tags.map((tag) => (
                <span
                  key={tag}
                  className="rounded-full bg-secondary px-2 py-1 text-xs font-medium text-secondary-foreground sm:px-3 sm:py-1.5 sm:text-sm"
                >
                  {tag}
                </span>
              ))}
            </div>

            <div>
              <h2 className="mb-2 text-base font-semibold sm:text-lg lg:text-xl">Description</h2>
              <p className="text-sm leading-relaxed text-muted-foreground sm:text-base break-words">{snippet.description}</p>
            </div>

            <CodeViewer code={snippet.code} />
          </div>
        </div>
      </div>
              
      <ImageModal
        src={snippet.screenshot || "/placeholder.svg"}
        alt={snippet.title}
        isOpen={isImageModalOpen}
        onClose={() => setIsImageModalOpen(false)}
      />
    </div>
  )
}
