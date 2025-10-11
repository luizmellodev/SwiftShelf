"use client"

import { useState, useRef, useEffect } from "react"
import { ChevronDown, ChevronUp, ChevronLeft, ChevronRight, FileCode, FileText } from "lucide-react"
import { CopyButton } from "@/components/copy-button"
import { parseSwiftCode, getFilenameFromSection, shouldCollapseCode, getCodePreview, type CodeSection } from "@/lib/swift-parser"

interface CodeViewerProps {
  code: string
  lineThreshold?: number
  previewLines?: number
}

export function CodeViewer({ code, lineThreshold = 30, previewLines = 20 }: CodeViewerProps) {
  const sections = parseSwiftCode(code)
  const [activeSection, setActiveSection] = useState(0)
  const [isExpanded, setIsExpanded] = useState(false)
  const [canScrollLeft, setCanScrollLeft] = useState(false)
  const [canScrollRight, setCanScrollRight] = useState(false)
  const [showFullFile, setShowFullFile] = useState(false)
  const scrollContainerRef = useRef<HTMLDivElement>(null)
  
  const currentSection = sections[activeSection]
  const isCollapsible = shouldCollapseCode(currentSection.code, lineThreshold)
  const displayCode = showFullFile 
    ? code 
    : (!isExpanded && isCollapsible 
      ? getCodePreview(currentSection.code, previewLines) 
      : currentSection.code)
  
  const isSimpleView = sections.length === 1 && sections[0].name === 'Code'
  const hasMultipleSections = sections.length > 1
  
  const checkScrollPosition = () => {
    if (scrollContainerRef.current) {
      const { scrollLeft, scrollWidth, clientWidth } = scrollContainerRef.current
      setCanScrollLeft(scrollLeft > 0)
      setCanScrollRight(scrollLeft < scrollWidth - clientWidth - 5)
    }
  }
  
  useEffect(() => {
    checkScrollPosition()
    const container = scrollContainerRef.current
    if (container) {
      container.addEventListener('scroll', checkScrollPosition)
      window.addEventListener('resize', checkScrollPosition)
      return () => {
        container.removeEventListener('scroll', checkScrollPosition)
        window.removeEventListener('resize', checkScrollPosition)
      }
    }
  }, [sections])
  
  const scroll = (direction: 'left' | 'right') => {
    if (scrollContainerRef.current) {
      const scrollAmount = 200
      scrollContainerRef.current.scrollBy({
        left: direction === 'left' ? -scrollAmount : scrollAmount,
        behavior: 'smooth'
      })
    }
  }
  
  return (
    <div>
      <div className="mb-3 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <h2 className="text-base font-semibold sm:text-lg lg:text-xl">SwiftUI Code</h2>
        <div className="flex items-center gap-2">
          {hasMultipleSections && (
            <button
              onClick={() => {
                setShowFullFile(!showFullFile)
                if (showFullFile) {
                  setIsExpanded(false)
                }
              }}
              className={`flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-medium transition-colors ${
                showFullFile
                  ? 'bg-primary text-primary-foreground'
                  : 'bg-secondary text-secondary-foreground hover:bg-secondary/80'
              }`}
            >
              <FileText className="h-3.5 w-3.5" />
              <span className="hidden sm:inline">{showFullFile ? 'View sections' : 'View full file'}</span>
              <span className="sm:hidden">{showFullFile ? 'Sections' : 'Full'}</span>
            </button>
          )}
          <CopyButton code={showFullFile ? code : currentSection.code} />
        </div>
      </div>
      
      {!isSimpleView && hasMultipleSections && !showFullFile && (
        <div className="mb-3 relative">
          {canScrollLeft && (
            <button
              onClick={() => scroll('left')}
              className="absolute left-0 top-0 bottom-0 z-10 w-8 bg-gradient-to-r from-background to-transparent flex items-center justify-start pl-1"
              aria-label="Scroll left"
            >
              <ChevronLeft className="h-4 w-4 text-muted-foreground" />
            </button>
          )}
          
          {canScrollRight && (
            <button
              onClick={() => scroll('right')}
              className="absolute right-0 top-0 bottom-0 z-10 w-8 bg-gradient-to-l from-background to-transparent flex items-center justify-end pr-1"
              aria-label="Scroll right"
            >
              <ChevronRight className="h-4 w-4 text-muted-foreground" />
            </button>
          )}
          
          <div 
            ref={scrollContainerRef}
            className="overflow-x-auto scrollbar-hide"
            style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
          >
            <div className="flex gap-1 border-b min-w-max">
              {sections.map((section, index) => {
                const filename = getFilenameFromSection(section.name, index)
                return (
                  <button
                    key={index}
                    onClick={() => {
                      setActiveSection(index)
                      setIsExpanded(false) // Reset expansion when switching tabs
                    }}
                    className={`flex items-center gap-2 px-3 py-2 text-sm font-medium transition-colors border-b-2 whitespace-nowrap ${
                      activeSection === index
                        ? 'border-primary text-foreground bg-muted/30'
                        : 'border-transparent text-muted-foreground hover:text-foreground hover:bg-muted/20'
                    }`}
                  >
                    <FileCode className="h-3.5 w-3.5" />
                    <span className="hidden sm:inline">{filename}</span>
                    <span className="sm:hidden">{section.name}</span>
                  </button>
                )
              })}
            </div>
          </div>
          
          {sections.length > 2 && (
            <div className="mt-1 text-xs text-muted-foreground flex items-center gap-1">
              <FileCode className="h-3 w-3" />
              <span>{sections.length} files • Scroll to see all →</span>
            </div>
          )}
        </div>
      )}
      
      <div className="relative rounded-lg border bg-muted/50">
        <div className="overflow-x-auto">
          <pre className="p-3 sm:p-4">
            <code className="text-xs leading-relaxed sm:text-sm whitespace-pre-wrap break-words">
              {displayCode}
            </code>
          </pre>
        </div>
        
        {!showFullFile && isCollapsible && (
          <div className="border-t bg-background/50 p-2">
            <button
              onClick={() => setIsExpanded(!isExpanded)}
              className="flex w-full items-center justify-center gap-2 rounded px-4 py-2 text-sm font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
            >
              {isExpanded ? (
                <>
                  <ChevronUp className="h-4 w-4" />
                  <span>Show less</span>
                </>
              ) : (
                <>
                  <ChevronDown className="h-4 w-4" />
                  <span>Show full code ({currentSection.code.split('\n').length} lines)</span>
                </>
              )}
            </button>
          </div>
        )}
        
        {showFullFile && (
          <div className="border-t bg-background/50 p-2">
            <div className="flex items-center justify-center gap-2 px-4 py-2 text-xs text-muted-foreground">
              <FileText className="h-3.5 w-3.5" />
              <span>Viewing complete file ({code.split('\n').length} lines)</span>
            </div>
          </div>
        )}
      </div>
      
      {!isSimpleView && hasMultipleSections && !showFullFile && (
        <div className="mt-2 text-xs text-muted-foreground flex items-center gap-2">
          <span>Viewing: {getFilenameFromSection(currentSection.name, activeSection)}</span>
          <span className="text-muted-foreground/60">•</span>
          <span>{activeSection + 1} of {sections.length}</span>
        </div>
      )}
    </div>
  )
}

