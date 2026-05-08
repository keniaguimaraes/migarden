release: sh -c "\
  echo '========================================' && \
  echo '=== DATABASE MIGRATION STARTED ===' && \
  echo '========================================' && \
  echo 'RAILS_ENV: '$RAILS_ENV && \
  echo 'DATABASE_URL: '$DATABASE_URL && \
  echo '' && \
  echo '[1/3] Checking database connection...' && \
  bundle exec rails dbconsole <<< 'SELECT 1;' 2>&1 | head -5 && \
  echo '' && \
  echo '[2/3] Current migration status:' && \
  bundle exec rails db:migrate:status 2>&1 | head -20 && \
  echo '' && \
  echo '[3/3] Running migrations...' && \
  bundle exec rails db:migrate --verbose && \
  echo '' && \
  echo 'Migration status after:' && \
  bundle exec rails db:migrate:status 2>&1 | head -20 && \
  echo '========================================' && \
  echo '=== MIGRATIONS COMPLETED ===' && \
  echo '========================================'"
web: bundle exec rails server -b 0.0.0.0 -p $PORT
worker: bundle exec sidekiq