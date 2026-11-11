import type { ReactNode } from "react"

/** CSS-only iPhone frame. Size it by width; everything else scales. */
export function DeviceFrame({ children, className = "" }: { children: ReactNode; className?: string }) {
  return (
    <div className={`device ${className}`}>
      <div className="device-screen">{children}</div>
    </div>
  )
}
