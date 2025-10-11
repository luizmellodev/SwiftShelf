"use client"

import { useState } from "react"
import { Check, Copy } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useToast } from "@/components/ui/toast"

interface CopyButtonProps {
  code: string
}

export function CopyButton({ code }: CopyButtonProps) {
  const [copied, setCopied] = useState(false)
  const [hasShownToast, setHasShownToast] = useState(false)
  const { showToast } = useToast()

  const handleCopy = async () => {
    await navigator.clipboard.writeText(code)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
    
    if (!hasShownToast) {
      setHasShownToast(true)
      showToast(
        "Liked this code? Then help support the project by giving your star on GitHub!",
        {
          label: "Star on GitHub",
          onClick: () => window.open("https://github.com/luizmellodev/swiftshelf", "_blank")
        }
      )
    }
  }

  return (
    <Button onClick={handleCopy} variant="outline" size="sm" className="gap-2 bg-transparent">
      {copied ? (
        <>
          <Check className="h-4 w-4" />
          Copied!
        </>
      ) : (
        <>
          <Copy className="h-4 w-4" />
          Copy Code
        </>
      )}
    </Button>
  )
}
