#!/usr/bin/env bash
set -e

# Si la carpeta no tiene un proyecto Angular, lo inicializa
if [ ! -f "angular.json" ]; then
  echo ">> No se encontro angular.json, inicializando proyecto Angular..."
  ng new frontend --directory . --skip-git --routing --style=scss --package-manager=npm --defaults
fi

# Instala dependencias si faltan node_modules
if [ ! -d "node_modules" ]; then
  npm install
fi

exec ng serve --host 0.0.0.0 --port 4200
