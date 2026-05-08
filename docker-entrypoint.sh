#!/bin/bash
set -e

echo "=========================================="
echo "===== RUNNING MIGRATIONS START ====="
echo "=========================================="

bundle exec rails db:migrate --verbose

echo "=========================================="
echo "===== MIGRATIONS COMPLETED ====="
echo "=========================================="

echo "===== PRECOMPILING ASSETS ====="
bundle exec rails assets:precompile
echo "===== ASSETS PRECOMPILED ====="

echo "===== STARTING RAILS SERVER ====="
exec "$@"
