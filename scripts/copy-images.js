#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function copyImages() {
  const snippetsDir = path.join(__dirname, '..', 'snippets');
  const publicDir = path.join(__dirname, '..', 'public');
  const publicSnippetsDir = path.join(publicDir, 'snippets');
  
  if (!fs.existsSync(snippetsDir)) {
    console.log('❌ Snippets directory not found');
    process.exit(1);
  }
  
  if (!fs.existsSync(publicSnippetsDir)) {
    fs.mkdirSync(publicSnippetsDir, { recursive: true });
    console.log('📁 Created public/snippets directory');
  }
  
  const folders = fs.readdirSync(snippetsDir)
    .filter(item => fs.statSync(path.join(snippetsDir, item)).isDirectory());
  
  if (folders.length === 0) {
    console.log('📁 No snippets found');
    return;
  }
  
  console.log(`🔍 Found ${folders.length} snippets, copying images...`);
  
  let copiedCount = 0;
  
  for (const folder of folders) {
    const folderPath = path.join(snippetsDir, folder);
    const screenshotPath = path.join(folderPath, 'screenshot.png');
    const demoVideoPath = path.join(folderPath, 'demo.mp4');
    const publicSnippetDir = path.join(publicSnippetsDir, folder);
    const publicScreenshotPath = path.join(publicSnippetDir, 'screenshot.png');
    const publicDemoVideoPath = path.join(publicSnippetDir, 'demo.mp4');
    
    if (!fs.existsSync(screenshotPath)) {
      console.log(`⚠️ Skipping ${folder}: no screenshot.png found`);
      continue;
    }
    
    try {
      if (!fs.existsSync(publicSnippetDir)) {
        fs.mkdirSync(publicSnippetDir, { recursive: true });
      }
      
      // Copy screenshot
      fs.copyFileSync(screenshotPath, publicScreenshotPath);
      console.log(`✅ Copied ${folder}/screenshot.png`);
      copiedCount++;
      
      // Copy video if exists
      if (fs.existsSync(demoVideoPath)) {
        fs.copyFileSync(demoVideoPath, publicDemoVideoPath);
        console.log(`🎬 Copied ${folder}/demo.mp4`);
      }
    } catch (error) {
      console.log(`❌ Error copying ${folder}:`, error.message);
    }
  }
  
  console.log(`🎉 Copied ${copiedCount} images to public/snippets/`);
}

if (require.main === module) {
  copyImages();
}

module.exports = { copyImages };
