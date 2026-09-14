#!/bin/sh

set -eu

mariadb_cmd() {
    mariadb \
        --protocol=socket \
        -uroot \
        -p"${MARIADB_ROOT_PASSWORD}" \
        "${MARIADB_DATABASE}" \
        "$@"
}

echo "==> Initializing schema migrations table..."

mariadb_cmd <<'SQL'
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(100) NOT NULL PRIMARY KEY,
    applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;
SQL

echo "==> Running database migrations..."

find /docker-entrypoint-initdb.d/mysql/migrations \
    -maxdepth 1 \
    -type f \
    -name '*.sql' \
    -print |
    sort |
    while IFS= read -r file; do

    version="$(basename "${file}" .sql)"

    applied="$(
        mariadb_cmd -Nse "
            SELECT COUNT(*)
            FROM schema_migrations
            WHERE version='${version}'
        "
    )"

    if [ "${applied}" -gt 0 ]; then
        echo "==> Skipping migration: ${version}"
        continue
    fi

    echo "==> Migration: ${version}"

    mariadb_cmd < "${file}"

    mariadb_cmd -e "
        INSERT INTO schema_migrations (version)
        VALUES ('${version}')
    "
done

echo "==> Running database seeds..."

find /docker-entrypoint-initdb.d/mysql/seeds \
    -maxdepth 1 \
    -type f \
    -name '*.sql' \
    -print |
    sort |
    while IFS= read -r file; do

    echo "==> Seed: $(basename "${file}")"

    mariadb_cmd < "${file}"
done

echo "==> Database initialization completed."