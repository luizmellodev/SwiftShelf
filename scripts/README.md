# 🛠️ Scripts do SwiftShelf

Este diretório contém scripts utilitários para gerenciar snippets e vídeos.

## 📜 Scripts Disponíveis

### 1. `validate-snippets.js`

Valida a estrutura e conteúdo dos snippets.

**Uso:**
```bash
npm run validate:snippets
# ou
node scripts/validate-snippets.js
```

**Validações:**
- ✅ Estrutura de pastas (`component-name.username`)
- ✅ Formato do `meta.yml` (campos obrigatórios)
- ✅ Username do GitHub
- ✅ Código Swift (import SwiftUI, View struct)
- ✅ Screenshot (PNG, tamanho, aspect ratio)
- ✅ Tags (apenas tags permitidas, máximo 3)
- ✅ Integridade dos arquivos

### 2. `validate-videos.js`

Valida vídeos de demonstração (opcional).

**Uso:**
```bash
npm run validate:videos
# ou
node scripts/validate-videos.js
```

**Validações:**
- ✅ Formato: MP4 (H.264)
- ✅ Duração: máximo 5 segundos
- ✅ Tamanho: máximo 200KB
- ✅ Resolução: largura máxima 500px
- ✅ FPS: máximo 30fps
- ⚠️ Detecta áudio desnecessário

**Requisitos:**
- FFmpeg instalado: `brew install ffmpeg`
- Se FFmpeg não estiver disponível, validações são limitadas

### 3. `convert-video.sh`

Converte vídeos do simulador iOS para MP4 otimizado.

**Uso:**
```bash
./scripts/convert-video.sh input.mov output.mp4

# Exemplo
./scripts/convert-video.sh ~/Desktop/recording.mov snippets/shimmer-button.luizmellodev/demo.mp4
```

**O que faz:**
- 📏 Reduz largura para 400px (mantém aspect ratio)
- 🎞️ Converte para 30fps
- 🗜️ Otimiza qualidade (CRF 28)
- 🚫 Remove áudio
- ⏱️ Limita a 5 segundos
- ⚡ Adiciona faststart para streaming

**Resultado:**
- Arquivo ~50-150KB (vs ~5-10MB do original!)
- Formato MP4 (H.264)
- Pronto para uso no site

### 4. `auto-convert-videos.sh` ⭐ NOVO!

Converte automaticamente todos os vídeos não otimizados no CI.

**Uso:**
```bash
bash scripts/auto-convert-videos.sh
```

**O que faz:**
- 🔍 Procura por `video.mov` ou `video.mp4` em cada snippet
- 🎬 Converte para `demo.mp4` otimizado
- 🗑️ Remove o arquivo original
- ✅ Valida tamanho e duração

**Executado automaticamente:**
- No CI/CD antes das validações
- Faz commit das mudanças no PR

### 5. `copy-images.js`

Copia screenshots e vídeos para o diretório `public/`.

**Uso:**
```bash
npm run copy-images
# ou
node scripts/copy-images.js
```

**O que faz:**
- 📸 Copia `screenshot.png` de cada snippet
- 🎬 Copia `demo.mp4` (se existir)
- 📁 Cria estrutura em `public/snippets/`
- ✅ Valida existência dos arquivos

**Executado automaticamente:**
- Durante `npm run build`
- Antes do deploy

## 🔄 Workflow Completo

### Método 1: Deixe o CI Fazer Tudo (Recomendado!)

```bash
# 1. Grave o vídeo no simulador (⌘ + R)

# 2. Copie para o snippet
cp ~/Desktop/recording.mov snippets/seu-componente.username/video.mov

# 3. Commit e push
git add .
git commit -m "Add new component with video demo"
git push

# O CI automaticamente:
# - Detecta o vídeo (sem precisar de flag no meta.yml!)
# - Converte video.mov → demo.mp4 (otimizado)
# - Remove video.mov
# - Faz commit no seu PR
# - Valida tudo
```

### Método 2: Conversão Local (Opcional)

```bash
# 1. Grave o vídeo no simulador (⌘ + R)

# 2. Converta localmente
./scripts/convert-video.sh ~/Desktop/recording.mov snippets/seu-componente.username/demo.mp4

# 3. Valide localmente
npm run validate

# 4. Commit e push
git add .
git commit -m "Add new component with video demo"
git push
```

## 🤖 CI/CD

Os scripts são executados automaticamente no GitHub Actions:

### Em Pull Requests:
1. 🎬 `auto-convert-videos.sh` - converte vídeos automaticamente
2. 💾 Faz commit dos vídeos otimizados no PR
3. ✅ `validate-snippets.js` - valida estrutura
4. ✅ `validate-videos.js` - valida vídeos otimizados
5. ❌ PR bloqueado se houver erros

### No Push para Main:
1. 🎬 Conversão automática de vídeos
2. ✅ Validações
3. 📦 `copy-images.js` - copia assets
4. 🏗️ Build do Next.js
5. 🚀 Deploy para Vercel

## 📊 Limites e Requisitos

### Screenshots (Obrigatório)
- Formato: PNG
- Tamanho máximo: 500KB
- Aspect ratio recomendado: 9:16

### Vídeos (Opcional)
- Formato: MP4 (H.264)
- Duração máxima: 5 segundos
- Tamanho máximo: 200KB
- Largura máxima: 500px
- FPS máximo: 30fps
- Sem áudio

## 🐛 Troubleshooting

### "FFmpeg não encontrado"
```bash
brew install ffmpeg
```

### "Vídeo muito grande"
Use o script de conversão - ele já otimiza automaticamente:
```bash
./scripts/convert-video.sh input.mov output.mp4
```

### "Duração muito longa"
Edite o vídeo antes de converter, ou ajuste o parâmetro `-t`:
```bash
# Limita a 3 segundos
ffmpeg -i input.mov -t 3 output.mp4
```

### "Validação falhou no CI"
1. Rode `npm run validate` localmente
2. Corrija os erros reportados
3. Commit e push novamente

## 💡 Dicas

### Para vídeos menores:
- Grave apenas a interação principal (3-5s)
- Use o script fornecido (já otimizado)
- Evite movimentos desnecessários

### Para melhor qualidade:
- Grave em resolução nativa do simulador
- Use fundo limpo e contrastante
- Mostre a animação/interação claramente

### Para CI mais rápido:
- Valide localmente antes do push
- Use vídeos otimizados
- Siga as convenções de nomenclatura

## 📚 Documentação Relacionada

- [CONTRIBUTING.md](../CONTRIBUTING.md) - Guia completo de contribuição
- [VIDEO_GUIDE.md](../VIDEO_GUIDE.md) - Guia detalhado de vídeos
- [META_EXAMPLE.yml](../META_EXAMPLE.yml) - Exemplos de meta.yml

---

**Precisa de ajuda?** Abra uma issue no GitHub! 🚀
