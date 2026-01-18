@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo   Setup Automation - Data Mahasiswa
echo   Laragon/XAMPP Compatible
echo ========================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Script tidak berjalan sebagai Administrator
    echo Beberapa fitur mungkin memerlukan hak administrator
    echo.
)

:: Step 1: Check Python Installation
echo [1/5] Mengecek instalasi Python...
python --version >nul 2>&1
if %errorLevel% equ 0 (
    python --version
    echo ✓ Python sudah terinstall
    set PYTHON_CMD=python
    goto :check_pip
) else (
    echo ✗ Python belum terinstall
    echo.
    echo [AUTO-INSTALL] Mencoba menginstall Python...
    
    :: Try winget first (Windows 10/11)
    where winget >nul 2>&1
    if %errorLevel% equ 0 (
        echo Menggunakan winget untuk install Python...
        winget install Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements
        timeout /t 3 >nul
        
        :: Refresh PATH
        call refreshenv >nul 2>&1
        if not exist refreshenv.bat (
            echo [INFO] Silakan restart terminal atau jalankan: refreshenv
        )
        
        python --version >nul 2>&1
        if %errorLevel% equ 0 (
            echo ✓ Python berhasil diinstall
            set PYTHON_CMD=python
            goto :check_pip
        )
    )
    
    :: Try chocolatey if available
    where choco >nul 2>&1
    if %errorLevel% equ 0 (
        echo Menggunakan Chocolatey untuk install Python...
        choco install python3 -y
        timeout /t 3 >nul
        python --version >nul 2>&1
        if %errorLevel% equ 0 (
            echo ✓ Python berhasil diinstall
            set PYTHON_CMD=python
            goto :check_pip
        )
    )
    
    echo.
    echo [ERROR] Gagal menginstall Python secara otomatis
    echo Silakan install Python manual dari: https://www.python.org/downloads/
    echo Pastikan centang "Add Python to PATH" saat instalasi
    pause
    exit /b 1
)

:check_pip
echo.
echo [2/5] Mengecek pip (Python package manager)...
%PYTHON_CMD% -m pip --version >nul 2>&1
if %errorLevel% equ 0 (
    echo ✓ pip sudah tersedia
) else (
    echo ✗ pip tidak ditemukan, mencoba install...
    %PYTHON_CMD% -m ensurepip --upgrade
)

:: Step 2: Install Python Dependencies
echo.
echo [3/5] Menginstall dependencies Python...
%PYTHON_CMD% -m pip install --upgrade pip --quiet
%PYTHON_CMD% -m pip install -r requirements.txt
if %errorLevel% neq 0 (
    echo [ERROR] Gagal menginstall dependencies
    pause
    exit /b 1
)
echo ✓ Dependencies berhasil diinstall

:: Step 3: Detect MySQL Path (Laragon/XAMPP)
echo.
echo [4/5] Mendeteksi MySQL (Laragon/XAMPP)...
set MYSQL_FOUND=0

:: Check Laragon
if exist "C:\laragon\bin\mysql\mysql-8.0.30\bin\mysql.exe" (
    set MYSQL_PATH=C:\laragon\bin\mysql\mysql-8.0.30\bin
    set MYSQL_FOUND=1
    echo ✓ Laragon MySQL ditemukan
) else if exist "C:\laragon\bin\mysql\mysql-8.0.24\bin\mysql.exe" (
    set MYSQL_PATH=C:\laragon\bin\mysql\mysql-8.0.24\bin
    set MYSQL_FOUND=1
    echo ✓ Laragon MySQL ditemukan
) else if exist "C:\laragon\bin\mysql\*\bin\mysql.exe" (
    for /d %%i in ("C:\laragon\bin\mysql\*") do (
        if exist "%%i\bin\mysql.exe" (
            set MYSQL_PATH=%%i\bin
            set MYSQL_FOUND=1
            echo ✓ Laragon MySQL ditemukan
            goto :mysql_found
        )
    )
)

:: Check XAMPP
if exist "C:\xampp\mysql\bin\mysql.exe" (
    set MYSQL_PATH=C:\xampp\mysql\bin
    set MYSQL_FOUND=1
    echo ✓ XAMPP MySQL ditemukan
)

:mysql_found
if %MYSQL_FOUND% equ 0 (
    echo [INFO] MySQL tidak terdeteksi di lokasi standar
    echo Pastikan MySQL sudah berjalan di Laragon/XAMPP
)

:: Step 4: Database Configuration
echo.
echo [5/5] Konfigurasi Database...
echo.
set /p DB_NAME="Masukkan nama database (tekan Enter untuk 'mahasiswa_db'): "
if "!DB_NAME!"=="" set DB_NAME=mahasiswa_db

set /p DB_USER="Masukkan username MySQL (tekan Enter untuk 'root'): "
if "!DB_USER!"=="" set DB_USER=root

set /p DB_PASS="Masukkan password MySQL (tekan Enter jika tidak ada password): "

set /p DB_HOST="Masukkan host MySQL (tekan Enter untuk 'localhost'): "
if "!DB_HOST!"=="" set DB_HOST=localhost

:: Create config file
echo Membuat file konfigurasi...
(
echo # Konfigurasi Database
echo DB_NAME=!DB_NAME!
echo DB_USER=!DB_USER!
echo DB_PASS=!DB_PASS!
echo DB_HOST=!DB_HOST!
) > config.env

:: Update seed_data.py is not needed anymore since it reads from config.env
echo Konfigurasi akan dibaca dari config.env oleh seed_data.py

echo.
echo ========================================
echo   Setup Selesai!
echo ========================================
echo.
echo Konfigurasi:
echo   Database: !DB_NAME!
echo   User: !DB_USER!
echo   Host: !DB_HOST!
echo.
echo Langkah selanjutnya:
echo   1. Pastikan MySQL sudah berjalan di Laragon/XAMPP
echo   2. Buat database '%DB_NAME%' di phpMyAdmin atau MySQL
echo   3. Jalankan: run.bat
echo.
pause
