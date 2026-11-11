/** SwiftShelf mark: an app-icon squircle holding three "books" on a shelf. */
export function LogoMark({ className = "h-6 w-6" }: { className?: string }) {
  return (
    <svg viewBox="0 0 32 32" className={className} aria-hidden="true">
      <rect width="32" height="32" rx="8" className="fill-swift" />
      <rect x="8" y="9" width="4" height="13" rx="1.2" fill="white" />
      <rect x="13.5" y="7" width="4" height="15" rx="1.2" fill="white" fillOpacity="0.85" />
      <rect x="19" y="10.5" width="4" height="11.5" rx="1.2" fill="white" fillOpacity="0.7" transform="rotate(12 21 22)" />
      <rect x="6.5" y="23" width="19" height="2" rx="1" fill="white" />
    </svg>
  )
}

export function Wordmark() {
  return (
    <span className="inline-flex items-center gap-2">
      <LogoMark />
      <span className="text-[15px] font-semibold tracking-tight">SwiftShelf</span>
    </span>
  )
}
