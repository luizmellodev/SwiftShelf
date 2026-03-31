"use client"

import { Grid3X3, Smartphone, LayoutGrid } from "lucide-react"
import { Button } from "@/components/ui/button"

interface ViewToggleProps {
  currentView: "grid" | "compact" | "reels"
  onViewChange: (view: "grid" | "compact" | "reels") => void
}

export function ViewToggle({ currentView, onViewChange }: ViewToggleProps) {
  return (
    <div className="fixed right-6 z-50 view-toggle-position">
      <div className="flex rounded-full bg-black/20 backdrop-blur-md border border-white/20 p-1">
        <Button
          variant={currentView === "grid" ? "default" : "ghost"}
          size="sm"
          onClick={() => onViewChange("grid")}
          className={`rounded-full transition-all ${
            currentView === "grid"
              ? "bg-white text-black shadow-lg"
              : "text-white hover:bg-white/10"
          }`}
          title="Default view"
        >
          <LayoutGrid className="h-4 w-4" />
        </Button>
        <Button
          variant={currentView === "compact" ? "default" : "ghost"}
          size="sm"
          onClick={() => onViewChange("compact")}
          className={`rounded-full transition-all ${
            currentView === "compact"
              ? "bg-white text-black shadow-lg"
              : "text-white hover:bg-white/10"
          }`}
          title="Compact view"
        >
          <Grid3X3 className="h-4 w-4" />
        </Button>
        <Button
          variant={currentView === "reels" ? "default" : "ghost"}
          size="sm"
          onClick={() => onViewChange("reels")}
          className={`rounded-full transition-all ${
            currentView === "reels"
              ? "bg-white text-black shadow-lg"
              : "text-white hover:bg-white/10"
          }`}
          title="Reels view"
        >
          <Smartphone className="h-4 w-4" />
        </Button>
      </div>
    </div>
  )
}
