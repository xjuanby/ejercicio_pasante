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
if [ -f ".env" ]; then
  sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=pgsql/" .env
  sed -i "s/^DB_HOST=.*/DB_HOST=${DB_HOST:-db}/" .env
  sed -i "s/^DB_PORT=.*/DB_PORT=${DB_PORT:-5432}/" .env
  sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-pasante}/" .env
  sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-pasante}/" .env
  sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-secret}/" .env
fi

# Genera APP_KEY si falta
if ! grep -q "^APP_KEY=base64" .env 2>/dev/null; then
  php artisan key:generate --force
fi

# Espera a que la base de datos este lista y ejecuta migraciones
php artisan migrate --force || echo ">> No se pudieron correr las migraciones, revisa la conexion a la base de datos."

exec php artisan serve --host 0.0.0.0 --port 8000
