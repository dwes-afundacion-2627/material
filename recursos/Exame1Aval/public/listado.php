<?php
declare(strict_types=1);
require __DIR__ . '/../src/bd.php';
require __DIR__ . '/../src/funciones.php';
require __DIR__ . '/../src/lecturas.php';

// TODO: ejercicios 1, 2 y 5:
// - Recoger y validar el parámetro del filtro.
// - Conectar y recuperar todas las lecturas.
// - Calcular el resumen y obtener las lecturas visibles.
// - Establecer los códigos HTTP necesarios antes de imprimir HTML.
// Puedes añadir las variables y funciones auxiliares que necesites.
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>Registro de lecturas</title></head>
<body>
<h1>Registro de lecturas</h1>
<p><a href="/nueva_lectura.php">Añadir lectura</a></p>

<!-- TODO: formulario de máximo de páginas pendientes ejercicio 5 -->
<!-- TODO: conservar el filtro, mostrar su valor inicial y explicar cómo ver todas. -->
<!-- TODO: mostrar los errores cuando corresponda. -->

<h2>Resumen de todas las lecturas</h2>
<p>Total: <!-- TODO --></p>
<p>Terminadas: <!-- TODO --></p>
<p>Páginas pendientes: <!-- TODO --></p>

<h2>Listado</h2>
<!-- TODO: decidir cuándo mostrar la tabla y cuándo el mensaje sin resultados. -->
<table>
    <thead>
        <tr><th>Título</th><th>Autor</th><th>Leídas / totales</th><th>Pendientes</th><th>Estado</th></tr>
    </thead>
    <tbody>
        <!-- TODO: generar las filas con PHP y enlazar cada título con su ficha. -->
    </tbody>
</table>
</body>
</html>
