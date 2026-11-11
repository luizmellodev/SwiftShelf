"use client"

import { Grid3X3, Smartphone, LayoutGrid } from "lucide-react"

type View = "grid" | "compact" | "reels"

interface ViewToggleProps {
  currentView: View
  onViewChange: (view: View) => void
}

const options: { view: View; label: string; icon: typeof LayoutGrid }[] = [
  { view: "grid", label: "Grid view", icon: LayoutGrid },
  { view: "compact", label: "Compact view", icon: Grid3X3 },
  { view: "reels", label: "Reels view", icon: Smartphone },
]

export function ViewToggle({ currentView, onViewChange }: ViewToggleProps) {
  return (
    <div className="fixed left-1/2 z-50 -translate-x-1/2 view-toggle-position md:left-auto md:right-6 md:translate-x-0">
      <div
        role="radiogroup"
        aria-label="Layout"
        className="flex gap-0.5 rounded-full border border-white/10 bg-neutral-900/80 p-1 shadow-[0_8px_30px_rgba(0,0,0,0.5)] backdrop-blur-xl"
      >
        {options.map(({ view, label, icon: Icon }) => {
          const active = currentView === view
          return (
            <button
              key={view}
              role="radio"
              aria-checked={active}
              aria-label={label}
              title={label}
              onClick={() => onViewChange(view)}
              className={`inline-flex h-9 w-11 items-center justify-center rounded-full transition-colors ${
                active ? "bg-white text-black" : "text-white/70 hover:bg-white/10 hover:text-white"
              }`}
            >
              <Icon className="h-4 w-4" />
            </button>
          )
        })}
      </div>
    </div>
  )
}
