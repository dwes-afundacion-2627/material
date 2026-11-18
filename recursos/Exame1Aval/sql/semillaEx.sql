USE expediciones;
START TRANSACTION;
DELETE FROM lectura;
INSERT INTO lectura (id, titulo, autor, paginas_total, paginas_leidas) VALUES
    (1, 'El bosque de cristal', 'Ana Vidal', 100, 0),
    (2, 'La última estación', 'Luis Romero', 200, 50),
    (3, 'Cuaderno del norte', 'Marta Lago', 80, 80),
    (4, 'Viaje sin mapa', 'Pablo Costa', 150, 100);
COMMIT;
