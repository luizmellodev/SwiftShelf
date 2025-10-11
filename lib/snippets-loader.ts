import { getSnippets } from "./read-snippets"
import { snippets as fallbackSnippets } from "./snippets-data"

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
    const dynamicSnippets = await getSnippets()
    
    if (dynamicSnippets.length > 0) {
      console.log(`✅ Loaded ${dynamicSnippets.length} snippets dynamically`)
      return dynamicSnippets
    }
  } catch (error) {
    console.warn("⚠️ Failed to load snippets dynamically, using fallback:", error)
  }
  
  console.log(`📦 Using ${fallbackSnippets.length} static snippets`)
  return fallbackSnippets
}

export function getStaticSnippets(): Snippet[] {
  return fallbackSnippets
}

export async function getDynamicSnippets(): Promise<Snippet[]> {
  return await loadSnippets()
}
