#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

function generateSnippetsData() {
  const snippetsDir = path.join(__dirname, '..', 'snippets');
  const outputPath = path.join(__dirname, '..', 'lib', 'snippets-data.ts');
  
  if (!fs.existsSync(snippetsDir)) {
    console.log('❌ Snippets directory not found');
    process.exit(1);
  }
  
  const folders = fs.readdirSync(snippetsDir)
    .filter(item => fs.statSync(path.join(snippetsDir, item)).isDirectory());
  
  if (folders.length === 0) {
    console.log('📁 No snippets found');
    return;
  }
  
  console.log(`🔍 Found ${folders.length} snippets, generating snippets-data.ts...`);
  
  const snippets = [];
  
  for (const folder of folders) {
    const folderPath = path.join(snippetsDir, folder);
    const metaPath = path.join(folderPath, 'meta.yml');
    const snippetPath = path.join(folderPath, 'snippet.swift');
    const screenshotPath = path.join(folderPath, 'screenshot.png');
    
    if (!fs.existsSync(metaPath) || !fs.existsSync(snippetPath) || !fs.existsSync(screenshotPath)) {
      console.log(`⚠️ Skipping ${folder}: missing required files`);
      continue;
    }
    
    try {
      const metaContent = fs.readFileSync(metaPath, 'utf-8');
      const meta = yaml.load(metaContent);
      const code = fs.readFileSync(snippetPath, 'utf-8');
      
      const escapedCode = code
        .replace(/\\/g, '\\\\')
        .replace(/`/g, '\\`')
        .replace(/\$/g, '\\$');
      
      snippets.push({
        id: folder,
        title: meta.title,
        author: meta.author,
        githubUsername: meta['github-username'] || 'unknown',
        tags: meta.tags || [],
        description: meta.description,
        screenshot: `/snippets/${folder}/screenshot.png`,
        code: escapedCode
      });
      
      console.log(`✅ Processed ${folder}`);
    } catch (error) {
      console.log(`❌ Error processing ${folder}:`, error.message);
    }
  }
  
  const tsContent = `export interface Snippet {
  id: string
  title: string
  author: string
  githubUsername: string
  tags: string[]
  description: string
  screenshot: string
  code: string
}

export const snippets: Snippet[] = [
${snippets.map(snippet => `  {
    id: "${snippet.id}",
    title: "${snippet.title}",
    author: "${snippet.author}",
    githubUsername: "${snippet.githubUsername}",
    tags: [${snippet.tags.map(tag => `"${tag}"`).join(', ')}],
    description: "${snippet.description}",
    screenshot: "${snippet.screenshot}",
    code: \`${snippet.code}\`,
  }`).join(',\n')}
]
`;
  
  fs.writeFileSync(outputPath, tsContent);
  console.log(`🎉 Generated snippets-data.ts with ${snippets.length} snippets`);
}

if (require.main === module) {
  generateSnippetsData();
}

module.exports = { generateSnippetsData };
