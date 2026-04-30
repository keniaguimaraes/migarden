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

# Ensure necessary directories exist for Puma and other processes
echo "Ensuring tmp/pids directory exists..."
mkdir -p /app/tmp/pids

# Execute the CMD from Dockerfile, running Puma in the background so cron can run
echo "Starting Puma server in the background..."
bundle exec puma -C config/puma.rb &

echo "Tail the log file to keep the container alive..."
tail -f /app/log/production.log
