web: sh -c "rails db:migrate:status | grep 'down' > /dev/null && rails db:migrate || echo 'Migrações já aplicadas'; bundle exec rails server -b 0.0.0.0 -p $PORT"
worker: bundle exec sidekiq