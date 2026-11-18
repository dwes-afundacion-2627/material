CREATE DATABASE IF NOT EXISTS expediciones
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE expediciones;

CREATE TABLE IF NOT EXISTS lectura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo TEXT NOT NULL,
    autor TEXT NOT NULL,
    paginas_total INT NOT NULL CHECK (paginas_total BETWEEN 1 AND 5000),
    paginas_leidas INT NOT NULL DEFAULT 0,
    CHECK (paginas_leidas BETWEEN 0 AND paginas_total)
) ENGINE=InnoDB;
