#!/bin/bash
set -e

echo "=== RUNNING MIGRATIONS ===" 
bundle exec rails db:migrate --verbose
echo "=== MIGRATIONS COMPLETED ===" 

echo "=== PRECOMPILING ASSETS ===" 
bundle exec rails assets:precompile
echo "=== ASSETS PRECOMPILED ===" 

echo "=== STARTING SERVER ===" 
exec "$@"
