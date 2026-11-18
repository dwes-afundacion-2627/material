<?php
declare(strict_types=1);
require_once __DIR__ . '/../src/bd.php';
require_once __DIR__ . '/../src/funciones.php';
require_once __DIR__ . '/../src/lecturas.php';
require_once __DIR__ . '/../src/validacion_lecturas.php';

// TODO, ejercicio 3:
// - Preparar los valores iniciales del formulario.
// - Distinguir GET y POST; recuperar los valores enviados.
// - Validar y responder con errores o guardar y redirigir.
// - Procesar la petición antes de imprimir HTML.
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>Nueva lectura</title></head>
<body>
<h1>Nueva lectura</h1>
<?php require __DIR__ . '/../plantillas/formulario_lectura.php'; ?>
<p><a href="/listado.php">Volver al listado</a></p>
</body>
</html>
