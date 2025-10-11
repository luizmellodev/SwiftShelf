"use client"

import { useState } from "react"
import { SnippetGallery } from "@/components/snippet-gallery"
import { SnippetReels } from "@/components/snippet-reels"
import { ViewToggle } from "@/components/view-toggle"
import { ContributeButton } from "@/components/contribute-button"
import { useToast } from "@/components/ui/toast"
import type { Snippet } from "@/lib/snippets-loader"
import { HelpCircle, Info } from "lucide-react"

interface LibraryClientProps {
  snippets: Snippet[]
}

export function LibraryClient({ snippets }: LibraryClientProps) {
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
            <div className="flex justify-center gap-3">
              <button 
                onClick={() => window.location.href = '/about'}
                className="group inline-flex items-center gap-1.5 px-4 py-2 text-xs font-medium text-gray-600 dark:text-gray-400 bg-transparent border border-gray-200 dark:border-gray-700 rounded-md hover:bg-gray-50 dark:hover:bg-gray-800 hover:text-gray-700 dark:hover:text-gray-300 transition-all duration-200 cursor-pointer"
              >
                <Info className="h-3.5 w-3.5" />
                About
              </button>
              <button 
                onClick={() => window.location.href = '/contribute'}
                className="group inline-flex items-center gap-1.5 px-4 py-2 text-xs font-medium text-gray-600 dark:text-gray-400 bg-transparent border border-gray-200 dark:border-gray-700 rounded-md hover:bg-gray-50 dark:hover:bg-gray-800 hover:text-gray-700 dark:hover:text-gray-300 transition-all duration-200 cursor-pointer"
              >
                <HelpCircle className="h-3.5 w-3.5" />
                How to Contribute
              </button>
            </div>
            </div>
          </header>

          <SnippetGallery snippets={snippets} />
        </div>
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

