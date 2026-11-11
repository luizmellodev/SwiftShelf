import type { Metadata } from "next"
import { notFound } from "next/navigation"
import { loadSnippets } from "@/lib/snippets-loader"
import { SnippetDetailClient } from "./snippet-detail-client"

export async function generateStaticParams() {
  const snippets = await loadSnippets()
  return snippets.map((snippet) => ({
    id: snippet.id,
  }))
}

export async function generateMetadata({ params }: { params: { id: string } }): Promise<Metadata> {
  const snippets = await loadSnippets()
  const snippet = snippets.find((s) => s.id === params.id)
  if (!snippet) return {}
  return {
    title: `${snippet.title} · SwiftShelf`,
    description: snippet.description,
  }
}

export default async function SnippetDetailPage({ params }: { params: { id: string } }) {
  const snippets = await loadSnippets()
  const index = snippets.findIndex((s) => s.id === params.id)

  if (index === -1) {
    notFound()
  }

  const snippet = snippets[index]
  const neighbour = (offset: number) => {
    const s = snippets[(index + offset + snippets.length) % snippets.length]
    return { id: s.id, title: s.title }
  }

  return <SnippetDetailClient snippet={snippet} prev={neighbour(-1)} next={neighbour(1)} />
}
