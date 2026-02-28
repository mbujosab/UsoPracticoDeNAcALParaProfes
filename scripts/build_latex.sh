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

# Permite que TeX encuentre paquetes locales "vendorizados" (AcroTeX, nacal, etc.).
# El ':' final es importante para conservar la búsqueda por defecto de TeX.
export TEXINPUTS=".:./acrotex:./nacal:${TEXINPUTS:-}:"

# (Opcional) si tus .bib/.bst están en subcarpetas y usas \bibliography{referencias/...}
export BIBINPUTS=".:./referencias:${BIBINPUTS:-}:"
export BSTINPUTS=".:./referencias:${BSTINPUTS:-}:"

# 1) Primera pasada: genera .aux y archivos PythonTeX
pdflatex -interaction=nonstopmode -halt-on-error "$BASENAME"

# 2) Ejecuta PythonTeX usando el Python del entorno conda de Binder (env "notebook")
CONDA_PY="/srv/conda/envs/notebook/bin/python"
if [[ ! -x "$CONDA_PY" ]]; then
  echo "No encuentro el Python del entorno conda en $CONDA_PY"
  echo "Entornos disponibles:"
  conda env list || true
  exit 1
fi

pythontex --interpreter "py:${CONDA_PY}" "$BASENAME"

# 3) Completa compilación (referencias, TOC, etc.)
latexmk -pdf -interaction=nonstopmode -halt-on-error "$BASENAME"

echo "OK: generado $(basename "$BASENAME" .tex).pdf en $WORKDIR"
