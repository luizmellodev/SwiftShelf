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
    window.open('/contribute', '_blank')
  }

  if (variant === "floating") {
    return (
      <Button
        onClick={handleClick}
        size={size}
        className={`fixed bottom-6 left-6 z-50 rounded-full shadow-lg hover:shadow-xl transition-all duration-300 bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-600 hover:to-cyan-600 ${hideOnMobile ? 'hidden md:flex' : ''} ${className}`}
      >
        <Plus className="h-4 w-4 mr-2" />
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
      className={`bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-600 hover:to-cyan-600 text-white shadow-md hover:shadow-lg transition-all duration-300 ${className}`}
    >
      <Github className="h-4 w-4 mr-2" />
      Contribute
    </Button>
  )
}
