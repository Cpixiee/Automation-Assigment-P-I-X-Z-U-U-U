# Seeder Data Mahasiswa dengan Python dan MySQL

Proyek ini berisi migration dan seeder untuk tabel `data_mahasiswa` menggunakan Python dan MySQL. **Dilengkapi dengan automation script untuk Windows dan Linux** yang dapat auto-install Python jika belum ada.

## Struktur File

- `migration.sql` - File SQL untuk membuat tabel `data_mahasiswa`
- `seed_data.py` - Script Python untuk mengisi data ke database (auto-load config dari config.env)
- `requirements.txt` - Dependencies Python yang diperlukan
- `setup.bat` / `setup.sh` - Script automation untuk setup (Windows/Linux)
- `run.bat` / `run.sh` - Script untuk menjalankan migration dan seeder (Windows/Linux)
- `config.env` - File konfigurasi database (auto-generated oleh setup script)
- 
### 🐧 Linux (XAMPP/Laragon)

1. **Beri permission execute**:
   ```bash
   chmod +x setup.sh run.sh
   ```

2. **Jalankan setup script** (akan auto-install Python jika belum ada):
   ```bash
   ./setup.sh
   ```
   
   Atau:
   ```bash
   bash setup.sh
   ```
   
   Script akan:
   - ✅ Mengecek dan auto-install Python (via apt/yum/pacman)
   - ✅ Install dependencies Python
   - ✅ Detect MySQL di XAMPP (/opt/lampp atau /opt/xampp)
   - ✅ Membuat file konfigurasi `config.env`

3. **Jalankan migration dan seeder**:
   ```bash
   ./run.sh
   ```

## Instalasi Manual

### 1. Install Python Dependencies

```bash
pip install -r requirements.txt
```

Atau install langsung:

```bash
pip install mysql-connector-python
```

### 2. Konfigurasi Database

**Opsi A: Menggunakan setup script** (Recommended)
- Jalankan `setup.bat` (Windows) atau `setup.sh` (Linux)
- Script akan membuat file `config.env` secara otomatis

**Opsi B: Manual edit**
- Buat file `config.env` dengan isi:
  ```
  DB_NAME=mahasiswa_db
  DB_USER=root
  DB_PASS=
  DB_HOST=localhost
  ```
- Atau edit langsung di `seed_data.py` (baris 13-20)

### 3. Buat Database (jika belum ada)

Masuk ke MySQL melalui command line atau phpMyAdmin dan buat database:

```sql
CREATE DATABASE mahasiswa_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Atau biarkan script `run.bat`/`run.sh` membuat database secara otomatis.

## Cara Menggunakan

### Opsi 1: Menggunakan Automation Script (Paling Mudah)

**Windows:**
```cmd
setup.bat    # Setup pertama kali
run.bat      # Jalankan migration & seeder
```

**Linux:**
```bash
./setup.sh   # Setup pertama kali
./run.sh     # Jalankan migration & seeder
```

### Opsi 2: Manual dengan Python

```bash
python seed_data.py
```

Script akan otomatis membaca konfigurasi dari `config.env` jika ada.

### Opsi 3: Manual Migration via MySQL

```bash
mysql -u root -p nama_database < migration.sql
python seed_data.py
```

## Struktur Tabel

Tabel `data_mahasiswa` memiliki struktur:

- **NPM** (INT, PRIMARY KEY, AUTO_INCREMENT) - Nomor Pokok Mahasiswa
- **Nama** (VARCHAR(255)) - Nama lengkap mahasiswa
- **Alamat** (VARCHAR(255)) - Alamat (Kota)
- **Hobi** (VARCHAR(255)) - Hobi mahasiswa
- **Asal_Sekolah** (VARCHAR(255)) - Asal sekolah mahasiswa

## Melihat Data di phpMyAdmin

1. Buka phpMyAdmin di browser
2. Pilih database yang telah dikonfigurasi
3. Klik pada tabel `data_mahasiswa`
4. Data akan tampil dengan 26 records

## Troubleshooting

### Error: "Access denied for user"
- Pastikan username dan password MySQL sudah benar
- Pastikan user memiliki hak akses ke database

### Error: "Unknown database"
- Pastikan database sudah dibuat terlebih dahulu
- Periksa nama database di konfigurasi

### Error: "Table already exists"
- Tabel sudah ada, script akan tetap berjalan untuk mengisi data
- Jika ingin reset, hapus tabel terlebih dahulu atau ubah `CREATE TABLE` menjadi `CREATE TABLE IF NOT EXISTS`

## Catatan

- Script akan menghapus data lama sebelum mengisi data baru
- NPM akan di-set sesuai dengan urutan data (1-26)
- Semua data menggunakan charset UTF-8 untuk mendukung karakter khusus
- File `config.env` akan dibuat otomatis oleh setup script
- Script Python akan otomatis membaca konfigurasi dari `config.env` jika ada

## Troubleshooting Automation Script

### Windows (setup.bat)

**Error: "Python tidak ditemukan"**
- Pastikan winget atau chocolatey sudah terinstall
- Atau install Python manual dari https://www.python.org/downloads/
- Pastikan centang "Add Python to PATH" saat instalasi

**Error: "Access denied"**
- Jalankan Command Prompt sebagai Administrator
- Atau install Python manual tanpa perlu admin rights

### Linux (setup.sh)

**Error: "Permission denied"**
```bash
chmod +x setup.sh run.sh
```

**Error: "sudo required"**
- Script akan meminta password sudo untuk install Python
- Atau install Python manual tanpa sudo jika sudah ada

**Error: "Package manager not found"**
- Install Python manual sesuai distribusi Linux Anda
- Ubuntu/Debian: `sudo apt-get install python3 python3-pip`
- CentOS/RHEL: `sudo yum install python3 python3-pip`
- Arch: `sudo pacman -S python python-pip`
