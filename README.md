# Docker Compose — Entorno local PHP / Nginx / MariaDB

Este proyecto utiliza Docker Compose para levantar un entorno local con:

- Nginx como webserver.
- PHP 8.4 + PHP-FPM.
- MariaDB 11.8.
- phpMyAdmin.
- Un Nginx adicional como reverse proxy HTTPS.
- Certificados locales generados con `mkcert`.
- Dominios locales resueltos mediante el fichero `hosts`.

> **Nota para mi yo del futuro:** si algo deja de funcionar después de tocar volúmenes, Nginx o HTTPS, revisar primero este documento antes de desmontar medio Docker.

---

## 1. Estructura general

La arquitectura actual es:

```text
                         HTTPS :443
                             │
                             ▼
                  ┌─────────────────────┐
                  │     proxy_https      │
                  │       Nginx         │
                  │                     │
                  │ TLS / certificados │
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

El entorno está pensado para trabajar con dominios locales, por ejemplo:

```text
app.test
www.app.test
```

También se puede utilizar otro dominio de pruebas si se cambia de forma coherente en:

- `.env`
- `nginx/default.conf`
- `nginx/proxy.conf`
- `/etc/hosts`
- certificados generados con `mkcert`

La idea es que el navegador resuelva el dominio hacia `127.0.0.1`, pero que HTTPS sea válido mediante un certificado local confiable.

---

# 3. Fichero hosts

Docker no se encarga de resolver los dominios `.test` hacia localhost desde el navegador.

Hay que añadirlos al fichero `hosts` de la máquina anfitriona.

## Linux / macOS

Editar:

```text
/etc/hosts
```

Por ejemplo:

```text
127.0.0.1 app.test
127.0.0.1 www.app.test
```

## Windows

Editar como administrador:

```text
C:\Windows\System32\drivers\etc\hosts
```

Y añadir:

```text
127.0.0.1 app.test
127.0.0.1 www.app.test
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

# 5. Certificados HTTPS con mkcert

Para tener HTTPS local sin avisos de certificado del navegador se utiliza `mkcert`.

La primera vez hay que instalar la CA local:

```bash
mkcert -install
```

Después se puede generar un certificado para el dominio de desarrollo.

Por ejemplo:

```bash
mkcert app.test "*.app.test"
```

Esto permite cubrir:

```text
app.test
foo.app.test
bar.app.test
...
```

Si además se utiliza `www.app.test`, el wildcard `*.app.test` lo cubre.

Una opción más explícita es:

```bash
mkcert app.test www.app.test "*.app.test"
```

Los ficheros generados se colocan en:

```text
nginx/certs/
```

Por ejemplo:

```text
nginx/certs/
├── app.test+2.pem
└── app.test+2-key.pem
```

Los nombres reales dependen de cómo se haya ejecutado `mkcert`.

---

# 6. Configuración de Nginx para HTTPS

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

# 7. Volúmenes: IMPORTANTE

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

# 8. `root` de Nginx

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

# 9. PHP-FPM y SCRIPT_FILENAME

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

# 10. Healthchecks

Hay dos healthchecks importantes.

## Webserver

El Nginx interno tiene:

```nginx
location = /healthz {
    access_log off;
    default_type text/plain;
    return 200 "OK\n";
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
    return 200 "OK\n";
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

# 11. Estructura recomendada

La estructura aproximada del proyecto:

```text
.
├── .env
├── .env.example
├── compose.yml
├── Dockerfile
│
├── nginx/
│   ├── default.conf
│   ├── proxy.conf
│   └── certs/
│       ├── ...
│       └── ...
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
nginx/certs/*
```

Si se quiere conservar un README o estructura:

```gitignore
nginx/certs/*
!nginx/certs/.gitkeep
```

---

# 12. Variables `.env`

Ejemplo actual:

```dotenv
COMPOSE_PROFILES=mysql

APP_DOMAIN=app.test
TZ=Europe/London

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

# 13. Levantar el entorno

Primera vez:

```bash
docker compose up -d --build
```

Ver estado:

```bash
docker compose ps
```

Ver logs:

```bash
docker compose logs -f
```

Ver logs únicamente de PHP:

```bash
docker compose logs -f php
```

Ver logs de Nginx:

```bash
docker compose logs -f webserver
```

Ver logs del proxy:

```bash
docker compose logs -f proxy_https
```

---

# 14. Comprobaciones útiles

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

# 15. MySQL / MariaDB

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

# 16. PostgreSQL

Existe también un perfil preparado:

```dotenv
COMPOSE_PROFILES=postgres
```

Pero antes de utilizarlo revisar el servicio PostgreSQL/pgAdmin del Compose.

En la configuración inicial había algunas inconsistencias:

### Nombre del servicio

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

### Red

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

### Volumen

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

# 17. Flujo HTTPS completo

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

# 18. Si vuelve a aparecer un 404 de PHP

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

# 19. Si el proxy vuelve a aparecer como `unhealthy`

Primero mirar los logs:

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
    return 200 "OK\n";
}
```

Entonces:

```bash
docker compose exec proxy_https \
    wget --no-check-certificate -qO- https://127.0.0.1/healthz
```

debería devolver:

```text
OK
```

---

# 20. Regla de oro

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

## Estado actual

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

> Si algo falla después de un cambio: **revisar primero `hosts` → certificado `mkcert` → `server_name` → volúmenes → `root` → `SCRIPT_FILENAME` → healthchecks.**
