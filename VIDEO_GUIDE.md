# 🎬 Guia de Vídeos para Componentes

Este guia explica como adicionar vídeos animados aos seus componentes SwiftUI no SwiftShelf.

## 📋 Visão Geral

- **Na Library**: Mostra screenshot estático, vídeo aparece no **hover**
- **Na Página de Detalhes**: Mostra vídeo automaticamente em loop
- **Tamanho**: ~50-150KB por vídeo (otimizado)
- **Formato**: MP4 (H.264)
- **Duração**: 5 segundos (loop automático)

## 🚀 Como Adicionar Vídeo a um Componente

### Método 1: Deixe o CI Fazer Tudo (Recomendado!) 🤖

**Super simples - apenas 3 passos:**

#### 1. Grave o Vídeo no Simulador iOS

No Xcode Simulator:
- `⌘ + R` para gravar a tela
- Interaja com o componente (máximo 5 segundos)
- Clique no botão de stop
- O vídeo será salvo em `~/Desktop` como `.mov`

#### 2. Adicione ao Snippet

```bash
# Copie o vídeo para a pasta do snippet
cp ~/Desktop/recording.mov snippets/shimmer-button.luizmellodev/video.mov
```

#### 3. Commit e Push

```bash
git add .
git commit -m "Add video demo for shimmer button"
git push
```

**O CI automaticamente:**
- ✅ Detecta o vídeo (sem precisar de `has-video` no meta.yml!)
- ✅ Converte `video.mov` → `demo.mp4` (otimizado)
- ✅ Remove o arquivo original
- ✅ Faz commit do vídeo otimizado no seu PR
- ✅ Valida tudo

**Resultado**: Você não precisa se preocupar com otimização! 🎉

---

### Método 2: Conversão Manual (Opcional)

Se preferir converter localmente antes de fazer push:

```bash
# Sintaxe
./scripts/convert-video.sh input.mov output.mp4

# Exemplo
./scripts/convert-video.sh ~/Desktop/recording.mov snippets/shimmer-button.luizmellodev/demo.mp4
```

O script automaticamente:
- ✅ Reduz para 400px de largura
- ✅ Converte para 30fps
- ✅ Otimiza qualidade (CRF 28)
- ✅ Remove áudio
- ✅ Limita a 5 segundos
- ✅ Adiciona faststart para streaming

**Resultado**: Arquivo ~50-150KB (vs ~5-10MB do original!)

## 📁 Estrutura de Arquivos

**Antes do CI (você adiciona):**
```
snippets/
└── shimmer-button.luizmellodev/
    ├── meta.yml
    ├── snippet.swift
    ├── screenshot.png
    └── video.mov         # ⬅️ Arquivo do simulador
```

**Depois do CI (automático):**
```
snippets/
└── shimmer-button.luizmellodev/
    ├── meta.yml
    ├── snippet.swift
    ├── screenshot.png    # ⬅️ Mostrado inicialmente
    └── demo.mp4          # ⬅️ Otimizado! (video.mov foi removido)
```

## 🎯 Comportamento

### Na Library (`/library`)
- Mostra `screenshot.png` por padrão
- No **hover**: troca para `demo.mp4` (autoplay, loop, muted)
- Sem hover: volta para screenshot

### Na Página de Detalhes (`/snippet/[id]`)
- Se `has-video: true`: mostra vídeo automaticamente
- Se `has-video: false`: mostra screenshot com zoom

## 💡 Dicas

### Grave Animações Curtas
- 3-5 segundos é ideal
- Foque na interação principal
- Evite tempos de espera longos

### Otimize o Tamanho
- Use o script fornecido (já otimizado!)
- Se precisar customizar:
  ```bash
  ffmpeg -i input.mov \
    -vf "scale=400:-1,fps=30" \
    -c:v libx264 \
    -crf 28 \
    -preset slow \
    -movflags +faststart \
    -an \
    -t 5 \
    output.mp4
  ```

### Teste Localmente
```bash
npm run dev
# Acesse http://localhost:3000/library
# Teste o hover nos cards
```

## 📊 Custos (Vercel Free Tier)

Com vídeos otimizados:
- **100KB por vídeo** × 50 componentes = 5MB
- **1000 visualizações/mês** × 5MB = 5GB bandwidth
- **Limite Vercel Free**: 100GB/mês
- **Conclusão**: ✅ Muito espaço sobrando!

## 🐛 Troubleshooting

### Vídeo não aparece no site
1. Verifique se `has-video: true` está no `meta.yml`
2. Confirme que `demo.mp4` existe na pasta do snippet
3. Rode `npm run build` novamente
4. Verifique se o arquivo foi copiado para `public/snippets/[id]/demo.mp4`

### Vídeo muito grande
- Use o script fornecido (já otimizado)
- Reduza a duração: `-t 3` (3 segundos)
- Aumente o CRF: `-crf 32` (menor qualidade, menor tamanho)

### FFmpeg não instalado
```bash
brew install ffmpeg
```

## 🎨 Exemplo Completo (Método Automático)

```bash
# 1. Grave no simulador (⌘+R, salva em ~/Desktop/recording.mov)

# 2. Copie para o snippet
cp ~/Desktop/recording.mov snippets/shimmer-button.luizmellodev/video.mov

# 3. Commit e push
git add .
git commit -m "Add video demo for shimmer button"
git push

# 4. O CI detecta e converte automaticamente!
# 5. Aguarde deploy no Vercel (~2min)
# 6. Acesse o site e teste o hover! 🎉
```

## 🤖 O Que o CI Faz Automaticamente

Quando você faz push de um PR com `video.mov` ou `video.mp4`:

1. **Detecta** o vídeo automaticamente (sem precisar de flag no meta.yml!)
2. **Converte** para `demo.mp4` otimizado:
   - 400px de largura
   - 30fps
   - ~50-150KB
   - Sem áudio
   - Máximo 5 segundos
3. **Remove** o arquivo original (`video.mov` ou `video.mp4`)
4. **Faz commit** das mudanças no seu PR
5. **Valida** o vídeo otimizado
6. **Aprova** o PR se tudo estiver OK

**Você não precisa fazer nada além de adicionar o vídeo original!** 🎉

## 🏷️ Componentes Community

Para componentes de terceiros, adicione também `source-url`:

```yaml
title: "Morphing Tab Bar"
description: "Custom tab bar that morphs between states"
author: "Kavsoft"
github-username: "kavsoft"
source-url: "https://kavsoft.dev/morphing-tab-bar"  # ⬅️ Link original
has-video: true
tags:
  - animation
  - navigation
  - community  # ⬅️ Tag especial
```

---

**Pronto!** Agora você pode adicionar vídeos animados a todos os componentes! 🚀
