#!/bin/sh

set -eu

psql_cmd() {
    psql \
        -v ON_ERROR_STOP=1 \
        --username="${POSTGRES_USER}" \
        --dbname="${POSTGRES_DB}" \
        "$@"
}

echo "==> Initializing schema migrations table..."

psql_cmd <<'SQL'
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(100) PRIMARY KEY,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
SQL

echo "==> Running PostgreSQL migrations..."

find /docker-entrypoint-initdb.d/migrations \
    -maxdepth 1 \
    -type f \
    -name '*.sql' \
    -print |
    sort |
    while IFS= read -r file; do

    version="$(basename "${file}" .sql)"

    case "${version}" in
        *[!A-Za-z0-9._-]*)
            echo "ERROR: Invalid migration filename: ${version}" >&2
            exit 1
            ;;
    esac

    applied="$({ psql_cmd -tAc "SELECT COUNT(*) FROM schema_migrations WHERE version = '${version}'"; } | tr -d '[:space:]')"

    if [ "${applied}" -gt 0 ]; then
        echo "==> Skipping migration: ${version}"
        continue
    fi

    echo "==> Migration: ${version}"

    psql_cmd -f "${file}"
    psql_cmd -c "INSERT INTO schema_migrations (version) VALUES ('${version}');"
done

echo "==> Running PostgreSQL seeds..."

find /docker-entrypoint-initdb.d/seeds \
    -maxdepth 1 \
    -type f \
    -name '*.sql' \
    -print |
    sort |
    while IFS= read -r file; do

    echo "==> Seed: $(basename "${file}")"
    psql_cmd -f "${file}"
done

echo "==> PostgreSQL database initialization completed."
