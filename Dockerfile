# Dockerfile for Local Development
FROM ruby:3.3.0-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs git curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Development environment settings
ENV RAILS_ENV=development

# Install gems (not using deployment mode for easier local updates)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
