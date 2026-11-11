import Link from "next/link"
import { Button } from "@/components/ui/button"
import { ArrowRight, Github, Copy, Smartphone, PackageOpen, Sparkles, Info } from "lucide-react"
import { loadSnippets } from "@/lib/snippets-loader"
import { HeroBackground } from "@/components/home/hero-background"
import { NumberTicker } from "@/components/home/number-ticker"
import { DemoMarquee, type MarqueeItem } from "@/components/home/demo-marquee"
import { SpotlightCard } from "@/components/home/spotlight-card"

export default async function Home() {
  const snippets = await loadSnippets()

  const demos: MarqueeItem[] = snippets
    .filter((s) => s.hasVideo && s.videoUrl)
    .map((s) => ({ id: s.id, title: s.title, videoUrl: s.videoUrl!, screenshot: s.screenshot }))
  // Interleave so neighbouring tiles in each row don't come from the same alphabetical cluster.
  const shuffled = [...demos.filter((_, i) => i % 2 === 0), ...demos.filter((_, i) => i % 2 === 1)]

  const linesOfSwift = snippets.reduce((sum, s) => sum + s.code.split("\n").length, 0)

  const stats = [
    { value: snippets.length, label: "Components" },
    { value: demos.length, label: "Live demos" },
    { value: linesOfSwift, label: "Lines of SwiftUI" },
    { value: 0, label: "Dependencies", static: true },
  ]

  const features = [
    {
      icon: Copy,
      title: "Copy, paste, ship",
      body: "Every component is a single self-contained SwiftUI file. Drop it in your project and it just builds.",
    },
    {
      icon: Smartphone,
      title: "Feels native",
      body: "Springs, haptics and gestures tuned to feel at home on iOS, not like a web port.",
    },
    {
      icon: PackageOpen,
      title: "No packages",
      body: "Only Apple frameworks. No SPM dependency to vet, update or break on the next Xcode.",
    },
  ]

  return (
    <main className="min-h-screen relative overflow-hidden">
      <section className="relative isolate">
        <HeroBackground />

        <div className="container mx-auto px-4 pt-20 pb-12 md:pt-32 md:pb-16">
          <div className="mx-auto max-w-4xl text-center">
            <div className="animate-fade-in-up">
              <div className="badge-beam relative mb-8 inline-flex items-center gap-2 rounded-full border border-primary/20 bg-primary/10 px-4 py-2 backdrop-blur-sm">
                <Sparkles className="h-4 w-4 text-primary motion-safe:animate-spin" />
                <span className="text-sm font-medium text-primary">Community Driven</span>
              </div>
            </div>

            <div className="animate-fade-in-up animation-delay-200">
              <h1 className="mb-4 text-balance text-5xl font-bold tracking-tight md:text-7xl">
                <span className="hero-title bg-gradient-to-r from-emerald-400 via-cyan-400 to-blue-500 bg-clip-text text-transparent">
                  SwiftShelf
                </span>
              </h1>
              <p className="text-2xl md:text-3xl font-semibold mb-6 text-balance">
                Production-ready SwiftUI components and views
              </p>
            </div>

            <p className="mb-8 text-pretty text-lg text-muted-foreground md:text-xl animate-fade-in-up animation-delay-400">
              A curated collection of production-ready SwiftUI snippets built by developers, for developers. Copy, paste,
              and ship faster. <span className="text-white italic">Simple as that.</span>
            </p>

            <div className="flex flex-col items-center justify-center gap-4 animate-fade-in-up animation-delay-600">
              <div className="flex w-full flex-col items-center justify-center gap-3 sm:w-auto sm:flex-row sm:gap-4">
                <Button asChild size="lg" className="cta-shine w-full gap-2 sm:w-auto hover:scale-105 transition-all duration-300 shadow-lg hover:shadow-xl">
                  <Link href="/library">
                    Browse Library <ArrowRight className="h-4 w-4" />
                  </Link>
                </Button>
                <Button asChild size="lg" variant="outline" className="w-full gap-2 bg-transparent sm:w-auto hover:scale-105 transition-all duration-300 backdrop-blur-sm border-primary/20 hover:border-primary/40">
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

          <dl className="mx-auto mt-14 grid max-w-3xl grid-cols-2 gap-px overflow-hidden rounded-xl border border-white/10 bg-white/10 animate-fade-in-up animation-delay-1000 md:mt-20 md:grid-cols-4">
            {stats.map((stat, i) => (
              <div key={stat.label} className="flex flex-col items-center gap-1 bg-background/80 px-4 py-5 backdrop-blur-sm">
                <dt className="order-2 text-xs font-medium uppercase tracking-wider text-muted-foreground">{stat.label}</dt>
                <dd className="order-1 bg-gradient-to-b from-white to-white/60 bg-clip-text text-3xl font-bold tracking-tight text-transparent md:text-4xl">
                  {stat.static ? stat.value : <NumberTicker value={stat.value} delay={1000 + i * 120} />}
                </dd>
              </div>
            ))}
          </dl>
        </div>
      </section>

      {shuffled.length > 0 && (
        <section aria-labelledby="demos-heading" className="relative py-10 md:py-16">
          <div className="container mx-auto mb-8 px-4 text-center md:mb-10">
            <h2 id="demos-heading" className="text-2xl font-semibold tracking-tight md:text-3xl">
              Don&apos;t read about it. <span className="text-muted-foreground">Watch it.</span>
            </h2>
            <p className="mt-2 text-sm text-muted-foreground md:text-base">
              Every tile is a real recording of the component. Tap one to grab the code.
            </p>
          </div>
          <DemoMarquee items={shuffled} />
        </section>
      )}

      <section className="container mx-auto px-4 py-12 md:py-20">
        <div className="mx-auto grid max-w-5xl gap-4 md:grid-cols-3">
          {features.map(({ icon: Icon, title, body }) => (
            <SpotlightCard key={title}>
              <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-lg border border-white/10 bg-gradient-to-br from-emerald-400/20 to-cyan-400/10">
                <Icon className="h-5 w-5 text-emerald-300" />
              </div>
              <h3 className="mb-1.5 font-semibold">{title}</h3>
              <p className="text-sm leading-relaxed text-muted-foreground">{body}</p>
            </SpotlightCard>
          ))}
        </div>

        <div className="mt-14 text-center md:mt-20">
          <Button asChild size="lg" className="gap-2 hover:scale-105 transition-all duration-300 shadow-lg hover:shadow-xl">
            <Link href="/library">
              Explore all {snippets.length} components <ArrowRight className="h-4 w-4" />
            </Link>
          </Button>
        </div>
      </section>
    </main>
  )
}
