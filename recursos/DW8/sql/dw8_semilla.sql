USE expediciones;
START TRANSACTION;
DELETE FROM producto;
DELETE FROM categoria_producto;

INSERT INTO categoria_producto (id, nombre) VALUES
    (1, 'Papelería'),
    (2, 'Accesorios'),
    (3, 'Electrónica'),
    (4, 'Hogar');

INSERT INTO producto (id, nombre, descripcion, precio, stock, categoria_id) VALUES
    (1, 'Cuaderno', 'Cuaderno de papel reciclado', 2.50, 12, 1),
    (2, 'Mochila', 'Mochila ligera para uso diario', 24.90, 5, 2),
    (3, 'Lámpara', 'Lámpara de lectura', 18.00, 0, 3),
    (4, 'Auriculares', 'Auriculares con cable', 35.50, 8, 3),
    (5, 'Estuche "Azul" <Mini>', 'Estuche compacto', 6.75, 3, 1);
COMMIT;
