USE expediciones;

DELETE FROM participacion;
DELETE FROM pronostico_mision;
DELETE FROM cronica;
DELETE FROM mision;
DELETE FROM usuario;

INSERT INTO usuario (id, email, alias, nombre, clave_hash, rol) VALUES
  (1, 'maestre@centro.local',     'Maestre',   'Maestre de prueba',
      '$2y$10$a3RNmtcBqt6W1hDlpfLO4earwVjHcx2P2e6Gyu9Ygbj3KKf1ezgQC', 'maestre'),
  (2, 'aventurero1@centro.local', 'Aventurera1', 'Aventurera de prueba uno',
      '$2y$10$R83OKs4uLj1OvN0ZaZirhukNnG0XKgu1gw3xiwTAkhERKoldIM5Iu', 'aventurero'),
  (3, 'aventurero2@centro.local', 'Aventurero2', 'Aventurero de prueba dos',
      '$2y$10$R83OKs4uLj1OvN0ZaZirhukNnG0XKgu1gw3xiwTAkhERKoldIM5Iu', 'aventurero');

INSERT INTO mision (id, titulo, descripcion, imagen_url, categoria, dificultad,
                    plazas_total, plazas_disponibles, latitud, longitud, fecha,
                    preparacion_a, preparacion_b, preparacion_c,
                    preparacion_recomendada) VALUES
  (1, 'Mision con tres plazas', 'Descripcion de prueba', NULL, 'exploracion', 2,
      3, 3, 43.36210, -8.41150, '2026-10-15',
      'Equipo ligero', 'Equipo impermeable', 'Equipo de escalada', 'a'),
  (2, 'Mision con la ultima plaza', 'Descripcion de prueba', NULL, 'rescate', 4,
      1, 1, 42.87800, -8.54480, '2026-10-20',
      'Equipo ligero', 'Equipo impermeable', 'Equipo de escalada', 'b'),
  (3, 'Mision agotada', 'Descripcion de prueba', NULL, 'vigilancia', 3,
      2, 0, 42.24060, -8.72070, '2026-10-25',
      'Equipo ligero', 'Equipo impermeable', 'Equipo de escalada', 'c');

INSERT INTO cronica (mision_id, usuario_id, texto) VALUES
  (1, 2, 'Cronica firmada de prueba'),
  (1, NULL, 'Cronica anonima de prueba');

INSERT INTO pronostico_mision (mision_id, fuente, codigo_tiempo, temperatura_max,
                               precipitacion, viento_max, factor_dominante,
                               riesgo, recomendacion) VALUES
  (1, 'doble-local', 61, 14.0, 80, 50.0, 'lluvia', 2,
      'Lluvia y viento fuerte: se recomienda equipo impermeable');
