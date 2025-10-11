import Link from "next/link"
import { Button } from "@/components/ui/button"
import { ArrowRight, Github, Code2, Users, Zap, Sparkles, Info } from "lucide-react"

export default function Home() {
  return (
    <main className="min-h-screen relative overflow-hidden">
      <div className="absolute inset-0 -z-10">
        <div className="absolute inset-0 bg-gradient-radial from-black/90 via-black/70 to-black/50"></div>
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-emerald-500/10 rounded-full blur-3xl animate-fade-in-scale animation-delay-0"></div>
        <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-cyan-500/10 rounded-full blur-3xl animate-fade-in-scale animation-delay-500"></div>
        <div className="absolute top-1/2 right-1/3 w-64 h-64 bg-blue-500/10 rounded-full blur-3xl animate-fade-in-scale animation-delay-1000"></div>
      </div>

      <section className="container mx-auto px-4 py-24 md:py-32 relative">
        <div className="mx-auto max-w-4xl text-center">
          <div className="animate-fade-in-up">
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/10 border border-primary/20 backdrop-blur-sm mb-8">
              <Sparkles className="h-4 w-4 text-primary animate-spin" />
              <span className="text-sm font-medium text-primary">Community Driven</span>
            </div>
          </div>
          
          <div className="animate-fade-in-up animation-delay-200">
            <h1 className="mb-4 text-balance text-5xl font-bold tracking-tight md:text-7xl">
              <span className="bg-gradient-to-r from-emerald-400 via-cyan-400 to-blue-500 bg-clip-text text-transparent">
                SwiftShelf
              </span>
            </h1>
            <p className="text-2xl md:text-3xl font-semibold mb-6">
            Production-ready SwiftUI components and views
            </p>
          </div>
          
          <p className="mb-8 text-pretty text-lg text-muted-foreground md:text-xl animate-fade-in-up animation-delay-400">
            A curated collection of production-ready SwiftUI snippets built by developers, for developers. Copy, paste,
            and ship faster. <span className="text-white italic">Simple as that.</span>
          </p>
          
          <div className="flex flex-col items-center justify-center gap-4 animate-fade-in-up animation-delay-600">
            <div className="flex flex-col items-center justify-center gap-4 sm:flex-row">
              <Button asChild size="lg" className="gap-2 hover:scale-105 transition-all duration-300 shadow-lg hover:shadow-xl">
                <Link href="/library">
                  Browse Library <ArrowRight className="h-4 w-4" />
                </Link>
              </Button>
              <Button asChild size="lg" variant="outline" className="gap-2 bg-transparent hover:scale-105 transition-all duration-300 backdrop-blur-sm border-primary/20 hover:border-primary/40">
                <a href="https://github.com/luizmellodev/swiftshelf" target="_blank" rel="noopener noreferrer">
                  <Github className="h-4 w-4" /> Contribute on GitHub
                </a>
              </Button>
            </div>
            
            <Link 
              href="/about"
              className="inline-flex items-center gap-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              <Info className="h-3.5 w-3.5" />
              Learn more about this project
            </Link>
          </div>
        </div>
      </section>
    </main>
  )
}
