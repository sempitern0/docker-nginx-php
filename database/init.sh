#!/bin/sh

set -eu

echo "==> Running database migrations..."

find /docker-entrypoint-initdb.d/migrations \
    -maxdepth 1 \
    -type f \
    -name '*.sql' \
    -print |
    sort |
    while IFS= read -r file; do
        echo "==> Migration: ${file}"

        mariadb \
            --protocol=socket \
            -uroot \
            -p"${MARIADB_ROOT_PASSWORD}" \
            "${MARIADB_DATABASE}" < "${file}"
    done

echo "==> Running database seeds..."

find /docker-entrypoint-initdb.d/seeds \
    -maxdepth 1 \
    -type f \
    -name '*.sql' \
    -print |
    sort |
    while IFS= read -r file; do
        echo "==> Seed: ${file}"

        mariadb \
            --protocol=socket \
            -uroot \
            -p"${MARIADB_ROOT_PASSWORD}" \
            "${MARIADB_DATABASE}" < "${file}"
    done

echo "==> Database initialization completed."