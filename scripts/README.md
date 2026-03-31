# 🛠️ SwiftShelf Scripts

This directory contains utility scripts for managing snippets and videos.

## 📜 Available Scripts

### 1. `validate-snippets.js`

Validates snippet structure and content.

**Usage:**
```bash
npm run validate:snippets
# or
node scripts/validate-snippets.js
```

**Validations:**
- ✅ Folder structure (`component-name.username`)
- ✅ `meta.yml` format (required fields)
- ✅ GitHub username
- ✅ Swift code (import SwiftUI, View struct)
- ✅ Screenshot (PNG, size, aspect ratio)
- ✅ Tags (only allowed tags, maximum 3)
- ✅ File integrity

### 2. `validate-videos.js`

Validates demonstration videos (optional).

**Usage:**
```bash
npm run validate:videos
# or
node scripts/validate-videos.js
```

**Validations:**
- ✅ Format: MP4 (H.264)
- ✅ Duration: maximum 5 seconds
- ✅ Size: maximum 200KB
- ✅ Resolution: maximum width 500px
- ✅ FPS: maximum 30fps
- ⚠️ Detects unnecessary audio

**Requirements:**
- FFmpeg installed: `brew install ffmpeg`
- If FFmpeg is not available, validations are limited

### 3. `convert-video.sh`

Converts iOS Simulator videos to optimized MP4.

**Usage:**
```bash
./scripts/convert-video.sh input.mov output.mp4

# Example
./scripts/convert-video.sh ~/Desktop/recording.mov snippets/shimmer-button.luizmellodev/demo.mp4
```

**What it does:**
- 📏 Reduces width to 400px (maintains aspect ratio)
- 🎞️ Converts to 30fps
- 🗜️ Optimizes quality (CRF 28)
- 🚫 Removes audio
- ⏱️ Limits to 5 seconds
- ⚡ Adds faststart for streaming

**Result:**
- File ~50-150KB (vs ~5-10MB original!)
- MP4 format (H.264)
- Ready to use on the website

### 4. `auto-convert-videos.sh` ⭐ NEW!

Automatically converts all non-optimized videos in CI.

**Usage:**
```bash
bash scripts/auto-convert-videos.sh
```

**What it does:**
- 🔍 Searches for `video.mov` or `video.mp4` in each snippet
- 🎬 Converts to optimized `demo.mp4`
- 🗑️ Removes original file
- ✅ Validates size and duration

**Executed automatically:**
- In CI/CD before validations
- Commits changes to PR

### 5. `copy-images.js`

Copies screenshots and videos to the `public/` directory.

**Usage:**
```bash
npm run copy-images
# or
node scripts/copy-images.js
```

**What it does:**
- 📸 Copies `screenshot.png` from each snippet
- 🎬 Copies `demo.mp4` (if exists)
- 📁 Creates structure in `public/snippets/`
- ✅ Validates file existence

**Executed automatically:**
- During `npm run build`
- Before deployment

## 🔄 Complete Workflow

### Method 1: Let CI Do Everything (Recommended!)

```bash
# 1. Record video in simulator (⌘ + R)

# 2. Copy to snippet
cp ~/Desktop/recording.mov snippets/your-component.username/video.mov

# 3. Commit and push
git add .
git commit -m "Add new component with video demo"
git push

# CI automatically:
# - Detects video (no meta.yml flag needed!)
# - Converts video.mov → demo.mp4 (optimized)
# - Removes video.mov
# - Commits to your PR
# - Validates everything
```

### Method 2: Local Conversion (Optional)

```bash
# 1. Record video in simulator (⌘ + R)

# 2. Convert locally
./scripts/convert-video.sh ~/Desktop/recording.mov snippets/your-component.username/demo.mp4

# 3. Validate locally
npm run validate

# 4. Commit and push
git add .
git commit -m "Add new component with video demo"
git push
```

## 🤖 CI/CD

Scripts are executed automatically in GitHub Actions:

### On Pull Requests:
1. 🎬 `auto-convert-videos.sh` - converts videos automatically
2. 💾 Commits optimized videos to PR
3. ✅ `validate-snippets.js` - validates structure
4. ✅ `validate-videos.js` - validates optimized videos
5. ❌ PR blocked if errors

### On Push to Main:
1. 🎬 Automatic video conversion
2. ✅ Validations
3. 📦 `copy-images.js` - copies assets
4. 🏗️ Next.js build
5. 🚀 Deploy to Vercel

## 📊 Limits and Requirements

### Screenshots (Required)
- Format: PNG
- Maximum size: 500KB
- Recommended aspect ratio: 9:16

### Videos (Optional)
- Format: MP4 (H.264)
- Maximum duration: 5 seconds
- Maximum size: 200KB
- Maximum width: 500px
- Maximum FPS: 30fps
- No audio

## 🐛 Troubleshooting

### "FFmpeg not found"
```bash
brew install ffmpeg
```

### "Video too large"
Use the conversion script - it optimizes automatically:
```bash
./scripts/convert-video.sh input.mov output.mp4
```

### "Duration too long"
Edit the video before converting, or adjust the `-t` parameter:
```bash
# Limit to 3 seconds
ffmpeg -i input.mov -t 3 output.mp4
```

### "Validation failed in CI"
1. Run `npm run validate` locally
2. Fix reported errors
3. Commit and push again

## 💡 Tips

### For smaller videos:
- Record only the main interaction (3-5s)
- Use the provided script (already optimized)
- Avoid unnecessary movements

### For better quality:
- Record in simulator's native resolution
- Use clean, contrasting background
- Show animation/interaction clearly

### For faster CI:
- Validate locally before pushing
- Use optimized videos
- Follow naming conventions

## 📚 Related Documentation

- [CONTRIBUTING.md](../CONTRIBUTING.md) - Complete contribution guide
- [.github/workflows/validate-and-deploy.yml](../.github/workflows/validate-and-deploy.yml) - CI/CD configuration

---

**Need help?** Open an issue on GitHub! 🚀
