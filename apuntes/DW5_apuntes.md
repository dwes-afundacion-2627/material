# DW5 · PHP embebido: sintaxis, variables y directivas

**Desenvolvemento web en contorno servidor · 2º DAW · Apuntes**

---

## Al terminar esta unidad vas a saber

- Meter código dentro de una plantilla HTML y entender qué sale por el otro lado.
- Variables, tipos y operadores de PHP, y  las conversiones.
- Calcular un porcentaje redondeado, una barra de cinco posiciones y
  los días que faltan para una fecha.
- Escribir en el documento sin abrir un agujero de seguridad.
- Cambiar el comportamiento por defecto de PHP con **directivas**: tipos estrictos,
  errores y zona horaria.
- Leer el registro de errores de tu sitio en lugar de mirar una página en blanco.
- Repartir una página en configuración, funciones y plantillas, y reutilizarlas.

Es la primera unidad en la que **tu código produce una página**.

---

## Cómo están escritos estos apuntes

Cada apartado tiene hasta tres partes:

| Parte | Qué es |
|---|---|
| **La explicación** | Lo que hay que saber antes de tocar el teclado |
| **En directo** | Un recorrido que se hace en clase **a la vez**, en la pantalla y en tu equipo. Pasos numerados, lo que tienes que ver en cada uno, una predicción antes de ejecutar, un fallo provocado a propósito y cómo se recupera |
| **Ahora tú** | Un ejercicio del mismo patrón, con otro dato, para hacerlo solo. **No lleva nota**: trae su resultado esperado y puedes saber si está bien sin preguntar |

Los recorridos «En directo» de los apartados 1 a 5 construyen **un solo fichero**,
`public/dw5_guiado.php`: la ficha de un taller. Se teclea por partes, una por
apartado. El apartado 6 lo reparte en varios ficheros y el 7 no toca código.

Lo que **se entrega y cuenta** está en `DW5_hoja_ejercicios.md`, y es un caso
distinto: la ficha de una misión.

Los dos ficheros de apoyo de esta unidad están en `dwes/recursos/DW5/`:

| Fichero | Qué trae |
|---|---|
| `apoyo.php` | Las dos funciones que se dan hechas: `h()` y `dias_entre()` |
| `plantilla_ficha.php` | El punto de partida de la ficha que se entrega: arranque y maquetación puestos, cálculos por hacer |

---

## 1. Qué hace PHP, exactamente

Un fichero `.php` es **una plantilla con agujeros**. El servidor la recorre de
arriba abajo: lo que está fuera de las etiquetas de código lo copia tal cual, y lo
que está dentro lo **ejecuta** y sustituye por lo que ese código escriba.

```php
<?php
$titulo     = "A torre baixo a tormenta";
$dificultad = 4;
$plazas     = 3;
$aberta     = true;
?>
<!doctype html>
<html lang="gl"><head><meta charset="utf-8"><title>Ficha</title></head>
<body>
<h1><?= $titulo ?></h1>
<p>Dificultade: <?= $dificultad ?> de 5</p>
<p>Prazas: <?= $plazas ?></p>
<p>Aberta (o bool en bruto): [<?= $aberta ?>]</p>
</body></html>
```

Y esto es **lo que sale**, ejecutado de verdad:

```html
<!doctype html>
<html lang="gl"><head><meta charset="utf-8"><title>Ficha</title></head>
<body>
<h1>A torre baixo a tormenta</h1>
<p>Dificultade: 4 de 5</p>
<p>Prazas: 3</p>
<p>Aberta (o bool en bruto): [1]</p>
</body></html>
```

Ni un `<?php` ni un `$titulo`. **Eso ya lo viste en DW4** (§5, «qué código viaja»);
ahora lo estás produciendo tú.

Fíjate en la última línea: **`true` se escribe como `1`**, y `false` **no escribe
nada** —cadena vacía—. No es un fallo: es cómo PHP convierte un booleano a texto.
Por eso un sí/no legible se prepara arriba como texto, y no se saca de pintar el
booleano.

### Las etiquetas

| Etiqueta | Para qué |
|---|---|
| `<?php ... ?>` | Un bloque de código |
| `<?= $algo ?>` | **Escribir** el valor de algo. Es lo mismo que `<?php echo $algo; ?>` |
| `// ...` | Un comentario de una línea, dentro del código. PHP no lo ejecuta y **no sale en el HTML** |
| `<!-- ... -->` | Un comentario de HTML. **Sí viaja** al navegador: se ve en «Ver código fuente» |

`<?=` es la que más vas a usar dentro del HTML: es corta y se lee.

### Lo del `?>` del final, con su letra pequeña

En un fichero que es **solo PHP** —`src/funciones.php`, `src/config.php`— el `?>`
del final **no se pone**. Un espacio o una línea en blanco detrás se envía al
navegador, y eso rompe cualquier cabecera o redirección posterior (lo vas a sufrir
en DW10, con las sesiones).

En una **plantilla mixta**, en cambio, cada bloque de código que se abre tiene que
cerrarse con `?>` para volver al HTML. Ahí el `?>` no es opcional: es lo que dice
«a partir de aquí, HTML otra vez». La regla es *no dejar un `?>` como última línea
del fichero*, no *no escribir nunca `?>`*.

### Las variables distinguen mayúsculas

`$plazas` y `$Plazas` son **dos variables distintas**. PHP no avisa al escribir la
segunda: la crea vacía, y lo que te enteras es de que un hueco sale en blanco.

### La regla que ordena el fichero

> **Primero se piensa, después se pinta.**

Todo el código que decide o calcula va **arriba**, en un bloque. Abajo queda el HTML
con `<?= ?>` para colocar valores. Un fichero con lógica repartida entre las
etiquetas es imposible de leer a la tercera semana, y esa es exactamente la queja
que resuelve DW12.

### En directo · G1 · La primera página del taller y su fuente

Vas a crear el fichero que se va a ir ampliando durante toda la unidad.

```bash
mkdir -p ~/proyecto/public
nano ~/proyecto/public/dw5_guiado.php
```

Teclea esto, exactamente:

```php
<?php
$titulo     = 'Taller de cordas e nos';   // string
$categoria  = 'formacion';                // string
$dificultad = 3;                          // int
$plazas_tot = 8;                          // int
$plazas_lib = 2;                          // int
$aberto     = true;                       // bool
?>
<!doctype html>
<html lang="gl">
<head><meta charset="utf-8"><title>Taller</title></head>
<body>
<h1><?= $titulo ?></h1>
<p>Categoria: <?= $categoria ?></p>
<p>Dificultade: <?= $dificultad ?>/5</p>
<p>Prazas: <?= $plazas_lib ?> libres de <?= $plazas_tot ?></p>
<p>Aberto (bool en bruto): [<?= $aberto ?>]</p>
<!-- este comentario de HTML si llega al navegador -->
</body>
</html>
```

**Antes de ejecutar, escribe tu predicción**: ¿cuántas de las once líneas del HTML
van a llevar algo que tú no has escrito literalmente? ¿Y qué va a aparecer entre
los corchetes de la última?

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `php -l ~/proyecto/public/dw5_guiado.php` | `No syntax errors detected` |
| 2 | `curl -sS -i http://localhost/dw5_guiado.php` | `HTTP/1.1 200 OK`, las cabeceras, una línea en blanco y debajo el HTML |
| 3 | Mira el cuerpo de la respuesta del paso 2 | `<h1>Taller de cordas e nos</h1>`. **Ni `<?php` ni `$titulo` por ningún lado** |
| 4 | En el mismo cuerpo, busca los corchetes | `[1]`: el `true` se ha escrito como **1** |
| 5 | Busca el comentario `//` del bloque de arriba | **No está.** El de `<!-- -->`, sí |
| 6 | En Windows, `http://localhost:8080/dw5_guiado.php` y `Ctrl+U` | Lo mismo que vio `curl`. La fuente del navegador y la respuesta HTTP son el mismo texto |

Cambia ahora `$aberto = true;` por `$aberto = false;`, repite el paso 2 y mira los
corchetes: `[]`, vacíos. Déjalo otra vez en `true`.

**El fallo provocado.** Cambia solo la línea del título de abajo:

```php
<h1><?= $Titulo ?></h1>
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 7 | Repite el paso 2 | `<h1></h1>`: el título **ha desaparecido** y la página sigue valiendo 200 |

Ninguna señal. Esa es la trampa de la mayúscula: el servidor responde que todo va
bien y lo único raro es un hueco. En el apartado 5.2 vas a hacer que PHP te lo
cuente.

**Cómo se recupera:** vuelve a `<?= $titulo ?>` y repite el paso 2. El título
reaparece.

**Si falla:**

- *`curl: (7) Failed to connect to localhost port 80`.* Apache está parado:
  `sudo systemctl status apache2` y, si procede, `sudo systemctl start apache2`.
- *Sale el código PHP en el navegador.* El fichero no está en `public/`, o no acaba
  en `.php`.
- *Sale 404.* La raíz de tu sitio es `~/proyecto/public` desde DW2: el fichero va
  ahí, y en la URL no lleva `/public/` delante.

### Ahora tú · E5.1 · La ficha de la biblioteca del barrio *(10 minutos)*

**Fichero:** `public/e51_hola.php`

Una página con tu cabecera HTML y tres datos guardados en variables: el título
**Biblioteca do barrio**, el número **12** de plazas y un booleano `disponible`.
Píntalos con `<?= ?>`.

**Resultado esperado.** En el HTML que llega al navegador:

| | Qué tiene que verse |
|---|---|
| El título | `Biblioteca do barrio`, escrito por la variable |
| El número | `12` |
| Con `disponible = true` | un `1` donde pintes el booleano |
| Con `disponible = false` | **nada**: el hueco queda vacío |
| En toda la respuesta | **ni `<?php`, ni `$`, ni ningún comentario `//`** |

Si en la fuente aparece un `<?php` o un `$`, el fichero no se está ejecutando:
comprueba la extensión y la carpeta.

**Si acabas pronto:** añade un comentario `//` en el bloque y otro `<!-- -->` en el
HTML, y localiza en la fuente cuál de los dos ha llegado.

---

## 2. Variables, tipos y textos

```php
$titulo     = "A torre baixo a tormenta";   // string
$dificultad = 4;                            // int
$precio     = 12.5;                         // float
$aberta     = true;                         // bool
$pronostico = null;                         // null: "no hay dato"
```

- Empiezan por `$` y **distinguen mayúsculas**.
- No se declara el tipo: se lo pone PHP según lo que le metas.
- `null` **no es cero ni cadena vacía**: es *no hay dato*. En DW18 te vas a alegrar
  de que exista.

`var_dump()` es la forma de ver **valor y tipo** a la vez. Es una herramienta de
trabajo, no algo que se deja en la página terminada.

### Textos

```php
$a = 'Prazas: $plazas';        // comillas simples: NO sustituye. Sale literal
$b = "Prazas: $plazas";        // comillas dobles: SÍ sustituye
$c = "Prazas: {$plazas}";      // con llaves, cuando pega con lo de al lado
$d = 'Prazas: ' . $plazas;     // concatenar con punto
```

El punto (`.`) concatena. **No es `+`**: en PHP, `+` es sumar y solo sumar.

### En directo · G2 · Tipos, comillas y concatenación

Añade al **bloque de arriba** de `dw5_guiado.php`:

```php
$precio     = 12.5;      // float
$pronostico = null;      // null
```

Y, al final del bloque, cuatro líneas de inspección temporales:

```php
var_dump($titulo, $dificultad, $precio, $aberto, $pronostico);
echo "Quedan $plazas_lib plazas\n";
echo "Quedan {$plazas_lib} plazas\n";
echo 'Quedan ' . $plazas_lib . " plazas\n";
echo 'Quedan $plazas_lib plazas', "\n";
```

**Antes de ejecutar:** de las cuatro líneas de `echo`, ¿cuántas van a escribir el
número 2 y cuántas el texto `$plazas_lib`?

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `php ~/proyecto/public/dw5_guiado.php` | El volcado de los cinco tipos y las cuatro líneas |
| 2 | Lee el volcado | `string(22)`, `int(3)`, `float(12.5)`, `bool(true)`, `NULL`. El `string` lleva **su longitud** |
| 3 | Lee las cuatro líneas | Las tres primeras, `Quedan 2 plazas`. La cuarta, `Quedan $plazas_lib plazas` |

Salida real del paso 3:

```
Quedan 2 plazas
Quedan 2 plazas
Quedan 2 plazas
Quedan $plazas_lib plazas
```

**El fallo provocado.** Cambia la tercera línea para concatenar con `+`:

```php
echo 'Quedan ' + $plazas_lib + " plazas\n";
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 4 | Repite el paso 1 | `Fatal error: Uncaught TypeError: Unsupported operand types: string + int` |

PHP no «suma textos»: `+` es aritmético y se niega. En otros lenguajes `+`
concatena, y es el error de traducción más repetido al llegar a PHP.

**Cómo se recupera:** vuelve al punto (`.`) y repite el paso 1.

Cuando lo hayas leído, **borra las cinco líneas de inspección**: eran para mirar.
`var_dump` no se queda en una página terminada.

### Ahora tú · AT5.2 · Las tres formas de construir el mismo texto *(5 minutos)*

**Fichero:** `public/at52_textos.php`

Con `$plazas = 9;`, construye el texto **Quedan 9 plazas** de dos maneras:
por interpolación con comillas dobles y por concatenación con el punto. Escribe
después la misma frase con **comillas simples** y mira qué sale. Termina con un
`var_dump($plazas)`.

**Resultado esperado**, en este orden:

```
Quedan 9 plazas
Quedan 9 plazas
Quedan $plazas plazas
int(9)
```

Las dos primeras líneas tienen que salir **idénticas** por los dos caminos. La
tercera tiene que salir con el `$plazas` escrito tal cual: ahí está la diferencia
entre las comillas.

**Si acabas pronto:** añade la variante con llaves, `"Quedan {$plazas} plazas"`, y
escribe en una línea cuándo hacen falta las llaves.

---

## 3. Operadores, y los tres sitios donde muerde

Los normales no tienen misterio: `+ - * / %`, `== != < > <= >=`, `&& || !`.

Estos sí:

```php
$a = "7";
$b = 7;
var_dump($a == $b);      // bool(true)   <- iguales "en valor"
var_dump($a === $b);     // bool(false)  <- distinto TIPO
var_dump("abc" == 0);    // bool(false)  <- en PHP 8 ya no es true
var_dump("" == 0);       // bool(false)  <- en PHP 8 tampoco
var_dump(null == false); // bool(true)
var_dump(null === false);// bool(false)
var_dump((int) "7 misiones");    // int(7)
var_dump((int) "misiones 7");    // int(0)
var_dump(0.1 + 0.2 == 0.3);      // bool(false)
var_dump(intdiv(7, 2), 7 % 2, 7 / 2);   // int(3) int(1) float(3.5)
```

**Las tres reglas que salen de ahí:**

1. **Usa `===` siempre.** `==` compara «como si fueran del mismo tipo» y eso, con
   datos que vienen de un formulario, da sorpresas. En este módulo, `===`.
2. **Lo que llega de un formulario es siempre texto.** `$_POST['dificultad']` es
   `"4"`, no `4`. Si necesitas el número, conviértelo **y comprueba antes que lo
   es** (eso es DW7).
3. **Los decimales no se comparan con `==`.** `0.1 + 0.2` no es exactamente `0.3`.
   Para dinero, o enteros de céntimos, o comparar con un margen.

Y las reglas exactas de las conversiones que vas a ver:

| Caso | Qué hace PHP | Resultado |
|---|---|---|
| `"7" == 7` | Convierte el texto numérico a número | `true` |
| `"abc" == 0` | Desde PHP 8, convierte el **0** a texto | `false` |
| `"" == 0` | Lo mismo: compara `""` con `"0"` | `false` |
| `null == false` | Los dos son «vacío» para `==` | `true` |
| `null === false` | Tipos distintos, y `===` los mira | `false` |
| `(int) "7 misiones"` | Lee desde el principio y para al dejar de haber número | `7` |
| `(int) "misiones 7"` | No hay número al principio | `0` |

### Y una que se paga cara

```php
(int) "7 misiones"   →   7
```

PHP **no protesta**: coge lo que puede y sigue. Por eso una validación de verdad no
es convertir, es **comprobar**. En DW7 lo harás con `ctype_digit()` o con una
expresión regular.

### En directo · G3a · Predecir, ejecutar, comparar

```bash
nano ~/proyecto/public/g3a_comparaciones.php
```

```php
<?php
$a = "7";
$b = 7;
var_dump($a == $b);
var_dump($a === $b);
var_dump("abc" == 0);
var_dump("" == 0);
var_dump(null == false);
var_dump(null === false);
var_dump((int) "7 misiones");
var_dump((int) "misiones 7");
var_dump(0.1 + 0.2 == 0.3);
var_dump(intdiv(7, 2), 7 % 2, 7 / 2);
```

**Antes de ejecutar nada**, escribe tus doce predicciones en una columna, en papel
—son doce y no diez, porque el último `var_dump` lleva tres valores—. El valor del
ejercicio está en haberlas escrito antes.

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `php ~/proyecto/public/g3a_comparaciones.php` | **Doce** líneas con valor y tipo |
| 2 | Compara con tus predicciones | Lo normal es fallar entre dos y cuatro |
| 3 | Mira la 3.ª y la 4.ª | `bool(false)` las dos. Antes de PHP 8 eran `true`: si lo has buscado en un manual viejo, te ha engañado |
| 4 | Mira la 7.ª y la 8.ª | `int(7)` y `int(0)`. **El mismo número, en otro sitio del texto, da cero** |
| 5 | Mira la última | `int(3) int(1) float(3.5)`: la división da `float` aunque salga exacta |

Salida real:

```
bool(true)
bool(false)
bool(false)
bool(false)
bool(true)
bool(false)
int(7)
int(0)
bool(false)
int(3)
int(1)
float(3.5)
```

**El fallo provocado.** Añade al final:

```php
var_dump(0.1 + 0.2);
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 6 | Repite el paso 1 | `float(0.30000000000000004)` |

Ahí está el motivo de que la comparación anterior diera `false`. No es un fallo de
PHP: es cómo se guardan los decimales en binario, y pasa igual en Java.

**Cómo se recupera:** para comparar decimales, `round($x, 10) == $y`, o trabajar en
enteros. Pruébalo: `var_dump(round(0.1 + 0.2, 10) == 0.3);` → `bool(true)`.

### Ahora tú · E5.2 · Predice, y luego ejecuta *(7 minutos)*

**Fichero:** `public/e52_tipos.php`

**Primero escribe tu predicción** al lado de cada línea, en un comentario. Después
ejecútalo y compara.

```php
<?php
var_dump("5" == 5);
var_dump("5" === 5);
var_dump(null == false);
var_dump(null === false);
var_dump("" == 0);
var_dump((int) "12 prazas");
var_dump((int) "prazas 12");
var_dump(0.1 + 0.7 == 0.8);
var_dump(round(0.1 + 0.7, 10) == 0.8);
```

**Resultado esperado**, en orden y con el tipo delante del valor:

```
bool(true)
bool(false)
bool(true)
bool(false)
bool(false)
int(12)
int(0)
bool(false)
bool(true)
```

Y contesta abajo, en tres líneas:

**a)** ¿Cuántas has fallado?
**b)** ¿Qué regla te llevas de las dos últimas?
**c)** Después de esto, ¿usarías `==` o `===` con datos que vienen de un formulario?

> Las nueve son de las que se preguntan en la prueba corta de la última sesión. Es
> el ejercicio que más se agradece haber hecho.

---

## 3.1 Los dos cálculos de la ficha

La ficha necesita dos números que no están en los datos: **cuánto está ocupado** y
**una barra** que se vea de un golpe. Los dos se calculan **arriba**.

### El porcentaje de ocupación

Lo que se ocupa es *lo que no está libre*:

```php
$ocupadas  = $plazas_tot - $plazas_lib;
$ocupacion = (int) round($ocupadas / $plazas_tot * 100);
```

Tres cosas, y las tres importan:

**1. Los paréntesis.** `$plazas_tot - $plazas_lib / $plazas_tot` **no** es lo mismo:
la división se hace antes que la resta. Con 8 y 2 daría `8 - 0,25 = 7,75` en vez de
`0,75`. Si no quieres fiarte del orden de memoria, escribe el paréntesis:

```php
($plazas_tot - $plazas_lib) / $plazas_tot
```

**2. `round()`.** `(8 - 2) / 8 * 100` da `75` justo, pero `(6 - 2) / 6 * 100` da
`66.666666666667`. `round($x)` devuelve el entero **más cercano**: `round(66.666)`
es `67`. Con un segundo argumento, redondea a esos decimales: `round(66.666, 2)` es
`66.67`.

**3. La conversión final, y por qué va después.** `round()` devuelve un `float`.
`(int)` lo deja en entero, y hace falta **para el tipo**, no para la pantalla:
`echo round(66.666)` ya escribe `67`, pero `var_dump` delata la diferencia:

```php
var_dump((int) round(4 / 6 * 100));   // int(67)
var_dump(round(4 / 6 * 100));         // float(67)
```

Y el orden importa, porque **`(int)` no redondea: trunca**. Se queda con la parte
entera y tira el resto:

```php
var_dump((int) round(4 / 6 * 100));   // int(67)   <- round primero, (int) despues
var_dump((int) (4 / 6 * 100));        // int(66)   <- sin round: se pierde un punto
```

Primero `round()`, después `(int)`. Al revés, o sin `round()`, el porcentaje sale
siempre un poco por debajo.

### La barra de dificultad

Cinco posiciones: un asterisco por punto de dificultad y un punto por lo que falta.

```php
$estrellas = str_repeat('*', $dificultad) . str_repeat('.', 5 - $dificultad);
```

`str_repeat($texto, $veces)` devuelve ese texto repetido. Y el punto de en medio es
el de concatenar del apartado 2: se pegan las dos mitades.

| `$dificultad` | `str_repeat('*', $d)` | `str_repeat('.', 5 - $d)` | `$estrellas` |
|---|---|---|---|
| 1 | `*` | `....` | `*....` |
| 3 | `***` | `..` | `***..` |
| 4 | `****` | `.` | `****.` |
| 5 | `*****` | *(cadena vacía)* | `*****` |

`str_repeat('.', 0)` devuelve cadena vacía, sin protestar. Que la dificultad pueda
venir fuera del 1-5 es un problema real, y se resuelve en DW6 con una decisión; en
DW5 los datos los pones tú y los pones coherentes.

### En directo · G3b · El porcentaje y la barra del taller

Añade al bloque de arriba de `dw5_guiado.php`, **después** de los datos:

```php
$ocupacion = (int) round(($plazas_tot - $plazas_lib) / $plazas_tot * 100);
$estrellas = str_repeat('*', $dificultad) . str_repeat('.', 5 - $dificultad);
```

Y cambia las dos líneas de abajo:

```php
<p>Dificultade: <?= $estrellas ?> (<?= $dificultad ?>/5)</p>
<p>Prazas: <?= $plazas_lib ?> libres de <?= $plazas_tot ?> · ocupacion <?= $ocupacion ?> %</p>
```

**Antes de ejecutar:** con 8 totales, 2 libres y dificultad 3, ¿qué porcentaje y qué
barra esperas? Escríbelos.

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `curl -sS http://localhost/dw5_guiado.php` | `Dificultade: ***.. (3/5)` |
| 2 | En la misma salida | `ocupacion 75 %`, **sin decimales** |
| 3 | Deja la fórmula pelada, `($plazas_tot - $plazas_lib) / $plazas_tot * 100`, sin `round()` ni `(int)`, y repite | Sigue saliendo `75 %`: con 8 y 2 la división es exacta |
| 4 | Cambia a `$plazas_tot = 6;` y repite, con la fórmula pelada | `ocupacion 66.666666666667 %` |
| 5 | Pon **solo** el `(int)`, sin `round()`, y repite | `ocupacion 66 %`. El `(int)` **trunca**: se ha perdido un punto |
| 6 | Pon `round()` **y** `(int)`, y repite | `ocupacion 67 %` |
| 7 | Añade `var_dump($ocupacion);` arriba, con el `(int)` y sin él | `int(67)` y `float(67)`: en la página no se ve, en el tipo sí |

Los pasos 3 y 4 son los que hay que ver: **el redondeo y la conversión no se notan
hasta que los números no son redondos**. Y el 5 es el que se cuela en una entrega,
porque 66 es un número perfectamente creíble. Borra el `var_dump` y deja
`$plazas_tot` otra vez en 8.

**El fallo provocado.** Cambia la fórmula para contar las **libres** en vez de las
ocupadas:

```php
$ocupacion = (int) round($plazas_lib / $plazas_tot * 100);
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 6 | Repite el paso 1 | `ocupacion 25 %` |

Nadie se da cuenta mirando el código: 25 es un número perfectamente creíble. Se
descubre **comprobando contra un caso que sabes de memoria**: si quedan 2 de 8
libres, está ocupado el 75 %, no el 25 %.

**Cómo se recupera:** vuelve al numerador `($plazas_tot - $plazas_lib)` y comprueba
que vuelve a decir 75 %.

### Ahora tú · AT5.3 · Dos fichas más *(10 minutos)*

**Fichero:** `public/at53_barra.php`

Calcula el porcentaje de ocupación y la barra de cinco posiciones para estos dos
casos, y escríbelos.

| Caso | Totales | Libres | Dificultad | Ocupación esperada | Barra esperada |
|---|---|---|---|---|---|
| A | 6 | 2 | 4 | `67 %` | `****.` |
| B | 5 | 5 | 1 | `0 %` | `*....` |

Los dos cálculos van **arriba**, en variables, y abajo solo se pintan.

El caso B es el que conviene mirar dos veces: con todas las plazas libres la
ocupación es **cero**, y la barra sigue teniendo cinco posiciones.

**Si acabas pronto:** haz el caso C —8 totales, 3 libres, dificultad 5— y predice
el resultado antes de ejecutarlo.

---

## 4. Escribir en el documento, y escapar

```php
echo "Hola";                      // lo normal
echo "Hola", " ", "mundo";        // varias cosas de una vez
var_dump($algo);                  // valor Y tipo (para depurar)
```

`var_dump` **no va en la página terminada**: es para mirar.

Una cosa pequeña y que confunde: `echo` **no añade ningún salto de línea**. Dos
`echo` seguidos escriben el texto pegado:

```php
echo "Quedan 3 prazas";
echo "Quedan 4 prazas";
```

escribe `Quedan 3 prazasQuedan 4 prazas`, de un tirón. Si quieres dos líneas en la
**salida de texto** —la que ves por terminal, o en el registro— hay que pedirlas:

```php
echo "Quedan 3 prazas", "\n";
echo "Quedan 4 prazas", "\n";
```

Y una distinción que hay que tener clara desde hoy: **la salida de texto y lo que se
ve en el navegador no son lo mismo**. El `"\n"` separa líneas en el texto, pero el
navegador lo trata como un espacio: en una página, lo que separa párrafos es
`<p>`...`</p>`, no el salto de línea. En la fuente verás las dos líneas; en la
página, una sola si no hay etiquetas.

### Escapar: `htmlspecialchars`

Lo que sale de tus manos es tuyo. Lo que **viene de fuera** —de un formulario, de una
base de datos, de un servicio— hay que escaparlo antes de pintarlo:

```php
$titulo = "A torre <script>alert(1)</script>";

echo "<h1>$titulo</h1>";
// SIN escapar : <h1>A torre <script>alert(1)</script></h1>

echo "<h1>", htmlspecialchars($titulo, ENT_QUOTES, "UTF-8"), "</h1>";
// escapado    : <h1>A torre &lt;script&gt;alert(1)&lt;/script&gt;</h1>
```

En el primer caso el navegador **ejecuta** ese script. En el segundo lo **enseña como
texto**, que es lo que se pidió.

Por eso en `apoyo.php` hay una función de una línea, **dada hecha**:

```php
function h(?string $s): string
{
    return htmlspecialchars((string) $s, ENT_QUOTES, 'UTF-8');
}
```

Y se usa **siempre** que se pinta algo que no has escrito tú: `<?= h($titulo) ?>`.
Escribir y documentar funciones propias es DW6; aquí se practica **usarla**.

### En directo · G4 · La alerta, la fuente y la función `h()`

Por ahora `h()` vive **dentro** de la página: en el apartado 6 sale a su fichero.
Añade al principio del bloque de `dw5_guiado.php`, antes de los datos:

```php
function h(?string $s): string
{
    return htmlspecialchars((string) $s, ENT_QUOTES, 'UTF-8');
}
```

Cambia el título por uno con una etiqueta dentro:

```php
$titulo = 'Taller de <cordas> e nos';
```

Y deja la línea de abajo **todavía sin escapar**: `<h1><?= $titulo ?></h1>`.

**Antes de ejecutar:** ¿qué va a aparecer en la página, y qué en la fuente?

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `curl -sS http://localhost/dw5_guiado.php \| grep h1` | `<h1>Taller de <cordas> e nos</h1>` |
| 2 | Ábrela en el navegador | El título dice **Taller de  e nos**: la palabra `cordas` ha desaparecido |
| 3 | `Ctrl+U` | El `<cordas>` **sí está** en la fuente |

El navegador ha tomado `<cordas>` por una etiqueta HTML que no conoce, y una
etiqueta no se pinta. Tu dato se ha convertido en marcado.

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 4 | Pon `<h1><?= h($titulo) ?></h1>` y repite el paso 1 | `<h1>Taller de &lt;cordas&gt; e nos</h1>` |
| 5 | Recarga el navegador | El título dice **Taller de \<cordas\> e nos**, entero |
| 6 | `Ctrl+U` otra vez | `&lt;cordas&gt;`. El navegador pinta `&lt;` como `<`, y no lo trata como etiqueta |

**El fallo provocado.** Cambia el título, solo durante este paso, por un texto con
una etiqueta que el navegador **sí** conoce y que además ejecuta:

```php
$titulo = 'Taller <script>alert("sen escapar")</script>';
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 7 | Quita el `h()` de la línea del título y recarga en el navegador | **Salta una ventana de alerta** |
| 8 | Devuelve el `h()` y recarga | No salta nada: la página enseña el texto `<script>alert("sen escapar")</script>` |

El script es tuyo y es inofensivo. En dos semanas el título lo escribe quien rellene
un formulario, y el script puede no ser inofensivo. Hoy esto es una **regla de
higiene con una demostración**: `h()` siempre. El tratamiento serio es DW7 y DW11.

**Cómo se recupera:** deja el título en `'Taller de <cordas> e nos'` y la línea con
`h()`. Pon `h()` también en la categoría.

### Ahora tú · E5.3 · El club del Norte *(10 minutos)*

**Fichero:** `public/e53_escapar.php`

1. Guarda en una variable este título: `Club <b>Norte</b>`.
2. Píntalo **sin escapar**. Ábrelo en el navegador. Anota qué pasa.
3. Píntalo con `h()`. Anota qué pasa ahora.
4. Mira las dos veces el **código fuente** que llega y explica la diferencia.

**Resultado esperado:**

| | En la página | En la fuente |
|---|---|---|
| Sin escapar | `Club Norte`, con **Norte en negrita** | `Club <b>Norte</b>` |
| Con `h()` | `Club <b>Norte</b>`, con las etiquetas **a la vista** | `Club &lt;b&gt;Norte&lt;/b&gt;` |

Las dos líneas de texto que tiene que escribir tu página:

```
<p>Sen escapar: Club <b>Norte</b></p>
<p>Escapado: Club &lt;b&gt;Norte&lt;/b&gt;</p>
```

Si en la segunda ves `<b>` en vez de `&lt;b&gt;`, el `h()` no se está aplicando.

**A partir de aquí, todo lo que pintes que no hayas escrito tú va con `h()`.**

---

## 5. Directivas: cambiar lo que PHP hace por defecto

Tres, y las tres van en el proyecto.

### 5.1 Tipos estrictos

```php
<?php
declare(strict_types=1);
```

Va **en la primera línea de código del fichero**, antes de nada. Con eso, PHP deja de
convertir los argumentos de las funciones por su cuenta:

```php
function plazas(int $n): string { return "Quedan $n prazas"; }

echo plazas(4), "\n";
echo plazas("4"), "\n";    // <- aqui cambia todo
```

La función del ejemplo está **dada hecha**: lo que se compara aquí es el efecto de la
directiva.

**Sin** `declare(strict_types=1)`:

```
Quedan 4 prazas
Quedan 4 prazas          <- PHP convierte "4" a 4 y sigue tan tranquilo
```

**Con** `declare(strict_types=1)`:

```
Quedan 4 prazas
PHP Fatal error: Uncaught TypeError: plazas(): Argument #1 ($n) must be of type
int, string given
```

Parece peor. Es **muchísimo mejor**: el error salta donde está el problema, no tres
funciones más allá con un dato raro.

> **Hasta dónde llega la directiva.** `strict_types` mira **los argumentos y los
> retornos de las funciones**, y nada más. **No quita las conversiones de PHP.** Con
> la directiva puesta:
>
> ```php
> var_dump("3" + 1);               // int(4)
> var_dump((int) "7 misiones");    // int(7)
> var_dump("10" == "1e1");         // bool(true)
> ```
>
> Las tres siguen igual. Lo del apartado 3 no se arregla con una directiva: se
> arregla comprobando, y eso es DW7.

### En directo · G5a · El antes y el después de la directiva

```bash
nano ~/proyecto/public/g5a_estricto.php
```

```php
<?php
declare(strict_types=1);
function plazas(int $n): string { return "Quedan $n prazas"; }
echo plazas(4), "\n";
echo plazas("4"), "\n";
```

**Antes de ejecutar:** ¿cuántas líneas va a escribir, y qué va a pasar con la
segunda llamada?

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `php ~/proyecto/public/g5a_estricto.php` | `Quedan 4 prazas` y debajo un `TypeError` |
| 2 | Lee el mensaje | `Argument #1 ($n) must be of type int, string given`, **con el fichero y la línea** |
| 3 | Comenta la línea 2 (`// declare(...)`) y repite | **Dos** líneas `Quedan 4 prazas`: la segunda llamada ha pasado |
| 4 | Quita los dos `, "\n"` y repite | `Quedan 4 prazasQuedan 4 prazas`, pegado |
| 5 | Devuélvelos | Otra vez dos líneas |

El paso 4 es el separador del apartado 4, visto en su sitio: `echo` no salta de
línea solo.

**El fallo provocado.** Descomenta la línea 2 y cambia la primera llamada a
`plazas(4.0)`:

```php
echo plazas(4.0), "\n";
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 6 | Repite el paso 1 | Otro `TypeError`: `must be of type int, float given` |

Un `4.0` tampoco pasa: con la directiva puesta, un `float` no se cuela como `int`
aunque no tenga decimales.

**Cómo se recupera:** vuelve a `plazas(4)`, y deja el fichero **con** la directiva.

### Ahora tú · E5.4a · Las dos llamadas *(4 minutos)*

**Fichero:** `public/e54a_estricto.php`

Copia el bloque facilitado y llámalo con `4` y con `"4"`. Ejecútalo **sin**
`declare(strict_types=1)` y **con** él. Pega las dos salidas y explica cuál
prefieres para el proyecto y por qué.

**Resultado esperado:**

| | Primera llamada, `plazas(4)` | Segunda llamada, `plazas("4")` |
|---|---|---|
| **Sin** la directiva | `Quedan 4 prazas` | `Quedan 4 prazas` |
| **Con** la directiva | `Quedan 4 prazas` | `TypeError`: `must be of type int, string given` |

---

### 5.2 Errores: visibles aquí, invisibles allí

Las directivas de errores se pueden poner en la configuración de PHP o desde el
propio fichero. Desde el fichero, **completas**, son estas cuatro líneas:

```php
error_reporting(E_ALL);          // de que me quiero enterar: de todo
ini_set('display_errors', '1');  // ¿se enseña en la respuesta? en desarrollo, si
ini_set('log_errors', '1');      // ¿se escribe en el registro? siempre, si
date_default_timezone_set('Europe/Madrid');
```

Las dos de en medio son independientes, y es la pareja lo que importa:

| | `display_errors` | `log_errors` |
|---|---|---|
| **Tu máquina de desarrollo** | `1`: quieres verlos al momento | `1` |
| **Un servidor de verdad** | `0`: un error enseña rutas, versiones y a veces datos | `1`, y se leen en el registro |

**Nunca las dos a cero.** Con `display_errors = 0` y `log_errors = 0` el error
ocurre y no queda rastro en ningún sitio.

### Dónde está tu registro

En DW2 configuraste tu sitio con su propio registro:

```apache
ErrorLog  ${APACHE_LOG_DIR}/proyecto_error.log
```

Así que lo tuyo se lee aquí, y no en el `error.log` general de Apache:

```bash
sudo tail -f /var/log/apache2/proyecto_error.log
```

Si miras `/var/log/apache2/error.log` y está vacío, no es que no haya error: es que
estás mirando el registro equivocado. El tuyo es `proyecto_error.log`.

### Tres cosas que no son lo mismo

Conviene separarlas desde hoy, porque se confunden:

| | Qué es | ¿Para la página? | ¿Qué código HTTP? |
|---|---|---|---|
| **Aviso** (`Warning`, `Notice`) | PHP ha encontrado algo raro y **sigue**: una variable que no existe, una clave que falta | No. La página se termina de servir | **200**. Para Apache todo ha ido bien |
| **Error fatal** en ejecución (`Fatal error`, `TypeError`) | PHP **para** a mitad de la página | Sí, a medias: sale lo que ya se había escrito y nada más | **500**, si no se había enviado nada aún |
| **Error de sintaxis** (`Parse error`) | El fichero **no se llega a ejecutar**: PHP no lo entiende | Sí. No sale nada de la página | **500** |

Lo importante de la tabla es la primera fila: **un aviso no rompe nada y no cambia
el código de estado**. Con `display_errors = 0`, la página sale «bien», con 200, y lo
único raro es un hueco vacío. Es exactamente lo que te pasó en G1 con `$Titulo`.

Y la de abajo: un error de sintaxis se come la página entera, así que `php -l` antes
de recargar ahorra la mitad de los 500.

### En directo · G5b · Provocar un aviso y encontrarlo en el registro

Añade las cuatro líneas de arranque al principio de `dw5_guiado.php`, antes de la
función `h()`:

```php
<?php
declare(strict_types=1);
date_default_timezone_set('Europe/Madrid');
error_reporting(E_ALL);
ini_set('display_errors', '1');
ini_set('log_errors', '1');
```

Y añade al HTML una línea con una variable **que no existe**:

```php
<p>Turno: [<?= $turnoAusente ?>]</p>
```

**Antes de ejecutar:** ¿qué código de estado va a devolver la página? ¿200 o 500?

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | Abre una segunda terminal: `sudo tail -f /var/log/apache2/proyecto_error.log` | Se queda esperando. Déjala a la vista |
| 2 | En la primera: `curl -sS -o /dev/null -w "%{http_code}\n" http://localhost/dw5_guiado.php` | **200**. El aviso no cambia el estado |
| 3 | `curl -sS http://localhost/dw5_guiado.php \| grep -A2 Turno` | El aviso **metido dentro del HTML**, entre los corchetes |
| 4 | Mira la segunda terminal | La misma línea, con **fecha, nombre de la variable, fichero y número de línea** |

Salida real del paso 3:

```html
<p>Turno: [<br />
<b>Warning</b>:  Undefined variable $turnoAusente in <b>/home/tuusuario/proyecto/public/dw5_guiado.php</b> on line <b>34</b><br />
]</p>
```

Fíjate en que PHP ha escrito `<br />` y `<b>` dentro de **tu** párrafo: el aviso no
va «por otro canal», se cuela en la respuesta. Por eso en producción se apaga.

Y la del paso 4, **tal como sale en la VM del curso**:

```
[Tue Oct 06 23:07:01 2026] [proxy_fcgi:error] [pid 1237] [client ::1:49800] AH01071: Got error 'PHP message: PHP Warning:  Undefined variable $turnoAusente in /home/tuusuario/proyecto/public/dw5_guiado.php on line 34'
```

Parece más ruidosa de lo que es, y el motivo está en DW2 §5: con **php-fpm**, Apache no
ejecuta PHP, se lo pide a otro proceso, y lo que PHP contesta llega **envuelto** —
`[proxy_fcgi:error]` y `AH01071: Got error '…'`—. Si tu VM quedó con el **módulo**, la
línea viene más desnuda, sin el envoltorio.

**No te pelees con el envoltorio.** Lo que has venido a buscar son tres cosas, y están
en las dos formas:

| | En la línea de arriba |
|---|---|
| **Qué** ha pasado | `PHP Warning: Undefined variable` |
| **Cómo se llama** | `$turnoAusente` |
| **Dónde** | `dw5_guiado.php` **on line 34** |

Ahí están las dos cosas que necesitas para arreglarlo: **cómo se llama** la variable
y **en qué línea** está.

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 5 | Cambia a `ini_set('display_errors', '0');` y repite el paso 3 | `<p>Turno: []</p>`: el hueco vacío, **sin ninguna pista** |
| 6 | Mira la segunda terminal | La línea **vuelve a aparecer**: `log_errors` sigue a 1 |
| 7 | Repite el paso 2 | Sigue siendo **200** |

Los pasos 5 a 7 son la unidad entera en tres órdenes: la página parece correcta,
responde 200, y lo que ha pasado solo está en el registro.

**El fallo provocado, el de verdad.** Rompe la sintaxis. Añade al bloque de arriba
una línea con una coma decimal, que es el error más repetido al venir de otro
idioma:

```php
$metros = 3 * 0,25;
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 8 | `php -l ~/proyecto/public/dw5_guiado.php` | `Parse error: syntax error, unexpected token ","`, con su línea |
| 9 | Repite el paso 2 | **500**, y esta vez sí |
| 10 | `curl -sS http://localhost/dw5_guiado.php` | **Nada**: el cuerpo está vacío. No sale ni el principio del HTML |
| 11 | Mira la segunda terminal | `PHP Parse error: syntax error, unexpected token ","` con el fichero y la línea |

Compara el paso 9 con el 7: **el aviso daba 200 y el error de sintaxis da 500**. Son
dos cosas distintas y se buscan de forma distinta: el aviso, leyendo el registro de
una página que «va bien»; el de sintaxis, con `php -l` **antes** de recargar.

> Un detalle que sorprende: quitar el punto y coma de la **última** sentencia de un
> bloque no rompe nada, porque el `?>` ya cierra la sentencia. Si quieres provocar un
> error de sintaxis a propósito, la coma decimal es más fiable.

**Cómo se recupera:**

1. Borra la línea del `$metros` y comprueba con `php -l`: `No syntax errors detected`.
2. Borra la línea del `<p>Turno:` del HTML.
3. Deja `display_errors` en `'1'`: estás en tu máquina de desarrollo.
4. `Ctrl+C` en la segunda terminal para recuperar el prompt.

### Ahora tú · E5.4b · El turno que no existe *(3 minutos)*

**Fichero:** `public/e54b_errores.php`

1. Provoca un aviso a propósito con una variable `$turnoAusente` que no has
   definido.
2. Alterna `display_errors` entre `'1'` y `'0'` y anota qué se ve en la página en
   cada caso.
3. Con él a `'0'`, **encuentra el aviso en el registro de tu sitio** y copia la
   línea.
4. Termina con el fallo **corregido**: define la variable, o quita la línea.

**Resultado esperado:**

| | Lo que ve quien visita | Código HTTP |
|---|---|---|
| `display_errors = 1` | `Turno: [` y el texto del aviso dentro de la página | 200 |
| `display_errors = 0` | `Turno: []`, un hueco vacío | 200 |

Y en `proyecto_error.log`, en los dos casos, una línea que contiene:

- el nombre de la variable: `$turnoAusente`
- el nombre de tu fichero: `e54b_errores.php`
- el número de línea

Lo que se mira es que hayas **encontrado** esa línea y que el fichero quede
arreglado al final.

---

### 5.3 Zona horaria, y los días que faltan

```php
date_default_timezone_set('Europe/Madrid');
```

Sin eso, PHP suele trabajar en UTC, y la diferencia se ve:

```
UTC             05/10/2026 11:00
Europe/Madrid   05/10/2026 13:00
```

Dos horas en octubre, **una en invierno**: España va una hora por delante de UTC en
horario de invierno y dos en verano. En un proyecto donde las misiones tienen
**fecha** y hay que rechazar las del pasado, eso no es un detalle.

`date()` da la fecha y la hora con el formato que le pidas:

```php
date('Y-m-d')      // 2026-10-05   <- el formato para guardar y comparar
date('d/m/Y')      // 05/10/2026   <- el formato para leer
date('H:i:s')      // 13:00:00
date('N')          // 1            <- dia de la semana, 1 = lunes
```

### Los días que faltan: una función dada hecha

Contar días parece una resta y no lo es. La forma que se escribe sola —restar dos
marcas de tiempo y dividir entre 86 400— **da mal un día al año**, porque hay dos
días que no tienen 24 horas: los del cambio de hora. En Madrid, del 27 al 29 de
marzo de 2027 hay **dos** días de calendario, pero solo 47 horas, y esa división
devuelve **1**.

Así que en `apoyo.php` tienes la función ya escrita y probada:

```php
dias_entre(string $hoy, string $fecha): int
```

**Qué hace.** Cuenta **días de calendario**, no intervalos de 24 horas.

**Contrato.** Las dos cadenas tienen que ser fechas válidas en formato
`AAAA-MM-DD`. Con cualquier otra cosa, la función se queja en vez de devolver un
número raro. Comprobar lo que escribe una persona es DW7; aquí los datos los pones
tú.

**Qué devuelve.** Un entero **con signo**:

| Llamada | Resultado | Por qué |
|---|---|---|
| `dias_entre('2026-10-05', '2026-10-08')` | `3` | faltan tres días |
| `dias_entre('2026-10-05', '2026-10-05')` | `0` | es hoy |
| `dias_entre('2026-10-08', '2026-10-05')` | `-3` | ya pasó, hace tres días |
| `dias_entre('2027-03-27', '2027-03-29')` | `2` | dos días, aunque solo haya 47 horas |

El negativo es útil: en DW6, «la fecha ya pasó» va a ser exactamente
`dias_entre(...) < 0`.

Para la fecha de hoy se le pasa `date('Y-m-d')`:

```php
$dias = dias_entre(date('Y-m-d'), $fecha);
```

> **Para investigar.** Nada de lo de arriba hace falta buscarlo. Si te sobra
> curiosidad: `number_format()` para separar miles, `strtotime('+1 week')` para
> fechas relativas y la lista completa de letras de `date()` en el manual.

### En directo · G5c · La fecha, la zona y los días

Añade al bloque de `dw5_guiado.php`, después de los datos:

```php
$hoy   = '2026-10-05';
$fecha = '2026-10-08';
$dias  = dias_entre($hoy, $fecha);
```

Copia también la función `dias_entre()` de `apoyo.php` al bloque de arriba, al lado
de `h()`. En el apartado 6 las dos se van a su fichero.

Y añade abajo:

```php
<p>Data: <?= h($fecha) ?> (faltan <?= $dias ?> dias)</p>
```

**Antes de ejecutar:** ¿cuántos días hay del 5 al 8 de octubre?

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `curl -sS http://localhost/dw5_guiado.php \| grep Data` | `faltan 3 dias` |
| 2 | `php -r "date_default_timezone_set('UTC'); echo date('d/m/Y H:i');"` | La hora **en UTC** |
| 3 | Lo mismo con `Europe/Madrid` | Dos horas más (en octubre) |
| 4 | `php -r "echo date('Y-m-d'), ' ', date('d/m/Y'), ' ', date('N');"` | Los tres formatos de la misma fecha |
| 5 | Pon `$fecha = '2026-10-05';` y repite el paso 1 | `faltan 0 dias` |
| 6 | Pon `$fecha = '2026-10-01';` y repite | `faltan -4 dias`. El signo dice que ya pasó |

**El fallo provocado.** Cambia la llamada por la resta de marcas de tiempo, que es
la que se escribe sola:

```php
$dias = (int) ((strtotime($fecha) - strtotime($hoy)) / 86400);
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 7 | Deja `$hoy = '2026-10-05'` y `$fecha = '2026-10-08'`, y repite el paso 1 | `faltan 3 dias`. **Parece que funciona** |
| 8 | Pon `$hoy = '2027-03-27'` y `$fecha = '2027-03-29'`, y repite | `faltan 1 dias`. Son **dos** días |

Ese es el día del cambio de hora. Con el dato cómodo el fallo no se ve; con el dato
incómodo, sí. Es la razón por la que esta función viene dada y probada.

**Cómo se recupera:** vuelve a `dias_entre($hoy, $fecha)`, repite el paso 8 y
comprueba que dice `2`. Deja luego las fechas en 2026-10-05 y 2026-10-08.

### Ahora tú · E5.4c · Relojes y días *(3 minutos)*

**Fichero:** `public/e54c_fechas.php`

1. Imprime `date('d/m/Y H:i')` con `UTC` y con `Europe/Madrid`. Anota la diferencia
   y di por qué le importa a un proyecto que rechaza fechas pasadas.
2. Calcula los días del **5 al 9 de octubre de 2026** y los de **una fecha a sí
   misma**.

**Resultado esperado:**

| | |
|---|---|
| Diferencia entre `UTC` y `Europe/Madrid` | **una hora** en horario de invierno, **dos** en verano. En octubre de 2026, dos |
| `dias_entre('2026-10-05', '2026-10-09')` | `4` |
| `dias_entre('2026-10-05', '2026-10-05')` | `0` |

---

## 6. Repartir el fichero: configuración, funciones y plantillas

Hasta ahora todo estaba en una página. El repositorio del proyecto, en cambio, viene
repartido así:

```
~/proyecto/
├── public/            <- la raiz del sitio. Lo UNICO que se sirve por web
│   ├── index.php
│   ├── ficha.php
│   └── estilo.css
├── plantillas/        <- la cabecera y el pie, una sola vez
│   ├── cabecera.php
│   └── pie.php
├── src/               <- codigo que NO se sirve
│   ├── config.php
│   └── funciones.php
└── datos/
```

Y se trae lo que hace falta con `require`:

```php
require __DIR__ . '/../src/funciones.php';
```

| | Si el fichero no está |
|---|---|
| `include` | Aviso y **sigue** |
| `require` | **Error fatal y para** |

**Usa `require`** para lo que es imprescindible: si falta la configuración, mejor que
la página muera a que se sirva a medias.

`__DIR__` es la carpeta del fichero actual. Con él las rutas no dependen de desde
dónde se llame, que es justo lo que va a pasar en DW12 cuando todo entre por
`index.php`.

### Los seis bloques, en este orden

Toda página del proyecto tiene esta forma, y el orden no es decorativo:

| | Bloque | Por qué va ahí |
|---|---|---|
| 1 | **Arranque**: zona horaria y directivas de error | Antes de que pueda fallar algo |
| 2 | **Configuración**: `$cfg = require __DIR__ . '/../src/config.php';` | La cabecera necesita `$cfg` para pintar el nombre y el lema |
| 3 | **Funciones** facilitadas: `require __DIR__ . '/../src/funciones.php';` | Antes de usar `h()` o `dias_entre()` |
| 4 | **Datos y cálculos** | *Primero se piensa* |
| 5 | **La cabecera**: `require __DIR__ . '/../plantillas/cabecera.php';` | Cuando ya está todo decidido |
| 6 | **Lo que se pinta**, y al final el pie | *Después se pinta* |

El bloque 2 es el que más se olvida. `plantillas/cabecera.php` **ya viene escrito**
en el repositorio y usa `$cfg['nombre_app']` y `$cfg['lema']`: si `$cfg` no está
cargado antes del `require`, la cabecera no tiene de dónde sacar el nombre.

> **Las plantillas del repositorio no se tocan.** `cabecera.php` y `pie.php` se
> **reutilizan** tal como vienen: ni se sobrescriben, ni se borran, ni se copian a
> otro sitio con otro nombre. Lo único que cambias tú es `src/config.php`, donde
> **bautizas tu aplicación**: ese nombre es el que sale en la cabecera de todas tus
> páginas.

### En directo · G6 · Sacar las funciones y reutilizar las plantillas

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `ls -R ~/proyecto` o `tree ~/proyecto -L 2` | El árbol de arriba, con `public/`, `plantillas/`, `src/` y `datos/` |
| 2 | `cat ~/proyecto/src/config.php` | Un `return [...]` con `nombre_app` y `lema` |
| 3 | `cat ~/proyecto/plantillas/cabecera.php` | Ahí está `$cfg['nombre_app']`. **Por eso hace falta `$cfg`** |
| 4 | Cambia `'nombre_app'` en `src/config.php` por el nombre de tu gremio | — |

Ahora el traslado. Crea `src/funciones.php` con **las dos funciones** copiadas de
`apoyo.php`, y en `dw5_guiado.php`:

1. borra las dos definiciones del bloque de arriba;
2. pon arriba, por este orden, el `$cfg` y el `require` de las funciones;
3. cambia el `<!doctype html>` y el `</body></html>` que tecleaste a mano por el
   `require` de la cabecera y el del pie.

El principio queda así:

```php
<?php
declare(strict_types=1);
date_default_timezone_set('Europe/Madrid');
error_reporting(E_ALL);
ini_set('display_errors', '1');
ini_set('log_errors', '1');

$cfg = require __DIR__ . '/../src/config.php';
require __DIR__ . '/../src/funciones.php';
```

y el final, así:

```php
require __DIR__ . '/../plantillas/cabecera.php';
?>
<h1><?= h($titulo) ?></h1>
...
<?php require __DIR__ . '/../plantillas/pie.php'; ?>
```

**Antes de ejecutar:** la página va a cambiar de aspecto. ¿Qué dos textos nuevos
esperas ver arriba?

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 5 | `curl -sS http://localhost/dw5_guiado.php` | La cabecera del repositorio, con **el nombre que pusiste en el paso 4** y el lema |
| 6 | En la misma salida, abajo | El cierre del pie. Tu HTML tecleado a mano ya no está |
| 7 | En la misma salida, en medio | Los mismos datos de antes: `***..`, `75 %`, `faltan 3 dias` |
| 8 | `ls ~/proyecto/plantillas` | Los **dos** ficheros, intactos. No se ha tocado ninguno |

**El fallo provocado.** Añade al final del fichero, para tener un testigo:

```php
<!-- MARCADOR FINAL -->
```

Y ahora, tres movimientos. **Primero**, equivoca la ruta del `require` de las
funciones:

```php
require __DIR__ . '/../src/funciones_que_no_existen.php';
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 9 | `curl -sS http://localhost/dw5_guiado.php` | Un `Fatal error` de `require` y **ningún `MARCADOR FINAL`**. No sale nada de la página |
| 10 | Cambia **ese mismo** `require` por `include` y repite | Dos `Warning` y, detrás, otro `Fatal error`: `Call to undefined function dias_entre()`. **Tampoco** sale el marcador |

El paso 10 es el que vale la pena: `include` ha dejado seguir, y la página se ha
muerto **dos líneas más abajo** de todas formas. Continuar no sirve de nada cuando lo
que faltaba se necesitaba de verdad; lo único que has ganado es que el error salga
lejos de su causa.

**Después**, devuelve esa ruta y pon un `include` **de algo que de verdad sea
opcional**, justo antes del marcador:

```php
<?php include __DIR__ . '/../src/extras.php'; ?>
<!-- MARCADOR FINAL -->
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 11 | Repite el paso 9 | La página **entera**, dos avisos, y el `MARCADOR FINAL` **sí aparece** |
| 12 | Cambia ese `include` por `require` y repite | Un `Fatal error` y el marcador **desaparece** |

Ahí está la diferencia en limpio, y sobre el único caso en que la elección es de
verdad una elección.

**Cómo se recupera:** devuelve la ruta buena del `require` de las funciones, quita
la línea del `include` opcional y el marcador, y comprueba con el paso 5.

### Ahora tú · E5.5 · La segunda página *(8 minutos)*

**Fichero:** `public/axenda.php`

Una **segunda** página que reutilice **la misma** configuración, **las mismas**
funciones y **las mismas** plantillas que la primera. Sin copiar la cabecera a otro
fichero y sin tocar `plantillas/`.

Que enseñe el nombre del taller y los días que faltan, y un enlace a la ficha.

**Resultado esperado:**

| | Qué tiene que verse |
|---|---|
| Arriba | La **misma** cabecera que la otra página, con el nombre que pusiste en `src/config.php` |
| En medio | El taller escapado y los días, calculados con `dias_entre()` |
| `ls plantillas/` | Los dos ficheros, **con la misma fecha de modificación** que antes de empezar |

Y la comprobación del `include`/`require`, con un `<!-- MARCADOR -->` al final del
fichero:

| Con una ruta que no existe | El marcador |
|---|---|
| `include` | **se ve** |
| `require` | **no se ve** |

**Termina con todo restaurado**: la ruta buena, `require`, y el marcador fuera.

---

## 7. Las tecnologías de servidor, en contexto

PHP no es la única forma de hacer esto. Lo que hay que saber es **qué papel cumple
cada pieza**, no la lista de nombres.

| Pieza | Ejemplos | Qué hace |
|---|---|---|
| Lenguaje de servidor | **PHP**, Python, Java, C#, JavaScript (Node) | Genera la respuesta |
| Servidor web | **Apache**, Nginx | Recibe la petición y sirve lo estático |
| Mecanismo que ejecuta el lenguaje | **módulo de Apache**, **php-fpm**, Gunicorn, Tomcat | Ejecuta el programa |
| Base de datos | **MariaDB**, PostgreSQL, SQLite | Guarda |
| Framework | **Laravel**, Django, Spring | Pone lo repetitivo ya hecho (DW13, DW14) |

### Las dos formas de ejecutar PHP detrás de Apache

En DW2 (§5) montaste las dos y las distinguiste con `php_sapi_name()`, que dice
**quién está ejecutando PHP**:

| Lo que dice `php_sapi_name()` | Qué significa | El servidor web es |
|---|---|---|
| `apache2handler` | PHP corre **dentro** de Apache, como módulo | Apache |
| `fpm-fcgi` | PHP corre **aparte**, en el servicio php-fpm, y Apache le pasa la petición | Apache |
| `cli` | No hay servidor web: lo has ejecutado tú desde la terminal | — |

Las dos primeras tienen a **Apache de servidor web**. Lo que cambia es dónde se
ejecuta PHP, no quién atiende la petición.

Y una trampa que se repite: **`php -v` en la terminal te dice la versión del intérprete
de la terminal**, no la del que está sirviendo tus páginas.

En una VM recién montada como la tuya las **dos suelen ser la misma**, porque las
instalaste juntas, así que al compararlas no verás ninguna diferencia. **Eso no hace
cierta la igualdad**: son dos programas distintos y nada obliga a que coincidan. En un
servidor de verdad, con dos versiones de PHP instaladas, no coinciden. La regla que te
llevas es *la del servidor se pregunta desde una página*, no *son iguales*.

### En directo · G7 · Cada pieza, con su evidencia

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `apache2 -v` | `Server version: Apache/2.4.x` → el **servidor web** |
| 2 | Crea `public/sapi.php` con `<?php echo php_sapi_name(), ' ', PHP_VERSION;` y pídelo con `curl` | `apache2handler` o `fpm-fcgi`, y la versión **del servidor** |
| 3 | `php -v` | La versión **del cliente de terminal**. Compárala con la del paso 2: en esta VM lo normal es que **salga la misma**, y eso no demuestra que tengan que serlo |
| 4 | `mariadb --version` o `systemctl status mariadb` | → el **almacén de datos** |
| 5 | `ls ~/proyecto` | **No hay `vendor/`**: todavía no hay framework |

**Antes del paso 2, predice:** ¿va a decir `apache2handler` o `fpm-fcgi`? Depende de
cuál de los dos caminos dejaste activo al final de DW2.

**El fallo provocado.** Ejecuta la misma página desde la terminal:

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 6 | `php ~/proyecto/public/sapi.php` | `cli`. **El mismo fichero dice otra cosa** |

No es un fallo del fichero: es que la SAPI describe **quién lo está ejecutando**. Un
«no me funciona» que se ha comprobado solo por terminal no se ha comprobado en el
servidor.

**Cómo se recupera:** pide la página siempre por HTTP cuando lo que quieres saber es
qué hace el servidor. Borra `sapi.php` al terminar, o déjalo: es inofensivo.

### Ahora tú · AT5.7 · Módulo o FPM *(5 minutos)*

Clasifica estas dos respuestas de `php_sapi_name()` y di, para cada una, **quién
ejecuta PHP** y **quién es el servidor web**:

| Respuesta | Quién ejecuta PHP | Quién es el servidor web |
|---|---|---|
| `apache2handler` | | |
| `fpm-fcgi` | | |

**Resultado esperado:** en `apache2handler`, PHP se ejecuta **dentro de Apache**,
como módulo; en `fpm-fcgi`, se ejecuta **en el servicio php-fpm, aparte**, y Apache
le pasa la petición por FastCGI. **En las dos, el servidor web es Apache.** Si has
escrito que en `fpm-fcgi` el servidor web es php-fpm, vuelve a DW2 §5.

---

## Errores típicos

| Síntoma | Qué pasa |
|---|---|
| La página sale en blanco | Error fatal o de sintaxis con `display_errors` apagado. A `proyecto_error.log` |
| Un hueco vacío y la página responde 200 | Un **aviso**: casi siempre una variable mal escrita. `proyecto_error.log` lo dice con su nombre |
| El registro general de Apache está vacío | Estás mirando `error.log`. El de tu sitio es **`proyecto_error.log`** |
| «headers already sent» | Hay una línea en blanco o un espacio **antes** de `<?php`, o un `?>` al final del fichero |
| Sale el código en el navegador | El fichero no acaba en `.php`, o no está bajo `public/` |
| Una comparación que «debería ser true» | Estás usando `==` con tipos distintos. `===` |
| Dos `echo` que salen pegados | `echo` no salta de línea. `, "\n"` para texto, `<p>` para una página |
| El porcentaje sale con muchos decimales | Falta `round()`, o falta el `(int)` de delante |
| El porcentaje sale «al revés» | Estás midiendo las libres. El numerador es `($tot - $lib)` |
| Los días faltan uno | Estás restando marcas de tiempo. `dias_entre()` |
| La fecha va una o dos horas desplazada | Falta la zona horaria |
| Sale `<script>` en la página y se ejecuta | No has escapado. `h()` |
| La cabecera sale sin nombre | Falta `$cfg = require ...` **antes** del `require` de la cabecera |

---

## Resumen en una página

```php
<?php
declare(strict_types=1);                 // 1 · arranque
date_default_timezone_set('Europe/Madrid');
error_reporting(E_ALL);
ini_set('display_errors', '1');
ini_set('log_errors', '1');

$cfg = require __DIR__ . '/../src/config.php';     // 2 · configuracion
require __DIR__ . '/../src/funciones.php';         // 3 · funciones dadas

$titulo    = '...';                                // 4 · datos y calculos
$ocupacion = (int) round(($tot - $lib) / $tot * 100);
$estrellas = str_repeat('*', $dif) . str_repeat('.', 5 - $dif);
$dias      = dias_entre(date('Y-m-d'), $fecha);

require __DIR__ . '/../plantillas/cabecera.php';   // 5 · la cabecera
?>
<h1><?= h($titulo) ?></h1>                         <!-- 6 · aqui se pinta -->
<?php require __DIR__ . '/../plantillas/pie.php'; ?>
```

- `<?php ?>` para bloques, `<?= ?>` para escribir. **Sin `?>` en la última línea de
  un fichero que sea solo PHP**; dentro de una plantilla mixta, cada bloque se cierra.
- `.` concatena. `+` solo suma. `echo` no salta de línea.
- **`===` siempre.** Lo del formulario es texto. `(int) "7 misiones"` da 7 sin
  protestar: convertir **no** es validar.
- Los cálculos, **arriba**: paréntesis, `round()`, `(int)`, `str_repeat()`.
- Los días, con `dias_entre()`: cuenta calendario, no 24 horas, y el signo dice si
  la fecha ya pasó.
- Todo lo que viene de fuera se pinta con `h()`.
- `declare(strict_types=1)` mira argumentos y retornos, **y nada más**.
- Errores: `display_errors` a 1 aquí y a 0 allí; `log_errors` a 1 **siempre**.
- Un **aviso** devuelve 200 y deja un hueco. Un **error de sintaxis** devuelve 500 y
  no deja página.
- Si algo no cuadra: **`proyecto_error.log`**.
