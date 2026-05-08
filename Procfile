release: bundle exec rails db:migrate && bundle exec rails assets:precompile
web: bundle exec rails server -b 0.0.0.0 -p $PORT
worker: bundle exec sidekiq