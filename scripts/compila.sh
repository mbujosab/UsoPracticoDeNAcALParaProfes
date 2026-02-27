#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Uso: $0 tex/archivo.tex"
    exit 1
fi

TEXFILE="$1"
WORKDIR="$(cd "$(dirname "$TEXFILE")" && pwd)"
BASENAME="$(basename "$TEXFILE")"

if [[ ! -f "$TEXFILE" ]]; then
    echo "Error: no existe el fichero '$TEXFILE'"
    exit 1
fi

cd "$WORKDIR"

pdflatex -interaction=batchmode "$BASENAME"
pythontex --interpreter python:python3 "$BASENAME"
latexmk -pdf -interaction=nonstopmode -halt-on-error "$BASENAME"

############# esta variante borra casi todos los ficheros auxiliares
# latexmk -pdf -interaction=nonstopmode -halt-on-error -c "$BASENAME"
# rm $(basename "$BASENAME" .tex).{qsl,pytxcode,sol}
# rm $(basename "$BASENAME" .tex)_xdefs.cut
# rm exerquiz.djs
cp $(basename "$BASENAME" .tex).pdf ../
