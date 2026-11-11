"use client"

import type { ReactNode } from "react"

/** Card with a soft emerald glow that follows the pointer on hover. */
export function SpotlightCard({ children, className = "" }: { children: ReactNode; className?: string }) {
  return (
    <div
      onPointerMove={(e) => {
        const rect = e.currentTarget.getBoundingClientRect()
        e.currentTarget.style.setProperty("--mx", `${e.clientX - rect.left}px`)
        e.currentTarget.style.setProperty("--my", `${e.clientY - rect.top}px`)
      }}
      className={`spotlight-card group relative overflow-hidden rounded-xl border border-white/10 bg-card/60 p-5 backdrop-blur-sm transition-colors hover:border-white/20 ${className}`}
    >
      <div className="spotlight-card-glow pointer-events-none absolute inset-0 opacity-0 transition-opacity duration-300 group-hover:opacity-100" />
      <div className="relative">{children}</div>
    </div>
  )
}
