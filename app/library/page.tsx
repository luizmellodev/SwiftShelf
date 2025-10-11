import { LibraryClient } from "./library-client"
import { loadSnippets } from "@/lib/snippets-loader"

export default async function LibraryPage() {
  const snippets = await loadSnippets()

  return <LibraryClient snippets={snippets} />
}
