#!/bin/bash

# Script to automatically convert non-optimized videos
# Searches for video.mov or video.mp4 in each snippet and converts to optimized demo.mp4
# Used in CI/CD to process videos automatically

set -e

SNIPPETS_DIR="snippets"
CONVERTED_COUNT=0
SKIPPED_COUNT=0
ERROR_COUNT=0

echo "🎬 Searching for videos to convert..."
echo ""

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ FFmpeg not found!"
    echo "   Install with: brew install ffmpeg (macOS) or apt-get install ffmpeg (Linux)"
    exit 1
fi

# Search for snippet folders
for folder in "$SNIPPETS_DIR"/*; do
    if [ ! -d "$folder" ]; then
        continue
    fi
    
    SNIPPET_NAME=$(basename "$folder")
    VIDEO_MOV="$folder/video.mov"
    VIDEO_MP4="$folder/video.mp4"
    DEMO_MP4="$folder/demo.mp4"
    META_YML="$folder/meta.yml"
    
    # Check if optimized demo.mp4 already exists
    if [ -f "$DEMO_MP4" ]; then
        # Check if it's optimized (size < 250KB)
        SIZE_KB=$(du -k "$DEMO_MP4" | cut -f1)
        if [ $SIZE_KB -lt 250 ]; then
            echo "⏭️  $SNIPPET_NAME: demo.mp4 already optimized (${SIZE_KB}KB)"
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
            continue
        else
            echo "🔄 $SNIPPET_NAME: demo.mp4 exists but not optimized (${SIZE_KB}KB) - reconverting..."
        fi
    fi
    
    # Search for video.mov or video.mp4
    INPUT_VIDEO=""
    if [ -f "$VIDEO_MOV" ]; then
        INPUT_VIDEO="$VIDEO_MOV"
    elif [ -f "$VIDEO_MP4" ]; then
        INPUT_VIDEO="$VIDEO_MP4"
    else
        continue
    fi
    
    echo "📹 Converting: $SNIPPET_NAME"
    echo "   Input: $(basename "$INPUT_VIDEO")"
    
    # Show original size
    ORIGINAL_SIZE_KB=$(du -k "$INPUT_VIDEO" | cut -f1)
    echo "   Original size: ${ORIGINAL_SIZE_KB}KB"
    
    # Convert video
    if ffmpeg -i "$INPUT_VIDEO" \
        -vf "scale=400:-1,fps=30" \
        -c:v libx264 \
        -crf 28 \
        -preset slow \
        -movflags +faststart \
        -an \
        -t 5 \
        "$DEMO_MP4" \
        -y \
        -loglevel error; then
        
        # Show final size
        FINAL_SIZE_KB=$(du -k "$DEMO_MP4" | cut -f1)
        echo "   ✅ Converted: ${FINAL_SIZE_KB}KB"
        
        # Remove original file
        rm "$INPUT_VIDEO"
        echo "   🗑️  Removed: $(basename "$INPUT_VIDEO")"
        
        CONVERTED_COUNT=$((CONVERTED_COUNT + 1))
        echo ""
    else
        echo "   ❌ Conversion error"
        ERROR_COUNT=$((ERROR_COUNT + 1))
        echo ""
    fi
done

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 CONVERSION SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Videos converted: $CONVERTED_COUNT"
echo "Videos already optimized: $SKIPPED_COUNT"
echo "Errors: $ERROR_COUNT"
echo ""

if [ $CONVERTED_COUNT -gt 0 ]; then
    echo "✅ Conversion complete!"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Original videos have been removed"
    echo "   2. Optimized demo.mp4 files created"
    echo "   3. Commit the changes!"
    echo ""
fi

if [ $ERROR_COUNT -gt 0 ]; then
    echo "⚠️  Some videos failed to convert"
    exit 1
fi

exit 0
