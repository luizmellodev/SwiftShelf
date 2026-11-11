"use client"

import { useState } from "react"
import { SnippetGallery } from "@/components/snippet-gallery"
import { SnippetReels } from "@/components/snippet-reels"
import { ViewToggle } from "@/components/view-toggle"
import { ContributeButton } from "@/components/contribute-button"
import { useToast } from "@/components/ui/toast"
import type { Snippet } from "@/lib/snippets-loader"
import { SiteHeader } from "@/components/site/site-header"
import { SiteFooter } from "@/components/site/site-footer"

interface LibraryClientProps {
  snippets: Snippet[]
}

export function LibraryClient({ snippets }: LibraryClientProps) {
  const [currentView, setCurrentView] = useState<"grid" | "compact" | "reels">("grid")
  const { showToast } = useToast()

  const handleViewChange = (view: "grid" | "compact" | "reels") => {
    setCurrentView(view)
    
    if (view === "reels") {
      showToast(
        "Liked this mode? Then leave your star on the repository!",
        {
          label: "Star on GitHub",
          onClick: () => window.open("https://github.com/luizmellodev/swiftshelf", "_blank")
        }
      )
    }
  }

  return (
    <main className="min-h-screen bg-background pb-16 md:pb-0">
      {currentView === "grid" || currentView === "compact" ? (
        <>
        <SiteHeader />
        <div className="container mx-auto px-4 pt-10 pb-16 md:pt-14">
          <header className="mb-8 md:mb-10">
            <h1 className="text-4xl font-semibold tracking-[-0.03em] md:text-5xl">Library</h1>
            <p className="mt-2 max-w-xl text-muted-foreground">
              {snippets.length} SwiftUI components, each a single file you can paste straight into Xcode.
            </p>
          </header>

          <SnippetGallery snippets={snippets} viewMode={currentView} />
        </div>
        <SiteFooter />
        </>
      ) : (
        <>
          <SnippetReels snippets={snippets} />
          <ContributeButton variant="floating" hideOnMobile={true} />
        </>
      )}
      
      <ViewToggle currentView={currentView} onViewChange={handleViewChange} />
    </main>
  )
}

