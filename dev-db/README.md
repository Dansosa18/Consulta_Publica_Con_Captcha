# Base de datos local

Esta configuración levanta una instancia MariaDB 11 para el
`consulta-service`. Usa la base `oficina_agua`, expone MariaDB en el puerto
`3307` del equipo y monta los scripts de `dev-db/init` en el directorio de
inicialización de la imagen.

## Preparación

Desde la raíz de `consulta-service`, copia el archivo de ejemplo:

```powershell
Copy-Item dev-db/.env.example dev-db/.env
```

Edita `dev-db/.env` y define una contraseña local para `MARIADB_ROOT_PASSWORD`.
El archivo `.env` está ignorado por Git y no debe versionarse.

## Levantar la base

Ejecuta desde la raíz del proyecto:

```powershell
docker compose --env-file dev-db/.env -f dev-db/docker-compose.yml up -d
```

La conexión queda disponible en:

```text
Host: localhost
Port: 3307
Database: oficina_agua
User de solo lectura: consulta_ro
Password local del usuario: consulta_ro_dev_only
```

La imagen ejecuta los scripts de `dev-db/init` solo cuando el volumen está
vacío y crea, en orden:

1. `01-schema.sql`: tablas, claves, índices y restricciones.
2. `02-seed.sql`: datos ficticios de prueba.
3. `03-users.sql`: usuario `consulta_ro` con permisos exclusivamente `SELECT`.
4. `04-seed-casos-adicionales.sql`: casos adicionales ficticios para ampliar
   la base de pruebas.

## Reiniciar desde cero

Para borrar el volumen de MariaDB y volver a ejecutar todo el esquema y los
seeds:

```powershell
docker compose --env-file dev-db/.env -f dev-db/docker-compose.yml down -v
docker compose --env-file dev-db/.env -f dev-db/docker-compose.yml up -d
```

No uses `down -v` si necesitas conservar los datos locales.

## Verificar el contenedor

```powershell
docker compose --env-file dev-db/.env -f dev-db/docker-compose.yml ps
docker compose --env-file dev-db/.env -f dev-db/docker-compose.yml logs -f mariadb
```
