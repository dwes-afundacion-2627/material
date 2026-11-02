CREATE DATABASE IF NOT EXISTS expediciones
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE expediciones;

CREATE TABLE IF NOT EXISTS categoria_producto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS producto (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(1000) NOT NULL DEFAULT '',
    precio DECIMAL(8,2) NOT NULL,
    stock INT NOT NULL,
    categoria_id INT NOT NULL,
    CONSTRAINT fk_dw8_producto_categoria FOREIGN KEY (categoria_id)
        REFERENCES categoria_producto(id),
    CONSTRAINT ck_dw8_producto_precio CHECK (precio >= 0),
    CONSTRAINT ck_dw8_producto_stock CHECK (stock BETWEEN 0 AND 9999)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
