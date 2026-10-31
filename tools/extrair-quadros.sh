#!/usr/bin/env bash
# Extrai quadros de um video para usar com \videoquadros (pacote animate).
#
# Uso:
#   tools/extrair-quadros.sh videos/demo.mp4 [pasta_saida] [fps] [largura]
#
# Exemplo:
#   tools/extrair-quadros.sh videos/demo-oscilador.mp4 videos/demo-quadros 8 360
#
# Depois, no slide:
#   \videoquadros[width=0.7\linewidth]{demo-quadros}{1}{40}

set -euo pipefail

video="${1:?uso: $0 video.mp4 [pasta_saida] [fps] [largura]}"
saida="${2:-videos/$(basename "${video%.*}")-quadros}"
fps="${3:-12}"
largura="${4:-480}"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "erro: ffmpeg nao encontrado no PATH" >&2
  exit 1
fi

mkdir -p "$saida"

ffmpeg -y -v error -i "$video" \
  -vf "fps=${fps},scale=${largura}:-2" \
  -start_number 1 \
  "${saida}/quadro-%04d.png"

total=$(find "$saida" -maxdepth 1 -name 'quadro-*.png' | wc -l)
rel="${saida#videos/}"

echo "quadros : ${total} em ${saida}"
echo "no LaTeX: \\videoquadros[width=0.7\\linewidth]{${rel}}{1}{${total}}"
