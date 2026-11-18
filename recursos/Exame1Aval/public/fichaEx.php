<?php
declare(strict_types=1);
require_once __DIR__ . '/../src/bd.php';
require_once __DIR__ . '/../src/funciones.php';
require_once __DIR__ . '/../src/lecturas.php';

// TODO, ejercicio 4:
// - Recoger y validar el ID.
// - Consultar la lectura y distinguir ID incorrecto de lectura inexistente.
// - Establecer los códigos HTTP antes del HTML.
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>Ficha de lectura</title></head>
<body>
<h1>Ficha de lectura</h1>
<!-- TODO: mostrar un mensaje de error o los datos de la lectura, según corresponda. -->
<h2><!-- Título --></h2>
<p>Autor: <!-- TODO --></p>
<p>Páginas totales: <!-- TODO --></p>
<p>Páginas leídas: <!-- TODO --></p>
<p>Páginas pendientes: <!-- TODO --></p>
<p>Estado: <!-- TODO --></p>
<p><a href="/listado.php">Volver al listado</a></p>
</body>
</html>
