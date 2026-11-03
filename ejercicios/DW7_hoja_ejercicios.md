# DW7 · Práctica evaluable · Crear, guardar y mostrar misiones

**Desarrollo web en entorno servidor · 2.º DAW · Formulario, validación y persistencia JSON**

## 1. Objetivo

Amplía tu aplicación de DW5 y DW6 para crear misiones desde un formulario, validarlas en PHP, guardarlas en JSON y mostrarlas en `tablon.php`.

El archivo será la fuente de datos del tablón. Sustituirás la llamada a `misiones()` por la lectura del JSON y reutilizarás tus funciones y el HTML de DW6.

```text
GET del formulario → enviar por POST → validar en PHP
                                         ↓
       Datos incorrectos → 422 + errores por campo + valores conservados
       Datos correctos   → añadir al JSON → 303 → GET del tablón
                                                  ↓
                                      leer JSON y mostrar misiones
```

Las altas deben permanecer después de actualizar la página o reiniciar PHP. Simular el guardado, mostrar `$_POST` o añadir una misión solo a un array temporal no cumple el objetivo.

## 2. Qué desarrollas tú y qué se proporciona

Con ayuda de los apuntes, desarrolla el formulario, la validación, los mensajes, la conservación de valores, la redirección y la integración con tu tablón. Las funciones propias de lectura y escritura JSON se facilitan completas en el apartado 5 y puedes copiarlas.

Se evalúa que sepas decidir cuándo guardar y utilizar los datos leídos, no memorizar el código del apoyo JSON. Esta práctica no utiliza MariaDB ni sesiones. No es necesario importar el array inicial de DW6: puedes comenzar con `[]` y crear las misiones con el formulario.

## 3. Organización y navegación

Conserva los archivos de tu aplicación y añade o adapta estas piezas:

```text
proyecto/
├── public/
│   ├── tablon.php                 # Lee el JSON y muestra las misiones
│   ├── nueva_mision.php           # GET y POST del formulario
│   └── ficha.php                  # Conserva el trabajo previo
├── src/
│   ├── config.php                 # Contiene la ruta fichero_datos
│   ├── funciones.php              # h() y funciones de DW6
│   ├── tablon.php                 # misiones(): ya no se usa en el tablón
│   ├── validacion_mision.php      # Tu validación
│   └── almacenamiento_json.php    # Código proporcionado
├── plantillas/
│   ├── cabecera.php
│   ├── pie.php
│   └── formulario_mision.php
├── datos/
│   └── misiones.json              # Inicialmente [] si es nuevo
├── documentacion/
│   └── pruebas_dw7_json.md
├── BITACORA_PROMPTS.md
└── README.md
```

El formulario envía POST a `/nueva_mision.php`. Tras guardar correctamente, redirige al tablón mediante 303. Añade enlaces para abrir el formulario desde el tablón y volver desde el formulario.

Añade un enlace desde la aplicación a `/nueva_mision.php` y otro desde el formulario para volver al tablón. El formulario se envía por POST a `/nueva_mision.php`. Si ya utilizas un controlador con la ruta `/gestor/mision`, puedes conservarla y documentar esa equivalencia; no necesitas crear dos versiones del formulario.

## 4. Campos y validación del servidor

La estructura de cada misión será la que utilizabas en DW6:

```php
[
    'id' => 1,
    'titulo' => 'Torre <Norte>',
    'categoria' => 'exploracion',
    'dificultad' => 4,
    'plazas_total' => 6,
    'plazas_libres' => 2,
    'fecha' => '2027-03-14',
]
```

El ejemplo muestra la estructura. Para las pruebas de alta utiliza una fecha que siga siendo válida el día que las realices.

El formulario contiene **seis campos de entrada**. El ID lo asigna el servidor al guardar.

| `name` | Validación obligatoria en PHP |
|---|---|
| `titulo` | Texto obligatorio, no solo espacios; máximo 200 caracteres. |
| `categoria` | Texto obligatorio, no solo espacios; máximo 60 caracteres. |
| `dificultad` | Entero entre 1 y 5. |
| `plazas_total` | Entero entre 1 y 50. |
| `plazas_libres` | Entero entre 0 y `plazas_total`, ambos incluidos. |
| `fecha` | Fecha existente con formato exacto `AAAA-MM-DD`, igual o posterior a hoy. |

Las longitudes se cuentan en caracteres, no en bytes. Utiliza `mb_strlen()` o la alternativa UTF-8 trabajada en los apuntes. No se piden descripción ni preparaciones en esta versión.

Cada campo debe tener `name`, `id` y un `<label for>` asociado. Utiliza POST y controles apropiados, con `required`, límites numéricos y fecha. Estas restricciones del navegador no sustituyen la validación en PHP.

Implementa en `src/validacion_mision.php`:

```php
function validar_mision(array $entrada, string $hoy): array
```

La función devuelve `[$datos, $errores]`. En un caso válido, `$datos` contiene las seis claves del formulario y dificultad y plazas como enteros; `$errores` es `[]`. Si hay errores, sus claves son los campos afectados y sus valores son mensajes comprensibles.

La función no imprime HTML, no redirige, no accede a archivos y no obtiene la fecha actual: recibe `$hoy`. Los campos ausentes o enviados como arrays deben rechazarse sin avisos de PHP. Conserva los valores originales por separado para devolverlos al formulario.

En particular, **cero plazas libres es válido**: significa que la misión está completa. Con 6 plazas totales y 2 libres se deben guardar esos mismos valores; con 7 libres se debe rechazar el envío. No conviertas automáticamente las plazas libres en el total.

## 5. Guía proporcionada: preparar y utilizar JSON

### Paso 1 · Crear el archivo con una colección vacía

Crea la carpeta `datos` fuera de `public/`. Dentro, crea `misiones.json` con **este contenido inicial exacto**:

```json
[]
```

Los corchetes representan una lista vacía. Un archivo sin contenido no es un JSON válido. No escribas etiquetas PHP, comentarios ni comas adicionales.

Desde el terminal de la VM puedes preparar la carpeta y editar el archivo así:

```bash
cd ~/proyecto
mkdir -p datos
nano datos/misiones.json
```

Si es nuevo, escribe `[]`, guarda con `Ctrl+O`, confirma con Intro y sal con `Ctrl+X`. Si ya contiene misiones que quieres conservar, no las sustituyas por `[]`: utiliza una copia de prácticas y ajusta su ruta en la configuración.

**Este paso se hace una vez.** No escribas `[]` desde el controlador cada vez que se abre o envía el formulario, porque borrarías las altas anteriores.

El JSON de esta práctica contiene únicamente las misiones creadas mediante el nuevo formulario. No hay que trasladar al archivo las que devuelve `misiones()`. El tablón mostrará únicamente esta colección JSON; el array de `misiones()` queda como trabajo anterior y ya no es su fuente de datos.

### Paso 2 · Entender qué hace el apoyo

JSON representa datos como texto. En PHP trabajamos con arrays; al guardar los convertimos a JSON y al leer hacemos el recorrido inverso.

| Operación | Qué hace |
|---|---|
| `file_get_contents($ruta)` | Lee el texto del archivo. |
| `json_decode($texto, true)` | Convierte el JSON en arrays PHP. |
| `$misiones[] = $mision` | Añade una nueva misión a la colección en memoria. |
| `json_encode($misiones)` | Convierte la colección completa a texto JSON. |
| `file_put_contents($ruta, $texto)` | Escribe la colección actualizada en el archivo. |

Para conservar las altas anteriores, el apoyo **lee → añade → escribe la colección completa**. No pega otro objeto al final del texto del archivo.

`JSON_PRETTY_PRINT` facilita la lectura en el editor; `JSON_UNESCAPED_UNICODE` mantiene legibles las tildes. `JSON_THROW_ON_ERROR` permite detectar un JSON incorrecto en lugar de tratarlo como una colección vacía. No necesitas modificar esas opciones.

### Paso 3 · Copiar las funciones de apoyo

Crea `src/almacenamiento_json.php` con este código completo:

```php
<?php
declare(strict_types=1);

function leer_misiones_json(string $ruta): array
{
    $texto = file_get_contents($ruta);
    if ($texto === false) {
        throw new RuntimeException('No se pudo leer el archivo de misiones.');
    }

    $misiones = json_decode($texto, true, 512, JSON_THROW_ON_ERROR);
    if (!is_array($misiones) || !array_is_list($misiones)) {
        throw new RuntimeException('El JSON debe contener una lista de misiones.');
    }

    return $misiones;
}

function escribir_misiones_json(string $ruta, array $misiones): void
{
    $texto = json_encode(
        $misiones,
        JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR
    );

    if (file_put_contents($ruta, $texto, LOCK_EX) === false) {
        throw new RuntimeException('No se pudo escribir el archivo de misiones.');
    }
}

function anadir_mision_json(string $ruta, array $mision): int
{
    $misiones = leer_misiones_json($ruta);

    $mayor_id = 0;
    foreach ($misiones as $existente) {
        $id = $existente['id'] ?? null;
        if (!is_int($id) || $id < 1) {
            throw new RuntimeException('Hay un identificador incorrecto en el JSON.');
        }
        if ($id > $mayor_id) {
            $mayor_id = $id;
        }
    }

    $mision['id'] = $mayor_id + 1;
    // Conservamos las plazas libres que ya ha comprobado la validación.
    $misiones[] = $mision;
    escribir_misiones_json($ruta, $misiones);

    return $mision['id'];
}
```

El apoyo requiere PHP 8.1 o posterior por `array_is_list()`, compatible con el entorno del curso. No exige instalar `mbstring` para trabajar con JSON.

La función que llamarás desde el formulario es `anadir_mision_json()`. Las otras dos forman parte de su funcionamiento interno. Recibe los datos validados y devuelve el ID asignado. Con un archivo inicial `[]`, la primera misión tendrá ID 1 y la siguiente ID 2. Estos identificadores pertenecen a la colección JSON que se muestra en el tablón.

El apoyo conserva el valor de `plazas_libres` recibido de tu validación. No lo sustituye por el total. El ID se asigna en el servidor; no se pide en el formulario ni se confía en uno enviado por el cliente.

El apoyo no sustituye la validación: solo debe recibir datos que ya hayan superado las reglas. Se utiliza para pruebas locales de una persona; `LOCK_EX` protege la escritura, pero no resuelve toda la concurrencia entre varios envíos simultáneos.

### Paso 4 · Configurar la ruta e incluir el apoyo

En el array de `src/config.php`, conserva las entradas que ya tienes y añade esta si todavía no existe:

```php
'fichero_datos' => __DIR__ . '/../datos/misiones.json',
```

Desde `public/nueva_mision.php`, incluye la configuración y el archivo de funciones:

```php
$cfg = require __DIR__ . '/../src/config.php';
require __DIR__ . '/../src/almacenamiento_json.php';
```

Reutiliza también `h()` y tu función de validación mediante las inclusiones correspondientes. No incluyas el propio JSON con `require`: no es código PHP.

### Paso 5 · Llamar al guardado después de validar

La llamada que añade la misión es:

```php
$id_nuevo = anadir_mision_json($cfg['fichero_datos'], $datos);
```

Debe estar en la rama en la que has comprobado que `$errores === []`. `$datos` es el array preparado por `validar_mision()`, no `$_POST` directamente.

Después de que la llamada termine correctamente, responde con **303 hacia `/tablon.php`** y termina la ejecución con `exit`. Escribe tú esa parte del controlador utilizando los apuntes. No hace falta utilizar `$id_nuevo` para construir el destino.

Después de la redirección aparecerá el tablón con la nueva misión. No se exige un aviso de éxito, parámetros añadidos a la URL ni sesiones. La misión debe existir tanto en el JSON como en el tablón.

Para tratar errores del archivo puedes usar este patrón, colocando la llamada de guardado dentro de `try`:

```php
$error_almacenamiento = '';

try {
    // Llamada al guardado: solo después de una validación correcta.
    // La redirección de éxito se realiza después de esa llamada.
} catch (RuntimeException | JsonException $e) {
    http_response_code(500);
    error_log($e->getMessage());
    $error_almacenamiento = 'No se pudo guardar la misión en el archivo.';
}
```

Si aparece ese error, muéstralo con `h()`, conserva el formulario y no redirijas como si se hubiese guardado. Los fallos de lectura o escritura se registran; no imprimas sus detalles internos ni avisos técnicos antes de enviar el estado HTTP. Una avería del archivo no es un error de validación del título o de las plazas.

### Paso 6 · Permisos si no se puede escribir

Con `php -S` iniciado por el usuario que creó el archivo, normalmente ya tienes acceso. Compruébalo con:

```bash
ls -ld ~/proyecto/datos
ls -l ~/proyecto/datos/misiones.json
```

Con Apache y PHP como módulo bajo la cuenta habitual `www-data` de Debian/Ubuntu, desde el terminal de tu usuario:

```bash
sudo chgrp www-data /home/{usuario}/proyecto/datos/misiones.json
sudo chmod g+rw /home/{usuario}/proyecto/datos/misiones.json
```

## 6. Leer el JSON desde `tablon.php`

### Cambiar el origen de los datos

Incluye la configuración y el apoyo JSON en el bloque PHP que prepara el tablón:

```php
$cfg = require __DIR__ . '/../src/config.php';
require __DIR__ . '/../src/almacenamiento_json.php';
```

Si ya cargabas la configuración, reutiliza `$cfg`. La entrada `fichero_datos` es una clave de ese array, no una palabra especial de PHP: contiene la ruta a `datos/misiones.json`.

Sustituye esta línea:

```php
$tablon = misiones();
```

por:

```php
try {
    $tablon = leer_misiones_json($cfg['fichero_datos']);
} catch (RuntimeException | JsonException $e) {
    http_response_code(500);
    error_log($e->getMessage());
    $error_almacenamiento = 'No se pudieron leer las misiones del archivo.';
}
```

Puedes escribirlo en dos pasos si te resulta más claro:

```php
$ruta = $cfg['fichero_datos'];
$tablon = leer_misiones_json($ruta);
```

Son dos formas equivalentes: utiliza solo una. La función devuelve el mismo tipo de colección que recorrías en DW6, un array de arrays asociativos. No necesitas copiar el JSON a un array fijo ni mezclarlo con `misiones()`.

### Reutilizar la presentación y los filtros

Sobre `$tablon`, reutiliza las funciones de DW6 para calcular ocupación, dificultad, disponibilidad y total de plazas libres. Genera una tarjeta o fila por misión, mostrando al menos título, categoría, dificultad, plazas libres y totales, fecha y estado abierta/completa. Escapa los textos con `h()`.

Conecta categoría y «solo con plazas libres» a un formulario GET. Deben funcionar las cuatro combinaciones: sin filtros, solo categoría, solo libres y ambos. Los filtros actúan sobre la colección leída; **no modifican ni reescriben el JSON**.

Muestra cuántas misiones son visibles, cuántas hay en total y las plazas libres del tablón completo. Calcula el total global sobre `$tablon`, no sobre la colección filtrada.

Si el archivo contiene `[]`, muestra un mensaje de tablón vacío y el enlace para crear una misión. Si existen misiones pero ninguna cumple el filtro, muestra el mensaje correspondiente sin avisos ni tarjetas vacías.

Protege también la lectura con el patrón `try/catch` facilitado en el apartado 5. Si el archivo falta, no se puede leer o está roto, responde con 500 y un mensaje general. Un error de lectura **no equivale a tener cero misiones** y no debe provocar que se sobrescriba el archivo con `[]`.

## 7. Mensajes y respuestas HTTP

| Situación | Respuesta esperada |
|---|---|
| Abrir el formulario | GET 200 con el formulario. |
| Enviar un campo incorrecto | POST 422, sin guardar. |
| Mostrar errores | `<div class="errores">` con mensajes por campo y valores conservados. |
| Enviar datos válidos | Guardar una sola misión y responder 303 hacia el tablón; terminar con `exit`. |
| Mostrar el destino | GET 200 con el tablón leído del JSON, incluida la nueva misión. |
| Actualizar el tablón | Repetir solo el GET, sin nuevas altas. |
| Fallo del archivo | 500 con mensaje general; no anunciar éxito ni presentarlo como vacío. |

Los errores del servidor deben verse en pantalla. Para comprobarlos puedes desactivar temporalmente las restricciones del navegador con `novalidate` o enviar peticiones mediante `curl` o las herramientas de desarrollo. Restaura las ayudas del navegador al terminar.

En la respuesta 422, conserva los valores de todos los campos y escápalos al generar HTML. Si el navegador vacía una entrada incorrecta de tipo number/date, puedes mostrar temporalmente ese control como texto. No conviertas arrays manipulados a la cadena «Array».

En JSON se guarda el texto original, no el resultado de `h()`. Una misión titulada `Torre <Norte>` debe conservar ese texto en el archivo y mostrarlo literalmente en el tablón, sin interpretarlo como HTML.

## 9. Qué entregar

- El repositorio con formulario, validación, apoyo JSON y tablón integrado.
- `datos/misiones.json` con al menos las tres misiones de prueba creadas mediante el formulario. Inclúyelo en Git; no contiene datos personales reales.
- `BITACORA_PROMPTS.md` actualizada, distinguiendo código facilitado y trabajo propio.

## 10. Criterios de revisión

Se comprobarán:

- Los seis campos y su validación en el servidor, incluida la relación entre plazas libres y totales.
- Los mensajes de error, el estado 422 y la conservación y el escape de los valores.
- El guardado real, los identificadores asignados en el servidor y la conservación de altas anteriores.
- La respuesta 303 y la ausencia de duplicados al actualizar el destino.
- La lectura del JSON desde `tablon.php`, sin utilizar el array fijo como fuente del listado.