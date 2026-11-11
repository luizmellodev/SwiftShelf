import Link from "next/link"
import { LogoMark } from "./logo"

export function SiteFooter() {
  return (
    <footer className="border-t border-white/[0.06]">
      <div className="container mx-auto flex flex-col gap-6 px-4 py-10 text-[13px] text-muted-foreground sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-2.5">
          <LogoMark className="h-5 w-5" />
          <span>
            SwiftShelf. Open source, built by{" "}
            <a href="https://luizmello.dev" target="_blank" rel="noopener noreferrer" className="text-foreground hover:underline">
              @luizmellodev
            </a>{" "}
            and contributors.
          </span>
        </div>
        <div className="flex flex-wrap gap-x-5 gap-y-2">
          <Link href="/library" className="hover:text-foreground">Library</Link>
          <Link href="/contribute" className="hover:text-foreground">Contribute</Link>
          <Link href="/about" className="hover:text-foreground">About</Link>
          <a href="https://github.com/luizmellodev/swiftshelf" target="_blank" rel="noopener noreferrer" className="hover:text-foreground">GitHub</a>
          <a href="https://buymeacoffee.com/luizmello.dev" target="_blank" rel="noopener noreferrer" className="hover:text-foreground">Buy me a coffee</a>
        </div>
      </div>
    </footer>
  )
}
