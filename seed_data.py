#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Seeder script untuk data_mahasiswa
Menggunakan MySQL dengan Python
"""

import mysql.connector
from mysql.connector import Error
import sys
import os

# Load configuration from config.env file if exists
def load_config():
    """Load database configuration from config.env or use defaults"""
    config = {
        'host': 'localhost',
        'database': 'your_database_name',
        'user': 'root',
        'password': '',
        'charset': 'utf8mb4',
        'collation': 'utf8mb4_unicode_ci'
    }
    
    # Try to load from config.env file
    if os.path.exists('config.env'):
        try:
            with open('config.env', 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#') and '=' in line:
                        key, value = line.split('=', 1)
                        key = key.strip()
                        value = value.strip()
                        if key == 'DB_NAME':
                            config['database'] = value
                        elif key == 'DB_USER':
                            config['user'] = value
                        elif key == 'DB_PASS':
                            config['password'] = value
                        elif key == 'DB_HOST':
                            config['host'] = value
        except Exception as e:
            print(f"⚠ Warning: Tidak dapat membaca config.env: {e}")
    
    # Override with environment variables if available
    config['host'] = os.getenv('DB_HOST', config['host'])
    config['database'] = os.getenv('DB_NAME', config['database'])
    config['user'] = os.getenv('DB_USER', config['user'])
    config['password'] = os.getenv('DB_PASS', config['password'])
    
    return config

# Konfigurasi database
DB_CONFIG = load_config()

# Data mahasiswa dari CSV
DATA_MAHASISWA = [
    (1, "Aditya Kasyful Khofa", "Jakarta Utara", "Motoran", "SMA Yapenda"),
    (2, "Akmalul Achsan Al Amin", "Bekasi", "Motoran", "SMAN 1 Babelan"),
    (3, "Andy Rizki Cahyadi", "Jakarta Timur", "Badminton", "SMKN 22 Jakarta"),
    (4, "Angelia Ramadhanti Putri A.", "Tangerang", "Mendengarkan Musik", "SMAS Sumpah Pemuda Jakarta Barat"),
    (5, "Aziizah Ameliya Hussein", "Jakarta Timur", "Menonton Film", "MAN 2 Jakarta"),
    (6, "Azrinna Fajriani Ahadian", "Jakarta Utara", "Berenang", "SMAN 13 Jakarta"),
    (7, "Betaryu Muhammad Prima", "Jakarta Pusat", "Membaca Novel", "SMKN 14 Jakarta"),
    (8, "Didan Somagadi", "Jakarta Pusat", "Baca Komik", "SMA YP IPPI"),
    (9, "Eliezer Kandari", "Jakarta Utara", "Nonton Film", "SMAN 1 Toraja Utara"),
    (10, "Jonathan Aditya Septiawan H.", "Jakarta Utara", "Motoran", "SMK Hang Tuah 1 Jakarta"),
    (11, "Lea Alexandra Herlina", "Jakarta Pusat", "Basket", "SMKN 14 Jakarta"),
    (12, "Levant Romeo Satria", "Jakarta Pusat", "Basket", "SMAN 27 Jakarta"),
    (13, "Muhammad Gilang Ramdani", "Jakarta Utara", "Maca Tarot", "SMK Hang Tuah 2 Jakarta"),
    (14, "Muhammad Farsyah Fachrizal Herwin", "Kab. Bogor", "Basket dan Voli", "SMAN 15 Kota Bekasi"),
    (15, "Muhammad Rafli Aditya", "Jakarta Timur", "Gym", "DOSQ 12 Jakarta"),
    (16, "Muhammad Rakha Mubarak", "Jakarta Pusat", "Menggambar", "SMK Negeri 1 Cileungsi"),
    (17, "Najwaa Devinta Putri Santoso", "Jakarta Utara", "Badminton", "SMAS Tanjung Priok"),
    (18, "Pratama Rakaputra Nova Zigni", "Jakarta Pusat", "Mendengarkan Musik", "SMAN 1 Randudongkal"),
    (19, "Sabrina Khaerun Nisa", "Jakarta Pusat", "Baca Novel", "SMKN 1 Jakarta"),
    (20, "Seylma Esha Marleoni Nitsa E.", "Jakarta Utara", "Baca Webtoon", "SMAS Sentosa Abadi"),
    (21, "Siti Aminah", "Jakarta Timur", "Nonton Drakor", "SMAN 88 Jakarta"),
    (22, "Syafiqa Salsabila", "Jakarta Barat", "Membaca", "SMKS AA"),
    (23, "Windy Wiritanaya", "Jakarta Utara", "Membaca", "SMAN 41 Jakarta"),
    (24, "Wit Urrohman", "Jakarta Selatan", "Basket", "SMKN 22 Jakarta"),
    (25, "Zakiya Nabila Arsya", "Jakarta Utara", "Nyemil", "SMKN 71 Jakarta"),
    (26, "Zourast Kristiandika", "Jakarta Timur", "Menulis", "SMAN 31 Jakarta"),
]


def create_connection():
    """Membuat koneksi ke database MySQL"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        if connection.is_connected():
            print("✓ Berhasil terhubung ke MySQL database")
            return connection
    except Error as e:
        print(f"✗ Error connecting to MySQL: {e}")
        sys.exit(1)


def run_migration(connection):
    """Menjalankan migration untuk membuat tabel"""
    try:
        cursor = connection.cursor()
        
        # Membaca file migration.sql
        with open('migration.sql', 'r', encoding='utf-8') as f:
            migration_sql = f.read()
        
        # Menjalankan setiap statement
        for statement in migration_sql.split(';'):
            statement = statement.strip()
            if statement:
                cursor.execute(statement)
        
        connection.commit()
        print("✓ Migration berhasil dijalankan")
        cursor.close()
    except Error as e:
        print(f"✗ Error running migration: {e}")
        connection.rollback()
        sys.exit(1)


def seed_data(connection):
    """Mengisi data ke tabel data_mahasiswa"""
    try:
        cursor = connection.cursor()
        
        # Menghapus data lama jika ada (optional)
        cursor.execute("DELETE FROM data_mahasiswa")
        
        # Query untuk insert data
        insert_query = """
        INSERT INTO data_mahasiswa (NPM, Nama, Alamat, Hobi, Asal_Sekolah)
        VALUES (%s, %s, %s, %s, %s)
        """
        
        # Insert semua data
        cursor.executemany(insert_query, DATA_MAHASISWA)
        connection.commit()
        
        print(f"✓ Berhasil menambahkan {len(DATA_MAHASISWA)} data mahasiswa")
        cursor.close()
    except Error as e:
        print(f"✗ Error seeding data: {e}")
        connection.rollback()
        sys.exit(1)


def verify_data(connection):
    """Memverifikasi data yang telah di-insert"""
    try:
        cursor = connection.cursor()
        cursor.execute("SELECT COUNT(*) FROM data_mahasiswa")
        count = cursor.fetchone()[0]
        print(f"✓ Total data di database: {count} records")
        
        # Menampilkan beberapa sample data
        cursor.execute("SELECT NPM, Nama, Alamat FROM data_mahasiswa LIMIT 5")
        records = cursor.fetchall()
        print("\nSample data:")
        for record in records:
            print(f"  NPM: {record[0]}, Nama: {record[1]}, Alamat: {record[2]}")
        
        cursor.close()
    except Error as e:
        print(f"✗ Error verifying data: {e}")


def main():
    """Fungsi utama"""
    print("=" * 50)
    print("Seeder Data Mahasiswa")
    print("=" * 50)
    
    # Membuat koneksi
    connection = create_connection()
    
    try:
        # Menjalankan migration
        print("\n[1/3] Menjalankan migration...")
        run_migration(connection)
        
        # Mengisi data
        print("\n[2/3] Mengisi data...")
        seed_data(connection)
        
        # Verifikasi data
        print("\n[3/3] Memverifikasi data...")
        verify_data(connection)
        
        print("\n" + "=" * 50)
        print("✓ Selesai! Data dapat dilihat di phpMyAdmin")
        print("=" * 50)
        
    finally:
        if connection.is_connected():
            connection.close()
            print("\n✓ Koneksi database ditutup")


if __name__ == "__main__":
    main()
