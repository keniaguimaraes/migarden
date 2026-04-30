#!/bin/bash
set -e

# Force output to stdout
exec > >(tee /proc/1/fd/1) 2>&1

echo "=========================================="
echo "=== Docker Entrypoint Starting ==="
echo "=========================================="

# Remove possibly stale server.pid files
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready (simple delay)
echo "Waiting for database to be ready..."
sleep 10

# Run database setup
echo "Running database migrations..."
bundle exec rails db:prepare

echo "Database setup done!"

# Ensure necessary directories exist for Puma
echo "Ensuring tmp/pids directory exists..."
mkdir -p /app/tmp/pids

# List migrations to verify
echo "=== Current migrations status ==="
bundle exec rails db:migrate:status || true

# Execute the command passed or default to rails server
echo "=========================================="
echo "=== Starting application ==="
echo "=========================================="

exec "${@:-bundle exec rails server -b 0.0.0.0}"
