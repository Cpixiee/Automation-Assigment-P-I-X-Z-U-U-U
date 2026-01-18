#!/bin/bash

# Setup Automation - Data Mahasiswa
# Compatible dengan Laragon/XAMPP di Linux

set -e

echo "========================================"
echo "  Setup Automation - Data Mahasiswa"
echo "  Laragon/XAMPP Compatible (Linux)"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check Python Installation
echo "[1/5] Mengecek instalasi Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓${NC} Python sudah terinstall: $PYTHON_VERSION"
    PYTHON_CMD=python3
elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version)
    echo -e "${GREEN}✓${NC} Python sudah terinstall: $PYTHON_VERSION"
    PYTHON_CMD=python
else
    echo -e "${RED}✗${NC} Python belum terinstall"
    echo ""
    echo "[AUTO-INSTALL] Mencoba menginstall Python..."
    
    # Detect Linux distribution
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        echo "Menggunakan apt untuk install Python..."
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip python3-venv
        PYTHON_CMD=python3
    elif [ -f /etc/redhat-release ]; then
        # RedHat/CentOS/Fedora
        echo "Menggunakan yum/dnf untuk install Python..."
        if command -v dnf &> /dev/null; then
            sudo dnf install -y python3 python3-pip
        else
            sudo yum install -y python3 python3-pip
        fi
        PYTHON_CMD=python3
    elif [ -f /etc/arch-release ]; then
        # Arch Linux
        echo "Menggunakan pacman untuk install Python..."
        sudo pacman -S --noconfirm python python-pip
        PYTHON_CMD=python
    else
        echo -e "${RED}[ERROR]${NC} Tidak dapat mendeteksi package manager"
        echo "Silakan install Python manual: https://www.python.org/downloads/"
        exit 1
    fi
    
    if command -v $PYTHON_CMD &> /dev/null; then
        echo -e "${GREEN}✓${NC} Python berhasil diinstall"
    else
        echo -e "${RED}[ERROR]${NC} Gagal menginstall Python"
        exit 1
    fi
fi

# Step 2: Check pip
echo ""
echo "[2/5] Mengecek pip (Python package manager)..."
if $PYTHON_CMD -m pip --version &> /dev/null; then
    echo -e "${GREEN}✓${NC} pip sudah tersedia"
else
    echo -e "${YELLOW}⚠${NC} pip tidak ditemukan, mencoba install..."
    $PYTHON_CMD -m ensurepip --upgrade
fi

# Step 3: Install Python Dependencies
echo ""
echo "[3/5] Menginstall dependencies Python..."
$PYTHON_CMD -m pip install --upgrade pip --quiet
$PYTHON_CMD -m pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Dependencies berhasil diinstall"
else
    echo -e "${RED}[ERROR]${NC} Gagal menginstall dependencies"
    exit 1
fi

# Step 4: Detect MySQL Path (Laragon/XAMPP)
echo ""
echo "[4/5] Mendeteksi MySQL (Laragon/XAMPP)..."
MYSQL_FOUND=0

# Check XAMPP Linux
if [ -d "/opt/lampp/bin" ] && [ -f "/opt/lampp/bin/mysql" ]; then
    MYSQL_PATH="/opt/lampp/bin"
    MYSQL_FOUND=1
    echo -e "${GREEN}✓${NC} XAMPP MySQL ditemukan di /opt/lampp"
elif [ -d "/opt/xampp/bin" ] && [ -f "/opt/xampp/bin/mysql" ]; then
    MYSQL_PATH="/opt/xampp/bin"
    MYSQL_FOUND=1
    echo -e "${GREEN}✓${NC} XAMPP MySQL ditemukan di /opt/xampp"
fi

# Check system MySQL
if [ $MYSQL_FOUND -eq 0 ]; then
    if command -v mysql &> /dev/null; then
        MYSQL_FOUND=1
        echo -e "${GREEN}✓${NC} MySQL system ditemukan"
    fi
fi

if [ $MYSQL_FOUND -eq 0 ]; then
    echo -e "${YELLOW}[INFO]${NC} MySQL tidak terdeteksi di lokasi standar"
    echo "Pastikan MySQL sudah berjalan"
fi

# Step 5: Database Configuration
echo ""
echo "[5/5] Konfigurasi Database..."
echo ""

read -p "Masukkan nama database (tekan Enter untuk 'mahasiswa_db'): " DB_NAME
DB_NAME=${DB_NAME:-mahasiswa_db}

read -p "Masukkan username MySQL (tekan Enter untuk 'root'): " DB_USER
DB_USER=${DB_USER:-root}

read -sp "Masukkan password MySQL (tekan Enter jika tidak ada password): " DB_PASS
echo ""
DB_PASS=${DB_PASS:-}

read -p "Masukkan host MySQL (tekan Enter untuk 'localhost'): " DB_HOST
DB_HOST=${DB_HOST:-localhost}

# Create config file
echo "Membuat file konfigurasi..."
cat > config.env << EOF
# Konfigurasi Database
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS
DB_HOST=$DB_HOST
EOF

# Update seed_data.py with config using sed
echo "Memperbarui konfigurasi di seed_data.py..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/'database': 'your_database_name'/'database': '$DB_NAME'/" seed_data.py
    sed -i '' "s/'user': 'root'/'user': '$DB_USER'/" seed_data.py
    sed -i '' "s/'password': ''/'password': '$DB_PASS'/" seed_data.py
    sed -i '' "s/'host': 'localhost'/'host': '$DB_HOST'/" seed_data.py
else
    # Linux
    sed -i "s/'database': 'your_database_name'/'database': '$DB_NAME'/" seed_data.py
    sed -i "s/'user': 'root'/'user': '$DB_USER'/" seed_data.py
    sed -i "s/'password': ''/'password': '$DB_PASS'/" seed_data.py
    sed -i "s/'host': 'localhost'/'host': '$DB_HOST'/" seed_data.py
fi

echo ""
echo "========================================"
echo "  Setup Selesai!"
echo "========================================"
echo ""
echo "Konfigurasi:"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo "  Host: $DB_HOST"
echo ""
echo "Langkah selanjutnya:"
echo "  1. Pastikan MySQL sudah berjalan"
echo "  2. Buat database '$DB_NAME' di phpMyAdmin atau MySQL"
echo "  3. Jalankan: ./run.sh"
echo ""
echo "Atau jalankan: bash run.sh"
echo ""
