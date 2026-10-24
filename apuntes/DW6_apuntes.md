# DW6 · Estructuras, arrays y funciones

**Desarrollo web en entorno servidor · 2.º DAW · Apuntes**

## Al terminar esta unidad vas a saber

- Tomar decisiones con condiciones y tratar los datos ausentes.
- Agrupar los datos de una misión y construir una colección de misiones.
- Recorrer arrays, acumular valores y generar fichas con bucles.
- Escribir funciones que reciben datos, calculan y devuelven resultados.
- Combinar filtros y comprobar qué ocurre cuando no hay resultados.
- Reutilizar las mismas funciones en el tablón y en la ficha.
- Explicar el ámbito de las variables y documentar tus funciones.

Al final tendrás un tablón de misiones generado desde datos en memoria, con filtros y funciones compartidas.

## Cómo están escritos estos apuntes

Cada apartado sigue este recorrido:

| Parte | Qué haces |
|---|---|
| **La explicación** | Lees lo que necesitas entender antes de programar |
| **En directo · G** | Construyes el ejemplo en clase, predices su resultado, lo ejecutas y corriges un fallo provocado |
| **Ahora tú · AT** | Resuelves una variante por tu cuenta y compruebas el resultado esperado. No se entrega ni lleva nota |
| **Aplicación a la entrega · E** | Incorporas lo aprendido a tu proyecto de misiones |

Los guiados incluyen directamente la solución completa.

Los guiados y los «Ahora tú» se guardan en **archivos independientes**. No los pegues todos en un mismo archivo: algunos definen funciones con el mismo nombre. El trabajo que sí crece de un apartado a otro es tu proyecto de misiones.

Lo que se entrega está en la hora de ejercicios del tema DW6. Al final de estos apuntes encontrarás esqueletos para empezar E6.1–E6.6. Los guiados G y las prácticas AT sirven para preparar ese trabajo.

### Cómo ejecutar los ejemplos

En esta versión, los guiados y los «Ahora tú» se ejecutan como páginas PHP en el navegador. Prepara los datos y cálculos antes del HTML y muestra los resultados con párrafos, listas o tablas. `<?= ... ?>` es la forma abreviada de `echo`: la usamos para insertar un valor en HTML, sin construir toda la página mediante instrucciones `echo`.

Los bloques de salida esperada describen los valores que debes ver, aunque ahora estén presentados en HTML. `var_dump()` y `print_r()` se mantienen únicamente para inspeccionar datos dentro de `<pre>` cuando lo pide el ejercicio. Los ejemplos breves de teoría conservan su forma original.

- **Ejemplo con HTML:** inicia `php -S localhost:8000 -t carpeta_del_ejemplo` y abre `http://localhost:8000/nombre.php` en el navegador. Sustituye la carpeta y el nombre por los tuyos.
- **Proyecto del sprint:** usa el entorno que ya tienes configurado. Su carpeta pública es `public/`; no abras los archivos PHP con doble clic.

En cada práctica, escribe primero tu predicción y después contrástala con la salida. Si hay un aviso, léelo antes de cambiar el código.

## Punto de partida

En DW5 construiste una ficha: guardaste datos en variables, calculaste valores y los insertaste en el HTML. Para mostrar cuatro misiones podrías copiar esa página cuatro veces. Funcionaría, pero cualquier cambio te obligaría a revisar las cuatro copias.

En DW6 vamos a guardar los datos juntos, recorrer la colección y reutilizar los cálculos. El destino es un tablón generado a partir de un array. La base de datos llega en DW8; los formularios y los datos de la URL, en DW7. Aquí los valores se escriben en el código para concentrarnos en el comportamiento del programa.

Conservamos la separación de DW5: los cálculos y las decisiones preparan los resultados; el HTML los presenta. Las condiciones y los bucles que deciden qué elementos HTML mostrar pueden estar en la plantilla. El filtrado y los cálculos reutilizables van en funciones.

## Mapa de trabajo

| Apartado | En directo | Ahora tú | Entregable que prepara o completa |
|---|---|---|---|
| 1. Decisiones | G1 | AT6.1 | Prepara E6.5 |
| 2. Arrays | G3 | AT6.3 | Datos de E6.1 |
| 3. Ausencia | G2 | AT6.2 | Prepara E6.5 |
| 4. Bucles | G4 | AT6.4 y AT6.5 | Prepara E6.2 y E6.4 |
| 5. Funciones | G5 | AT6.6 y AT6.7 | E6.1 y E6.4 |
| 6. Filtros | G6 | AT6.8 | E6.3 y E6.4 |
| 7. HTML | G8 | AT6.10 | E6.2 y E6.3 |
| 8. Reutilización | Recupera G5 y G8; sin guiado nuevo | Comprobación de dos páginas | E6.4 y E6.5 |
| 9. Ámbito | G7 | AT6.9 | E6.6 |

Los identificadores G y AT se conservan para que coincidan con los archivos de soluciones. Por eso G3 y AT6.3 aparecen antes de G2 y AT6.2: primero trabajamos arrays y después la ausencia de datos.

Los entregables se construyen por partes. Cada vez que aparezca un E6.x, continúa ese ejercicio en los mismos archivos del proyecto.


---

## 1. Decisiones y prioridad

**En este punto:** G1 → AT6.1 → **E6.5**.

### La explicación

Una condición produce `true` o `false`. El `if` comprueba esa condición y ejecuta el bloque solo si es verdadera.

```php
$plazas = 2;
if ($plazas > 0) {
    $estado = 'abierta';
} else {
    $estado = 'COMPLETA';
}
echo $estado;
```

La condición no cambia las plazas: las consulta. Para comprobar las dos ramas, ejecuta con 2 y con 0. Probar solo un dato que funciona deja sin comprobar la otra decisión.

Con varias alternativas se usa `elseif`. El orden importa: se ejecuta la primera rama verdadera y las restantes ya no se comprueban.

```php
if ($fecha < $hoy) {
    $estado = 'PASADA';
} elseif ($plazas > 0) {
    $estado = 'abierta';
} else {
    $estado = 'COMPLETA';
}
```

Aquí una misión pasada no aparece abierta aunque conserve plazas. La comparación de fechas supone cadenas válidas con el formato `AAAA-MM-DD` y la misma zona de referencia. No es una solución para interpretar cualquier formato de fecha.

#### Comparar y combinar

`=` asigna; `===` compara valor y tipo; `!==` comprueba que el valor o el tipo sean diferentes. `>` y `>=` comparan cantidades. Usa paréntesis para dejar clara una combinación.

```php
$admitida = ($dificultad <= 3) && ($plazas > 0);
$destacada = ($categoria === 'rescate') || ($dificultad === 5);
$completa = !($plazas > 0);
```

`&&` exige las dos condiciones; `||`, al menos una; `!` invierte un booleano. En la primera expresión, dificultad 2 con cero plazas no pasa. Estos operadores también hacen cortocircuito: pueden no evaluar la segunda parte cuando la primera ya determina el resultado.

#### El ternario

```php
$estado = $plazas > 0 ? 'abierta' : 'COMPLETA';
```

Se lee: «si quedan plazas, abierta; en caso contrario, completa». Es útil para elegir un valor sencillo. Si hay varios pasos o condiciones difíciles, un `if` resulta más claro.

### En directo · G1 · Decidir el estado de un taller

**Enunciado:**

Crea una página PHP que muestre el estado de un taller en un párrafo HTML. Usa estos datos iniciales: hoy `2026-10-16`, fecha del taller `2026-10-10` y 2 plazas disponibles.

1. Carga `funciones.php`, que contiene `h()` y `dias_entre()`. Calcula `$dias = dias_entre($hoy, $fecha)` y prepara `$estado` antes del HTML mediante `if`, `elseif` y `else`.
2. Si `$dias < 0`, la fecha ya pasó y el estado será PASADO, aunque queden plazas.
3. Si no pasó y quedan plazas, será abierto; si no quedan, COMPLETO.
4. Inserta el estado en un `<p>` mediante `<?= h($estado) ?>`.

Supón fechas válidas en formato AAAA-MM-DD y plazas no negativas. Una fecha igual a hoy no se considera pasada. Comprueba las tres ramas cambiando la fecha a `2026-10-20` y las plazas a 2 y a 0. Con los datos iniciales debe aparecer PASADO.

**Objetivo:** Relacionar cada condición con la rama que se ejecuta.

**Antes de ejecutar:** Con 0 plazas y una fecha pasada, ¿qué estado debe tener prioridad?


#### Solución HTML · G1

Guarda este código en un archivo PHP y ábrelo mediante la URL del servidor.

El ejemplo supone que `funciones.php` está en la misma carpeta. Si guardas G1 dentro de `public/` y el apoyo está en `src/`, usa `require __DIR__ . '/../src/funciones.php';`. No vuelvas a definir `h()`. La función existente se llama `dias_entre()`: devuelve un número negativo si la fecha pasó, cero si coincide y positivo si es futura.

```php
<?php
    declare(strict_types=1);
    // Este archivo de apoyo contiene h() y dias_entre().
    require __DIR__ . '../src/funciones.php';
    
    $hoy = '2026-10-16';
    $fecha = '2026-10-10';
    $plazas = 2;
    $dias = dias_entre($hoy, $fecha);
    
    if ($dias < 0) {
        $estado = 'PASADO';
    } elseif ($plazas > 0) {
        $estado = 'ABIERTO';
    } else {
        $estado = 'COMPLETO';
    }
?>

<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <title>G1 · Estado del taller</title>
</head>
<body>
    <h1>G1 · Estado del taller</h1>
    <p>Estado: <?= h($estado) ?></p>
</body>
</html>
```

| Paso | Qué haces | Qué debes observar al ejecutar el código |
|---|---|---|
| 1 | Usa fecha 2026-10-10 y hoy 2026-10-16, con 2 plazas | PASADO: la fecha tiene prioridad. |
| 2 | Cambia la fecha a 2026-10-20, con 2 plazas | ABIERTO |
| 3 | Mantén esa fecha y pon 0 plazas | COMPLETO |

**Resultado esperado del ejemplo base:**

```text
PASADO
```

**Fallo provocado y recuperación:** Coloca primero la condición de las plazas: el taller pasado con plazas aparecerá abierto. Recupera el orden correcto.

**Si no coincide:** comprueba primero el archivo que estás ejecutando, los datos de partida y el primer aviso. No cambies varias cosas a la vez.


### Ahora tú · AT6.1 · Un estado con prioridades

**Individual · sin entrega ni nota.**

Un taller puede estar CANCELADO, PASADO, COMPLETO o ABIERTO. Prepara una variable `$estado` con `if` y `elseif`, siguiendo este orden de prioridad:

1. Si está cancelado, CANCELADO, aunque la fecha haya pasado o no queden plazas.
2. Si no está cancelado y su fecha es anterior a hoy, PASADO.
3. Si no ocurre lo anterior y quedan cero plazas, COMPLETO.
4. En los demás casos, ABIERTO.

Muestra el estado en un párrafo HTML después de decidirlo. Las fechas son válidas en formato AAAA-MM-DD y las plazas no son negativas. Una fecha igual a hoy no está pasada.

**Comprueba:** con hoy 2027-03-15, fecha 2027-03-20, 4 plazas y cancelado false → ABIERTO. Prueba también: cancelado true, fecha 2027-03-10 y 0 plazas → CANCELADO; cancelado false con esos mismos datos → PASADO; cancelado false, fecha 2027-03-20 y 0 plazas → COMPLETO. Comprueba la fecha igual a hoy con plazas → ABIERTO.

Explica qué resultado incorrecto aparecería si se comprobasen las plazas antes que la cancelación.

**Presentación en HTML:** muestra los resultados en párrafos, listas o tablas usando `<?= ... ?>`. Escapa los textos con `h()`. Si inspeccionas tipos con `var_dump()`, hazlo dentro de `<pre>` como comprobación auxiliar.

### Aplicación a la entrega · E6.5

Identifica la decisión que sustituirá al texto fijo de estado de DW5. Todavía no reescribas la página con funciones: lo haremos en el apartado 8.

---

## 2. Arrays: de una misión a una colección

**En este punto:** G2 → AT6.2 → **E6.1**.

### La explicación

Un array **indexado** usa normalmente posiciones numéricas que empiezan en cero:

```php
$categorias = ['exploracion', 'rescate'];
echo $categorias[1]; // rescate
```

Un array **asociativo** permite acceder a los datos por su nombre:

```php
$mision = [
    'id' => 1,
    'titulo' => 'Torre <Norte>',
    'categoria' => 'exploracion',
    'dificultad' => 4,
    'plazas_total' => 6,
    'plazas_libres' => 2,
    'fecha' => '2027-03-14',
];

echo $mision['titulo'];
```

Un **array multidimensional** es un array que contiene otros arrays. En nuestro caso, cada misión es un array asociativo con campos como `titulo` y `plazas_libres`, y el tablón agrupa varias misiones: `$tablon = [$mision1, $mision2];`.

Para acceder a un dato usamos **dos niveles**: primero elegimos la misión por su posición y después el campo por su clave. Así, `$tablon[0]` devuelve el array completo de la primera misión, mientras que `$tablon[0]['titulo']` devuelve únicamente su título.

### Lo que hay que saber hacer con ellos

En este apartado accedemos a posiciones y claves concretas, añadimos elementos y contamos cuántos hay. Todavía no necesitamos bucles.

```php
$cantidad = count($tablon); // Cuenta las misiones de la colección.
$tablon[] = $mision;        // Añade al final la misión definida arriba.
$claves = array_keys($mision); // Devuelve un array con los nombres de sus campos.
```

`array_keys()` devuelve las claves; para inspeccionarlas puedes usar `print_r()` o `var_dump()`. Con `print_r($claves, true)`, el segundo argumento hace que se devuelva un texto en lugar de imprimirlo directamente. Así podemos escaparlo con `h()` e insertarlo dentro de `<pre>`.

**Ejemplo**: muestra cada campo accediendo a su clave.

```php
<?php
    declare(strict_types=1);
    // Apoyo de DW5: este ejemplo supone funciones.php en la misma carpeta.
    require __DIR__ . '../src/funciones.php';
    
    $m = ['titulo' => 'La cima blanca', 'dificultad' => 5, 'plazas_libres' => 3];
    $cantidadCampos = count($m);
    $claves = array_keys($m);
?>

<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>Campos de una misión</title></head>
<body>
    <h1>Campos de una misión</h1>
    <p>Título: <?= h($m['titulo']) ?></p>
    <p>Dificultad: <?= $m['dificultad'] ?></p>
    <p>Plazas libres: <?= $m['plazas_libres'] ?></p>
    <p>Cantidad de campos: <?= $cantidadCampos ?></p>
    <h2>Claves del array</h2>
    <pre><?= h(print_r($claves, true)) ?></pre>
</body>
</html>
```

Si guardas el ejemplo en `public/` y las funciones están en `src/`, adapta la carga a `require __DIR__ . '/../src/funciones.php';`.

Debes ver La cima blanca, dificultad 5, 3 plazas libres y 3 campos. Las claves son titulo, dificultad y plazas_libres.

`count($m)` cuenta los campos de una misión; `count($tablon)` cuenta las misiones de la colección. Ninguno suma plazas. Para sumar las plazas de dos misiones conocidas podrías escribir `$tablon[0]['plazas_libres'] + $tablon[1]['plazas_libres']`. En el apartado 4 aprenderás a hacerlo con un bucle para cualquier cantidad de misiones.

Leer una clave inexistente provoca un aviso. Puedes inspeccionar el array con `var_dump()` dentro de `<pre>` para comprobar los nombres reales. En el apartado 3 veremos cómo tratar las claves ausentes y los valores null con `isset()` y `??`.

### En directo · G2 · Un taller y varios talleres

**Enunciado:**

Crea una colección `$talleres` con dos arrays asociativos: Mapa con 2 plazas y Cuerda con 0. Cada taller debe usar las claves `titulo` y `plazas`.

1. Accede al título del segundo taller por su posición y guárdalo en una variable.
2. Añade al final Brujula con 3 plazas mediante `$talleres[]`.
3. Calcula cuántos talleres contiene la colección con `count()`.
4. Muestra en dos párrafos HTML el segundo título y la cantidad de talleres. Escapa el título con `h()`.

Debes ver Cuerda y 3 talleres. No necesitas bucles. Para inspeccionar la primera entrada, puedes usar `var_dump($talleres[0])` dentro de `<pre>`. Distingue la cantidad de talleres de la suma de sus plazas.

**Objetivo:** Acceder a una colección sin confundir posición y clave.

**Antes de ejecutar:** ¿Qué diferencia hay entre `$talleres[1]` y `$talleres[1]["titulo"]`?


#### Solución HTML · G2

Guarda este código en un archivo PHP y ábrelo mediante la URL del servidor.

```php
<?php
    declare(strict_types=1);
    require __DIR__ . '../src/funciones.php';
    
    $talleres = [
        ['titulo' => 'Mapa', 'plazas' => 2],
        ['titulo' => 'Cuerda', 'plazas' => 0],
    ];
    $segundoTitulo = $talleres[1]['titulo'];
    $talleres[] = ['titulo' => 'Brujula', 'plazas' => 3];
    $cantidad = count($talleres);
    // Para inspeccionar la primera entrada, descomenta esta línea:
    // var_dump($talleres[0]);
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <title>G2 · Colección de talleres</title>
</head>
<body>
    <h1>G2 · Colección de talleres</h1>
    <p>Segundo taller: <?= h($segundoTitulo) ?></p>
    <p>Cantidad de talleres: <?= $cantidad ?></p>
    <!-- Descomenta esta inspección si necesitas ver las claves de la primera entrada. -->
    <!-- <pre><?php /* var_dump($talleres[0]); */ ?></pre> -->
</body>
</html>
```

| Paso | Qué haces | Qué debes observar al ejecutar el código |
|---|---|---|
| 1 | Accede al segundo título antes de añadir el tercero | Cuerda |
| 2 | Añade Brujula y cuenta | 3 elementos. |
| 3 | Inspecciona la primera entrada | Tiene las claves titulo y plazas. |

**Resultado esperado del ejemplo base:**

```text
Cuerda
3
```

**Fallo provocado y recuperación:** Lee temporalmente `$talleres[0]['plaza']` en lugar de `$talleres[0]['plazas']`, con los avisos activados, y observa el aviso. No basta con renombrar una clave al crear el array. Inspecciona con `var_dump()` dentro de `<pre>` y corrige el acceso.

**Si no coincide:** comprueba primero el archivo que estás ejecutando, los datos de partida y el primer aviso. No cambies varias cosas a la vez.


### Ahora tú · AT6.2 · Actualizar un inventario

**Individual · sin entrega ni nota.**

Crea un inventario con tres artículos. Cada artículo debe tener exactamente las claves `codigo`, `nombre` y `unidades`:

| Código | Nombre | Unidades |
|---|---|---|
| M01 | Mapa | 2 |
| C01 | Cuerda | 3 |
| L01 | Linterna | 0 |

Sin utilizar bucles ni funciones propias:

1. Añade 2 unidades a Cuerda modificando su campo, sin sustituir el artículo completo.
2. Añade al final B01, Brújula, con 1 unidad.
3. Muestra nombre y unidades del segundo artículo.
4. Inspecciona las claves del primero con `array_keys()` y muestra `h(print_r($claves, true))` dentro de `<pre>`. El segundo argumento de `print_r()` hace que devuelva el texto en lugar de imprimirlo directamente.
5. Muestra cuántos artículos hay y suma las unidades accediendo a las cuatro posiciones.

**Resultados esperados:** Cuerda, 5 unidades; claves codigo, nombre, unidades; 4 artículos y 8 unidades. Explica por qué `count($inventario)` no devuelve 8 y qué habría que cambiar en la suma si añadieses un quinto artículo.

**Presentación en HTML:** muestra los resultados en párrafos, listas o tablas usando `<?= ... ?>`. Escapa los textos con `h()`. Si inspeccionas tipos con `var_dump()`, hazlo dentro de `<pre>` como comprobación auxiliar.

### Aplicación a la entrega · E6.1

Prepara un array con las cuatro misiones y las claves exigidas. En el apartado 5 lo envolverás en misiones(): array; no hace falta conocer funciones todavía.

---

## 3. Ausencia de datos

**En este punto:** G3 → AT6.3 → **E6.5**.

### La explicación
`null` representa la ausencia de valor. No es lo mismo que cero, cadena vacía o `false`.

```php
$m = ['plazas_libres' => 0, 'pronostico' => null, 'titulo' => ''];
$pronostico = $m['pronostico'] ?? 'sin dato';
$plazas = $m['plazas_libres'] ?? 99;
$titulo = $m['titulo'] ?: 'Sin título';
```

Resultados esperados: `sin dato`, `0` y `Sin título`.

- `??` elige el sustituto si la clave no existe o su valor es `null`. Conserva `0`, `false` y `''`.
- `?:` elige el sustituto si el valor se interpreta como falso. Esto incluye `0`, `'0'`, `''`, `false`, `null` y un array vacío.

Por eso `0 ?: 99` devuelve 99: no sirve para conservar un cero válido. Además, `?:` no evita por sí solo el aviso de una clave inexistente. Si el título puede faltar, primero recupéralo con `??` y después decide cómo tratar el texto vacío.

`isset($m['pronostico'])` da `false` tanto si la clave falta como si vale `null`. No distingue esos dos casos. No confundas «tiene un valor no nulo» con «la clave está presente».

### En directo · G3 · Ausencia no es cero

**Enunciado:**

Crea una página PHP para presentar los datos de un taller que contiene `plazas = 0`, `pronostico = null` y `titulo = ''`.

1. Recupera el pronóstico con `??` y el sustituto sin dato.
2. Recupera las plazas con `??` y el sustituto 99: debes conservar el cero.
3. Guarda en otra variable el resultado de recuperar las mismas plazas con `?:` y el sustituto 99, para comparar ambos operadores.
4. Sustituye el título vacío por Sin titulo mediante `?:`.
5. Muestra los cuatro resultados en párrafos HTML; escapa los textos con `h()`. Añade una inspección con `var_dump()` dentro de `<pre>` para comprobar los tipos.

Debes obtener sin dato, 0, 99 y Sin titulo. Repite con 2 plazas y después eliminando la clave pronostico. Explica qué operador conserva el cero y cuál lo sustituye.

**Objetivo:** Distinguir clave ausente, null, cero y texto vacío.

**Antes de ejecutar:** ¿Qué operador conserva las cero plazas?


#### Solución HTML · G3

Guarda este código en un archivo PHP y ábrelo mediante la URL del servidor.

```php
<?php
    declare(strict_types=1);
    require __DIR__ . '../src/funciones.php';
    
    $taller = ['plazas' => 0, 'pronostico' => null, 'titulo' => ''];
    $pronostico = $taller['pronostico'] ?? 'sin dato';
    $plazas = $taller['plazas'] ?? 99;
    $contraste = $taller['plazas'] ?: 99;
    $titulo = $taller['titulo'] ?: 'Sin titulo';
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <title>G3 · Ausencia no es cero</title>
</head>
<body>
    <h1>G3 · Ausencia no es cero</h1>
    <p>Pronóstico: <?= h($pronostico) ?></p>
    <p>Plazas con ?? : <?= $plazas ?></p>
    <p>Plazas con ?: : <?= $contraste ?></p>
    <p>Título: <?= h($titulo) ?></p>
    <!-- Inspección de tipos: es una comprobación auxiliar, no la presentación de la página. -->
    <pre><?php var_dump($pronostico, $plazas, $contraste, $titulo); ?></pre>
</body>
</html>
```

| Paso | Qué haces | Qué debes observar al ejecutar el código |
|---|---|---|
| 1 | Ejecuta los cuatro var_dump | sin dato, 0, 99 y Sin titulo, con sus tipos. |
| 2 | Cambia plazas a 2 | Ambos operadores conservan 2. |
| 3 | Elimina la clave pronostico | ?? sigue dando sin dato sin aviso por esa clave. |

**Resultado esperado del ejemplo base:**

```text
string(8) "sin dato"
int(0)
int(99)
string(10) "Sin titulo"
```

**Fallo provocado y recuperación:** Sustituye ?? por ?: en la línea de las plazas: el cero se convierte en 99. Restaura ??.

**Si no coincide:** comprueba primero el archivo que estás ejecutando, los datos de partida y el primer aviso. No cambies varias cosas a la vez.


### Ahora tú · AT6.3 · El cero tiene significado

**Individual · sin entrega ni nota.**

Crea un array con plazas = 0 y pronostico = null. Recupera las plazas con sustituto 9 y el pronóstico con sustituto "sin dato". El cero debe conservarse. Comprueba también el array vacío.

**Comprobación esperada:** int(0) y string(8) "sin dato"; con el array vacío, int(9) y "sin dato".

**Presentación en HTML:** muestra los resultados en párrafos, listas o tablas usando `<?= ... ?>`. Escapa los textos con `h()`. Si inspeccionas tipos con `var_dump()`, hazlo dentro de `<pre>` como comprobación auxiliar.

### Aplicación a la entrega · E6.5

Anota cómo conservarás un cero válido y cómo prepararás sin dato para un pronóstico null. Lo integrarás en la ficha en el apartado 8.

---

## 4. Bucles y acumuladores

**En este punto:** G4 → AT6.4, AT6.5 → **E6.2 y E6.4**.

### La explicación

`foreach` recorre los elementos de una colección. En cada vuelta coloca el elemento actual en la variable indicada:

```php
$total = 0;
foreach ($tablon as $m) {
    $total += $m['plazas_libres'];
}
```

Con plazas 2, 0 y 3, el acumulador pasa por 0 → 2 → 2 → 5. Se inicializa antes del bucle. Si lo pones a cero dentro, perderás lo que ya has sumado. Si el array está vacío, no hay vueltas y el total sigue siendo cero.

```php
foreach ($mision as $clave => $valor) {
    echo $clave, ': ', $valor, PHP_EOL;
}
```

Esta segunda forma recorre los campos de una misión. No la confundas con recorrer las misiones del tablón.

#### `for` y `while`

```php
for ($i = 1; $i <= 3; $i++) {
    echo $i, PHP_EOL;
}
$quedan = 3;
while ($quedan > 0) {
    echo $quedan, PHP_EOL;
    $quedan--;
}
```

El primero muestra 1, 2, 3; el segundo, 3, 2, 1. `for` agrupa inicio, condición y avance. `while` repite mientras la condición sea verdadera: olvidar actualizar `$quedan` provoca un bucle que no termina. Para el tablón, `foreach` expresa mejor la intención.

### En directo · G4 · Recorrer y acumular

**Enunciado:**

Crea una página con una colección de tres talleres: Mapa con 2 plazas, Cuerda con 0 y Brujula con 3. Usa las claves `titulo` y `plazas`.

1. Inicializa `$total` a cero antes de un `foreach` y acumula las plazas de todos los talleres en el bloque PHP previo al HTML.
2. En la presentación, utiliza otro `foreach` para generar una lista `<ul>` con un `<li>` por título. Escapa los títulos con `h()`.
3. Muestra el total de plazas en un párrafo después de la lista.
4. Repite la prueba sustituyendo la colección por `[]`.

Con los datos iniciales deben aparecer los tres títulos en su orden y Total: 5. Con la colección vacía no debe generarse ningún `<li>` y el total debe ser 0. No reinicialices el acumulador dentro del recorrido.

**Objetivo:** Distinguir el elemento actual del acumulador.

**Antes de ejecutar:** Con 2, 0 y 3 plazas, ¿qué valores toma el total en cada vuelta?


#### Solución HTML · G4

Guarda este código en un archivo PHP y ábrelo mediante la URL del servidor.

```php
<?php
    declare(strict_types=1);
    require __DIR__ . '../src/funciones.php';
    
    $talleres = [
        ['titulo' => 'Mapa', 'plazas' => 2],
        ['titulo' => 'Cuerda', 'plazas' => 0],
        ['titulo' => 'Brujula', 'plazas' => 3],
    ];
    $total = 0;
    foreach ($talleres as $t) {
        $total += $t['plazas'];
    }
?>

<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <title>G4 · Recorrer y acumular</title>
</head>
<body>
    <h1>G4 · Recorrer y acumular</h1>
    <ul>
    <?php foreach ($talleres as $t): ?>
        <li><?= h($t['titulo']) ?></li>
    <?php endforeach; ?>
    </ul>
    <p>Total: <?= $total ?></p>
</body>
</html>
```

| Paso | Qué haces | Qué debes observar al ejecutar el código |
|---|---|---|
| 1 | Recorre Mapa, Cuerda y Brujula | Los tres títulos, en ese orden. |
| 2 | Lee el acumulador final | 5 |
| 3 | Repite con [] | Total: 0; ningún título. |

**Resultado esperado del ejemplo base:**

```text
Mapa
Cuerda
Brujula
Total: 5
```

**Fallo provocado y recuperación:** Mueve $total = 0 dentro del bucle: solo queda la última aportación. Devuélvelo fuera.

**Si no coincide:** comprueba primero el archivo que estás ejecutando, los datos de partida y el primer aviso. No cambies varias cosas a la vez.


### Ahora tú · AT6.4 · Sumar y contar son cosas distintas

**Individual · sin entrega ni nota.**

Con unidades [2, 0, 3], calcula con un foreach la suma y cuántos elementos tienen unidades positivas. Repítelo con []. Inicializa los dos acumuladores fuera.

**Comprobación esperada:** Suma: 5; positivos: 2. Con el array vacío: 0 y 0.

**Presentación en HTML:** muestra los resultados en párrafos, listas o tablas usando `<?= ... ?>`. Escapa los textos con `h()`. Si inspeccionas tipos con `var_dump()`, hazlo dentro de `<pre>` como comprobación auxiliar.

### Ahora tú · AT6.5 · Preparar cajas y etiquetas

**Individual · sin entrega ni nota.**

Hay 11 unidades de material y cada caja admite 4. Con un `while`, prepara las cajas y guarda sus contenidos en un array. Después muestra en HTML el número de cada caja y sus unidades usando un `foreach`. La última puede quedar incompleta. Después usa un `for` para generar un párrafo HTML con una etiqueta por cada caja creada: ETIQUETA 1, ETIQUETA 2…

Muestra también el total de cajas. Si no hay unidades, muestra No hay material y no generes cajas ni etiquetas. Los datos de entrada son enteros: unidades no negativas y capacidad estrictamente positiva.

**Comprueba:** 11 unidades → cajas de 4, 4 y 3, tres etiquetas y total 3. Con 8 → dos cajas de 4 y dos etiquetas. Con 0 → No hay material y total 0. No uses una fórmula para sustituir el `while`.

Explica qué variable hace avanzar el bucle y por qué la capacidad cero impediría terminar si quedase material.

**Esqueleto opcional:** completa los TODO y comprueba todos los casos.

```php
<?php
    declare(strict_types=1);
    require __DIR__ . '../src/funciones.php';
    
    $unidades = 11;
    $capacidad = 4;
    $pendientes = $unidades;
    $cajas = [];
    // TODO: while que guarde el contenido de cada caja en el array.
    $totalCajas = count($cajas);
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <title>Preparar cajas y etiquetas</title>
</head>
<body>
    <h1>Preparar cajas y etiquetas</h1>
    <!-- TODO: mensaje si no hay material; foreach para presentar cajas; for para etiquetas. -->
    <p>Total de cajas: <?= $totalCajas ?></p>
</body>
</html>
```



**Presentación en HTML:** muestra los resultados en párrafos, listas o tablas usando `<?= ... ?>`. Escapa los textos con `h()`. Si inspeccionas tipos con `var_dump()`, hazlo dentro de `<pre>` como comprobación auxiliar.

### Aplicación a la entrega · E6.2 y E6.4

Prueba en el navegador el recorrido y la suma de plazas. La función de suma se completa tras el apartado 5 y el HTML del tablón se integra en el 7.

---

## 5. Funciones y casos límite

**En este punto:** G5 → AT6.6, AT6.7 → **E6.1 y E6.4**.

### La explicación

```php
function hay_plazas(array $m): bool
{
    return $m['plazas_libres'] > 0;
}
$disponible = hay_plazas($mision);
```

La declaración define una operación; la llamada la ejecuta. `$m` es el parámetro local y `$mision` es el argumento que le pasamos. `array` indica el tipo de entrada y `bool`, el de salida. `return` entrega un resultado y termina esa llamada.

`echo` envía salida; `return` devuelve un valor que otro código puede usar. Si `ocupacion()` hiciera `echo`, no podríamos guardar el resultado limpiamente en una variable o compararlo en otra condición. En este proyecto, las funciones de cálculo no imprimen.

Una función sin tipo de retorno declarado que termina sin `return` devuelve `null`. Si declara un retorno obligatorio como `: int`, no devolver un entero produce un error de tipo. No se debe generalizar «sin return siempre vale null» a las funciones tipadas.

#### Valores por defecto

```php
function filtrar(array $tablon, ?string $categoria = null, bool $solo_libres = false): array
```

`?string` admite texto o `null`. Los valores por defecto permiten llamar con uno, dos o tres argumentos. El cuerpo de esta función se construye en el guiado G6.

| Llamada | Resultado que buscamos |
|---|---|
| `filtrar($tablon)` | Todas |
| `filtrar($tablon, 'exploracion')` | De esa categoría |
| `filtrar($tablon, null, true)` | Con plazas, de cualquier categoría |
| `filtrar($tablon, 'exploracion', true)` | De esa categoría y con plazas |

#### Proteger los límites

No basta con probar `barra(3)`. Hay que decidir qué ocurre con `barra(-2)` y `barra(9)`. En esta unidad la barra siempre tiene cinco caracteres: limitamos la dificultad al intervalo 0–5 antes de llamar a `str_repeat()`.

Tampoco se puede dividir entre cero en `ocupacion()`. En el guiado, un total no positivo devuelve 100, interpretado como «sin capacidad disponible». Es una decisión que debes documentar, no una regla matemática. En E6.4 puedes devolver 0 o 100 para ese caso si justificas la elección; lo obligatorio es evitar la división por cero. Los demás datos de las misiones se suponen coherentes; validar entradas ajenas será DW7.

Pruebas mínimas: un caso habitual, una frontera y un caso vacío o fuera de rango. No uses solo datos que hagan verdadera la condición.

### En directo · G5 · Un cálculo convertido en función

**Enunciado:**

Escribe una función `porcentaje(int $total, int $libres): int` que calcule el porcentaje de plazas ocupadas de un taller y presenta sus resultados en una página HTML.

1. Si el total es menor o igual a cero, devuelve 100 antes de hacer ninguna división. En este guiado representa la ausencia de capacidad disponible.
2. Si el total es positivo, calcula las plazas ocupadas como total menos libres, obtén su porcentaje y redondéalo al entero más cercano con `round()`. Convierte el resultado a `int`.
3. Documenta los parámetros, el retorno y la decisión para un total no positivo. Supón que, con total positivo, las plazas libres están entre cero y total.
4. La función solo calcula y devuelve: no imprime. Guarda los resultados de las llamadas con `(6, 2)` y `(0, 0)` y muéstralos en párrafos HTML con el símbolo %.

Los resultados deben ser 67 % y 100 %. Comprueba además que `(4, 4)` devuelve 0 %.

**Objetivo:** Pasar datos, devolver resultados y proteger los límites.

**Antes de ejecutar:** ¿Qué recibe, qué devuelve y qué no debe imprimir la función?


#### Solución HTML · G5

Guarda este código en un archivo PHP y ábrelo mediante la URL del servidor.

```php
<?php
    declare(strict_types=1);
    require __DIR__ . '../src/funciones.php';
    
    /**
     * Calcula el porcentaje ocupado, redondeado a un entero.
     * Un total no positivo se interpreta como ausencia de capacidad disponible.
     * @param int $total Capacidad del taller.
     * @param int $libres Plazas libres; entre 0 y total cuando total es positivo.
     * @return int Porcentaje ocupado; 100 si el total no es positivo.
     */
    function porcentaje(int $total, int $libres): int {
        if ($total <= 0) {
            return 100;
        }
        return (int) round(($total - $libres) / $total * 100);
    }
    $ocupacion = porcentaje(6, 2);
    $sinCapacidad = porcentaje(0, 0);
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <title>G5 · Porcentaje de ocupación</title>
</head>
<body>
    <h1>G5 · Porcentaje de ocupación</h1>
    <p>Ocupación de (6, 2): <?= $ocupacion ?> %</p>
    <p>Ocupación de (0, 0): <?= $sinCapacidad ?> %</p>
</body>
</html>
```

| Paso | Qué haces | Qué debes observar al ejecutar el código |
|---|---|---|
| 1 | Llama con (6, 2) | 67 |
| 2 | Llama con (0, 0) | 100, según la decisión de este guiado. |
| 3 | Llama con (4, 4) | 0 |

**Resultado esperado del ejemplo base:**

```text
67
100
```

**Fallo provocado y recuperación:** Cambia return por echo manteniendo : int; observarás salida y un error por no devolver el tipo comprometido. Restaura return.

**Si no coincide:** comprueba primero el archivo que estás ejecutando, los datos de partida y el primer aviso. No cambies varias cosas a la vez.


### Ahora tú · AT6.6 · Una función que devuelve

**Individual · sin entrega ni nota.**

Escribe doble(int $n): int sin echo dentro. Guarda el resultado de doble(7) y muéstralo fuera de la función, en un párrafo HTML. Añade documentación @param y @return. Prueba cero y -3.

**Comprobación esperada:** 14; para cero, 0; para -3, -6.

**Presentación en HTML:** muestra los resultados en párrafos, listas o tablas usando `<?= ... ?>`. Escapa los textos con `h()`. Si inspeccionas tipos con `var_dump()`, hazlo dentro de `<pre>` como comprobación auxiliar.

### Ahora tú · AT6.7 · Limitar antes de repetir

**Individual · sin entrega ni nota.**

Escribe nivel(int $n): string, de cuatro posiciones: + para las activas y . para el resto. Usa if para limitar n a 0–4 y str_repeat para construir la cadena. Prueba -1, 2 y 8.

**Comprobación esperada:** ...., ++.. y ++++; siempre cuatro caracteres.

**Presentación en HTML:** muestra los resultados en párrafos, listas o tablas usando `<?= ... ?>`. Escapa los textos con `h()`. Si inspeccionas tipos con `var_dump()`, hazlo dentro de `<pre>` como comprobación auxiliar.

### Aplicación a la entrega · E6.1 y E6.4

Cierra misiones() y escribe hay_plazas(), ocupacion(), barra() y plazas_libres_totales(). Añade sus bloques de documentación; filtrar() se trabaja en el apartado 6.

---
