release: sh -c "echo '=== Running migrations ===' && bundle exec rails db:migrate && echo '=== Migrations done ==='"
web: bundle exec rails server -b 0.0.0.0 -p $PORT
worker: bundle exec sidekiq