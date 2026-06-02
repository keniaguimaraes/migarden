web: bin/rails db:prepare && bin/rails server -b ::
worker: bundle exec rake solid_queue:start
release: bundle exec rails db:migrate
