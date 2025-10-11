import { ImageIcon } from "lucide-react"

interface ImagePlaceholderProps {
  className?: string
  size?: "sm" | "md" | "lg"
}

export function ImagePlaceholder({ className = "", size = "md" }: ImagePlaceholderProps) {
  const iconSizeClasses = {
    sm: "h-8 w-8",
    md: "h-12 w-12", 
    lg: "h-16 w-16"
  }

  return (
    <div className={`flex items-center justify-center bg-gray-800 ${className}`}>
      <ImageIcon className={`${iconSizeClasses[size]} text-gray-400`} />
    </div>
  )
}
