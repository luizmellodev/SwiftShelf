#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { execSync } = require('child_process');
const { ALLOWED_TAGS, isAllowedTag, getSuggestedTags } = require('../lib/allowed-tags.js');

function validateImage(imagePath) {
  try {
    try {
      execSync('identify -version', { stdio: 'ignore' });
    } catch (error) {
      console.log(`⚠️  ImageMagick not available, skipping detailed image validation`);
      return { isValid: true, warnings: ['ImageMagick not available for detailed validation'] };
    }

    const identifyOutput = execSync(`identify "${imagePath}"`, { encoding: 'utf8' });
    const parts = identifyOutput.trim().split(' ');
    
    if (parts.length < 3) {
      return { isValid: false, error: 'Could not parse image information' };
    }

    const dimensions = parts[2].split('x');
    const width = parseInt(dimensions[0]);
    const height = parseInt(dimensions[1]);
    const format = parts[1].toLowerCase();
    
    const warnings = [];
    const errors = [];

    if (format !== 'png') {
      errors.push(`Invalid format: ${format} (must be PNG)`);
    }

    const aspectRatio = width / height;
    const targetRatio = 9 / 16;
    const tolerance = 0.1;
    
    if (Math.abs(aspectRatio - targetRatio) > tolerance) {
      const currentRatio = `${width}:${height}`;
      const targetRatioStr = `9:16`;
      warnings.push(`Aspect ratio ${currentRatio} is not ideal (target: ${targetRatioStr})`);
    }

    const minWidth = 800;
    const maxWidth = 2000;
    const minHeight = 1000;
    const maxHeight = 3000;
    
    if (width < minWidth || width > maxWidth) {
      warnings.push(`Width ${width}px is not ideal (recommended: 800-2000px)`);
    }
    
    if (height < minHeight || height > maxHeight) {
      warnings.push(`Height ${height}px is not ideal (recommended: 1000-3000px)`);
    }

    const stats = fs.statSync(imagePath);
    const sizeKB = Math.round(stats.size / 1024);
    
    if (stats.size > 512000) {
      errors.push(`File size ${sizeKB}KB exceeds limit (max 500KB)`);
    }

    return {
      isValid: errors.length === 0,
      errors,
      warnings,
      dimensions: { width, height },
      format,
      sizeKB
    };

  } catch (error) {
    return {
      isValid: false,
      error: `Image validation failed: ${error.message}`,
      warnings: []
    };
  }
}

function validateSnippets() {
  const snippetsDir = path.join(__dirname, '..', 'snippets');
  
  if (!fs.existsSync(snippetsDir)) {
    console.log('❌ Snippets directory not found');
    process.exit(1);
  }
  
  const snippetDirs = fs.readdirSync(snippetsDir)
    .filter(item => fs.statSync(path.join(snippetsDir, item)).isDirectory());
  
  if (snippetDirs.length === 0) {
    console.log('📁 No snippets found');
    return;
  }
  
  console.log(`🔍 Validating ${snippetDirs.length} snippets...\n`);
  
  let allValid = true;
  
  for (const snippetDir of snippetDirs) {
    const snippetPath = path.join(snippetsDir, snippetDir);
    const isValid = validateSnippet(snippetPath, snippetDir);
    if (!isValid) {
      allValid = false;
    }
  }
  
  if (allValid) {
    console.log('\n🎉 All snippets are valid!');
    process.exit(0);
  } else {
    console.log('\n❌ Some snippets have validation errors');
    process.exit(1);
  }
}

function validateSnippet(snippetPath, snippetDir) {
  console.log(`📁 Validating ${snippetDir}...`);
  
  let isValid = true;
  
  if (!/^[a-z0-9-]+\.[a-z0-9-]+$/.test(snippetDir)) {
    console.log(`❌ Invalid folder name: ${snippetDir}`);
    console.log(`   Expected format: component-name.username`);
    console.log(`   Use kebab-case for both component names and usernames`);
    isValid = false;
  }
  
  const username = snippetDir.split('.')[1];
  
  const requiredFiles = ['meta.yml', 'snippet.swift', 'screenshot.png'];
  for (const file of requiredFiles) {
    const filePath = path.join(snippetPath, file);
    if (!fs.existsSync(filePath)) {
      console.log(`❌ Missing required file: ${file}`);
      isValid = false;
    }
  }
  
  if (!isValid) {
    return false;
  }
  
  try {
    const metaPath = path.join(snippetPath, 'meta.yml');
    const metaContent = fs.readFileSync(metaPath, 'utf8');
    const meta = yaml.load(metaContent);
    
    const requiredFields = ['title', 'author', 'github-username', 'tags', 'description'];
    for (const field of requiredFields) {
      if (!meta[field]) {
        console.log(`❌ Missing required field '${field}' in meta.yml`);
        isValid = false;
      }
    }
    
    if (meta['github-username'] && meta['github-username'] !== username) {
      console.log(`❌ github-username '${meta['github-username']}' in meta.yml doesn't match folder username '${username}'`);
      isValid = false;
    }
    
    if (meta.tags && !Array.isArray(meta.tags)) {
      console.log(`❌ 'tags' must be an array in meta.yml`);
      isValid = false;
    }
    
    if (meta.tags && meta.tags.length > 3) {
      console.log(`❌ Too many tags: ${meta.tags.length} (max 3 allowed)`);
      console.log(`   Current tags: ${meta.tags.join(', ')}`);
      isValid = false;
    }
    
    if (meta.tags && Array.isArray(meta.tags)) {
      const invalidTags = meta.tags.filter(tag => !isAllowedTag(tag));
      if (invalidTags.length > 0) {
        console.log(`❌ Invalid tags found: ${invalidTags.join(', ')}`);
        console.log(`   Please use existing tags from our approved list.`);
        console.log(`   Available tags: ${ALLOWED_TAGS.slice(0, 20).join(', ')}... (and ${ALLOWED_TAGS.length - 20} more)`);
        
        invalidTags.forEach(invalidTag => {
          const suggestions = getSuggestedTags(invalidTag);
          if (suggestions.length > 0) {
            console.log(`   💡 Suggestions for "${invalidTag}": ${suggestions.join(', ')}`);
          }
        });
        
        isValid = false;
      }
    }
    
  } catch (error) {
    console.log(`❌ Invalid YAML syntax in meta.yml: ${error.message}`);
    isValid = false;
  }
  
  try {
    const swiftPath = path.join(snippetPath, 'snippet.swift');
    const swiftContent = fs.readFileSync(swiftPath, 'utf8');
    
    if (!swiftContent.includes('import SwiftUI')) {
      console.log(`❌ Swift file must import SwiftUI`);
      isValid = false;
    }
    
    if (!swiftContent.includes('struct ') || !swiftContent.includes(': View')) {
      console.log(`❌ Swift file should define a View struct`);
      isValid = false;
    }
    
  } catch (error) {
    console.log(`❌ Error reading Swift file: ${error.message}`);
    isValid = false;
  }
  
  try {
    const screenshotPath = path.join(snippetPath, 'screenshot.png');
    const imageValidation = validateImage(screenshotPath);
    
    if (!imageValidation.isValid) {
      console.log(`❌ Screenshot validation failed:`);
      if (imageValidation.error) {
        console.log(`   ${imageValidation.error}`);
      }
      if (imageValidation.errors) {
        imageValidation.errors.forEach(error => {
          console.log(`   ❌ ${error}`);
        });
      }
      isValid = false;
    } else {
      if (imageValidation.dimensions && imageValidation.format && imageValidation.sizeKB) {
        const { dimensions, format, sizeKB } = imageValidation;
        console.log(`📸 Screenshot: ${dimensions.width}x${dimensions.height} ${format.toUpperCase()}, ${sizeKB}KB`);
      } else {
        console.log(`📸 Screenshot: Basic validation passed`);
      }
    }
    
    if (imageValidation.warnings && imageValidation.warnings.length > 0) {
      imageValidation.warnings.forEach(warning => {
        console.log(`⚠️  ${warning}`);
      });
    }
    
  } catch (error) {
    console.log(`❌ Error reading screenshot: ${error.message}`);
    isValid = false;
  }
  
  if (isValid) {
    console.log(`✅ ${snippetDir} validation passed`);
  }
  
  return isValid;
}

if (require.main === module) {
  validateSnippets();
}

module.exports = { validateSnippets, validateSnippet };
