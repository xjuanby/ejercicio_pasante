# Proyecto pasante — Angular + Laravel + PostgreSQL (Docker)

## Requisitos

- Docker y Docker Compose instalados.

## Estructura

```
test_pasante/
├── docker-compose.yml
├── .env.example
├── frontend/        (Angular, se genera automaticamente en el primer arranque)
│   ├── Dockerfile
│   └── entrypoint.sh
└── backend/          (Laravel, se genera automaticamente en el primer arranque)
    ├── Dockerfile
    └── entrypoint.sh
```

Las carpetas `frontend/` y `backend/` estan vacias a proposito: los contenedores
generan el proyecto Angular y el proyecto Laravel automaticamente la primera
vez que se levantan (via `entrypoint.sh`). Las corridas siguientes detectan que
el proyecto ya existe y solo instalan dependencias y arrancan el servidor.

## Instalacion

1. Copiar el archivo de variables de entorno:

   ```bash
   cp .env.example .env
   ```

   Ajustar usuario/contraseña/puertos si es necesario.

2. Construir las imagenes y levantar los servicios:

   ```bash
   docker compose up --build
   ```

   La primera vez tardara varios minutos: se instala Postgres, se crea el
   proyecto Angular (`ng new`) y el proyecto Laravel (`composer create-project`).

3. Cuando termine, la salida de consola debe mostrar los tres servicios activos:

   - `db` (PostgreSQL) en el puerto `5432`
   - `backend` (Laravel) en http://localhost:8000
   - `frontend` (Angular) en http://localhost:4200

4. Verificar que Laravel se conecta a PostgreSQL correctamente:

   ```bash
   docker compose exec backend php artisan migrate:status
   ```

## Uso diario

- Levantar en segundo plano: `docker compose up -d`
- Ver logs: `docker compose logs -f backend` (o `frontend`, `db`)
- Detener: `docker compose down`
- Detener y borrar datos de la base: `docker compose down -v`
- Entrar a un contenedor: `docker compose exec backend bash` / `docker compose exec frontend bash`

## Comandos utiles dentro de los contenedores

```bash
# Laravel
docker compose exec backend php artisan migrate
docker compose exec backend php artisan make:controller NombreController
docker compose exec backend composer require paquete/nombre

# Angular
docker compose exec frontend ng generate component nombre
docker compose exec frontend npm install paquete
```

## Notas

- El codigo de `frontend/` y `backend/` queda montado como volumen: los cambios
  que hagas en tu editor se reflejan al instante dentro del contenedor.
- Si borras `frontend/` o `backend/` por completo, al volver a levantar
  `docker compose up` el `entrypoint.sh` los vuelve a generar desde cero.
- `DB_HOST` para Laravel debe ser `db` (nombre del servicio en
  `docker-compose.yml`), no `localhost`.
