#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 tex/main.tex"
  exit 2
fi

TEXFILE="$1"
WORKDIR="$(cd "$(dirname "$TEXFILE")" && pwd)"
BASENAME="$(basename "$TEXFILE")"

cd "$WORKDIR"

# 1) Primera pasada: genera .aux y archivos pythontex
pdflatex -interaction=nonstopmode -halt-on-error "$BASENAME"

# 2) Ejecuta PythonTeX (si existe). Dependiendo de la distro puede llamarse pythontex o pythontex3.
if command -v pythontex >/dev/null 2>&1; then
  #pythontex "$BASENAME"
  pythontex --interpreter python:python3 "$BASENAME"
elif command -v pythontex3 >/dev/null 2>&1; then
  pythontex3 "$BASENAME"
else
  # Fallback: intentar localizar el script pythontex3.py (a veces está en TEXMF)
  # Si esto falla, habrá que ajustar apt.txt para instalar pythontex desde TeX Live o pip.
  echo "No encuentro 'pythontex' ni 'pythontex3' en PATH."
  echo "Sugerencia: verifica instalación de pythontex (TeX Live) o añade un paso de instalación."
  exit 1
fi

# 3) Completa compilación (referencias, TOC, etc.)
latexmk -pdf -interaction=nonstopmode -halt-on-error "$BASENAME"

echo "OK: generado $(basename "$BASENAME" .tex).pdf en $WORKDIR"
