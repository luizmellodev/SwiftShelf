import { getSnippets } from "./read-snippets"

export interface Snippet {
  id: string
  title: string
  author: string
  githubUsername: string
  tags: string[]
  description: string
  screenshot: string
  code: string
}

export async function loadSnippets(): Promise<Snippet[]> {
  try {
    const snippets = await getSnippets()
    
    if (snippets.length > 0) {
      console.log(`✅ Loaded ${snippets.length} snippets dynamically`)
      return snippets
    }
    
    console.warn("⚠️ No snippets found in snippets directory")
    return []
  } catch (error) {
    console.error("❌ Failed to load snippets:", error)
    throw error
  }
}
