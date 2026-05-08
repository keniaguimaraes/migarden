#!/bin/bash
set -e

echo "=== Starting server ==="
exec bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}