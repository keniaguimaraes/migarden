FROM ruby:3.3.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  postgresql-client \
  imagemagick \
  libvips && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the app
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["sh", "-c", "bundle exec rails server -b 0.0.0.0"]
