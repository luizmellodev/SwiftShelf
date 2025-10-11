"use client"

import { Github, FileText, Code, Image, CheckCircle, ArrowDown } from "lucide-react"
import { Button } from "@/components/ui/button"

export default function ContributePage() {
  const scrollToExamples = () => {
    document.getElementById('examples-section')?.scrollIntoView({ behavior: 'smooth' })
  }

  const scrollToTags = () => {
    document.getElementById('tags-section')?.scrollIntoView({ behavior: 'smooth' })
  }

  return (
    <main className="min-h-screen bg-background">
      <div className="container mx-auto px-4 py-12 max-w-4xl">
        <header className="mb-12 text-center">
          <h1 className="mb-4 text-balance text-5xl font-bold tracking-tight md:text-7xl">
            <span className="bg-gradient-to-r from-emerald-400 via-cyan-400 to-blue-500 bg-clip-text text-transparent">
              Contribute
            </span>
          </h1>
          <p className="text-lg text-muted-foreground">
            Help us grow the SwiftUI snippet collection
          </p>
        </header>

        <div className="space-y-8">
          <section className="bg-card rounded-lg border p-6">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              <Github className="h-6 w-6" />
              Quick Start
            </h2>
            <div className="space-y-4">
              <div className="flex items-start gap-3">
                <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-bold">1</div>
                <div>
                  <p className="font-medium">Fork this repository</p>
                  <p className="text-sm text-muted-foreground">Create your own copy of the project</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-bold">2</div>
                <div>
                  <p className="font-medium">Create your snippet folder</p>
                  <p className="text-sm text-muted-foreground">Add a new folder in <code className="bg-muted px-2 py-1 rounded">/snippets/</code> with format <code className="bg-muted px-2 py-1 rounded">component-name.username</code></p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-bold">3</div>
                <div>
                  <p className="font-medium">Add your files</p>
                  <p className="text-sm text-muted-foreground">Include meta.yml, snippet.swift, and screenshot.png</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-bold">4</div>
                <div>
                  <p className="font-medium">Submit a Pull Request</p>
                  <p className="text-sm text-muted-foreground">We'll review and merge your contribution</p>
                </div>
              </div>
            </div>
          </section>

          <section className="bg-card rounded-lg border p-6">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              <FileText className="h-6 w-6" />
              File Structure
            </h2>
            <div className="bg-muted rounded-lg p-4 font-mono text-sm">
              <div>snippets/</div>
              <div className="ml-4">component-name.username/</div>
              <div className="ml-8">meta.yml          # Metadata about your snippet. Check below</div>
              <div className="ml-8">snippet.swift     # Your SwiftUI code</div>
              <div className="ml-8">screenshot.png    # Screenshot (9:16 aspect ratio)</div>
            </div>
            <div className="mt-4 p-4 bg-muted/50 rounded-lg border">
              <h3 className="font-semibold mb-2">Folder Naming Rules:</h3>
              <div className="mb-3 p-3 bg-blue-50 dark:bg-blue-950/20 rounded border border-blue-200 dark:border-blue-800">
                <p className="text-sm text-blue-800 dark:text-blue-200">
                  <strong>Format:</strong> <code>component-name.username</code><br/>
                  <strong>Note:</strong> The dot (.) separates the component name from the username, not a hyphen.
                </p>
              </div>
              <ul className="text-sm text-muted-foreground space-y-1">
                <li>• Use kebab-case for component names and usernames</li>
                <li>• No spaces or special characters</li>
                <li>• Must match github-username in meta.yml</li>
              </ul>
            </div>
          </section>

          <section className="bg-card rounded-lg border p-6">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              <Code className="h-6 w-6" />
              meta.yml File
            </h2>
            <div className="bg-muted rounded-lg p-4">
              <pre className="text-sm">{`title: Your Snippet Title
author: Your Name
github-username: yourusername
tags:
  - tag1
  - tag2
  - tag3
description: A brief description of what your snippet does`}</pre>
            </div>
            <div className="mt-4 space-y-4">
              <div>
                <h3 className="font-semibold mb-2">Required Fields:</h3>
                <ul className="space-y-1 text-sm text-muted-foreground">
                  <li>• <strong>title</strong>: Short, descriptive name for your snippet</li>
                  <li>• <strong>author</strong>: Your display name (can be your real name or GitHub username)</li>
                  <li>• <strong>github-username</strong>: Your GitHub username (must match folder name)</li>
                  <li>• <strong>tags</strong>: Array of relevant tags (max 3, must use approved tags)</li>
                  <li>• <strong>description</strong>: One sentence explaining what the snippet does</li>
                </ul>
              </div>
              
              <div className="p-4 bg-blue-50 dark:bg-blue-950/20 rounded-lg border border-blue-200 dark:border-blue-800">
                <h4 className="font-semibold text-blue-900 dark:text-blue-100 mb-2">🏷️ Taglines & Tags</h4>
                <p className="text-sm text-blue-800 dark:text-blue-200 mb-3">
                  Tags help users discover your snippet. Use exactly 3 tags from our approved list.
                </p>
                
                <div className="mb-4">
                  <h5 className="font-medium text-blue-900 dark:text-blue-100 text-xs mb-2">Popular Tags</h5>
                  <div className="flex flex-wrap gap-1">
                    {['button', 'card', 'animation', 'ui', 'form', 'layout', 'loading', 'ios', 'modal', 'navigation', 'theme', 'gradient'].map(tag => (
                      <span key={tag} className="px-2 py-1 bg-blue-100 dark:bg-blue-900/30 rounded text-xs font-mono">
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>
                
                <div className="flex gap-2">
                  <Button 
                    onClick={scrollToTags}
                    variant="outline" 
                    size="sm" 
                    className="text-blue-700 dark:text-blue-300 border-blue-300 dark:border-blue-700 hover:bg-blue-100 dark:hover:bg-blue-900/30"
                  >
                    <span className="text-xs">🏷️</span>
                    <span className="ml-1">View All Tags</span>
                  </Button>
                  
                  <Button 
                    onClick={scrollToExamples}
                    variant="outline" 
                    size="sm" 
                    className="text-blue-700 dark:text-blue-300 border-blue-300 dark:border-blue-700 hover:bg-blue-100 dark:hover:bg-blue-900/30"
                  >
                    <ArrowDown className="h-4 w-4 mr-2" />
                    See Examples Below
                  </Button>
                </div>
              </div>
            </div>
          </section>

          <section className="bg-card rounded-lg border p-6">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              <Image className="h-6 w-6" />
              Screenshot Requirements
            </h2>
            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <h3 className="font-semibold mb-2">Technical Specs</h3>
                <ul className="space-y-1 text-sm text-muted-foreground">
                  <li>• Aspect ratio: 9:16!</li>
                  <li>• Format: PNG only! Other formats will be rejected</li>
                  <li>• Size: Under 500KB!! Larger files will be rejected</li>
                  <li>• Resolution: 800-2000px width, 1000-3000px height</li>
                </ul>
              </div>
              <div>
                <h3 className="font-semibold mb-2">Content Guidelines</h3>
                <ul className="space-y-1 text-sm text-muted-foreground">
                  <li>• Show your component in action</li>
                  <li>• Use realistic content</li>
                  <li>• Avoid placeholder text</li>
                  <li>• Make it visually appealing</li>
                </ul>
              </div>
            </div>
            <div className="mt-4 p-4 bg-green-50 dark:bg-green-950/20 rounded-lg border border-green-200 dark:border-green-800">
              <h4 className="font-semibold text-green-900 dark:text-green-100 mb-2">🔍 Automatic Validation</h4>
              <p className="text-sm text-green-800 dark:text-green-200">
                Your screenshot will be automatically validated for format, size, aspect ratio, and resolution. 
                Invalid images will be rejected with helpful error messages.
              </p>
            </div>
          </section>

          <section className="bg-card rounded-lg border p-6">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              <CheckCircle className="h-6 w-6" />
              Guidelines
            </h2>
            <div className="space-y-3">
              <div className="flex items-start gap-3">
                <CheckCircle className="h-5 w-5 text-green-500 mt-0.5" />
                <div>
                  <p className="font-medium">Keep snippets simple and focused</p>
                  <p className="text-sm text-muted-foreground">One component/feature per snippet</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <CheckCircle className="h-5 w-5 text-green-500 mt-0.5" />
                <div>
                  <p className="font-medium">Use clear, descriptive names</p>
                  <p className="text-sm text-muted-foreground">Make it easy to understand what your snippet does</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <CheckCircle className="h-5 w-5 text-green-500 mt-0.5" />
                <div>
                  <p className="font-medium">Add relevant tags</p>
                  <p className="text-sm text-muted-foreground">Help others discover your snippet</p>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <CheckCircle className="h-5 w-5 text-green-500 mt-0.5" />
                <div>
                  <p className="font-medium">Test your snippet</p>
                  <p className="text-sm text-muted-foreground">Make sure it works before submitting</p>
                </div>
              </div>
            </div>
          </section>

          <section id="tags-section" className="bg-card rounded-lg border p-6">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              <span className="text-lg">🏷️</span>
              Allowed Tags
            </h2>
            <p className="text-muted-foreground mb-6">
              Choose exactly 3 tags from our comprehensive list of 150+ approved tags:
            </p>
            
            <div className="space-y-6">
              <div>
                <h3 className="font-semibold mb-3 text-green-700 dark:text-green-400">UI Components</h3>
                <div className="flex flex-wrap gap-2">
                  {['button', 'card', 'input', 'text', 'image', 'icon', 'badge', 'chip', 'avatar', 'list', 'grid', 'stack', 'spacer', 'divider', 'separator'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-green-100 dark:bg-green-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-blue-700 dark:text-blue-400">Layout & Navigation</h3>
                <div className="flex flex-wrap gap-2">
                  {['layout', 'container', 'section', 'modal', 'sheet', 'popover', 'tooltip', 'overlay', 'navigation', 'tab', 'menu', 'sidebar', 'header', 'footer', 'breadcrumb'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-blue-100 dark:bg-blue-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-purple-700 dark:text-purple-400">Forms</h3>
                <div className="flex flex-wrap gap-2">
                  {['form', 'field', 'picker', 'selector', 'toggle', 'switch', 'slider', 'stepper', 'checkbox', 'radio'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-purple-100 dark:bg-purple-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-orange-700 dark:text-orange-400">Data Display</h3>
                <div className="flex flex-wrap gap-2">
                  {['table', 'chart', 'graph', 'timeline', 'calendar', 'progress', 'meter', 'stat', 'metric'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-orange-100 dark:bg-orange-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-red-700 dark:text-red-400">Feedback</h3>
                <div className="flex flex-wrap gap-2">
                  {['alert', 'notification', 'toast', 'loading', 'spinner', 'skeleton', 'empty', 'error', 'success', 'warning'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-red-100 dark:bg-red-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-pink-700 dark:text-pink-400">Media</h3>
                <div className="flex flex-wrap gap-2">
                  {['video', 'audio', 'player', 'gallery', 'carousel'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-pink-100 dark:bg-pink-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-cyan-700 dark:text-cyan-400">Animation</h3>
                <div className="flex flex-wrap gap-2">
                  {['animation', 'transition', 'motion', 'gesture', 'interaction'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-cyan-100 dark:bg-cyan-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-indigo-700 dark:text-indigo-400">Theming</h3>
                <div className="flex flex-wrap gap-2">
                  {['theme', 'color', 'gradient', 'shadow', 'border', 'radius'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-indigo-100 dark:bg-indigo-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-gray-700 dark:text-gray-400">Platform</h3>
                <div className="flex flex-wrap gap-2">
                  {['ios', 'macos', 'watchos', 'tvos'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-gray-100 dark:bg-gray-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-teal-700 dark:text-teal-400">Category</h3>
                <div className="flex flex-wrap gap-2">
                  {['ui', 'component', 'screen', 'view', 'widget', 'element'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-teal-100 dark:bg-teal-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-amber-700 dark:text-amber-400">Style</h3>
                <div className="flex flex-wrap gap-2">
                  {['minimal', 'modern', 'classic', 'elegant', 'bold', 'subtle'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-amber-100 dark:bg-amber-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-emerald-700 dark:text-emerald-400">Function</h3>
                <div className="flex flex-wrap gap-2">
                  {['auth', 'login', 'signup', 'profile', 'settings', 'search', 'filter', 'sort', 'action', 'control'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-emerald-100 dark:bg-emerald-900/30 rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            <div className="mt-6 p-4 bg-blue-50 dark:bg-blue-950/20 rounded-lg border border-blue-200 dark:border-blue-800">
              <h4 className="font-semibold text-blue-900 dark:text-blue-100 mb-2">💡 Tag Selection Tips</h4>
              <ul className="text-sm text-blue-800 dark:text-blue-200 space-y-1">
                <li>• Choose exactly 3 tags that best describe your snippet</li>
                <li>• Mix different categories (e.g., one UI tag + one animation tag + one platform tag)</li>
                <li>• Use specific tags over generic ones when possible</li>
                <li>• Consider how users would search for your component</li>
              </ul>
            </div>
          </section>

          <section id="examples-section" className="bg-card rounded-lg border p-6">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              <span className="text-lg">📋</span>
              Examples
            </h2>
            <p className="text-muted-foreground mb-6">
              Here are 3 complete examples of how your meta.yml should look:
            </p>
            
            <div className="space-y-6">
              <div className="bg-muted rounded-lg p-4">
                <h3 className="font-semibold mb-2 text-green-700 dark:text-green-400">
                  Example 1: Animated Button
                </h3>
                <div className="bg-black rounded p-3 font-mono text-sm text-green-400 overflow-x-auto">
                  <pre>{`title: Animated Button
author: John Doe
github-username: john-doe
tags:
  - button
  - animation
  - ui
description: A beautiful animated button with spring animation and haptic feedback`}</pre>
                </div>
                <p className="text-xs text-muted-foreground mt-2">
                  Folder: <code>animated-button.john-doe/</code>
                </p>
              </div>

              <div className="bg-muted rounded-lg p-4">
                <h3 className="font-semibold mb-2 text-blue-700 dark:text-blue-400">
                  Example 2: Gradient Card
                </h3>
                <div className="bg-black rounded p-3 font-mono text-sm text-blue-400 overflow-x-auto">
                  <pre>{`title: Gradient Card
author: Jane Smith
github-username: jane-smith
tags:
  - card
  - gradient
  - layout
description: A modern card component with gradient background and glassmorphism effect`}</pre>
                </div>
                <p className="text-xs text-muted-foreground mt-2">
                  Folder: <code>gradient-card.jane-smith/</code>
                </p>
              </div>

              <div className="bg-muted rounded-lg p-4">
                <h3 className="font-semibold mb-2 text-purple-700 dark:text-purple-400">
                  Example 3: Loading Spinner
                </h3>
                <div className="bg-black rounded p-3 font-mono text-sm text-purple-400 overflow-x-auto">
                  <pre>{`title: Loading Spinner
author: Mike Johnson
github-username: mike-johnson
tags:
  - loading
  - animation
  - ui
description: Smooth rotating loading spinner with customizable colors`}</pre>
                </div>
                <p className="text-xs text-muted-foreground mt-2">
                  Folder: <code>loading-spinner.mike-johnson/</code>
                </p>
              </div>
            </div>

            <div className="mt-6 p-4 bg-green-50 dark:bg-green-950/20 rounded-lg border border-green-200 dark:border-green-800">
              <h4 className="font-semibold text-green-900 dark:text-green-100 mb-2">💡 Key Points</h4>
              <ul className="text-sm text-green-800 dark:text-green-200 space-y-1">
                <li>• All fields are required</li>
                <li>• Use exactly 3 tags (no more, no less)</li>
                <li>• Tags must be from the approved list</li>
                <li>• github-username must match your folder name</li>
                <li>• Description should be one clear sentence</li>
              </ul>
            </div>
          </section>

          <section className="text-center py-8">
            <h2 className="text-2xl font-bold mb-4">Ready to contribute?</h2>
            <p className="text-muted-foreground mb-6">
              Join our community and help others discover amazing SwiftUI components
            </p>
            <div className="flex gap-4 justify-center">
              <Button 
                size="lg" 
                className="bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-600 hover:to-cyan-600"
                onClick={() => window.open('https://github.com/luizmellodev/SwiftShelf', '_blank')}
              >
                <Github className="h-5 w-5 mr-2" />
                Contribute
              </Button>
            </div>
          </section>
        </div>
      </div>
    </main>
  )
}
