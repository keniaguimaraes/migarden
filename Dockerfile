# syntax=docker/dockerfile:1
FROM ruby:3.3.0-slim AS base

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs git curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Set environment variables
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Precompile assets (if applicable)
# RUN if [ "$RAILS_ENV" = "production" ]; then bundle exec rails assets:precompile; fi

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
