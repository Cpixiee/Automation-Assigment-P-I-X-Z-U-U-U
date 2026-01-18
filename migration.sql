-- Migration: Create data_mahasiswa table
-- Database: MySQL
-- Table: data_mahasiswa

CREATE TABLE IF NOT EXISTS `data_mahasiswa` (
  `NPM` INT NOT NULL AUTO_INCREMENT,
  `Nama` VARCHAR(255) NOT NULL,
  `Alamat` VARCHAR(255) NOT NULL,
  `Hobi` VARCHAR(255) NOT NULL,
  `Asal_Sekolah` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`NPM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
