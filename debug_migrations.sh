#!/bin/bash
# Debug script to troubleshoot migrations on Railway

echo "=========================================="
echo "=== miGarden Migration Debug Script ===" 
echo "=========================================="
echo ""

echo "1. Environment Variables"
echo "======================="
echo "RAILS_ENV: $RAILS_ENV"
echo "DATABASE_URL: ${DATABASE_URL:0:50}..." # Mostrar apenas os primeiros 50 caracteres
echo "RACK_ENV: $RACK_ENV"
echo ""

echo "2. Database Connection Test"
echo "============================"
bundle exec rails dbconsole <<< "SELECT version();" 2>&1 | head -3
echo ""

echo "3. Migration Files Found"
echo "========================"
ls -la /app/db/migrate/ | grep -E "create_|add_"
echo ""

echo "4. Current Database Schema"
echo "==========================="
echo "Tables in database:"
bundle exec rails dbconsole <<< "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
" 2>&1 | grep -v "^table_name" | grep -v "^-"
echo ""

echo "5. Migration Status Before"
echo "==========================="
bundle exec rails db:migrate:status 2>&1
echo ""

echo "6. Running Migrations (VERBOSE)"
echo "================================"
bundle exec rails db:migrate --verbose 2>&1
echo ""

echo "7. Migration Status After"
echo "=========================="
bundle exec rails db:migrate:status 2>&1
echo ""

echo "8. Verify Tables Created"
echo "========================"
bundle exec rails dbconsole <<< "
SELECT 
  table_name,
  (SELECT count(*) FROM information_schema.columns c WHERE c.table_name = t.table_name) as columns
FROM information_schema.tables t
WHERE table_schema = 'public'
ORDER BY table_name;
" 2>&1
echo ""

echo "9. Test Database Data"
echo "====================="
bundle exec rails console <<< "
puts 'Plants table:'
puts Plant.count rescue puts 'Plants table not found'
puts 'Care Parameters table:'
puts CareParameter.count rescue puts 'CareParameter table not found'
puts 'Care Logs table:'
puts CareLog.count rescue puts 'CareLog table not found'
" 2>&1 | grep -v "^irb("
echo ""

echo "=========================================="
echo "=== Debug Complete ===" 
echo "=========================================="
