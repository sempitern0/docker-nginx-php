# Docker Compose — Entorno local PHP / Nginx / MariaDB

Este proyecto utiliza Docker Compose para levantar un entorno local con:

- Nginx como webserver.
- PHP 8.4 + PHP-FPM.
- MariaDB 11.8.
- phpMyAdmin.
- Un Nginx adicional como reverse proxy HTTPS.
- Certificados locales generados con `mkcert`.
- Dominios locales resueltos mediante el fichero `hosts`.
- Un `Makefile` con atajos para las tareas habituales de desarrollo.

> **Nota para mi yo del futuro:** si algo deja de funcionar después de tocar volúmenes, Nginx o HTTPS, revisar primero este documento antes de desmontar medio Docker.

---

# 1. Estructura general

La arquitectura actual es:

```text
                         HTTPS :443
                              │
                              ▼
                    ┌─────────────────────┐
                    │     proxy_https      │
                    │       Nginx         │
                    │                     │
                    │ TLS / certificados  │
                    │ HTTP → HTTPS        │
                    └──────────┬──────────┘
                               │
                               │ HTTP :80
                               ▼
                    ┌─────────────────────┐
                    │      webserver      │
                    │       Nginx         │
                    │                     │
                    │ static + FastCGI   │
                    └──────────┬──────────┘
                               │
                               │ FastCGI :9000
                               ▼
                    ┌─────────────────────┐
                    │         php         │
                    │      PHP-FPM 8.4    │
                    └──────────┬──────────┘
                               │
                               │ MySQL :3306
                               ▼
                    ┌─────────────────────┐
                    │       mariadb       │
                    │      MariaDB 11.8   │
                    └─────────────────────┘
```

phpMyAdmin se conecta directamente a `mariadb`.

---

# 2. Dominios locales

El entorno utiliza como dominio base:

```text
app.test
```

También se puede utilizar cualquier subdominio cubierto por el certificado wildcard:

```text
app.test
www.app.test
api.app.test
admin.app.test
```

La configuración principal del proyecto utiliza:

```text
app.test
*.app.test
```

Si se cambia el dominio base, hay que actualizar de forma coherente:

- `.env`
- `nginx/default.conf`
- `nginx/proxy.conf`
- `/etc/hosts` o el fichero `hosts` de Windows
- certificados HTTPS
- configuración del `Makefile` si se quiere cambiar el valor por defecto

El `Makefile` permite sobrescribir el dominio sin modificarlo:

```bash
make setup BASE_DOMAIN=example.test
```

---

# 3. Fichero hosts

Docker no se encarga de resolver los dominios `.test` hacia localhost desde el navegador.

Hay que añadir el dominio al fichero `hosts` de la máquina anfitriona.

## Linux / macOS

Editar:

```text
/etc/hosts
```

Añadir:

```text
127.0.0.1 app.test
::1       app.test
```

Si se utilizan subdominios, no es necesario añadirlos individualmente si el certificado los cubre; sin embargo, el sistema operativo debe resolverlos. La forma más sencilla es añadirlos explícitamente:

```text
127.0.0.1 app.test
127.0.0.1 www.app.test
127.0.0.1 api.app.test
127.0.0.1 admin.app.test
```

## Windows

Editar como administrador:

```text
C:\Windows\System32\drivers\etc\hosts
```

Añadir:

```text
127.0.0.1 app.test
::1       app.test
```

Para subdominios:

```text
127.0.0.1 app.test
127.0.0.1 www.app.test
127.0.0.1 api.app.test
127.0.0.1 admin.app.test
```

Comprobar después:

```bash
ping app.test
```

Debería resolver a:

```text
127.0.0.1
```

> Si se cambia el dominio, recordar actualizar también el certificado y los `server_name` de Nginx.

---

# 4. Por qué usar `.test`

Para el desarrollo local se utiliza el dominio:

```text
.test
```

Por ejemplo:

```text
app.test
```

Es preferible a inventar dominios públicos o utilizar dominios reales para el entorno local.

El dominio `.test` está reservado para pruebas/documentación y evita depender de que exista realmente un dominio público.

---

# 5. Primera instalación

La forma recomendada de preparar el proyecto por primera vez es utilizar el `Makefile`:

```bash
make setup
```

Este comando prepara automáticamente:

1. Permisos de los scripts.
2. Directorios necesarios.
3. Certificados HTTPS locales.
4. Build de las imágenes Docker.
5. Arranque de los contenedores.

El flujo está pensado para que la primera instalación requiera el mínimo de configuración manual posible.

Al finalizar, se muestra:

```text
=================================================================
 Docker-Nginx-PHP is ready!

 Remember to add these lines to your hosts file:
   127.0.0.1 app.test
   ::1       app.test

 Application available at:
   https://app.test
=================================================================
```

Después de añadir el dominio al fichero `hosts`, la aplicación estará disponible en:

```text
https://app.test
```

> El `Makefile` es la interfaz recomendada para las tareas habituales del proyecto. Los comandos directos de `docker compose` siguen siendo válidos cuando sea necesario realizar alguna operación específica.

---

# 6. Makefile — comandos rápidos

El proyecto incluye un `Makefile` para simplificar las tareas habituales de Docker, PHP, Nginx y certificados HTTPS.

Para consultar todos los comandos disponibles:

```bash
make help
```

Si no se especifica ningún target, `make` muestra la ayuda:

```bash
make
```

## 6.1. Setup

Primera instalación:

```bash
make setup
```

Preparar los directorios:

```bash
make init-dirs
```

Generar los certificados:

```bash
make certs
```

Comprobar certificados existentes:

```bash
make certs-check
```

Regenerar certificados:

```bash
make certs-force
```

---

## 6.2. Docker Compose

Levantar los contenedores en primer plano:

```bash
make up
```

Levantar en segundo plano:

```bash
make up-detached
```

Reconstruir imágenes y levantar:

```bash
make up-build
```

Parar contenedores:

```bash
make stop
```

Parar y eliminar contenedores:

```bash
make down
```

Iniciar contenedores existentes:

```bash
make start
```

Reiniciar:

```bash
make restart
```

Reconstruir y reiniciar forzando la recreación:

```bash
make restart-rebuild
```

Mostrar estado:

```bash
make ps
```

Mostrar procesos:

```bash
make top
```

---

## 6.3. Build

Construir las imágenes:

```bash
make build
```

Construir sin caché:

```bash
make build-nc
```

Descargar imágenes base:

```bash
make pull
```

Parar, reconstruir y volver a levantar:

```bash
make rebuild
```

---

## 6.4. Logs

Logs de todos los servicios:

```bash
make logs
```

Logs de Nginx:

```bash
make logs-nginx
```

Logs de PHP:

```bash
make logs-php
```

Últimas 100 líneas:

```bash
make logs-tail
```

---

## 6.5. Acceso a los contenedores

Shell del contenedor PHP:

```bash
make php
```

También disponible como:

```bash
make shell
```

Shell del contenedor Nginx:

```bash
make nginx
```

---

## 6.6. PHP y Composer

Versión de PHP:

```bash
make php-version
```

Extensiones instaladas:

```bash
make php-extensions
```

Instalar dependencias:

```bash
make composer-install
```

Actualizar dependencias:

```bash
make composer-update
```

Ejecutar Composer directamente:

```bash
make composer install
```

Por ejemplo:

```bash
make composer require vendor/package
```

Los argumentos posteriores a `composer` se pasan al comando Composer dentro del contenedor PHP.

---

## 6.7. Diagnóstico

Validar la configuración de Docker Compose:

```bash
make config
```

Listar las imágenes utilizadas:

```bash
make images
```

Mostrar estadísticas de los contenedores:

```bash
make stats
```

---

## 6.8. Limpieza

Eliminar contenedores detenidos y redes no utilizadas:

```bash
make clean
```

Eliminar las imágenes locales del proyecto:

```bash
make clean-images
```

Eliminar contenedores y volúmenes:

```bash
make destroy-volumes
```

Eliminar completamente contenedores, redes, imágenes y volúmenes:

```bash
make destroy
```

> **Cuidado:** los comandos `destroy-volumes` y `destroy` pueden eliminar datos persistentes almacenados en volúmenes Docker.

---

## 6.9. Reset completo

Para reconstruir completamente el entorno:

```bash
make reset
```

Para realizar una instalación limpia:

```bash
make fresh
```

Estos comandos están pensados para situaciones en las que se necesita empezar de nuevo con el entorno Docker.

---

## 6.10. Resumen rápido

| Necesidad | Comando |
|---|---|
| Primera instalación | `make setup` |
| Ayuda | `make help` |
| Levantar | `make up-detached` |
| Levantar + build | `make up-build` |
| Parar | `make stop` |
| Eliminar contenedores | `make down` |
| Reiniciar | `make restart` |
| Estado | `make ps` |
| Logs | `make logs` |
| Logs Nginx | `make logs-nginx` |
| Logs PHP | `make logs-php` |
| Shell PHP | `make php` |
| Shell Nginx | `make nginx` |
| Build | `make build` |
| Build sin caché | `make build-nc` |
| Composer install | `make composer-install` |
| Versión PHP | `make php-version` |
| Generar certificados | `make certs` |
| Comprobar certificados | `make certs-check` |
| Regenerar certificados | `make certs-force` |
| Reset completo | `make reset` |
| Limpieza total | `make destroy` |

---

# 7. Certificados HTTPS con mkcert

Para tener HTTPS local sin avisos de certificado del navegador se utiliza `mkcert`.

La configuración por defecto genera un certificado para:

```text
app.test
*.app.test
```

Esto permite cubrir:

```text
app.test
www.app.test
api.app.test
admin.app.test
foo.app.test
```

El certificado incluye tanto el dominio base como el wildcard porque:

```text
*.app.test
```

no cubre por sí solo:

```text
app.test
```

## Generación automática

La forma recomendada es:

```bash
make certs
```

Durante la primera instalación:

```bash
make setup
```

ya se ejecuta automáticamente este paso.

El Makefile detecta Windows y ejecuta el script PowerShell:

```text
scripts/generate_certs.ps1
```

En Linux/macOS ejecuta:

```text
scripts/generate_certs.sh
```

Ambos scripts utilizan `mkcert` por defecto.

Los certificados se almacenan en:

```text
docker/nginx/certs/
```

Por ejemplo:

```text
docker/nginx/certs/
├── app.test.crt
└── app.test.key
```

Los nombres exactos dependerán de la ejecución del script.

## Regenerar certificados

Comprobar si existen:

```bash
make certs-check
```

Regenerarlos:

```bash
make certs-force
```

El comando `certs-force` elimina previamente los certificados del proyecto y vuelve a generarlos.

> Los certificados y las claves privadas son archivos locales de desarrollo y no deben incluirse en el repositorio.

---

# 8. Configuración de Nginx para HTTPS

El reverse proxy HTTPS utiliza los certificados montados en:

```text
/etc/nginx/certs
```

en el contenedor.

La configuración tiene una parte HTTP:

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name app.test www.app.test;

    return 301 https://$host$request_uri;
}
```

Y otra HTTPS:

```nginx
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name app.test www.app.test;

    ssl_certificate /etc/nginx/certs/...
    ssl_certificate_key /etc/nginx/certs/...

    ...
}
```

El proxy termina TLS y después reenvía la petición al Nginx interno:

```nginx
location / {
    proxy_pass http://webserver:80;
}
```

Por tanto:

```text
https://app.test
       │
       ▼
proxy_https:443
       │
       ▼
webserver:80
       │
       ▼
php:9000
```

---

# 9. Volúmenes: IMPORTANTE

Este fue un problema importante durante la configuración.

La aplicación está físicamente en:

```text
./sites/app
```

El contenedor `webserver` debe verla como:

```text
/usr/share/nginx/html
```

Y PHP debe verla **exactamente en la misma ruta**.

Por tanto:

```yaml
webserver:
  volumes:
    - ./sites/app:/usr/share/nginx/html:ro

php:
  volumes:
    - ./sites/app:/usr/share/nginx/html:ro
```

No hacer esto en PHP:

```yaml
- ./sites:/usr/share/nginx/html:ro
```

si Nginx utiliza:

```text
./sites/app
```

porque entonces las rutas internas de Nginx y PHP dejan de coincidir.

---

# 10. `root` de Nginx

Con el volumen:

```yaml
- ./sites/app:/usr/share/nginx/html:ro
```

el `root` correcto es:

```nginx
root /usr/share/nginx/html;
```

No:

```nginx
root /usr/share/nginx/html/app;
```

La relación correcta es:

```text
HOST

./sites/app/index.php
        │
        │ bind mount
        ▼
CONTAINER

/usr/share/nginx/html/index.php
```

Por tanto:

```nginx
root /usr/share/nginx/html;
```

---

# 11. PHP-FPM y SCRIPT_FILENAME

La configuración actual utiliza:

```nginx
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
```

Esto significa que si se solicita:

```text
/login.php
```

Nginx debe terminar pasando a PHP:

```text
/usr/share/nginx/html/login.php
```

Por eso es fundamental que PHP tenga el mismo volumen y la misma ruta:

```text
/usr/share/nginx/html
```

Si Nginx y PHP montan directorios diferentes, aparecerán errores del tipo:

```text
File not found
```

o respuestas `404`.

---

# 12. Healthchecks

Hay dos healthchecks importantes.

## Webserver

El Nginx interno tiene:

```nginx
location = /healthz {
    access_log off;
    default_type text/plain;
    return 200 "OK
";
}
```

Y Docker comprueba:

```bash
wget -qO- http://127.0.0.1/healthz
```

Por tanto:

```text
webserver → /healthz → 200 OK
```

## Reverse proxy

El reverse proxy también debe tener su propio endpoint:

```nginx
location = /healthz {
    access_log off;
    default_type text/plain;
    return 200 "OK
";
}
```

Y su healthcheck:

```bash
wget --no-check-certificate -qO- https://127.0.0.1/healthz
```

Esto es importante porque comprobar simplemente `/` no garantiza que Nginx esté sano.

Durante la configuración original el proxy aparecía como:

```text
unhealthy
```

porque el healthcheck hacía:

```text
GET /
```

y `/` devolvía:

```text
404
```

El contenedor funcionaba, pero Docker interpretaba el `404` como fallo del healthcheck.

La solución es comprobar `/healthz`.

---

# 13. Estructura recomendada

La estructura aproximada del proyecto:

```text
.
├── .env
├── .env.example
├── compose.yml
├── Dockerfile
├── Makefile
│
├── docker/
│   └── nginx/
│       └── certs/
│           ├── ...
│           └── ...
│
├── nginx/
│   ├── default.conf
│   └── proxy.conf
│
├── scripts/
│   ├── generate_certs.ps1
│   └── generate_certs.sh
│
├── php/
│   └── Dockerfile
│
├── sites/
│   └── app/
│       ├── index.php
│       └── ...
│
└── storage/
```

Los certificados son locales y no deberían formar parte del código fuente si el proyecto se comparte.

Añadir a `.gitignore`:

```gitignore
.env
docker/nginx/certs/*
```

Si se quiere conservar la estructura:

```gitignore
docker/nginx/certs/*
!docker/nginx/certs/.gitkeep
```

---

# 14. Variables `.env`

Ejemplo actual:

```dotenv
COMPOSE_PROFILES=mysql

APP_DOMAIN=app.test
APP_TIMEZONE=Europe/London

DB_DATABASE=app_db
DB_EMAIL=admin@admin.com
DB_USER=ca_user
DB_PASSWORD=
DB_ROOT_PASSWORD=
DB_ALLOW_EMPTY_PASSWORD=yes

WEBSERVER_CONTAINER_NAME=webserver
PHP_CONTAINER_NAME=php
MARIADB_CONTAINER_NAME=mariadb
POSTGRES_CONTAINER_NAME=postgresdb
PHPMYADMIN_CONTAINER_NAME=phpmyadmin
PROXY_CONTAINER_NAME=webserver_proxy_https

DOCKER_RESTART_POLICY=unless-stopped

MYSQL_PORT=3306
PHPMYADMIN_PORT=8080

POSTGRES_PORT=5432
PGADMIN_PORT=8081

HTTP_PORT=80
HTTPS_PORT=443
```

Para producción no utilizar:

```dotenv
DB_ALLOW_EMPTY_PASSWORD=yes
```

ni dejar contraseñas vacías.

---

# 15. Levantar el entorno

## Primera vez

Utilizar:

```bash
make setup
```

Después añadir al fichero `hosts`:

```text
127.0.0.1 app.test
::1       app.test
```

Y abrir:

```text
https://app.test
```

## Uso diario

Levantar en segundo plano:

```bash
make up-detached
```

Ver el estado:

```bash
make ps
```

Ver los logs:

```bash
make logs
```

Reconstruir cuando haya cambios en Docker:

```bash
make up-build
```

Parar:

```bash
make down
```

---

# 16. Comprobaciones útiles

Comprobar que PHP ve los ficheros:

```bash
docker compose exec php ls -la /usr/share/nginx/html
```

Comprobar que Nginx ve los mismos:

```bash
docker compose exec webserver ls -la /usr/share/nginx/html
```

Comprobar configuración de Nginx:

```bash
docker compose exec webserver nginx -t
```

Y para el proxy:

```bash
docker compose exec proxy_https nginx -t
```

Comprobar PHP-FPM:

```bash
docker compose exec php php-fpm -t
```

Comprobar healthcheck:

```bash
docker inspect --format='{{json .State.Health}}' webserver
```

o:

```bash
docker inspect --format='{{json .State.Health}}' webserver_proxy_https
```

---

# 17. MySQL / MariaDB

El perfil actual es:

```dotenv
COMPOSE_PROFILES=mysql
```

Se levantan:

```text
mariadb
phpmyadmin
```

MariaDB queda disponible desde el host en:

```text
localhost:3306
```

phpMyAdmin:

```text
http://localhost:8080
```

Desde otros contenedores no se utiliza `localhost`.

PHP debe conectarse a:

```text
mariadb:3306
```

porque `mariadb` es el nombre DNS del servicio dentro de la red Docker.

---

# 18. PostgreSQL

Existe también un perfil preparado:

```dotenv
COMPOSE_PROFILES=postgres
```

Pero antes de utilizarlo revisar el servicio PostgreSQL/pgAdmin del Compose.

En la configuración inicial había algunas inconsistencias:

## Nombre del servicio

El servicio es:

```yaml
postgresdb:
```

pero pgAdmin tenía:

```yaml
depends_on:
  - postgres_db
```

Debe coincidir:

```yaml
depends_on:
  - postgresdb
```

## Red

La red definida es:

```yaml
server-network:
```

pero pgAdmin tenía:

```yaml
laravel-app-network
```

Debe utilizar:

```yaml
server-network
```

## Volumen

Si se utiliza:

```yaml
postgres_data:/var/lib/postgresql/data
```

hay que declarar también:

```yaml
volumes:
  postgres_data:
```

Estos problemas no afectan al perfil MySQL.

---

# 19. Flujo HTTPS completo

Cuando todo está correctamente configurado:

```text
1. Navegador
   │
   │ https://app.test
   ▼
2. hosts
   │
   │ 127.0.0.1
   ▼
3. Docker → proxy_https :443
   │
   │ certificado mkcert
   ▼
4. proxy_https
   │
   │ HTTP
   ▼
5. webserver :80
   │
   ├── fichero estático
   │
   └── PHP
       │
       │ FastCGI
       ▼
6. php :9000
   │
   │ SQL
   ▼
7. mariadb :3306
```

---

# 20. Si vuelve a aparecer un 404 de PHP

Comprobar en este orden:

### 1. ¿Existe el fichero en el host?

```bash
ls -la ./sites/app/
```

### 2. ¿Existe en Nginx?

```bash
docker compose exec webserver ls -la /usr/share/nginx/html/
```

### 3. ¿Existe en PHP?

```bash
docker compose exec php ls -la /usr/share/nginx/html/
```

Los tres deben corresponder.

### 4. Revisar el `root`

Debe ser:

```nginx
root /usr/share/nginx/html;
```

### 5. Revisar `SCRIPT_FILENAME`

Debe ser:

```nginx
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
```

### 6. Revisar `fastcgi_pass`

Debe apuntar al servicio Docker:

```nginx
fastcgi_pass php:9000;
```

No utilizar:

```text
localhost:9000
```

porque PHP-FPM está en otro contenedor.

---

# 21. Si el proxy vuelve a aparecer como `unhealthy`

Primero mirar los logs:

```bash
make logs-nginx
```

o directamente:

```bash
docker compose logs proxy_https
```

Si aparece:

```text
GET / HTTP/1.1" 404
```

comprobar que el healthcheck no esté apuntando a `/`.

Debe utilizar:

```text
/healthz
```

Y el proxy debe tener:

```nginx
location = /healthz {
    access_log off;
    default_type text/plain;
    return 200 "OK
";
}
```

Entonces:

```bash
docker compose exec proxy_https     wget --no-check-certificate -qO- https://127.0.0.1/healthz
```

debería devolver:

```text
OK
```

---

# 22. Regla de oro

Si algún día vuelvo a tocar los volúmenes de la aplicación:

**Nginx y PHP deben ver la aplicación en exactamente la misma ruta interna.**

Actualmente:

```text
HOST

./sites/app
   │
   ├───────────────┐
   ▼               ▼
Nginx             PHP
/usr/share/       /usr/share/
nginx/html        nginx/html
```

Y Nginx:

```nginx
root /usr/share/nginx/html;
```

No cambiar esto sin revisar también:

```nginx
SCRIPT_FILENAME
```

y los volúmenes de ambos servicios.

---

# 23. Estado actual

- [x] Nginx interno funcionando.
- [x] PHP-FPM funcionando.
- [x] MariaDB funcionando.
- [x] phpMyAdmin funcionando.
- [x] Reverse proxy HTTPS funcionando.
- [x] Dominios locales de pruebas funcionando.
- [x] Resolución mediante `hosts`.
- [x] Certificados locales mediante `mkcert`.
- [x] Wildcard local mediante `*.app.test`.
- [x] Healthcheck dedicado `/healthz`.
- [x] Nginx y PHP compartiendo exactamente la misma raíz de aplicación.
- [x] `Makefile` para simplificar las tareas habituales.
- [x] Setup inicial automatizado mediante `make setup`.
- [x] Generación automática de certificados en Windows y Linux/macOS.

> Si algo falla después de un cambio: **revisar primero `hosts` → certificado `mkcert` → `server_name` → volúmenes → `root` → `SCRIPT_FILENAME` → healthchecks.**
