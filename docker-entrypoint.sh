#!/bin/bash
set -e

echo "[FortExplorer] Starting MariaDB service..."
service mariadb start

# Initialize database
echo "[FortExplorer] Checking database..."
mysql -e "CREATE DATABASE IF NOT EXISTS fort_explorer CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Check if tables exist
TABLE_COUNT=$(mysql -s -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'fort_explorer';")

if [ "$TABLE_COUNT" -eq "0" ]; then
    echo "[FortExplorer] Database empty. Importing 367 forts & schema from database_production_dump.sql..."
    if [ -f /var/www/html/database_production_dump.sql ]; then
        mysql fort_explorer < /var/www/html/database_production_dump.sql
        echo "[FortExplorer] Database import complete! 367 forts ready."
    else
        echo "[FortExplorer] Warning: database_production_dump.sql not found."
    fi
else
    echo "[FortExplorer] Database already populated ($TABLE_COUNT tables)."
fi

# Set correct file ownership
chown -R www-data:www-data /var/www/html/assets/images/uploads

echo "[FortExplorer] Starting Apache web server..."
exec apache2-foreground
