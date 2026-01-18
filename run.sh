#!/bin/bash

# Menjalankan Migration dan Seeder
# Compatible dengan Laragon/XAMPP di Linux

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================"
echo "  Menjalankan Migration dan Seeder"
echo "========================================"
echo ""

# Check Python
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Python tidak ditemukan!"
    echo "Silakan jalankan setup.sh terlebih dahulu"
    exit 1
fi

# Determine Python command
if command -v python3 &> /dev/null; then
    PYTHON_CMD=python3
else
    PYTHON_CMD=python
fi

# Check config file
if [ ! -f config.env ]; then
    echo -e "${RED}[ERROR]${NC} File config.env tidak ditemukan!"
    echo "Silakan jalankan setup.sh terlebih dahulu"
    exit 1
fi

# Load config
source config.env

echo "Menggunakan konfigurasi:"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Host: $DB_HOST"
echo ""

# Check if database exists (optional - create if not exists)
echo "Mengecek database..."
$PYTHON_CMD -c "
import mysql.connector
try:
    conn = mysql.connector.connect(
        host='$DB_HOST',
        user='$DB_USER',
        password='$DB_PASS'
    )
    cursor = conn.cursor()
    cursor.execute('CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci')
    cursor.close()
    conn.close()
    print('✓ Database siap')
except Exception as e:
    print('⚠ Tidak dapat membuat database secara otomatis')
    print('Pastikan database $DB_NAME sudah dibuat di phpMyAdmin')
" 2>/dev/null || echo "⚠ Pastikan database '$DB_NAME' sudah dibuat"

# Run Python seeder
echo ""
echo "Menjalankan migration dan seeder..."
echo ""
$PYTHON_CMD seed_data.py

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo -e "  ${GREEN}✓ Selesai!${NC}"
    echo "========================================"
    echo ""
    echo "Data dapat dilihat di phpMyAdmin:"
    echo "  Database: $DB_NAME"
    echo "  Table: data_mahasiswa"
    echo ""
else
    echo ""
    echo -e "${RED}[ERROR]${NC} Terjadi kesalahan saat menjalankan seeder"
    echo "Periksa konfigurasi database dan pastikan MySQL berjalan"
    echo ""
    exit 1
fi
