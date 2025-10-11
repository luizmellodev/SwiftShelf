"use client"

import { Github, Plus } from "lucide-react"
import { Button } from "@/components/ui/button"

interface ContributeButtonProps {
  variant?: "default" | "floating" | "minimal"
  size?: "sm" | "default" | "lg"
  className?: string
  hideOnMobile?: boolean
}

export function ContributeButton({ 
  variant = "default", 
  size = "default",
  className = "",
  hideOnMobile = false
}: ContributeButtonProps) {
  const handleClick = () => {
    window.open('https://github.com/luizmellodev/SwiftShelf', '_blank')
  }

  if (variant === "floating") {
    return (
      <Button
        onClick={handleClick}
        size={size}
        className={`fixed bottom-6 left-6 z-50 rounded-full bg-gradient-to-r from-emerald-500 to-cyan-500 font-bold border-0 cursor-pointer shadow-[0_0_20px_rgba(34,211,238,0.4),0_0_40px_rgba(34,211,238,0.2)] ${hideOnMobile ? 'hidden md:flex' : ''} ${className}`}
      >
        <Plus className="h-5 w-5 mr-3" />
        Contribute
      </Button>
    )
  }

  if (variant === "minimal") {
    return (
      <Button
        onClick={handleClick}
        variant="outline"
        size={size}
        className={`hover:bg-primary hover:text-primary-foreground transition-colors ${className}`}
      >
        <Github className="h-4 w-4 mr-2" />
        Contribute
      </Button>
    )
  }

  return (
    <Button
      onClick={handleClick}
      size={size}
      className={`bg-gradient-to-r from-emerald-500 to-cyan-500 text-white font-bold border-0 cursor-pointer shadow-[0_0_20px_rgba(34,211,238,0.4),0_0_40px_rgba(34,211,238,0.2)] ${className}`}
    >
      <Github className="h-5 w-5 mr-3" />
      Contribute
    </Button>
  )
}
