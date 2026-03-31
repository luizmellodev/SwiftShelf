#!/usr/bin/env node

/**
 * Validates snippet demonstration videos
 * 
 * Requirements:
 * - Format: MP4 (H.264)
 * - Duration: maximum 5 seconds
 * - Size: maximum 200KB
 * - Resolution: maximum width 500px
 * - FPS: maximum 30fps
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const MAX_DURATION_SECONDS = 5;
const MAX_FILE_SIZE_KB = 200;
const MAX_WIDTH_PX = 500;
const MAX_FPS = 30;

let hasErrors = false;
let videoCount = 0;
let validVideoCount = 0;

console.log('🎬 Validating demonstration videos...\n');

// Check if ffprobe is available
function checkFFProbe() {
  try {
    execSync('ffprobe -version', { stdio: 'ignore' });
    return true;
  } catch {
    console.log('⚠️  FFprobe not found - video validation will be limited');
    console.log('   For full validation, install: brew install ffmpeg\n');
    return false;
  }
}

const hasFFProbe = checkFFProbe();

// Get video metadata using ffprobe
function getVideoMetadata(videoPath) {
  if (!hasFFProbe) {
    return null;
  }

  try {
    const output = execSync(
      `ffprobe -v quiet -print_format json -show_format -show_streams "${videoPath}"`,
      { encoding: 'utf-8' }
    );
    return JSON.parse(output);
  } catch (error) {
    console.error(`   ❌ Error reading metadata: ${error.message}`);
    return null;
  }
}

// Validate a specific video
function validateVideo(videoPath, snippetName) {
  console.log(`📹 Validating: ${snippetName}/demo.mp4`);
  
  const errors = [];
  const warnings = [];
  
  // 1. Check if file exists
  if (!fs.existsSync(videoPath)) {
    errors.push('File not found');
    return { errors, warnings };
  }
  
  // 2. Check file size
  const stats = fs.statSync(videoPath);
  const sizeKB = stats.size / 1024;
  
  if (sizeKB > MAX_FILE_SIZE_KB) {
    errors.push(`File too large: ${sizeKB.toFixed(1)}KB (maximum: ${MAX_FILE_SIZE_KB}KB)`);
  } else {
    console.log(`   ✅ Size: ${sizeKB.toFixed(1)}KB`);
  }
  
  // 3. Check extension
  if (path.extname(videoPath).toLowerCase() !== '.mp4') {
    errors.push('Invalid format - use .mp4');
  }
  
  // 4. Validate metadata with ffprobe (if available)
  if (hasFFProbe) {
    const metadata = getVideoMetadata(videoPath);
    
    if (metadata) {
      // Duration
      const duration = parseFloat(metadata.format.duration);
      if (duration > MAX_DURATION_SECONDS) {
        errors.push(`Duration too long: ${duration.toFixed(1)}s (maximum: ${MAX_DURATION_SECONDS}s)`);
      } else {
        console.log(`   ✅ Duration: ${duration.toFixed(1)}s`);
      }
      
      // Video stream
      const videoStream = metadata.streams.find(s => s.codec_type === 'video');
      
      if (videoStream) {
        // Codec
        if (videoStream.codec_name !== 'h264') {
          warnings.push(`Non-optimized codec: ${videoStream.codec_name} (recommended: h264)`);
        } else {
          console.log(`   ✅ Codec: H.264`);
        }
        
        // Resolution
        const width = videoStream.width;
        if (width > MAX_WIDTH_PX) {
          warnings.push(`Width too large: ${width}px (recommended: maximum ${MAX_WIDTH_PX}px)`);
        } else {
          console.log(`   ✅ Resolution: ${width}x${videoStream.height}`);
        }
        
        // FPS
        const fpsMatch = videoStream.r_frame_rate.match(/(\d+)\/(\d+)/);
        if (fpsMatch) {
          const fps = parseInt(fpsMatch[1]) / parseInt(fpsMatch[2]);
          if (fps > MAX_FPS) {
            warnings.push(`FPS too high: ${fps.toFixed(0)} (recommended: maximum ${MAX_FPS})`);
          } else {
            console.log(`   ✅ FPS: ${fps.toFixed(0)}`);
          }
        }
      }
      
      // Check if it has audio (shouldn't have)
      const audioStream = metadata.streams.find(s => s.codec_type === 'audio');
      if (audioStream) {
        warnings.push('Video contains audio (not needed - increases file size)');
      }
    }
  }
  
  return { errors, warnings };
}

// Process all snippets
const snippetsDir = path.join(__dirname, '..', 'snippets');

if (!fs.existsSync(snippetsDir)) {
  console.error('❌ snippets/ directory not found');
  process.exit(1);
}

const folders = fs.readdirSync(snippetsDir);

for (const folder of folders) {
  const folderPath = path.join(snippetsDir, folder);
  
  if (!fs.statSync(folderPath).isDirectory()) continue;
  
  const demoMp4Path = path.join(folderPath, 'demo.mp4');
  const videoMovPath = path.join(folderPath, 'video.mov');
  const videoMp4Path = path.join(folderPath, 'video.mp4');
  
  // Check if any video exists (demo.mp4, video.mov, or video.mp4)
  const hasAnyVideo = fs.existsSync(demoMp4Path) || fs.existsSync(videoMovPath) || fs.existsSync(videoMp4Path);
  
  // If video exists, validate
  if (hasAnyVideo) {
    videoCount++;
    
    // If video.mov or video.mp4 exists (not converted yet), warn but don't fail
    if (fs.existsSync(videoMovPath) || fs.existsSync(videoMp4Path)) {
      console.log(`ℹ️  ${folder}: Original video detected - will be automatically converted by CI`);
      validVideoCount++;
      console.log('');
      continue;
    }
    
    // Validate demo.mp4 (already converted)
    if (fs.existsSync(demoMp4Path)) {
      const { errors, warnings } = validateVideo(demoMp4Path, folder);
      
      if (errors.length > 0) {
        hasErrors = true;
        console.log(`   ❌ ERRORS:`);
        errors.forEach(err => console.log(`      - ${err}`));
      }
      
      if (warnings.length > 0) {
        console.log(`   ⚠️  WARNINGS:`);
        warnings.forEach(warn => console.log(`      - ${warn}`));
      }
      
      if (errors.length === 0) {
        validVideoCount++;
        if (warnings.length === 0) {
          console.log(`   ✅ Valid video!`);
        }
      }
      
      console.log('');
    }
  }
}

// Summary
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('📊 VALIDATION SUMMARY');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log(`Total videos: ${videoCount}`);
console.log(`Valid videos: ${validVideoCount}`);
console.log(`Videos with errors: ${videoCount - validVideoCount}`);
console.log('');

if (videoCount === 0) {
  console.log('ℹ️  No videos found (this is OK - videos are optional)');
  console.log('');
  process.exit(0);
}

if (hasErrors) {
  console.log('❌ VALIDATION FAILED');
  console.log('');
  console.log('💡 To fix videos, use the conversion script:');
  console.log('   ./scripts/convert-video.sh input.mov snippets/YOUR-COMPONENT/demo.mp4');
  console.log('');
  process.exit(1);
}

console.log('✅ ALL VIDEOS ARE VALID!');
console.log('');
process.exit(0);
