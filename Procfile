release: sh -c " \
  echo '=========================================='; \
  echo '=== DATABASE MIGRATION STARTED ==='; \
  echo '=========================================='; \
  echo ''; \
  echo '[1/4] Removing stale PID files...'; \
  rm -f tmp/pids/server.pid; \
  echo '✓ Done'; \
  echo ''; \
  echo '[2/4] Testing database connection...'; \
  bundle exec rails dbconsole <<< 'SELECT 1;' 2>&1 | grep -E '(^.|ERROR)' || echo '✓ Connected'; \
  echo ''; \
  echo '[3/4] Running migrations (verbose)...'; \
  bundle exec rails db:migrate --verbose; \
  echo ''; \
  echo '[4/4] Migration status:'; \
  bundle exec rails db:migrate:status; \
  echo ''; \
  echo '=========================================='; \
  echo '=== MIGRATIONS COMPLETED ==='; \
  echo '==========================================';"
web: bundle exec rails server -b 0.0.0.0 -p $PORT
worker: bundle exec sidekiq