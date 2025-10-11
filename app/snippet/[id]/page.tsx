import { notFound } from "next/navigation"
import { loadSnippets } from "@/lib/snippets-loader"
import { SnippetDetailClient } from "./snippet-detail-client"

export async function generateStaticParams() {
  const snippets = await loadSnippets()
  return snippets.map((snippet) => ({
    id: snippet.id,
  }))
}

export default async function SnippetDetailPage({ params }: { params: { id: string } }) {
  const snippets = await loadSnippets()
  const snippet = snippets.find((s) => s.id === params.id)

  if (!snippet) {
    notFound()
  }

  return <SnippetDetailClient snippet={snippet} />
}
