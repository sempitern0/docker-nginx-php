# Docker Nginx PHP

Development starter for native PHP applications with Nginx, PHP-FPM and a selectable MariaDB or PostgreSQL database.

The project is designed around a simple rule: **each site lives under `sites/<site>/public`** and Nginx exposes only that `public` directory.

## Requirements

- Docker Engine
- Docker Compose v2 (`docker compose`)
- Git
- `mkcert` for local HTTPS certificates
- On Linux, `certutil`/`libnss3-tools` is useful when Firefox or other NSS-based browsers are used

The repository includes Bash and PowerShell certificate helpers for Unix-like systems and Windows.

## 1. Configure `.env`

Create your local environment file from the example:

```bash
cp .env.example .env
```

On Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Open `.env` and replace the example values with your local values. At minimum, review:

```dotenv
COMPOSE_PROFILES=mysql

APP_NAME=My App
APP_DOMAIN=https://app.test
APP_TIMEZONE=Europe/Madrid
APP_LOCALE=es

DB_DRIVER=mysql
DB_HOST=mariadb
DB_PORT=3306
DB_DATABASE=app_db
DB_USER=app
DB_PASSWORD=change-me
DB_ROOT_PASSWORD=change-me-too

ADMIN_GATE_SECRET=change-me
RATE_LIMIT_SECRET=change-me
```

For PostgreSQL, switch the database settings to PostgreSQL values and enable the `postgres` Compose profile. The application configuration chooses the PostgreSQL defaults when `DB_DRIVER=pgsql` is used.

**Do not commit `.env`.** Keep real secrets and local credentials out of Git.

## 2. Generate local HTTPS certificates

The HTTPS proxy expects the certificate files in:

```text
nginx/certs/
```

The default Nginx configuration expects:

```text
nginx/certs/app.crt
nginx/certs/app.key
```

### Recommended: mkcert

Generate a certificate for the default site:

### Linux / macOS / WSL

```bash
chmod +x scripts/generate_certs.sh
./scripts/generate_certs.sh \
  --output ./nginx/certs \
  --name app \
  --domains app.test \*.app.test \
  --tool mkcert
```

### Windows PowerShell

```powershell
.\scripts\generate_certs.ps1 `
  -OutputDir .\nginx\certs `
  -FileName app `
  -Domains "app.test *.app.test" `
  -Tool mkcert
```

The scripts generate:

```text
nginx/certs/app.crt
nginx/certs/app.key
nginx/certs/app-CA.crt
```

The `*-CA.crt` file is the local root CA certificate. **That is the certificate to import when another browser or machine does not trust the local CA automatically.** The CA private key must never be shared.

`mkcert -install` installs its local CA into supported trust stores. Browser support depends on the operating system and browser; restart the browser after installing the CA when required.

### Import `app-CA.crt` manually

If the browser still shows **Not secure**, import `nginx/certs/app-CA.crt` into the browser/OS trusted root store.

**Chrome / Chromium / Edge**

On Windows, open the certificate, choose **Install Certificate**, select **Current User** or **Local Machine**, then place it in **Trusted Root Certification Authorities**. Restart the browser.

On Linux, Chromium/Chrome normally use the system/NSS trust mechanisms supported by the local installation. Re-run `mkcert -install` and restart the browser first.

**Firefox**

`mkcert` can install its CA into Firefox's NSS store on supported platforms when the required NSS tooling is available. Restart Firefox after installation. You can also import `app-CA.crt` manually in **Settings → Privacy & Security → Certificates → View Certificates → Authorities → Import** and trust it for websites.

**Important:** import the `-CA.crt`, not `app.crt`. `app.crt` is the server certificate.

### Using a different certificate name

The proxy configuration currently points to:

```nginx
ssl_certificate /etc/nginx/certs/app.crt;
ssl_certificate_key /etc/nginx/certs/app.key;
```

You have two options when the generated name is not `app`.

**Option A — generate using `app` (recommended):**

```bash
./scripts/generate_certs.sh --output ./nginx/certs --name app --domains app.test --tool mkcert
```

**Option B — keep a custom name and update Nginx:**

For a certificate named `myproject`:

```nginx
ssl_certificate /etc/nginx/certs/myproject.crt;
ssl_certificate_key /etc/nginx/certs/myproject.key;
```

The file name must match the files mounted into the proxy container.

## 3. Add local hostnames

Nginx resolves sites dynamically from the hostname. A hostname such as `shop.test` maps to:

```text
sites/shop/public
```

Add each local hostname to your hosts file.

### Linux / macOS

Edit:

```text
/etc/hosts
```

Example:

```text
127.0.0.1 app.test
127.0.0.1 shop.test
::1       app.test
::1       shop.test
```

### Windows

Edit as Administrator:

```text
C:\Windows\System32\drivers\etc\hosts
```

Example:

```text
127.0.0.1 app.test
127.0.0.1 shop.test
```

## 4. Choose MariaDB or PostgreSQL

The Compose file uses profiles for the databases.

### MariaDB

In `.env`:

```dotenv
COMPOSE_PROFILES=mysql
DB_DRIVER=mysql
DB_HOST=mariadb
DB_PORT=3306
```

Start the stack:

```bash
docker compose up -d --build
```

MariaDB also exposes phpMyAdmin on:

```text
http://localhost:8080
```

### PostgreSQL

In `.env`:

```dotenv
COMPOSE_PROFILES=postgres
DB_DRIVER=pgsql
DB_HOST=postgresdb
DB_PORT=5432
```

Start the stack:

```bash
docker compose up -d --build
```

PostgreSQL also exposes pgAdmin on:

```text
http://localhost:8081
```

### Check the stack

```bash
docker compose ps
docker compose logs -f
```

Or use the included Make targets where they match your local setup:

```bash
make help
```

## 5. Access the application over HTTPS

With the default certificate and host entry in place:

```text
https://app.test
```

For another site:

```text
https://shop.test
```

The HTTPS proxy listens on ports `80` and `443`, redirects HTTP to HTTPS, and forwards the request to the internal Nginx webserver.

If the browser reports **Not secure**, check these three things first:

1. The hostname in the URL is covered by the certificate SANs.
2. `app-CA.crt` is trusted by the browser/OS.
3. The browser was restarted after changing trust settings.

## 6. Create a new site

Create a directory under `sites` with a `public` directory inside it:

```text
sites/
└── shop/
    └── public/
        └── index.php
```

Minimal `index.php`:

```php
<?php

declare(strict_types=1);

echo 'Hello from shop';
```

Add the hostname:

```text
127.0.0.1 shop.test
```

Then open:

```text
https://shop.test
```

The repository's Nginx configuration captures the `<site>.test` hostname and sets the document root to:

```text
/usr/share/nginx/html/<site>/public
```

so only the site's `public` directory is served.

### Site layout

A typical site can grow into:

```text
sites/shop/
├── common/
├── config/
├── public/
│   ├── index.php
│   ├── css/
│   ├── js/
│   └── assets/
└── storage/
```

Keep private application code, configuration and data outside `public` whenever possible. Nginx blocks common sensitive files such as `.env`, `.sql`, `.log`, `.conf` and shell scripts.

## 7. Database initialization and resets

Database migrations and seeds are executed by the database initialization process. The repository keeps MariaDB and PostgreSQL scripts in separate trees:

```text
mysql/
├── init.sh
├── migrations/
└── seeds/

postgres/
├── init.sh
├── migrations/
└── seeds/
```

Because the official database images run initialization scripts when the data directory is initialized, changing a migration or seed does **not** automatically re-run it against an existing volume.

For a clean development database:

```bash
docker compose down -v

docker compose up -d --build
```

This removes the database volume and recreates the schema and seed data from scratch.

## 8. Useful commands

```bash
# Start

docker compose up -d --build

# Stop

docker compose down

# Logs

docker compose logs -f

# Status

docker compose ps

# Complete local reset, including database volumes

docker compose down -v
```

For the Makefile helper commands:

```bash
make help
make up-build
make logs
make ps
make destroy-volumes
```

## Project structure

```text
.
├── .env.example
├── docker-compose.yml
├── nginx/
│   ├── default.conf
│   ├── proxy.conf
│   └── certs/
├── php/
├── mysql/
│   ├── init.sh
│   ├── migrations/
│   └── seeds/
├── postgres/
│   ├── init.sh
│   ├── migrations/
│   └── seeds/
├── scripts/
│   ├── generate_certs.sh
│   └── generate_certs.ps1
└── sites/
    └── app/
        ├── common/
        ├── config/
        └── public/
```

## Security notes

This project is for development environments. The local CA generated by `mkcert` is trusted on the developer machine; its root private key is highly sensitive and must not be shared.

Keep `.env`, database passwords, application secrets and private keys out of version control.
