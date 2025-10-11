import fs from "fs"
import path from "path"
import yaml from "js-yaml"

export interface Snippet {
  id: string
  title: string
  author: string
  description: string
  tags: string[]
  screenshotUrl: string
  code: string
}

export async function getSnippets(): Promise<Snippet[]> {
  const snippetsDir = path.join(process.cwd(), "snippets")

  try {
    if (!fs.existsSync(snippetsDir)) {
      console.warn("Snippets directory not found, using fallback data")
      return []
    }

    const folders = fs.readdirSync(snippetsDir)
    const snippets: Snippet[] = []

    for (const folder of folders) {
      const folderPath = path.join(snippetsDir, folder)

      if (!fs.statSync(folderPath).isDirectory()) continue

      const metaPath = path.join(folderPath, "meta.yml")
      const snippetPath = path.join(folderPath, "snippet.swift")
      const screenshotPath = path.join(folderPath, "screenshot.png")

      if (!fs.existsSync(metaPath) || !fs.existsSync(snippetPath) || !fs.existsSync(screenshotPath)) {
        console.warn(`Skipping ${folder}: missing required files`)
        continue
      }

      const metaContent = fs.readFileSync(metaPath, "utf-8")
      const meta = yaml.load(metaContent) as {
        title: string
        author: string
        description: string
        tags: string[]
      }

      const code = fs.readFileSync(snippetPath, "utf-8")

      snippets.push({
        id: folder,
        title: meta.title,
        author: meta.author,
        description: meta.description,
        tags: meta.tags || [],
        screenshotUrl: `/snippets/${folder}/screenshot.png`,
        code,
      })
    }

    return snippets
  } catch (error) {
    console.error("Error reading snippets:", error)
    return []
  }
}
