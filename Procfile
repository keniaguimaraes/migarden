release: bundle exec rails db:migrate --verbose && echo "=== MIGRATIONS COMPLETED ===" && bundle exec rails db:migrate:status
web: bundle exec rails server -b 0.0.0.0 -p $PORT
worker: bundle exec sidekiq