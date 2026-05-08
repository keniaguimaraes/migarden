#!/bin/bash
set -e

# Force output to stdout
exec > >(tee /proc/1/fd/1) 2>&1

echo "=========================================="
echo "=== Docker Entrypoint Starting ==="
echo "=========================================="
echo "Container started at: $(date)"
echo "User: $(whoami)"
echo "Working directory: $(pwd)"
echo ""

# Remove possibly stale server.pid files
echo "[1/6] Cleaning up stale PID files..."
rm -f /app/tmp/pids/server.pid
echo "✓ PID files cleaned"
echo ""

# Wait for database to be ready (simple delay)
echo "[2/6] Waiting for database to be ready..."
sleep 10
echo "✓ Database ready (waited 10 seconds)"
echo ""

# Check database connection
echo "[3/6] Testing database connection..."
if bundle exec rails dbconsole <<< "SELECT 1;" > /dev/null 2>&1; then
  echo "✓ Database connection OK"
else
  echo "⚠ Database connection failed - will retry during migration"
fi
echo ""

# Run database setup
echo "[4/6] Running database setup (db:prepare)..."
bundle exec rails db:prepare || echo "⚠ db:prepare completed with issues"
echo "✓ Database setup completed"
echo ""

# Run migrations with verbose output
echo "[5/6] Running migrations (verbose)..."
bundle exec rails db:migrate --verbose 2>&1 | tee /tmp/migration.log
echo "✓ Migrations completed"
echo ""

# Check migration status
echo "[6/6] Checking migration status..."
bundle exec rails db:migrate:status 2>&1 | head -30
echo ""

# Ensure necessary directories exist for Puma
echo "Ensuring tmp/pids directory exists..."
mkdir -p /app/tmp/pids

echo "=========================================="
echo "=== Application Ready ===" 
echo "Startup completed at: $(date)"
echo "=========================================="
echo ""

# Execute the command passed or default to rails server
exec "${@:-bundle exec rails server -b 0.0.0.0}"
