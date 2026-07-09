#!/usr/bin/env bash
set -e

# Si la carpeta no tiene un proyecto Laravel, lo inicializa
if [ ! -f "composer.json" ]; then
  echo ">> No se encontro composer.json, inicializando proyecto Laravel..."
  composer create-project laravel/laravel tmp_laravel
  shopt -s dotglob
  mv tmp_laravel/* .
  rm -rf tmp_laravel
  shopt -u dotglob
fi

# Instala dependencias si falta vendor/
if [ ! -d "vendor" ]; then
  composer install --no-interaction
fi

# Configura conexion a PostgreSQL en .env
# (usa -E con "^#?\s*" porque el .env por defecto de Laravel trae estas
# variables comentadas, ya que por defecto usa SQLite)
if [ -f ".env" ]; then
  sed -i -E "s/^#?[[:space:]]*DB_CONNECTION=.*/DB_CONNECTION=pgsql/" .env
  sed -i -E "s/^#?[[:space:]]*DB_HOST=.*/DB_HOST=${DB_HOST:-db}/" .env
  sed -i -E "s/^#?[[:space:]]*DB_PORT=.*/DB_PORT=${DB_PORT:-5432}/" .env
  sed -i -E "s/^#?[[:space:]]*DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-pasante}/" .env
  sed -i -E "s/^#?[[:space:]]*DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-pasante}/" .env
  sed -i -E "s/^#?[[:space:]]*DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-secret}/" .env

  # Por si alguna variable no existia en absoluto en el .env
  grep -q "^DB_CONNECTION=" .env || echo "DB_CONNECTION=pgsql" >> .env
  grep -q "^DB_HOST=" .env || echo "DB_HOST=${DB_HOST:-db}" >> .env
  grep -q "^DB_PORT=" .env || echo "DB_PORT=${DB_PORT:-5432}" >> .env
  grep -q "^DB_DATABASE=" .env || echo "DB_DATABASE=${DB_DATABASE:-pasante}" >> .env
  grep -q "^DB_USERNAME=" .env || echo "DB_USERNAME=${DB_USERNAME:-pasante}" >> .env
  grep -q "^DB_PASSWORD=" .env || echo "DB_PASSWORD=${DB_PASSWORD:-secret}" >> .env
fi

# Genera APP_KEY si falta
if ! grep -q "^APP_KEY=base64" .env 2>/dev/null; then
  php artisan key:generate --force
fi

# Espera a que la base de datos este lista y ejecuta migraciones
php artisan migrate --force || echo ">> No se pudieron correr las migraciones, revisa la conexion a la base de datos."

exec php artisan serve --host 0.0.0.0 --port 8000
