#!/bin/bash

# Script to convert iOS Simulator videos to optimized MP4
# Usage: ./convert-video.sh input.mov output.mp4

set -e

if [ "$#" -ne 2 ]; then
    echo "❌ Usage: ./convert-video.sh input.mov output.mp4"
    echo ""
    echo "Example:"
    echo "  ./convert-video.sh ~/Desktop/recording.mov snippets/shimmer-button.luizmellodev/demo.mp4"
    exit 1
fi

INPUT="$1"
OUTPUT="$2"

if [ ! -f "$INPUT" ]; then
    echo "❌ File not found: $INPUT"
    exit 1
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ FFmpeg not found!"
    echo ""
    echo "Install with Homebrew:"
    echo "  brew install ffmpeg"
    exit 1
fi

echo "🎬 Converting video..."
echo "📁 Input:  $INPUT"
echo "📁 Output: $OUTPUT"
echo ""

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT")"

# Convert video
# - scale=400:-1: Reduce width to 400px (maintains aspect ratio)
# - fps=30: 30 frames per second (sufficient for animations)
# - crf=28: Quality (18=high, 28=good, 32=medium)
# - preset slow: Better compression (slower but smaller file)
# - movflags +faststart: Optimize for streaming (loads faster)
# - an: Remove audio (not needed)
# - t 5: Limit to 5 seconds (loop)

ffmpeg -i "$INPUT" \
  -vf "scale=400:-1,fps=30" \
  -c:v libx264 \
  -crf 28 \
  -preset slow \
  -movflags +faststart \
  -an \
  -t 5 \
  "$OUTPUT" \
  -y

# Show file sizes
INPUT_SIZE=$(du -h "$INPUT" | cut -f1)
OUTPUT_SIZE=$(du -h "$OUTPUT" | cut -f1)

echo ""
echo "✅ Conversion complete!"
echo "📊 Original size: $INPUT_SIZE"
echo "📊 Final size:    $OUTPUT_SIZE"
echo ""
echo "🎯 Next steps:"
echo "  1. Run 'npm run build' to copy the video"
echo "  2. Commit and push!"
