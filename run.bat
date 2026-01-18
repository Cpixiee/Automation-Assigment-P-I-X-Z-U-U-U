@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo   Menjalankan Migration dan Seeder
echo ========================================
echo.

:: Check Python
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python tidak ditemukan!
    echo Silakan jalankan setup.bat terlebih dahulu
    pause
    exit /b 1
)

:: Check config file
if not exist config.env (
    echo [ERROR] File config.env tidak ditemukan!
    echo Silakan jalankan setup.bat terlebih dahulu
    pause
    exit /b 1
)

:: Load config
for /f "tokens=1,2 delims==" %%a in (config.env) do (
    if "%%a"=="DB_NAME" set DB_NAME=%%b
    if "%%a"=="DB_USER" set DB_USER=%%b
    if "%%a"=="DB_PASS" set DB_PASS=%%b
    if "%%a"=="DB_HOST" set DB_HOST=%%b
)

echo Menggunakan konfigurasi:
echo   Database: %DB_NAME%
echo   User: %DB_USER%
echo   Host: %DB_HOST%
echo.

:: Check if database exists (optional - create if not exists)
echo Mengecek database...
python -c "import mysql.connector; conn = mysql.connector.connect(host='%DB_HOST%', user='%DB_USER%', password='%DB_PASS%'); cursor = conn.cursor(); cursor.execute('CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci'); cursor.close(); conn.close(); print('✓ Database siap')" 2>nul
if errorlevel 1 (
    echo [WARNING] Tidak dapat membuat database secara otomatis
    echo Pastikan database '%DB_NAME%' sudah dibuat di phpMyAdmin
    echo.
)

:: Run Python seeder
echo Menjalankan migration dan seeder...
echo.
python seed_data.py

if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo   ✓ Selesai!
    echo ========================================
    echo.
    echo Data dapat dilihat di phpMyAdmin:
    echo   Database: %DB_NAME%
    echo   Table: data_mahasiswa
    echo.
) else (
    echo.
    echo [ERROR] Terjadi kesalahan saat menjalankan seeder
    echo Periksa konfigurasi database dan pastikan MySQL berjalan
    echo.
)

pause
