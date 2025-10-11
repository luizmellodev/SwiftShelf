"use client"

import { useState, useEffect } from "react"
import { SnippetGallery } from "@/components/snippet-gallery"
import { SnippetReels } from "@/components/snippet-reels"
import { ViewToggle } from "@/components/view-toggle"
import { ContributeButton } from "@/components/contribute-button"
import { useToast } from "@/components/ui/toast"
import { snippets } from "@/lib/snippets-data"

export default function LibraryPage() {
  const [currentView, setCurrentView] = useState<"grid" | "reels">("grid")
  const { showToast } = useToast()

  const handleViewChange = (view: "grid" | "reels") => {
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
    <main className="min-h-screen bg-background">
      {currentView === "grid" ? (
        <div className="container mx-auto px-4 py-12">
          <header className="mb-12 text-center">
          <div className="animate-fade-in-up animation-delay-200">
          <h1 className="mb-4 text-balance text-5xl font-bold tracking-tight md:text-7xl">
              <span className="bg-gradient-to-r from-emerald-400 via-cyan-400 to-blue-500 bg-clip-text text-transparent">
                SwiftShelf
              </span>
            </h1>
            <p className="text-lg text-muted-foreground mb-6">Browse and copy production-ready SwiftUI components</p>
            <div className="flex justify-center">
              <ContributeButton />
            </div>
            </div>
          </header>

          <SnippetGallery snippets={snippets} />
        </div>
      ) : (
        <>
          <SnippetReels snippets={snippets} />
          <ContributeButton variant="floating" />
        </>
      )}
      
      <ViewToggle currentView={currentView} onViewChange={handleViewChange} />
    </main>
  )
}
