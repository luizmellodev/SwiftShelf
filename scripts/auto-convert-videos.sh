#!/bin/bash

# Script para converter automaticamente vídeos não otimizados
# Procura por video.mov ou video.mp4 em cada snippet e converte para demo.mp4 otimizado
# Usado no CI/CD para processar vídeos automaticamente

set -e

SNIPPETS_DIR="snippets"
CONVERTED_COUNT=0
SKIPPED_COUNT=0
ERROR_COUNT=0

echo "🎬 Procurando vídeos para converter..."
echo ""

# Verifica se ffmpeg está instalado
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ FFmpeg não encontrado!"
    echo "   Instale com: brew install ffmpeg (macOS) ou apt-get install ffmpeg (Linux)"
    exit 1
fi

# Procura por pastas de snippets
for folder in "$SNIPPETS_DIR"/*; do
    if [ ! -d "$folder" ]; then
        continue
    fi
    
    SNIPPET_NAME=$(basename "$folder")
    VIDEO_MOV="$folder/video.mov"
    VIDEO_MP4="$folder/video.mp4"
    DEMO_MP4="$folder/demo.mp4"
    META_YML="$folder/meta.yml"
    
    # Verifica se já existe demo.mp4 otimizado
    if [ -f "$DEMO_MP4" ]; then
        # Verifica se é otimizado (tamanho < 250KB)
        SIZE_KB=$(du -k "$DEMO_MP4" | cut -f1)
        if [ $SIZE_KB -lt 250 ]; then
            echo "⏭️  $SNIPPET_NAME: demo.mp4 já otimizado (${SIZE_KB}KB)"
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
            continue
        else
            echo "🔄 $SNIPPET_NAME: demo.mp4 existe mas não está otimizado (${SIZE_KB}KB) - reconvertendo..."
        fi
    fi
    
    # Procura por video.mov ou video.mp4
    INPUT_VIDEO=""
    if [ -f "$VIDEO_MOV" ]; then
        INPUT_VIDEO="$VIDEO_MOV"
    elif [ -f "$VIDEO_MP4" ]; then
        INPUT_VIDEO="$VIDEO_MP4"
    else
        continue
    fi
    
    echo "📹 Convertendo: $SNIPPET_NAME"
    echo "   Input: $(basename "$INPUT_VIDEO")"
    
    # Mostra tamanho original
    ORIGINAL_SIZE_KB=$(du -k "$INPUT_VIDEO" | cut -f1)
    echo "   Tamanho original: ${ORIGINAL_SIZE_KB}KB"
    
    # Converte o vídeo
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
        
        # Mostra tamanho final
        FINAL_SIZE_KB=$(du -k "$DEMO_MP4" | cut -f1)
        echo "   ✅ Convertido: ${FINAL_SIZE_KB}KB"
        
        # Remove o arquivo original
        rm "$INPUT_VIDEO"
        echo "   🗑️  Removido: $(basename "$INPUT_VIDEO")"
        
        CONVERTED_COUNT=$((CONVERTED_COUNT + 1))
        echo ""
    else
        echo "   ❌ Erro ao converter"
        ERROR_COUNT=$((ERROR_COUNT + 1))
        echo ""
    fi
done

# Resumo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RESUMO DA CONVERSÃO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Vídeos convertidos: $CONVERTED_COUNT"
echo "Vídeos já otimizados: $SKIPPED_COUNT"
echo "Erros: $ERROR_COUNT"
echo ""

if [ $CONVERTED_COUNT -gt 0 ]; then
    echo "✅ Conversão concluída!"
    echo ""
    echo "💡 Próximos passos:"
    echo "   1. Os vídeos originais foram removidos"
    echo "   2. demo.mp4 otimizados foram criados"
    echo "   3. Commit as mudanças!"
    echo ""
fi

if [ $ERROR_COUNT -gt 0 ]; then
    echo "⚠️  Alguns vídeos falharam na conversão"
    exit 1
fi

exit 0
