#!/usr/bin/env node

/**
 * Valida vídeos de demonstração dos snippets
 * 
 * Requisitos:
 * - Formato: MP4 (H.264)
 * - Duração: máximo 5 segundos
 * - Tamanho: máximo 200KB
 * - Resolução: largura máxima 500px
 * - FPS: máximo 30fps
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

console.log('🎬 Validando vídeos de demonstração...\n');

// Verifica se ffprobe está disponível
function checkFFProbe() {
  try {
    execSync('ffprobe -version', { stdio: 'ignore' });
    return true;
  } catch {
    console.log('⚠️  FFprobe não encontrado - validações de vídeo serão limitadas');
    console.log('   Para validação completa, instale: brew install ffmpeg\n');
    return false;
  }
}

const hasFFProbe = checkFFProbe();

// Obtém metadados do vídeo usando ffprobe
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
    console.error(`   ❌ Erro ao ler metadados: ${error.message}`);
    return null;
  }
}

// Valida um vídeo específico
function validateVideo(videoPath, snippetName) {
  console.log(`📹 Validando: ${snippetName}/demo.mp4`);
  
  const errors = [];
  const warnings = [];
  
  // 1. Verifica se o arquivo existe
  if (!fs.existsSync(videoPath)) {
    errors.push('Arquivo não encontrado');
    return { errors, warnings };
  }
  
  // 2. Verifica tamanho do arquivo
  const stats = fs.statSync(videoPath);
  const sizeKB = stats.size / 1024;
  
  if (sizeKB > MAX_FILE_SIZE_KB) {
    errors.push(`Tamanho muito grande: ${sizeKB.toFixed(1)}KB (máximo: ${MAX_FILE_SIZE_KB}KB)`);
  } else {
    console.log(`   ✅ Tamanho: ${sizeKB.toFixed(1)}KB`);
  }
  
  // 3. Verifica extensão
  if (path.extname(videoPath).toLowerCase() !== '.mp4') {
    errors.push('Formato inválido - use .mp4');
  }
  
  // 4. Valida metadados com ffprobe (se disponível)
  if (hasFFProbe) {
    const metadata = getVideoMetadata(videoPath);
    
    if (metadata) {
      // Duração
      const duration = parseFloat(metadata.format.duration);
      if (duration > MAX_DURATION_SECONDS) {
        errors.push(`Duração muito longa: ${duration.toFixed(1)}s (máximo: ${MAX_DURATION_SECONDS}s)`);
      } else {
        console.log(`   ✅ Duração: ${duration.toFixed(1)}s`);
      }
      
      // Stream de vídeo
      const videoStream = metadata.streams.find(s => s.codec_type === 'video');
      
      if (videoStream) {
        // Codec
        if (videoStream.codec_name !== 'h264') {
          warnings.push(`Codec não otimizado: ${videoStream.codec_name} (recomendado: h264)`);
        } else {
          console.log(`   ✅ Codec: H.264`);
        }
        
        // Resolução
        const width = videoStream.width;
        if (width > MAX_WIDTH_PX) {
          warnings.push(`Largura muito grande: ${width}px (recomendado: máximo ${MAX_WIDTH_PX}px)`);
        } else {
          console.log(`   ✅ Resolução: ${width}x${videoStream.height}`);
        }
        
        // FPS
        const fpsMatch = videoStream.r_frame_rate.match(/(\d+)\/(\d+)/);
        if (fpsMatch) {
          const fps = parseInt(fpsMatch[1]) / parseInt(fpsMatch[2]);
          if (fps > MAX_FPS) {
            warnings.push(`FPS muito alto: ${fps.toFixed(0)} (recomendado: máximo ${MAX_FPS})`);
          } else {
            console.log(`   ✅ FPS: ${fps.toFixed(0)}`);
          }
        }
      }
      
      // Verifica se tem áudio (não deveria ter)
      const audioStream = metadata.streams.find(s => s.codec_type === 'audio');
      if (audioStream) {
        warnings.push('Vídeo contém áudio (não necessário - aumenta tamanho do arquivo)');
      }
    }
  }
  
  return { errors, warnings };
}

// Processa todos os snippets
const snippetsDir = path.join(__dirname, '..', 'snippets');

if (!fs.existsSync(snippetsDir)) {
  console.error('❌ Diretório snippets/ não encontrado');
  process.exit(1);
}

const folders = fs.readdirSync(snippetsDir);

for (const folder of folders) {
  const folderPath = path.join(snippetsDir, folder);
  
  if (!fs.statSync(folderPath).isDirectory()) continue;
  
  const demoMp4Path = path.join(folderPath, 'demo.mp4');
  const videoMovPath = path.join(folderPath, 'video.mov');
  const videoMp4Path = path.join(folderPath, 'video.mp4');
  
  // Verifica se existe algum vídeo (demo.mp4, video.mov, ou video.mp4)
  const hasAnyVideo = fs.existsSync(demoMp4Path) || fs.existsSync(videoMovPath) || fs.existsSync(videoMp4Path);
  
  // Se existe vídeo, valida
  if (hasAnyVideo) {
    videoCount++;
    
    // Se existe video.mov ou video.mp4 (não convertido ainda), avisa mas não falha
    if (fs.existsSync(videoMovPath) || fs.existsSync(videoMp4Path)) {
      console.log(`ℹ️  ${folder}: Vídeo original detectado - será convertido automaticamente pelo CI`);
      validVideoCount++;
      console.log('');
      continue;
    }
    
    // Valida demo.mp4 (já convertido)
    if (fs.existsSync(demoMp4Path)) {
      const { errors, warnings } = validateVideo(demoMp4Path, folder);
      
      if (errors.length > 0) {
        hasErrors = true;
        console.log(`   ❌ ERROS:`);
        errors.forEach(err => console.log(`      - ${err}`));
      }
      
      if (warnings.length > 0) {
        console.log(`   ⚠️  AVISOS:`);
        warnings.forEach(warn => console.log(`      - ${warn}`));
      }
      
      if (errors.length === 0) {
        validVideoCount++;
        if (warnings.length === 0) {
          console.log(`   ✅ Vídeo válido!`);
        }
      }
      
      console.log('');
    }
  }
}

// Resumo
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('📊 RESUMO DA VALIDAÇÃO');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log(`Total de vídeos: ${videoCount}`);
console.log(`Vídeos válidos: ${validVideoCount}`);
console.log(`Vídeos com erros: ${videoCount - validVideoCount}`);
console.log('');

if (videoCount === 0) {
  console.log('ℹ️  Nenhum vídeo encontrado (isso é OK - vídeos são opcionais)');
  console.log('');
  process.exit(0);
}

if (hasErrors) {
  console.log('❌ VALIDAÇÃO FALHOU');
  console.log('');
  console.log('💡 Para corrigir vídeos, use o script de conversão:');
  console.log('   ./scripts/convert-video.sh input.mov snippets/SEU-COMPONENTE/demo.mp4');
  console.log('');
  process.exit(1);
}

console.log('✅ TODOS OS VÍDEOS SÃO VÁLIDOS!');
console.log('');
process.exit(0);
