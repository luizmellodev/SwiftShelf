"use client"

import { Grid3X3, Smartphone } from "lucide-react"
import { Button } from "@/components/ui/button"

interface ViewToggleProps {
  currentView: "grid" | "reels"
  onViewChange: (view: "grid" | "reels") => void
}

export function ViewToggle({ currentView, onViewChange }: ViewToggleProps) {
  return (
    <div className="fixed bottom-6 right-6 z-50">
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
        >
          <Smartphone className="h-4 w-4" />
        </Button>
      </div>
    </div>
  )
}
