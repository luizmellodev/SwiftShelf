import { notFound } from "next/navigation"
import { snippets } from "@/lib/snippets-data"
import { SnippetDetailClient } from "./snippet-detail-client"

export function generateStaticParams() {
  return snippets.map((snippet) => ({
    id: snippet.id,
  }))
}

export default function SnippetDetailPage({ params }: { params: { id: string } }) {
  const snippet = snippets.find((s) => s.id === params.id)

  if (!snippet) {
    notFound()
  }

  return <SnippetDetailClient snippet={snippet} />
}
