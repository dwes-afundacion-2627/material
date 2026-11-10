CREATE DATABASE IF NOT EXISTS expediciones
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE expediciones;

DROP TABLE IF EXISTS participacion;
DROP TABLE IF EXISTS pronostico_mision;
DROP TABLE IF EXISTS cronica;
DROP TABLE IF EXISTS mision;
DROP TABLE IF EXISTS usuario;

CREATE TABLE usuario (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  email      VARCHAR(190) NOT NULL UNIQUE,
  alias      VARCHAR(60)  NOT NULL,        -- lo que se ve en la clasificacion:
  nombre     VARCHAR(120) NOT NULL,        -- nunca el nombre completo proyectado
  clave_hash VARCHAR(255) NOT NULL,        -- password_hash(), nunca en claro
  rol        ENUM('aventurero','maestre') NOT NULL DEFAULT 'aventurero',
  creado_en  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE mision (
  id                 INT AUTO_INCREMENT PRIMARY KEY,
  titulo             VARCHAR(200) NOT NULL,
  descripcion        TEXT,
  imagen_url         VARCHAR(500),
  categoria          VARCHAR(60)  NOT NULL,
  dificultad         TINYINT      NOT NULL,
  plazas_total       INT          NOT NULL DEFAULT 1,
  plazas_disponibles INT          NOT NULL DEFAULT 1,
  latitud            DECIMAL(8,5) NOT NULL,
  longitud           DECIMAL(8,5) NOT NULL,
  fecha              DATE         NOT NULL,
  preparacion_a      VARCHAR(80)  NOT NULL,
  preparacion_b      VARCHAR(80)  NOT NULL,
  preparacion_c      VARCHAR(80)  NOT NULL,
  preparacion_recomendada ENUM('a','b','c') NOT NULL,
  creado_en          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT plazas_en_rango CHECK (plazas_disponibles >= 0
                                    AND plazas_disponibles <= plazas_total),
  CONSTRAINT dificultad_en_rango CHECK (dificultad BETWEEN 1 AND 5)
) ENGINE=InnoDB;

CREATE TABLE cronica (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  mision_id  INT NOT NULL,
  usuario_id INT NULL,                     -- NULL = cronica anonima
  texto      VARCHAR(2000) NOT NULL,
  creado_en  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (mision_id)  REFERENCES mision(id)  ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE participacion (
  id                   INT AUTO_INCREMENT PRIMARY KEY,
  mision_id            INT NOT NULL,
  usuario_id           INT NOT NULL,
  estado               ENUM('reservada','completada','cancelada')
                         NOT NULL DEFAULT 'reservada',
  preparacion          ENUM('a','b','c') NOT NULL,
  preparacion_adecuada TINYINT(1) NOT NULL DEFAULT 0,
  riesgo_aplicado      TINYINT    NOT NULL DEFAULT 0,   -- se congela al reservar
  puntos               INT        NOT NULL DEFAULT 0,
  fecha_alta           DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_fin            DATETIME   NULL,
  reserva_viva         TINYINT(1) AS (IF(estado = 'reservada', 1, NULL)) STORED,
  UNIQUE KEY una_reserva_viva (mision_id, usuario_id, reserva_viva),
  FOREIGN KEY (mision_id)  REFERENCES mision(id)  ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
  CONSTRAINT riesgo_aplicado_en_rango CHECK (riesgo_aplicado BETWEEN 0 AND 2)
) ENGINE=InnoDB;

CREATE TABLE pronostico_mision (
  mision_id        INT PRIMARY KEY,
  fuente           VARCHAR(60)  NOT NULL,
  codigo_tiempo    INT          NULL,
  temperatura_max  DECIMAL(4,1) NULL,
  precipitacion    INT          NULL,      -- probabilidad, 0-100
  viento_max       DECIMAL(5,1) NULL,      -- km/h
  factor_dominante ENUM('lluvia','viento','temperatura','ninguno') NOT NULL,
  riesgo           TINYINT      NOT NULL,  -- 0 bajo · 1 medio · 2 alto
  recomendacion    VARCHAR(200) NOT NULL,
  json_original    TEXT         NULL,
  actualizado_en   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (mision_id) REFERENCES mision(id) ON DELETE CASCADE,
  CONSTRAINT riesgo_en_rango CHECK (riesgo BETWEEN 0 AND 2)
) ENGINE=InnoDB;
