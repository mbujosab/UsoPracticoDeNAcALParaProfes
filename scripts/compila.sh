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

# Permite que TeX encuentre paquetes locales "vendorizados" (AcroTeX, nacal, etc.).
# El ':' final es importante para conservar la búsqueda por defecto de TeX.
export TEXINPUTS=".:./acrotex:./nacal:${TEXINPUTS:-}:"

# (Opcional) si tus .bib/.bst están en subcarpetas y usas \bibliography{referencias/...}
export BIBINPUTS=".:./referencias:${BIBINPUTS:-}:"
export BSTINPUTS=".:./referencias:${BSTINPUTS:-}:"

# 1) Primera pasada: genera .aux y archivos PythonTeX
pdflatex -interaction=batchmode "$BASENAME"

# 2) Ejecuta PythonTeX usando el Python del entorno conda de Binder (env "notebook")
CONDA_PY="/srv/conda/envs/notebook/bin/python"
if [[ ! -x "$CONDA_PY" ]]; then
  echo "No encuentro el Python del entorno conda en $CONDA_PY"
  echo "Entornos disponibles:"
  conda env list || true
  exit 1
fi

pythontex --interpreter python:python3 "$BASENAME"

# 3) Completa compilación (referencias, TOC, etc.)
latexmk -pdf -interaction=nonstopmode -halt-on-error "$BASENAME"

############# esta variante borra casi todos los ficheros auxiliares
# latexmk -pdf -interaction=nonstopmode -halt-on-error -c "$BASENAME"
# rm $(basename "$BASENAME" .tex).{qsl,pytxcode,sol}
# rm $(basename "$BASENAME" .tex)_xdefs.cut
# rm exerquiz.djs

# 4) Copiamos el PDF al directorio raíz
cp $(basename "$BASENAME" .tex).pdf ../
