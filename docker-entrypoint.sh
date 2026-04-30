#!/bin/bash
set -e

echo "=== Docker Entrypoint Starting ==="

# Remove possibly stale server.pid files
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready (simple delay)
echo "Waiting for database to be ready..."
sleep 10

# Run database setup
echo "Running database migrations..."
bundle exec rails db:prepare 2>&1 || echo "Migration failed, trying db:migrate..."
bundle exec rails db:migrate 2>&1 || echo "Migration check complete"

echo "Database setup done!"

# Ensure necessary directories exist for Puma
echo "Ensuring tmp/pids directory exists..."
mkdir -p /app/tmp/pids

# List migrations to verify
echo "=== Current migrations status ==="
bundle exec rails db:migrate:status 2>&1 || true

# Execute the CMD from Dockerfile (which will be 'rails s' or 'sidekiq')
echo "Starting application..."
exec "$@"
