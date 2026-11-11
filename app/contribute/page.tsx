"use client"

import { Github, FileText, Code, Image, CheckCircle, ArrowDown } from "lucide-react"
import { Button } from "@/components/ui/button"
import { SiteHeader } from "@/components/site/site-header"
import { SiteFooter } from "@/components/site/site-footer"

export default function ContributePage() {
  const scrollToExamples = () => {
    document.getElementById('examples-section')?.scrollIntoView({ behavior: 'smooth' })
  }

  const scrollToTags = () => {
    document.getElementById('tags-section')?.scrollIntoView({ behavior: 'smooth' })
  }

  return (
    <>
    <SiteHeader />
    <main className="min-h-screen bg-background">
      <div className="container mx-auto px-4 pt-10 pb-16 max-w-4xl md:pt-14">
        <header className="mb-10 md:mb-14">
          <h1 className="text-4xl font-semibold tracking-[-0.03em] md:text-5xl">Contribute</h1>
          <p className="mt-2 text-lg text-muted-foreground">Help us grow the SwiftUI snippet collection</p>
        </header>

        <div className="space-y-8">
          <section className="bg-card rounded-2xl border border-white/[0.08] p-6">
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
                  <p className="font-medium">Add your 3 files</p>
                  <p className="text-sm text-muted-foreground">
                    Create a folder <code className="bg-muted px-2 py-1 rounded">component-name.username</code> in <code className="bg-muted px-2 py-1 rounded">/snippets/</code> with:
                  </p>
                  <div className="mt-2 space-y-1">
                    <div className="flex items-center gap-2 text-sm">
                      <span className="w-1.5 h-1.5 bg-swift rounded-full"></span>
                      <code className="bg-muted px-2 py-1 rounded text-xs">snippet.swift</code> - Your SwiftUI code
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <span className="w-1.5 h-1.5 bg-swift rounded-full"></span>
                      <code className="bg-muted px-2 py-1 rounded text-xs">meta.yml</code> - Component description
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <span className="w-1.5 h-1.5 bg-swift rounded-full"></span>
                      <code className="bg-muted px-2 py-1 rounded text-xs">screenshot.png</code> - Component preview
                    </div>
                  </div>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <div className="flex h-6 w-6 items-center justify-center rounded-full bg-primary text-primary-foreground text-sm font-bold">3</div>
                <div>
                  <p className="font-medium">Submit a Pull Request</p>
                  <p className="text-sm text-muted-foreground">That's it! Our CI handles the rest automatically</p>
                </div>
              </div>
            </div>
            
            {/* Quick Action Button */}
            <div className="mt-6 pt-6 border-t">
              <div className="text-center">
                <button 
                  onClick={() => window.open('https://github.com/luizmellodev/SwiftShelf/fork', '_blank')}
                  className="group inline-flex items-center gap-2 px-6 py-3 rounded-full bg-swift hover:bg-swift/90 text-swift-foreground font-medium transition-colors duration-200"
                >
                  <Github className="h-5 w-5" />
                  Start Contributing Now
                </button>
                <p className="text-sm text-muted-foreground mt-2">
                  Ready to get started? Click above to fork the repository
                </p>
              </div>
            </div>
          </section>

          {/* Details Section Header */}
          <div className="text-center py-6">
            <div className="inline-flex items-center gap-2 px-6 py-3 bg-muted rounded-full text-sm font-medium text-muted-foreground">
              <span>Need more details?</span>
              <ArrowDown className="h-4 w-4" />
              <span>All the rules and guidelines are below</span>
            </div>
          </div>

          <section className="bg-card rounded-2xl border border-white/[0.08] p-6">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              <FileText className="h-6 w-6" />
              File Structure
            </h2>
            <div className="bg-muted rounded-lg p-4 font-mono text-sm">
              <div>snippets/</div>
              <div className="ml-4">component-name.username/</div>
              <div className="ml-8">meta.yml          # Metadata about your snippet. Check below</div>
              <div className="ml-8">snippet.swift     # Your SwiftUI code (ALL CODE GOES HERE!)</div>
              <div className="ml-8">screenshot.png    # Screenshot (9:16 aspect ratio)</div>
            </div>
            
            <div className="mt-4 p-4 bg-white/[0.03] rounded-xl border border-white/10 border-l-2 border-l-swift">
              <h3 className="font-semibold mb-2 text-foreground">All code in one file</h3>
              <p className="text-sm text-muted-foreground mb-3">
                Put <strong>all your code</strong> in <code className="bg-white/10 px-1 rounded font-mono">snippet.swift</code> - don't create separate files!
              </p>
              <ul className="text-sm text-muted-foreground space-y-1">
                <li>• All structs, enums, classes, extensions go in <code className="bg-white/10 px-1 rounded font-mono">snippet.swift</code></li>
                <li>• Our system automatically separates them for display</li>
                <li>• Use <code className="bg-white/10 px-1 rounded font-mono">// MARK: - Name</code> comments to organize sections</li>
                <li>• The parser detects structs, enums, classes, extensions, and #Preview automatically</li>
              </ul>
            </div>
            
            <div className="mt-4 p-4 bg-muted/50 rounded-lg border">
              <h3 className="font-semibold mb-2">Folder Naming Rules:</h3>
              <div className="mb-3 p-3 bg-gray-50 dark:bg-gray-950/20 rounded border border-gray-200 dark:border-gray-800">
                <p className="text-sm text-gray-800 dark:text-gray-200">
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

          <section className="bg-card rounded-2xl border border-white/[0.08] p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-2xl font-bold flex items-center gap-2">
                <Code className="h-6 w-6" />
                meta.yml File
              </h2>
              <Button 
                onClick={scrollToExamples}
                variant="outline" 
                size="sm" 
                className="text-swift border-swift/30 hover:bg-swift/10 cursor-pointer transition-all duration-200 hover:scale-105"
              >
                <ArrowDown className="h-4 w-4 mr-2" />
                See Examples Below
              </Button>
            </div>
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
              
              <div className="p-4 bg-gray-50 dark:bg-gray-950/20 rounded-lg border border-gray-200 dark:border-gray-800">
                <h4 className="font-semibold text-gray-900 dark:text-gray-100 mb-2">Taglines & tags</h4>
                <p className="text-sm text-gray-800 dark:text-gray-200 mb-3">
                  Tags help users discover your snippet. Use exactly 3 tags from our approved list.
                </p>
                
                <div className="mb-4">
                  <h5 className="font-medium text-gray-900 dark:text-gray-100 text-xs mb-2">Popular Tags</h5>
                  <div className="flex flex-wrap gap-1">
                    {['button', 'card', 'animation', 'ui', 'form', 'layout', 'loading', 'ios', 'modal', 'navigation', 'theme', 'gradient'].map(tag => (
                      <span key={tag} className="px-2 py-1 bg-gray-100 dark:bg-gray-900/30 rounded text-xs font-mono">
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
                    className="text-swift border-swift/30 hover:bg-swift/10 cursor-pointer transition-all duration-200 hover:scale-105"
                  >
                    View all tags
                  </Button>
                </div>
              </div>
            </div>
          </section>

          <section className="bg-card rounded-2xl border border-white/[0.08] p-6">
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
              <div className="mt-4 p-4 bg-gray-50 dark:bg-gray-950/20 rounded-lg border border-gray-200 dark:border-gray-800">
                <h4 className="font-semibold text-gray-900 dark:text-gray-100 mb-2"> Taking Screenshots</h4>
                <p className="text-sm text-gray-800 dark:text-gray-200 mb-3">
                  Taking screenshots from the iOS Simulator is super easy!
                </p>
                <div className="space-y-2 text-sm text-gray-800 dark:text-gray-200">
                  <p><strong>Quick Steps:</strong></p>
                  <ul className="space-y-1 ml-4">
                    <li>• Open your component in the iOS Simulator</li>
                    <li>• Press <code className="bg-gray-100 dark:bg-gray-900/30 px-1 rounded font-semibold">Command + S</code> to save a screenshot</li>
                    <li>• Right-click the screenshot thumbnail that appears</li>
                    <li>• Select "Save to Desktop" (or your preferred location)</li>
                    <li>• Rename it to <code className="bg-gray-100 dark:bg-gray-900/30 px-1 rounded">screenshot.png</code></li>
                  </ul>
                </div>
                <p className="text-sm text-gray-800 dark:text-gray-200 mt-3">
                  Your screenshot will be automatically validated for format, size, aspect ratio, and resolution. 
                  Invalid images will be rejected with helpful error messages.
                </p>
              </div>
          </section>

          <section className="bg-card rounded-2xl border border-white/[0.08] p-6">
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
                  <p className="font-medium">All code in snippet.swift</p>
                  <p className="text-sm text-muted-foreground">Put all structs, enums, classes, and extensions in one file - we'll display them beautifully</p>
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

          <section id="tags-section" className="bg-card rounded-2xl border border-white/[0.08] p-6">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              Allowed Tags
            </h2>
            <p className="text-muted-foreground mb-6">
              Choose exactly 3 tags from our comprehensive list of 150+ approved tags:
            </p>
            
            <div className="space-y-6">
              <div>
                <h3 className="font-semibold mb-3 text-foreground">UI Components</h3>
                <div className="flex flex-wrap gap-2">
                  {['button', 'card', 'input', 'text', 'image', 'icon', 'badge', 'chip', 'avatar', 'list', 'grid', 'stack', 'spacer', 'divider', 'separator'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-white/[0.05] border border-white/[0.06] rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-foreground">Layout & Navigation</h3>
                <div className="flex flex-wrap gap-2">
                  {['layout', 'container', 'section', 'modal', 'sheet', 'popover', 'tooltip', 'overlay', 'navigation', 'tab', 'menu', 'sidebar', 'header', 'footer', 'breadcrumb'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-white/[0.05] border border-white/[0.06] rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-foreground">Forms</h3>
                <div className="flex flex-wrap gap-2">
                  {['form', 'field', 'picker', 'selector', 'toggle', 'switch', 'slider', 'stepper', 'checkbox', 'radio'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-white/[0.05] border border-white/[0.06] rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-foreground">Data Display</h3>
                <div className="flex flex-wrap gap-2">
                  {['table', 'chart', 'graph', 'timeline', 'calendar', 'progress', 'meter', 'stat', 'metric'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-white/[0.05] border border-white/[0.06] rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-foreground">Feedback</h3>
                <div className="flex flex-wrap gap-2">
                  {['alert', 'notification', 'toast', 'loading', 'spinner', 'skeleton', 'empty', 'error', 'success', 'warning'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-white/[0.05] border border-white/[0.06] rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-foreground">Media</h3>
                <div className="flex flex-wrap gap-2">
                  {['video', 'audio', 'player', 'gallery', 'carousel'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-white/[0.05] border border-white/[0.06] rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-foreground">Animation</h3>
                <div className="flex flex-wrap gap-2">
                  {['animation', 'transition', 'motion', 'gesture', 'interaction'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-white/[0.05] border border-white/[0.06] rounded text-xs font-mono">
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
                <h3 className="font-semibold mb-3 text-foreground">Category</h3>
                <div className="flex flex-wrap gap-2">
                  {['ui', 'component', 'screen', 'view', 'widget', 'element'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-white/[0.05] border border-white/[0.06] rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-foreground">Style</h3>
                <div className="flex flex-wrap gap-2">
                  {['minimal', 'modern', 'classic', 'elegant', 'bold', 'subtle'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-white/[0.05] border border-white/[0.06] rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="font-semibold mb-3 text-foreground">Function</h3>
                <div className="flex flex-wrap gap-2">
                  {['auth', 'login', 'signup', 'profile', 'settings', 'search', 'filter', 'sort', 'action', 'control'].map(tag => (
                    <span key={tag} className="px-2 py-1 bg-white/[0.05] border border-white/[0.06] rounded text-xs font-mono">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            <div className="mt-6 p-4 bg-gray-50 dark:bg-gray-950/20 rounded-lg border border-gray-200 dark:border-gray-800">
              <h4 className="font-semibold text-gray-900 dark:text-gray-100 mb-2">Tag selection tips</h4>
              <ul className="text-sm text-gray-800 dark:text-gray-200 space-y-1">
                <li>• Choose exactly 3 tags that best describe your snippet</li>
                <li>• Mix different categories (e.g., one UI tag + one animation tag + one platform tag)</li>
                <li>• Use specific tags over generic ones when possible</li>
                <li>• Consider how users would search for your component</li>
              </ul>
            </div>
          </section>

          <section id="examples-section" className="bg-card rounded-2xl border border-white/[0.08] p-6">
            <h2 className="text-2xl font-bold mb-4 flex items-center gap-2">
              <span className="text-lg">📋</span>
              Examples
            </h2>
            <p className="text-muted-foreground mb-6">
              Here are 3 complete examples of how your meta.yml should look:
            </p>
            
            <div className="space-y-6">
              <div className="bg-muted rounded-lg p-4">
                <h3 className="font-semibold mb-2 text-foreground">
                  Example 1: Animated Button
                </h3>
                <div className="bg-[#1f1f24] rounded-xl border border-white/[0.06] p-3 font-mono text-sm text-green-400 overflow-x-auto">
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
                <h3 className="font-semibold mb-2 text-foreground">
                  Example 2: Gradient Card
                </h3>
                <div className="bg-[#1f1f24] rounded-xl border border-white/[0.06] p-3 font-mono text-sm text-[#e5e5e7] overflow-x-auto">
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
                <h3 className="font-semibold mb-2 text-foreground">
                  Example 3: Loading Spinner
                </h3>
                <div className="bg-[#1f1f24] rounded-xl border border-white/[0.06] p-3 font-mono text-sm text-[#e5e5e7] overflow-x-auto">
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

            <div className="mt-6 p-4 bg-gray-50 dark:bg-gray-950/20 rounded-lg border border-gray-200 dark:border-gray-800">
              <h4 className="font-semibold text-gray-900 dark:text-gray-100 mb-2">Key points</h4>
              <ul className="text-sm text-gray-800 dark:text-gray-200 space-y-1">
                <li>• All fields are required</li>
                <li>• Use exactly 3 tags (no more, no less)</li>
                <li>• Tags must be from the approved list</li>
                <li>• github-username must match your folder name</li>
                <li>• Description should be one clear sentence</li>
              </ul>
            </div>  
          </section>

          <section className="bg-card rounded-2xl border border-white/[0.08] p-6">
            <div className="text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 rounded-full border border-white/10 bg-white/[0.04] text-swift mb-6">
                <span className="text-2xl">🌱</span>
              </div>
              <h4 className="text-2xl font-bold text-foreground mb-4">Thank you for helping us grow!</h4>
              <p className="text-lg text-muted-foreground mb-6">
                Your contribution helps build a stronger Swift community. Every snippet makes a difference!
              </p>
              
              <div className="bg-muted/50 rounded-lg p-4 mb-6">
                <p className="text-sm text-muted-foreground mb-3">
                  Created with ❤️ by <strong>@luizmellodev</strong>
                </p>
                <p className="text-sm text-muted-foreground mb-4">
                  If you find this project helpful, consider supporting it:
                </p>
                <button 
                  onClick={() => window.open('https://buymeacoffee.com/luizmello.dev', '_blank')}
                  className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-swift hover:bg-swift/90 text-swift-foreground font-medium transition-colors duration-200"
                >
                  <span>☕</span>
                  Buy me a coffee
                </button>
              </div>
              
              <p className="text-sm text-muted-foreground">
                Need help? Check the detailed guidelines above or open an issue on GitHub.
              </p>
            </div>
          </section>
        </div>
      </div>
    </main>
    <SiteFooter />
    </>
  )
}
