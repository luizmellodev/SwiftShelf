import Link from "next/link"
import { ArrowRight, Github } from "lucide-react"
import { loadSnippets } from "@/lib/snippets-loader"
import { SiteHeader } from "@/components/site/site-header"
import { SiteFooter } from "@/components/site/site-footer"
import { HeroBackground } from "@/components/home/hero-background"
import { HeroShowcase } from "@/components/home/hero-showcase"
import { NumberTicker } from "@/components/home/number-ticker"
import { DemoMarquee, type MarqueeItem } from "@/components/home/demo-marquee"

const FEATURED = [
  "border-beam",
  "bank-card-flip",
  "gooey-tab-bar",
  "magnetic-dock",
  "liquid-switch",
  "island-toast",
  "flip-clock",
  "hero-expand-card",
]

export default async function Home() {
  const snippets = await loadSnippets()

  const demos: MarqueeItem[] = snippets
    .filter((s) => s.hasVideo && s.videoUrl)
    .map((s) => ({ id: s.id, title: s.title, videoUrl: s.videoUrl!, screenshot: s.screenshot }))

  const featured = FEATURED.map((slug) => demos.find((d) => d.id.split(".")[0] === slug)).filter(
    (d): d is MarqueeItem => Boolean(d),
  )
  // Interleave so neighbouring tiles in each row don't come from the same alphabetical cluster.
  const marquee = [...demos.filter((_, i) => i % 2 === 0), ...demos.filter((_, i) => i % 2 === 1)]

  const linesOfSwift = snippets.reduce((sum, s) => sum + s.code.split("\n").length, 0)

  const stats = [
    { value: snippets.length, label: "components" },
    { value: linesOfSwift, label: "lines of SwiftUI" },
    { value: 0, label: "dependencies", static: true },
  ]

  const steps = [
    {
      n: "01",
      title: "Find it",
      body: `Browse ${snippets.length} components by tag, or search by name. Every one has a recording, so you know how it moves before you read a line.`,
    },
    {
      n: "02",
      title: "Copy one file",
      body: "Each component lives in a single snippet.swift. Paste it into your project and it builds. Apple frameworks only.",
    },
    {
      n: "03",
      title: "Make it yours",
      body: "Plain SwiftUI split into MARK sections. Swap colors, retune the springs, change the haptics. Nothing is hidden behind a package.",
    },
  ]

  return (
    <>
      <SiteHeader />
      <main className="relative overflow-hidden">
        <section className="relative isolate">
          <HeroBackground />

          <div className="container mx-auto grid gap-10 px-4 pt-10 pb-16 md:grid-cols-[1.15fr_0.85fr] md:grid-rows-[1fr_auto] md:gap-x-8 md:gap-y-0 md:pt-20 md:pb-24 lg:gap-x-16">
            <div className="text-center md:col-start-1 md:row-start-1 md:self-end md:text-left">
              <p className="animate-fade-in-up mb-5 inline-flex items-center gap-2 font-mono text-xs text-muted-foreground">
                <span className="h-1.5 w-1.5 rounded-full bg-swift" />
                Open-source SwiftUI library
              </p>

              <h1 className="animate-fade-in-up animation-delay-200 text-balance text-[2.4rem] font-semibold leading-[1.05] tracking-[-0.035em] sm:text-6xl lg:text-7xl">
                SwiftUI components that feel at home{" "}
                <span className="text-muted-foreground">on iOS.</span>
              </h1>

              <p className="animate-fade-in-up animation-delay-400 mx-auto mt-5 max-w-xl text-pretty text-[15px] leading-relaxed sm:mt-6 text-muted-foreground sm:text-lg md:mx-0">
                A curated collection of production-ready SwiftUI snippets built by developers, for developers. Copy,
                paste, and ship faster. <span className="text-foreground">Simple as that.</span>
              </p>

              <div className="animate-fade-in-up animation-delay-600 mt-7 flex items-center justify-center gap-2.5 sm:gap-3 md:justify-start">
                <Link
                  href="/library"
                  className="inline-flex h-11 flex-1 items-center justify-center gap-2 whitespace-nowrap rounded-full bg-foreground px-4 text-sm font-medium text-background transition-transform hover:scale-[1.03] active:scale-[0.98] sm:flex-none sm:px-6"
                >
                  Browse library <ArrowRight className="h-4 w-4" />
                </Link>
                <a
                  href="https://github.com/luizmellodev/swiftshelf"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex h-11 flex-1 items-center justify-center gap-2 whitespace-nowrap rounded-full border border-white/15 px-4 text-sm font-medium transition-colors hover:border-white/30 hover:bg-white/[0.04] sm:flex-none sm:px-6"
                >
                  <Github className="h-4 w-4" /> Star on GitHub
                </a>
              </div>


            </div>

            <div className="animate-fade-in-up animation-delay-400 md:col-start-2 md:row-span-2 md:row-start-1 md:self-center">
              <HeroShowcase items={featured} />
            </div>

            <dl className="animate-fade-in-up animation-delay-1000 mx-auto flex w-full md:col-start-1 md:row-start-2 md:mt-12 md:self-start max-w-md justify-center gap-8 border-t border-white/[0.08] pt-6 sm:gap-12 md:mx-0 md:justify-start">
              {stats.map((stat, i) => (
                <div key={stat.label} className="flex flex-col">
                  <dd className="text-2xl font-semibold tracking-tight sm:text-3xl">
                    {stat.static ? stat.value : <NumberTicker value={stat.value} delay={900 + i * 150} />}
                  </dd>
                  <dt className="order-last mt-1 font-mono text-[11px] text-muted-foreground">{stat.label}</dt>
                </div>
              ))}
            </dl>
          </div>
        </section>

        {marquee.length > 0 && (
          <section aria-labelledby="demos-heading" className="relative border-t border-white/[0.06] py-16 md:py-24">
            <div className="container mx-auto mb-10 flex flex-col gap-3 px-4 md:flex-row md:items-end md:justify-between">
              <div>
                <h2 id="demos-heading" className="text-3xl font-semibold tracking-tight md:text-4xl">
                  Every component, recorded live.
                </h2>
                <p className="mt-2 max-w-lg text-muted-foreground">
                  No mockups, no stills. What you see is the code running. Tap one to grab it.
                </p>
              </div>
              <Link
                href="/library"
                className="group inline-flex items-center gap-1 text-sm font-medium text-swift hover:underline"
              >
                See all {snippets.length}
                <ArrowRight className="h-3.5 w-3.5 transition-transform group-hover:translate-x-0.5" />
              </Link>
            </div>
            <DemoMarquee items={marquee} />
          </section>
        )}

        <section className="border-t border-white/[0.06] py-16 md:py-24">
          <div className="container mx-auto px-4">
            <h2 className="max-w-xl text-3xl font-semibold tracking-tight md:text-4xl">
              From browser to build in a minute.
            </h2>
            <ol className="mt-10 grid gap-10 md:grid-cols-3 md:gap-8">
              {steps.map((step) => (
                <li key={step.n} className="border-t border-white/10 pt-5">
                  <span className="font-mono text-xs text-swift">{step.n}</span>
                  <h3 className="mt-2 text-lg font-semibold">{step.title}</h3>
                  <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{step.body}</p>
                </li>
              ))}
            </ol>
          </div>
        </section>

        <section className="container mx-auto px-4 pb-20 md:pb-28">
          <div className="flex flex-col items-start gap-6 rounded-3xl border border-white/[0.08] bg-card px-6 py-10 sm:px-10 md:flex-row md:items-center md:justify-between">
            <div>
              <h2 className="text-2xl font-semibold tracking-tight md:text-3xl">Built something worth sharing?</h2>
              <p className="mt-2 max-w-lg text-muted-foreground">
                Open a pull request with your snippet, a screenshot and a short recording. CI checks the rest.
              </p>
            </div>
            <Link
              href="/contribute"
              className="inline-flex h-11 shrink-0 items-center gap-2 rounded-full bg-swift px-6 text-sm font-medium text-swift-foreground transition-transform hover:scale-[1.03] active:scale-[0.98]"
            >
              How to contribute <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </section>
      </main>
      <SiteFooter />
    </>
  )
}
