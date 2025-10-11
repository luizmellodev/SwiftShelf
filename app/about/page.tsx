import Link from "next/link"
import { Heart, Code, Rocket, Book, Github, Coffee, ArrowRight } from "lucide-react"
import { Button } from "@/components/ui/button"

export default function AboutPage() {
  return (
    <main className="min-h-screen bg-background">
      <div className="container mx-auto px-4 py-12 max-w-4xl">
        <header className="mb-12 text-center">
          <h1 className="mb-4 text-balance text-5xl font-bold tracking-tight md:text-7xl">
            <span className="bg-gradient-to-r from-blue-400 via-purple-400 to-pink-500 bg-clip-text text-transparent">
              About SwiftShelf
            </span>
          </h1>
          <p className="text-lg text-muted-foreground">
            Building tools for the iOS development community
          </p>
        </header>

        <div className="space-y-8">
          <section className="bg-card rounded-lg border p-8">
            <div className="flex items-center gap-3 mb-6">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-blue-900 text-white">
                <Heart className="h-6 w-6" />
              </div>
              <div>
                <h2 className="text-2xl font-bold">The idea behind SwiftShelf</h2>
                <p className="text-sm text-muted-foreground">Why SwiftShelf exists?</p>
              </div>
            </div>
            
            <div className="space-y-4 text-muted-foreground">
              <p className="leading-relaxed">
                Hey! I'm <strong className="text-foreground">Luiz Mello</strong>, an iOS developer passionate about crafting small digital experiences that feel intentional, useful, and fun!
              </p>
              
              <p className="leading-relaxed">
                As an iOS developer, I've always wanted to give something back to the community that has taught me so much. 
                SwiftShelf was born from this desire. I wanted to create a place where developers can easily find, 
                share, and learn from beautiful SwiftUI components.
              </p>

              <p className="leading-relaxed">
                But there was another, personal goal: I wanted to deepen my knowledge of <strong className="text-foreground">CI/CD workflows</strong> and <strong className="text-foreground">GitHub Actions</strong>. 
                This project became the perfect playground to learn automation, validation pipelines, 
                and how to build systems that just work.
              </p>
            </div>
          </section>

          <section className="bg-gradient-to-br from-emerald-50 to-teal-50 dark:from-emerald-950/20 dark:to-teal-950/20 rounded-lg border border-emerald-200 dark:border-emerald-800 p-8">
            <div className="text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-emerald-600 text-white mb-6">
                <Rocket className="h-8 w-8" />
              </div>
              
              <h2 className="text-3xl font-bold mb-4">Want to Contribute?</h2>
              <p className="text-muted-foreground mb-6 max-w-2xl mx-auto">
                Join the community! Share your SwiftUI components and help other developers build amazing apps. 
                Every contribution makes a difference.
              </p>
              
              <Link href="/contribute">
                <Button size="lg" className="bg-emerald-600 hover:bg-emerald-700 text-white gap-2">
                  <Github className="h-5 w-5" />
                  Start Contributing
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </Link>
            </div>
          </section>

          <section className="bg-card rounded-lg border p-8">
            <div className="flex items-center gap-3 mb-6">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-blue-900 text-white">
                <Book className="h-6 w-6" />
              </div>
              <div>
                <h2 className="text-2xl font-bold">How Does It Work?</h2>
                <p className="text-sm text-muted-foreground">Behind the scenes</p>
              </div>
            </div>
            
            <p className="text-muted-foreground mb-6 leading-relaxed">
              SwiftShelf uses a completely automated CI/CD pipeline to validate and process every contribution. Probably not the best way to do it, but it's a fun project to learn about CI/CD workflows and GitHub Actions.
            </p>

            <p className="text-muted-foreground mb-6 leading-relaxed">
              From checking file formats, images and code to validating tags, everything is automated to ensure quality and consistency.
            </p>

            <div className="flex flex-col sm:flex-row gap-4">
              <a 
                href="https://code2tutorial.com/tutorial/21e17592-680d-4026-a032-fdbccec2863d/index.md"
                target="_blank"
                rel="noopener noreferrer"
                className="flex-1"
              >
                <Button variant="outline" className="w-full gap-2">
                  <Book className="h-4 w-4" />
                  How it works in detail
                  <ArrowRight className="h-4 w-4 ml-auto" />
                </Button>
              </a>
              
              <a 
                href="https://github.com/luizmellodev/SwiftShelf"
                target="_blank"
                rel="noopener noreferrer"
                className="flex-1"
              >
                <Button variant="outline" className="w-full gap-2">
                  <Github className="h-4 w-4" />
                  View project on GitHub
                  <ArrowRight className="h-4 w-4 ml-auto" />
                </Button>
              </a>
            </div>

            <div className="mt-6 p-4 bg-muted/30 rounded-lg">
              <h3 className="font-semibold mb-3">Tech Stack</h3>
              <div className="flex flex-wrap gap-2">
                {[
                  'Next.js', 
                  'React', 
                  'TypeScript', 
                  'Tailwind CSS', 
                  'GitHub Actions', 
                  'Vercel', 
                  'Swift', 
                  'SwiftUI', 
                  'YAML', 
                  'Node.js',
                  'Radix UI',
                  'Lucide Icons'
                ].map(tech => (
                  <span key={tech} className="px-3 py-1 bg-background rounded-full text-sm border">
                    {tech}
                  </span>
                ))}
              </div>
            </div>
          </section>

          <section className="bg-card rounded-lg border p-8 text-center">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-amber-600 text-white mb-6">
              <Coffee className="h-8 w-8" />
            </div>
            
            <h2 className="text-2xl font-bold mb-4">Support the Project</h2>
            <p className="text-muted-foreground mb-6 max-w-2xl mx-auto">
              SwiftShelf is open source and free to use. If you find it helpful and want to support 
              continued development, consider buying me a coffee!
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
              <a 
                href="https://buymeacoffee.com/luizmello.dev"
                target="_blank"
                rel="noopener noreferrer"
              >
                <Button className="bg-amber-500 hover:bg-amber-600 text-white gap-2">
                  <Coffee className="h-5 w-5" />
                  Buy me a coffee
                </Button>
              </a>
              
              <a 
                href="https://github.com/luizmellodev"
                target="_blank"
                rel="noopener noreferrer"
              >
                <Button variant="outline" className="gap-2">
                  <Github className="h-5 w-5" />
                  Follow on GitHub
                </Button>
              </a>
            </div>
          </section>

          <div className="text-center py-8">
            <p className="text-muted-foreground">
              Made with <Heart className="inline h-4 w-4 text-red-500" /> by{" "}
              <a 
                href="https://luizmello.dev" 
                target="_blank" 
                rel="noopener noreferrer"
                className="font-semibold text-foreground hover:underline"
              >
                @luizmellodev
              </a>
            </p>
          </div>
        </div>
      </div>
    </main>
  )
}

