#!/bin/bash

# Script para converter vídeos do simulador iOS para MP4 otimizado
# Uso: ./convert-video.sh input.mov output.mp4

set -e

if [ "$#" -ne 2 ]; then
    echo "❌ Uso: ./convert-video.sh input.mov output.mp4"
    echo ""
    echo "Exemplo:"
    echo "  ./convert-video.sh ~/Desktop/recording.mov snippets/shimmer-button.luizmellodev/demo.mp4"
    exit 1
fi

INPUT="$1"
OUTPUT="$2"

if [ ! -f "$INPUT" ]; then
    echo "❌ Arquivo não encontrado: $INPUT"
    exit 1
fi

# Verifica se ffmpeg está instalado
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ FFmpeg não encontrado!"
    echo ""
    echo "Instale com Homebrew:"
    echo "  brew install ffmpeg"
    exit 1
fi

echo "🎬 Convertendo vídeo..."
echo "📁 Input:  $INPUT"
echo "📁 Output: $OUTPUT"
echo ""

# Cria diretório de output se não existir
mkdir -p "$(dirname "$OUTPUT")"

# Converte o vídeo
# - scale=400:-1: Reduz largura para 400px (mantém aspect ratio)
# - fps=30: 30 frames por segundo (suficiente para animações)
# - crf=28: Qualidade (18=alta, 28=boa, 32=média)
# - preset slow: Compressão melhor (mais lento mas menor arquivo)
# - movflags +faststart: Otimiza para streaming (carrega mais rápido)
# - an: Remove áudio (não precisa)
# - t 5: Limita a 5 segundos (loop)

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

# Mostra tamanho do arquivo
INPUT_SIZE=$(du -h "$INPUT" | cut -f1)
OUTPUT_SIZE=$(du -h "$OUTPUT" | cut -f1)

echo ""
echo "✅ Conversão concluída!"
echo "📊 Tamanho original: $INPUT_SIZE"
echo "📊 Tamanho final:    $OUTPUT_SIZE"
echo ""
echo "🎯 Próximos passos:"
echo "  1. Adicione 'has-video: true' no meta.yml do componente"
echo "  2. Rode 'npm run build' para copiar o vídeo"
echo "  3. Commit e push!"
