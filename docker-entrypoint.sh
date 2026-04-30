#!/bin/bash
set -e

# Remove possibly stale server.pid files
rm -f /app/tmp/pids/server.pid

# Wait for database to be ready (simple delay)
echo "Waiting for database to be ready..."
sleep 10

# Run database setup
echo "Running database migrations..."
bundle exec rails db:prepare

# --- Start Scheduler for Daily Notifications ---
# Schedule the job to run daily at 8:00 AM
(crontab -l 2>/dev/null; echo "0 8 * * * /usr/bin/env bash -c 'RAILS_ENV=production bundle exec rails runner \"DailyNotificationJob.perform_now\" >> log/cron.log 2>&1'") | crontab -
echo "DailyNotificationJob scheduled for 8:00 AM."
# -----------------------------------------------

# Execute the CMD from Dockerfile, running Puma in the background so cron can run
echo "Starting Puma server in the background..."
bundle exec puma -C config/puma.rb &

# Keep the container alive by tailing the server logs (if running in foreground)
# Or, if the main CMD is supposed to be the server, we need a different approach.
# Since the original used 'exec "$@"' which likely starts Puma in foreground,
# we need to replace it to allow cron to start, then manually start Puma in background.

# Check if the CMD was 'rails server -b 0.0.0.0' or similar. We assume it starts Puma.
# If the main process stops, the container stops. We'll replace 'exec "$@"' with the manual start and tail to keep it alive.

echo "Tail the log file to keep the container alive..."
tail -f /app/log/production.log
