import Link from "next/link"
import { Github } from "lucide-react"
import { Wordmark } from "./logo"

const links = [
  { href: "/library", label: "Library" },
  { href: "/about", label: "About" },
  { href: "/contribute", label: "Contribute", hideOnPhone: true },
]

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-40 border-b border-white/[0.06] bg-background/70 backdrop-blur-xl backdrop-saturate-150 supports-[backdrop-filter]:bg-background/55">
      <nav className="container mx-auto flex h-12 items-center justify-between px-4">
        <Link href="/" aria-label="SwiftShelf home" className="rounded-md outline-offset-4">
          <Wordmark />
        </Link>
        <div className="flex items-center gap-1 text-[13px] sm:gap-2">
          {links.map((l) => (
            <Link
              key={l.href}
              href={l.href}
              className={`rounded-full px-3 py-1.5 text-muted-foreground transition-colors hover:text-foreground ${
                l.hideOnPhone ? "hidden sm:inline-flex" : ""
              }`}
            >
              {l.label}
            </Link>
          ))}
          <a
            href="https://github.com/luizmellodev/swiftshelf"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="SwiftShelf on GitHub"
            className="ml-1 inline-flex h-8 w-8 items-center justify-center rounded-full text-muted-foreground transition-colors hover:bg-white/5 hover:text-foreground"
          >
            <Github className="h-4 w-4" />
          </a>
        </div>
      </nav>
    </header>
  )
}
