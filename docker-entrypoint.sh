#!/bin/bash
set -e

# Remove possibly stale server.pid files
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready (simple delay)
echo "Waiting for database to be ready..."
sleep 10

# Run database setup
echo "Running database migrations..."
bundle exec rails db:prepare

# Execute the CMD from Dockerfile
exec "$@"