# DW7 · Formularios y datos que vienen del cliente

**Desarrollo web en entorno servidor · 2.º DAW · Apuntes**

## Al terminar esta unidad vas a saber

- Construir un formulario y explicar qué información envía.
- Recuperar datos de la URL y de un formulario con `$_GET` y `$_POST`.
- Conectar los filtros de DW6 con una petición real del navegador.
- Validar en PHP los datos recibidos, incluidos campos ausentes o manipulados.
- Mostrar errores concretos sin hacer que la persona tenga que rellenarlo todo otra vez.
- "Guardar" datos válidos y redirigir para que recargar la página no repita el envío anterior.

### Preparación de los ejemplos

Trabaja sobre una copia de prácticas o dentro de tu repositorio, respetando esta organización:

```text
proyecto/
├── public/
│   └── DW7/
│       ├── g1.php
│       ├── g2.php
│       ├── g3.php
│       ├── g4.php
│       └── g5.php
├── src/
│   ├── funciones.php                 # h(), dias_entre() y funciones de DW6
│   ├── tablon.php                    # misiones() de DW6
│   ├── formularios_demo.php          # Apoyo creado en G3
│   └── talleres_demo.php             # Apoyo creado en G6
└── plantillas/
    └── formulario_taller_demo.php    # Creada en G4

```


**Importante**. Necesitas la extensión `mbstring` de PHP para trabajar con longitudes de texto mediante `mb_strlen()`:

```bash
sudo apt install php-mbstring
sudo systemctl restart apache2
```
## Punto de partida: ahora los datos los escribe otra persona

En DW6, tú escribías el array de misiones y elegías los argumentos de los filtros:

```php
$visibles = filtrar($tablon, 'exploracion', true);
```

Sabías qué valores ibas a recibir porque estaban en tu propio código. En DW7, esos valores pueden proceder de una URL o de un formulario. Pueden estar vacíos, faltar, tener un formato incorrecto o haber sido manipulados.

El recorrido que vamos a construir es:

```text
Formulario o URL
       ↓
PHP recibe los datos
       ↓
PHP comprueba si cumplen las reglas
       ↓
¿Hay errores?
  Sí → mostrar errores y conservar lo escrito
  No → guardar y redirigir al listado
```

Enviar un dato no significa que sea válido. Recibirlo, validarlo, guardarlo y mostrarlo son pasos diferentes.

---

## 1. Construir un formulario y recibir sus datos


### La explicación

Un formulario agrupa controles: cuadros de texto, desplegables, casillas, botones… Al enviarlo, el navegador construye una petición HTTP con los datos de los controles que corresponda enviar.

Tres atributos fundamentales:

| Atributo | Ejemplo | Significado |
|---|---|---|
| `action` | `/DW7/g1.php` | Dirección que recibirá el envío. |
| `method` | `post` | Método HTTP utilizado para enviar el formulario. |
| `name` | `nombre` | Clave con la que PHP podrá recuperar el valor de ese campo. |

`id` y `name` tienen funciones diferentes. El `id` identifica un elemento HTML y permite asociarlo a su etiqueta mediante `for`. El `name` identifica el dato que se envía.

```html
<label for="nombre">Nombre</label>
<input id="nombre" name="nombre" type="text">
```

Aquí coinciden, pero podrían ser distintos. Un campo con `id` y sin `name` puede verse perfectamente y, aun así, no enviar su valor.

### Dos peticiones distintas a la misma página

Al abrir la dirección desde la barra del navegador, normalmente llega un **GET**. Al pulsar el botón de un formulario con `method="post"`, llega un **POST**.

PHP puede distinguirlos:

```php
$metodo = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($metodo === 'POST') {
    // Procesar el formulario enviado.
}
```

### Cómo se recupera un campo

En un formulario POST convencional, PHP coloca los campos en `$_POST`:

```php
$nombre = $_POST['nombre'] ?? '';
```

El operador `??` proporciona un valor alternativo si la clave no existe o contiene `null`. Evita el aviso por acceder a una clave ausente, pero **no valida el dato**.

Los campos escalares de un formulario llegan normalmente como cadenas: un `input type="number"` con 4 suele llegar como `"4"`, no como el entero `4`. Además, PHP admite campos de formulario con sintaxis de array, como `nombre[]`. Una petición manipulada podría enviarte un array donde esperabas texto.

Por eso, cuando esperamos texto, comprobaremos también su tipo antes de usar funciones de cadenas:

```php
$nombre = $_POST['nombre'] ?? '';
if (!is_string($nombre)) {
    $nombre = '';
}
```

En nuestros ejemplos, un tipo inesperado se tratará como un campo vacío y la validación lo rechazará cuando sea obligatorio.

### En directo · G1 · ¿Qué recibe PHP?

**Enunciado:** crea un formulario con nombre y número de plazas. Al enviarlo, muestra los valores recibidos y una inspección del array `$_POST`.

**Antes de ejecutar:** si escribes 4 en el campo numérico, ¿llegará a PHP como entero o como cadena?

**Archivo completo:** `public/DW7/g1.php`.

```php
<?php
declare(strict_types=1);
    require __DIR__ . '../../../src/funciones.php';
    
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $metodo = 'POST';
    } elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $metodo = 'GET';
    }
    
    $nombre = $_POST['nombre'] ?? '';
    $plazas = $_POST['plazas'] ?? '';
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>G1 · Recibir un formulario</title></head>
<body>
    <h1>Solicitud de taller</h1>
    <form method="post" action="/DW7/g1.php">
        <label for="nombre">Nombre</label>
        <input id="nombre" name="nombre" type="text">
        <label for="plazas">Plazas</label>
        <input id="plazas" name="plazas" type="number" min="1" max="5">
        <button type="submit">Enviar</button>
    </form>
    <?php if ($metodo === 'POST'): ?>
        <h2>Datos recibidos</h2>
        <p>Nombre: <?= h($nombre) ?></p>
        <p>Plazas recibidas como texto: <?= h($plazas) ?></p>
        <pre><?= h(print_r($_POST, true)) ?></pre>
        <p>¿Las plazas son una cadena? <?= is_string($_POST['plazas'] ?? null) ? 'Sí' : 'No' ?></p>
    <?php endif; ?>
</body>
</html>
```

**Paso a paso:**

1. La primera visita es un GET: se muestra el formulario, sin el bloque de resultados.
2. Al enviarlo, el navegador hace un POST a la dirección de `action`.
3. PHP recupera los campos mediante sus nombres y prepara las variables.
4. El HTML muestra esas variables con `h()`.
5. `print_r($_POST, true)` devuelve una representación textual del array. `h()` la escapa y `<pre>` conserva su distribución. Es una comprobación auxiliar.

**Resultado esperado:** con Ana y 4, aparecen esos dos valores y la comprobación del tipo indica «Sí». Todavía no estamos validando ni guardando.

**Fallo provocado y recuperación:** quita `name="plazas"`, envía y observa que la clave desaparece de la inspección. Restaura el atributo.

---

## 2. GET: consultar y filtrar desde la URL

### La explicación

Una URL puede incluir una cadena de consulta después de `?`:

```text
/DW7/g2.php?categoria=exploracion&libres=1
```

Hay dos parámetros: `categoria`, con el valor `exploracion`, y `libres`, con el valor `1`. El carácter `&` separa los pares. PHP los interpreta y los coloca en `$_GET`.

| Necesidad | Método habitual en esta unidad |
|---|---|
| Consultar un tablón, buscar o filtrar | GET |
| Dar de alta una misión y modificar datos guardados | POST |

GET permite copiar, compartir y guardar un enlace con los filtros. POST envía los campos en el cuerpo de la petición, pero **no los cifra por sí mismo**: el cifrado del transporte lo proporciona HTTPS.


### Ausencia, cadena vacía y casillas

No recibir `categoria` y recibir `categoria=` son situaciones diferentes: la primera no tiene esa clave; la segunda contiene una cadena vacía.

Para nuestro filtro, ambas significarán «todas las categorías», así que las convertimos a `null` antes de llamar a `filtrar()`.

Una casilla sin marcar normalmente no envía su campo. Por eso en este ejercicio `isset($_GET['libres'])` activa el filtro cuando el parámetro está presente. Con este contrato, incluso `?libres=0` lo activa: se comprueba la presencia, no el significado numérico del texto.

### En directo · G2 · Conectar el filtro de DW6

**Enunciado:** conserva `misiones()` y `filtrar()` de DW6. Añade una entrada por URL y un formulario GET para seleccionar categoría y exigir plazas libres.

**Antes de ejecutar:** al aplicar un filtro, ¿debe cambiar el total de plazas del tablón completo?

**Archivo completo:** `public/DW7/g2.php`.

```php
<?php
    declare(strict_types=1);
    require __DIR__ . '/../../src/funciones.php';
    require __DIR__ . '/../../src/tablon.php';

    $categoria = $_GET['categoria'] ?? null;
    if (!is_string($categoria)) {
        $categoria = null;
    } else {
        $categoria = trim($categoria);
        if ($categoria === '') {
            $categoria = null;
        }
    }

    $solo_libres = isset($_GET['libres']);
    $tablon = misiones();
    $visibles = filtrar($tablon, $categoria, $solo_libres);
    $cantidad = count($tablon);
    $cantidad_visible = count($visibles);
    $total_libres = plazas_libres_totales($tablon);
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>G2 · Filtros GET</title></head>
<body>
    <h1>Tablón filtrado</h1>
    <form method="get" action="/DW7/g2.php">
        <label for="categoria">Categoría</label>
        <input id="categoria" name="categoria" value="<?= h($categoria ?? '') ?>">
        <label><input type="checkbox" name="libres" value="1" <?= $solo_libres ? 'checked' : '' ?>> Solo con plazas</label>
        <button type="submit">Filtrar</button>
    </form>
    <p><?= $cantidad_visible ?> de <?= $cantidad ?> misiones · <?= $total_libres ?> plazas libres en total</p>
    <?php if ($visibles === []): ?>
        <p class="vacio">No hay misiones que cumplan el filtro.</p>
    <?php endif; ?>
    <?php foreach ($visibles as $m): ?>
        <div class="mision">
            <h2><?= h($m['titulo']) ?></h2>
            <p><?= h($m['categoria']) ?> · <?= $m['plazas_libres'] ?> plazas libres.</p>
        </div>
    <?php endforeach; ?>
</body>
</html>
```

**Paso a paso:** recuperamos los parámetros, adaptamos sus valores al contrato de la función, llamamos a `filtrar()` y mostramos su resultado. La función no lee `$_GET`: sigue recibiendo argumentos, igual que en DW6.

**Comprueba:** URL sin parámetros; `?categoria=exploracion`; `?libres=1`; ambos; `?categoria=inventada`; `?categoria=`. Usa una categoría que exista en tus datos y otra que no exista.

**Fallo provocado y recuperación:** elimina temporalmente la conversión de `''` a `null`. Envía el campo de categoría vacío y observa cómo el filtro busca una categoría vacía. Restaura la conversión.

---

## 3. Validar: comprobar antes de aceptar

### La explicación

Este formulario dice que la dificultad va de 1 a 5:

```html
<input name="dificultad" type="number" min="1" max="5" required>
```

Y esto es lo que pasa cuando alguien no usa tu formulario. **Ejecutado de verdad
contra la aplicación del sprint 1:**

```
$ curl -i -X POST http://localhost:8000/gestor/mision \
    -d "titulo=A torre&categoria=exploracion&dificultad=9&plazas_total=3" \
    -d "fecha=2027-03-14&preparacion_a=A&preparacion_b=B&preparacion_c=C" \
    -d "preparacion_recomendada=b"
```

El `min`, el `max` y el `required` **no han impedido nada**: no son del servidor, son
del navegador, y `curl` no es un navegador. Lo mismo se consigue abriendo las
herramientas de desarrollo y borrando el atributo, en cinco segundos.

> **La validación del navegador es comodidad. La del servidor es seguridad.**
>
> La del navegador avisa sin recargar y se agradece. La del servidor es la que decide
> si el dato entra. **Se necesitan las dos, y una no sustituye a la otra.**

Y esto es lo que contestó **el servidor** de la aplicación bien hecha:

```
HTTP/1.1 422 Unprocessable Content
...
<div class="errores">
  <p>La mision no se ha guardado. Corrige esto:</p>
  <ul>
    <li data-campo="dificultad">La dificultad va de 1 a 5</li>
```

La misión **no se guardó**.

Validar consiste en comprobar si un dato cumple unas reglas. Convertirlo a otro tipo no demuestra que fuera correcto.

```php
$numero = (int) '9 plazas'; // Produce 9: no sirve para rechazar esa entrada.
```

Si necesitamos un entero, primero lo validamos:

```php
$numero = filter_var($texto, FILTER_VALIDATE_INT);
if ($numero === false) {
    // No se ha obtenido un entero válido.
}
```

`"0"` puede producir el entero `0`. Por eso usamos `=== false`: distingue el cero del fallo. Después comprobamos el rango permitido. Que cero sea un entero no significa que sea una cantidad de plazas admitida.

### Las herramientas que vamos a utilizar

| Regla | Herramienta | Qué debes entender |
|---|---|---|
| Eliminar espacios de los extremos | `trim()` | `"   "` pasa a `""`; no elimina espacios entre palabras. |
| Campo obligatorio | Comparar con `''` | Un texto vacío no cumple la regla. |
| Longitud máxima | `mb_strlen($texto, 'UTF-8')` | Cuenta caracteres; `strlen()` cuenta bytes. |
| Entero válido | `FILTER_VALIDATE_INT` | Devuelve un entero o `false`. |
| Rango | Comparaciones con límites | Se comprueba después de validar el entero. |
| Opción permitida | `in_array($valor, ['a', 'b', 'c'], true)` | El tercer argumento exige también coincidencia de tipo. |
| Fecha existente | Crear la fecha y volver a formatearla | Detecta fechas que PHP normaliza, como un día inexistente de febrero. |

Normalizar puede significar quitar espacios o convertir una cadena numérica validada en entero. No significa cambiar silenciosamente una dificultad 9 por 5 para aceptarla.

### Una fecha no es válida solo por tener guiones

`2027-02-31` parece tener el formato esperado, pero no existe. PHP puede normalizar esa entrada a una fecha de marzo.

```php
$d = DateTimeImmutable::createFromFormat('!Y-m-d', $fecha);
if ($d === false || $d->format('Y-m-d') !== $fecha) {
    // La fecha no existe o no coincide con el formato exigido.
}
```

El `!` reinicia los componentes no indicados, como la hora. La comprobación importante para detectar la normalización es volver a obtener `Y-m-d` y compararlo con la cadena recibida.

Una vez comprobado el formato exacto y la existencia, las cadenas `AAAA-MM-DD` se pueden comparar para decidir si la fecha está antes de `$hoy`. Esta comparación no debe trasladarse sin más a cadenas como `DD/MM/AAAA`.

```php
$fecha = '2027-02-30';
$d = DateTimeImmutable::createFromFormat('!Y-m-d', $fecha);

// PHP ajusta el 30 de febrero al 2 de marzo.
$d->format('Y-m-d'); // '2027-03-02'
```

### La función devuelve dos cosas juntas

La función de validación devuelve un array de dos posiciones:

```php
return [$datos, $errores];
```

La primera contiene los datos preparados. La segunda contiene los mensajes, asociados al nombre del campo. Un array de errores vacío significa que se han superado las comprobaciones.

```php
[$datos, $errores] = validar_taller($entrada, $hoy);
```

Esta escritura se llama **desestructuración**. Equivale a guardar primero el resultado y después tomar su posición 0 y su posición 1. No hay dos retornos independientes.

La función recibe `$hoy` como argumento para poder probarla con una fecha fija. No guarda archivos, no muestra HTML y no redirige.

### En directo · G3 · Validar un taller sin navegador

**Enunciado:** valida nombre obligatorio de hasta 60 caracteres, plazas enteras entre 1 y 5 y una fecha existente que no sea anterior a hoy. Primero prueba la función con datos escritos en el código; después la conectaremos al formulario.

**Antes de ejecutar:** ¿qué debería ocurrir con `"0"`, `"3 personas"` y una fecha imposible?

**Archivo completo de apoyo:** `src/formularios_demo.php`.

```php
<?php
declare(strict_types=1);

/**
 * Recupera un campo de texto sin aceptar arrays en su lugar.
 * @param array $entrada Datos recibidos.
 * @param string $campo Nombre del campo.
 * @return string Texto recibido, o cadena vacía si falta o no es una cadena.
 */
function leer_texto(array $entrada, string $campo): string
{
    $valor = $entrada[$campo] ?? '';
    if (!is_string($valor)) {
        return '';
    }
    return $valor;
}

/**
 * Valida los tres campos del taller.
 * @param array $entrada Datos del formulario.
 * @param string $hoy Fecha de referencia válida en formato AAAA-MM-DD.
 * @return array Dos posiciones: datos normalizados y errores por campo.
 */
function validar_taller(array $entrada, string $hoy): array
{
    $errores = [];
    $datos = [];

    $datos['nombre'] = trim(leer_texto($entrada, 'nombre'));
    if ($datos['nombre'] === '') {
        $errores['nombre'] = 'Escribe un nombre.';
    } elseif (mb_strlen($datos['nombre'], 'UTF-8') > 60) {
        $errores['nombre'] = 'El nombre no puede superar 60 caracteres.';
    }

    $texto_plazas = leer_texto($entrada, 'plazas');
    $plazas = filter_var($texto_plazas, FILTER_VALIDATE_INT);
    if ($plazas === false || $plazas < 1 || $plazas > 5) {
        $errores['plazas'] = 'Las plazas deben ser un entero de 1 a 5.';
        $datos['plazas'] = null;
    } else {
        $datos['plazas'] = $plazas;
    }

    $datos['fecha'] = trim(leer_texto($entrada, 'fecha'));
    $d = DateTimeImmutable::createFromFormat('!Y-m-d', $datos['fecha']);
    if ($d === false || $d->format('Y-m-d') !== $datos['fecha']) {
        $errores['fecha'] = 'Escribe una fecha existente con formato AAAA-MM-DD.';
        $datos['fecha'] = null;
    } elseif ($datos['fecha'] < $hoy) {
        $errores['fecha'] = 'La fecha no puede ser anterior a hoy.';
        $datos['fecha'] = null;
    }

    return [$datos, $errores];
}
```

**Archivo completo para probarla:** `public//DW7/g3.php`.

```php
<?php
    declare(strict_types=1);
    ini_set('display_errors', '1');
    require __DIR__ . '/../../src/funciones.php';
    require __DIR__ . '/../../src/formularios_demo.php';

    $entrada = ['nombre' => 'Orientación', 'plazas' => '3', 'fecha' => '2027-03-14'];
    $hoy = '2027-03-01';
    [$datos, $errores] = validar_taller($entrada, $hoy);
?>

<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>G3 · Validación</title></head>
<body>
    <h1>Resultado de la validación</h1>
    <?php if ($errores === []): ?>
        <p>Los datos son válidos. Esta prueba todavía no guarda nada.</p>
    <?php else: ?>
        <ul>
        <?php foreach ($errores as $campo => $mensaje): ?>
            <li><?= h($campo) ?>: <?= h($mensaje) ?></li>
        <?php endforeach; ?>

        <?php /* foreach (array_keys($errores) as $campo): ?>
            <li><?= h($campo) ?>: <?= h($errores[$campo]) ?></li>
        <?php endforeach; */ ?>
        </ul>
    <?php endif; ?>
    <h2>Datos preparados</h2>
    <pre><?= h(print_r($datos, true)) ?></pre>
</body>
</html>
```

**Paso a paso:**

1. `leer_texto()` recupera cadenas sin avisos por claves ausentes ni conversiones de arrays a texto.
2. `validar_taller()` comprueba cada regla y añade los errores por nombre de campo.
3. Si las plazas son correctas, las guarda como entero. Si no, usa `null`; esos datos no deberán guardarse porque hay un error.
4. La página decide qué HTML mostrar a partir del array de errores.

**Resultado esperado:** el caso inicial no produce errores y devuelve 3 como entero. Cambia un dato cada vez para comprobar las demás ramas.

**Fallo provocado y recuperación:** sustituye temporalmente la validación del entero por un simple cast `(int)` y prueba `"3 personas"`. Observa por qué convertir no equivale a validar. Restaura `FILTER_VALIDATE_INT`.

---

## 4. Responder a un error sin perder lo escrito

### La explicación

Cuando una persona rellena varios campos y se equivoca en uno, necesita saber qué corregir y conservar lo demás.

La respuesta tendrá tres componentes:

1. **Estado HTTP 422:** se ha procesado la petición, pero los datos no cumplen las reglas.
2. **Mensajes concretos:** asociados a cada campo incorrecto.
3. **Formulario relleno:** con los valores que había enviado, escapados al introducirlos en HTML.

El código de estado no aparece automáticamente como un mensaje en la página. `http_response_code(422)` establece información de la respuesta HTTP; tú sigues teniendo que construir el HTML que la persona leerá.

### Valores recibidos y datos normalizados

Conviene separar:

- `$valores`: cadenas recibidas, útiles para volver a rellenar el formulario.
- `$datos`: valores preparados por la función, que solo guardaremos si no hay errores.
- `$errores`: mensajes de validación.

Así, si alguien escribió `"3 personas"`, puedes conservar ese texto para que entienda qué debe corregir, aunque el campo normalizado no contenga un entero válido.

Para mostrar literalmente una entrada numérica inválida en esta demostración usaremos `type="text"` con `inputmode="numeric"`. Los controles `type="number"` y `type="date"` pueden mostrar un valor vacío si su atributo `value` contiene texto incompatible con ese tipo de control. En el formulario de misiones utilizarás los tipos exigidos en la hoja y mensajes claros para los valores rechazados.

### Mostrar texto con seguridad

```php
<input name="nombre" value="<?= h($valores['nombre']) ?>">
```

Las comillas que delimitan `value` y la llamada a `h()` son importantes. Escapar evita que caracteres introducidos por la persona alteren el HTML.

`h()` no valida las reglas del taller y `validar_taller()` no sustituye el escape HTML. Son dos trabajos distintos. Guarda el texto normalizado y escápalo al mostrarlo; no lo guardes ya convertido en entidades HTML.

### En directo · G4 · Rechazar y conservar

**Enunciado:** conecta `validar_taller()` al formulario. Si hay errores, devuelve 422, muestra los mensajes y conserva los valores. Si los datos son válidos, indícalo sin guardarlos todavía.

**Antes de ejecutar:** si falla la fecha, ¿por qué no debe vaciarse el nombre?

**Plantilla completa:** `plantillas/formulario_taller_demo.php`. Recibe `$accion`, `$valores` y `$errores` de la página que la incluye.

```php
<?php if ($errores !== []): ?>
    <div class="errores">
        <p>El taller no se ha guardado. Revisa estos campos:</p>
        <ul>
        <?php foreach ($errores as $campo => $mensaje): ?>
            <li data-campo="<?= h($campo) ?>"><?= h($mensaje) ?></li>
        <?php endforeach; ?>
        </ul>
    </div>
<?php endif; ?>
<form method="post" action="<?= h($accion) ?>">
    <p>
        <label for="nombre">Nombre</label>
        <input id="nombre" name="nombre" required maxlength="60" value="<?= h($valores['nombre']) ?>">
    </p>
    <p>
        <label for="plazas">Plazas: de 1 a 5</label>
        <input id="plazas" name="plazas" type="text" inputmode="numeric" required value="<?= h($valores['plazas']) ?>">
    </p>
    <p>
        <label for="fecha">Fecha: AAAA-MM-DD</label>
        <input id="fecha" name="fecha" type="text" required value="<?= h($valores['fecha']) ?>">
    </p>
    <button type="submit">Enviar taller</button>
</form>
```

**Página completa:** `public/DW7/g4.php`.

```php
<?php
    declare(strict_types=1);
    date_default_timezone_set('Europe/Madrid');
    require __DIR__ . '/../../src/funciones.php';
    require __DIR__ . '/../../src/formularios_demo.php';

    $accion = '/DW7/g4.php';
    $valores = ['nombre' => '', 'plazas' => '', 'fecha' => ''];
    $errores = [];
    $aceptado = false;

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $metodo = 'POST';
    } elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $metodo = 'GET';
    }

    if ($metodo === 'POST') {
        foreach ($valores as $campo => $valor) {
            $valores[$campo] = leer_texto($_POST, $campo);
        }

        [$datos, $errores] = validar_taller($_POST, date('Y-m-d'));
        
        if ($errores !== []) {
            http_response_code(422);
        } else {
            $aceptado = true;
        }
    }
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>G4 · Errores de formulario</title></head>
<body>
    <h1>Alta de taller</h1>
    <?php if ($aceptado): ?>
        <p>Datos válidos. En este guiado todavía no se guardan.</p>
    <?php endif; ?>
    <?php require __DIR__ . '/../../plantillas/formulario_taller_demo.php'; ?>
</body>
</html>
```

**Paso a paso:** primero se inicializan las variables para que el GET también funcione. Solo un POST activa la validación. Después se decide el estado de la respuesta y, por último, se genera el HTML.

**Comprueba:** nombre válido, plazas 9 y una fecha futura. Debes ver el error de plazas y conservar los tres valores. Mira el estado 422 en la pestaña Red/Network del navegador.

Prueba también un nombre como `Taller "Norte" <b>`. Debe conservarse como texto, sin romper el atributo del campo. Busca `&quot;` y `&lt;` en el código fuente de la respuesta: que `<b>` se vea dentro de un cuadro de texto, por sí solo, no demuestra que el atributo esté escapado correctamente.

**Fallo provocado y recuperación:** reinicia temporalmente `$valores` después de la validación. Observa que el formulario se vacía aunque los datos hubieran llegado. Restaura el orden.

---
