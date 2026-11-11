"use client"

import Link from "next/link"
import { useState } from "react"
import { ArrowLeft, ArrowRight, Github, ZoomIn, Play } from "lucide-react"
import { ImageModal } from "@/components/image-modal"
import { SnippetImage } from "@/components/snippet-image"
import { CodeViewer } from "@/components/code-viewer"
import { AutoplayVideo } from "@/components/autoplay-video"
import { DeviceFrame } from "@/components/device-frame"
import { SiteHeader } from "@/components/site/site-header"
import { SiteFooter } from "@/components/site/site-footer"
import { useReducedMotion } from "@/lib/use-reduced-motion"
import type { Snippet } from "@/lib/snippets-loader"

interface NeighbourLink {
  id: string
  title: string
}

interface SnippetDetailClientProps {
  snippet: Snippet
  prev: NeighbourLink
  next: NeighbourLink
}

export function SnippetDetailClient({ snippet, prev, next }: SnippetDetailClientProps) {
  const [isImageModalOpen, setIsImageModalOpen] = useState(false)
  const [hovering, setHovering] = useState(false)
  const [videoReady, setVideoReady] = useState(false)
  const reduced = useReducedMotion()
  const videoActive = !reduced || hovering
  const hasVideo = Boolean(snippet.hasVideo && snippet.videoUrl)

  return (
    <>
      <SiteHeader />
      <main className="min-h-screen bg-background">
        <div className="container mx-auto max-w-6xl px-4 pt-6 pb-16 sm:pt-10">
          <nav aria-label="Breadcrumb" className="mb-8 flex items-center gap-2 font-mono text-xs text-muted-foreground">
            <Link href="/library" className="inline-flex items-center gap-1.5 transition-colors hover:text-foreground">
              <ArrowLeft className="h-3.5 w-3.5" />
              Library
            </Link>
            <span className="opacity-40">/</span>
            <span className="truncate text-foreground/80">{snippet.title}</span>
          </nav>

          <div className="flex flex-col gap-10 lg:grid lg:grid-cols-[340px_minmax(0,1fr)] lg:gap-14">
            <div className="lg:sticky lg:top-20 lg:self-start">
              <div
                className="group relative mx-auto w-[240px] sm:w-[280px] lg:w-[300px]"
                onMouseEnter={() => setHovering(true)}
                onMouseLeave={() => setHovering(false)}
                onClick={() => reduced && hasVideo && setHovering((h) => !h)}
              >
                <DeviceFrame>
                  <SnippetImage src={snippet.screenshot || ""} alt={snippet.title} fill className="object-cover object-top" />
                  {hasVideo ? (
                    <>
                      <AutoplayVideo
                        src={snippet.videoUrl!}
                        active={videoActive}
                        rootMargin="0px"
                        onReady={() => setVideoReady(true)}
                        className={`absolute inset-0 h-full w-full object-cover object-top transition-opacity duration-500 ${
                          videoReady ? "opacity-100" : "opacity-0"
                        }`}
                      />
                      {!videoActive && (
                        <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center gap-2 bg-black/30">
                          <div className="rounded-full bg-white/90 p-3.5 shadow-lg">
                            <Play className="h-6 w-6 fill-black text-black" />
                          </div>
                          <p className="text-xs font-medium text-white drop-shadow">Hover or tap to play</p>
                        </div>
                      )}
                    </>
                  ) : (
                    <button
                      onClick={() => setIsImageModalOpen(true)}
                      aria-label="Zoom screenshot"
                      className="absolute inset-0 flex items-center justify-center bg-black/0 opacity-0 transition hover:bg-black/30 hover:opacity-100 focus-visible:opacity-100"
                    >
                      <span className="rounded-full bg-white/90 p-3 shadow-lg">
                        <ZoomIn className="h-5 w-5 text-black" />
                      </span>
                    </button>
                  )}
                </DeviceFrame>
              </div>
            </div>

            <div className="flex min-w-0 flex-col gap-8">
              <header>
                <h1 className="text-balance text-3xl font-semibold tracking-[-0.03em] sm:text-4xl lg:text-5xl">
                  {snippet.title}
                </h1>
                <p className="mt-4 max-w-2xl text-pretty leading-relaxed text-muted-foreground">{snippet.description}</p>
                <div className="mt-5 flex flex-wrap items-center gap-x-4 gap-y-3">
                  <a
                    href={`https://github.com/${snippet.githubUsername}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-2 text-sm text-muted-foreground transition-colors hover:text-foreground"
                  >
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={`https://github.com/${snippet.githubUsername}.png?size=48`}
                      alt=""
                      width={22}
                      height={22}
                      loading="lazy"
                      onError={(e) => {
                        e.currentTarget.style.display = "none"
                      }}
                      className="h-[22px] w-[22px] rounded-full bg-card"
                    />
                    {snippet.author}
                    <Github className="h-3.5 w-3.5 opacity-60" />
                  </a>
                  <span className="hidden h-4 w-px bg-white/10 sm:block" />
                  <ul className="flex flex-wrap gap-1.5">
                    {snippet.tags.map((tag) => (
                      <li key={tag} className="rounded-full border border-white/10 px-2.5 py-0.5 font-mono text-[11px] text-muted-foreground">
                        {tag}
                      </li>
                    ))}
                  </ul>
                </div>
              </header>

              <CodeViewer code={snippet.code} />
            </div>
          </div>

          <nav aria-label="More components" className="mt-16 grid gap-3 border-t border-white/[0.06] pt-8 sm:grid-cols-2">
            <Link
              href={`/snippet/${prev.id}`}
              className="group flex flex-col gap-1 rounded-2xl border border-white/[0.08] p-4 transition-colors hover:border-white/20"
            >
              <span className="inline-flex items-center gap-1 font-mono text-[11px] text-muted-foreground">
                <ArrowLeft className="h-3 w-3" /> Previous
              </span>
              <span className="truncate font-medium group-hover:text-swift">{prev.title}</span>
            </Link>
            <Link
              href={`/snippet/${next.id}`}
              className="group flex flex-col items-end gap-1 rounded-2xl border border-white/[0.08] p-4 text-right transition-colors hover:border-white/20"
            >
              <span className="inline-flex items-center gap-1 font-mono text-[11px] text-muted-foreground">
                Next <ArrowRight className="h-3 w-3" />
              </span>
              <span className="max-w-full truncate font-medium group-hover:text-swift">{next.title}</span>
            </Link>
          </nav>
        </div>
      </main>
      <SiteFooter />

      <ImageModal
        src={snippet.screenshot || "/placeholder.svg"}
        alt={snippet.title}
        isOpen={isImageModalOpen}
        onClose={() => setIsImageModalOpen(false)}
      />
    </>
  )
}
