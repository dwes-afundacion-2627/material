<?php
declare(strict_types=1);

/*
 * DW5 · punto de partida de `public/ficha.php`.
 *
 * Copia este fichero a `public/ficha.php` de tu repositorio y rellena los huecos
 * marcados con TODO. El arranque, el orden de los seis bloques y la maquetacion
 * ya estan puestos: lo que falta son los datos y los calculos.
 */

// ---------------------------------------------------------------- 1. arranque
date_default_timezone_set('Europe/Madrid');
error_reporting(E_ALL);
ini_set('display_errors', '1');
ini_set('log_errors', '1');

// ------------------------------------------------- 2. configuracion del sitio
// `$cfg` es lo que la cabecera necesita para pintar el nombre y el lema.
$cfg = require __DIR__ . '/../src/config.php';

// ------------------------------------------------- 3. funciones facilitadas
// `h()` y `dias_entre()`.
require __DIR__ . '/../src/funciones.php';

// -------------------------------------------------------- 4. datos y calculos
// Todo lo que decide algo va AQUI. Abajo solo se coloca.

$titulo      = '';     // TODO texto de la mision; mete un `<` para ver el escape
$categoria   = '';     // TODO
$dificultad  = 0;      // TODO entero de 1 a 5
$plazas_tot  = 0;      // TODO entero mayor que cero
$plazas_lib  = 0;      // TODO entero entre 0 y $plazas_tot
$fecha       = '';     // TODO AAAA-MM-DD
$pronostico  = null;   // se queda en null en DW5

$hoy         = '';     // TODO fecha de referencia, AAAA-MM-DD

$ocupacion   = 0;      // TODO porcentaje entero de plazas ocupadas
$estrellas   = '';     // TODO barra de cinco posiciones: asteriscos y puntos
$dias        = 0;      // TODO dias naturales de $hoy a $fecha

$estado           = 'aberta';     // texto fijo en DW5; en DW6 pasa a ser una decision
$pronostico_texto = 'sen dato';   // idem

// ------------------------------------------------------------- 5. la cabecera
require __DIR__ . '/../plantillas/cabecera.php';
?>
<!-- ------------------------------------------------------ 6. aqui se pinta -->
<h2><?= h($titulo) ?></h2>
<p>Categoria: <?= h($categoria) ?> · Dificultade: <?= $estrellas ?> (<?= $dificultad ?>/5)</p>
<p>Prazas: <?= $plazas_lib ?> libres de <?= $plazas_tot ?> · ocupacion <?= $ocupacion ?> %</p>
<p>Data: <?= h($fecha) ?> (faltan <?= $dias ?> dias)</p>
<p>Estado: <?= h($estado) ?></p>
<p>Prognostico: <?= h($pronostico_texto) ?></p>
<?php require __DIR__ . '/../plantillas/pie.php'; ?>
