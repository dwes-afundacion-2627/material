# DW6 · Hoja de ejercicios entregables

**Estructuras, arrays y funciones · DWES · 2º DAW**

Esta hoja contiene los **entregables E6.1–E6.5**. Los ejercicios guiados y los «Ahora tú» de los apuntes sirven para preparar este trabajo; no son archivos adicionales que debas entregar con esta hoja.

Continúa en **el mismo repositorio**. Ya tienes una ficha que muestra una misión. Ahora vas a construir un tablón que recorra una colección de misiones y a trasladar los cálculos a funciones compartidas.

Al terminar tendrás dos páginas conectadas por el código que reutilizan: `public/tablon.php` mostrará la colección y `public/ficha.php` seguirá mostrando una misión.

**Conserva tu ambientación.** Puedes elegir los títulos y categorías de tus misiones; los nombres de los archivos, las funciones y las claves que se indican en esta hoja deben mantenerse.

---

## Antes de empezar: qué conservas y qué vas a cambiar

No crees otro repositorio ni una carpeta independiente para cada ejercicio. E6.1–E6.6 son partes de una misma aplicación.

| Archivo o carpeta | Qué haces en DW6 |
|---|---|
| `src/config.php` | Lo conservas con el nombre y el lema de tu aplicación. Sigues cargándolo en `$cfg` antes de la cabecera. |
| `plantillas/cabecera.php` y `plantillas/pie.php` | Los reutilizas con `require`. No los editas, borras ni duplicas. |
| `public/index.php` | Conservas el punto de entrada que ya tiene el repositorio. Para comprobar esta entrega abres directamente `tablon.php` y `ficha.php`. |
| `src/funciones.php` | Conservas `h()` y `dias_entre()` y añades las cinco funciones de E6.4. |
| `public/ficha.php` | Modificas la ficha de DW5 para que utilice las funciones compartidas. |
| `src/tablon.php` | Creas este archivo para los datos en memoria de E6.1. |
| `public/tablon.php` | Creas esta página y la completas entre E6.2 y E6.3. |
| `BITACORA_PROMPTS.md` | Lo mantienes al día con el trabajo real de esta unidad. |

`src/tablon.php` y `public/tablon.php` **son archivos distintos**: el primero proporciona los datos; el segundo los utiliza para generar HTML.

### Cómo avanzar por los ejercicios

Los apartados se apoyan entre sí. E6.4 reúne las funciones que vas necesitando durante el trabajo; no es necesario esperar a terminar E6.3 para empezar a escribirlas.

1. Crea los datos de E6.1.
2. Construye el listado de E6.2 y añade a `src/funciones.php` las funciones que necesites.
3. Escribe `filtrar()` en ese mismo archivo y úsala en E6.3.
4. Revisa en E6.4 que las cinco funciones cumplen su contrato y están documentadas.
5. Adapta la ficha existente en E6.5.

---

## E6.1 — El tablón en memoria

**Archivo que creas:** `src/tablon.php`.

### Qué tienes que hacer

Escribe una función `misiones(): array` que devuelva **un array con al menos cuatro misiones**. Cada misión será, a su vez, un array asociativo.

Cada una debe tener estas siete claves:

| Clave | Contenido |
|---|---|
| `id` | Identificador entero, diferente para cada misión. |
| `titulo` | Título de la misión. |
| `categoria` | Categoría, por ejemplo `exploracion`, `rescate` o una de tu ambientación. |
| `dificultad` | Entero de 1 a 5. |
| `plazas_total` | Número total de plazas. |
| `plazas_libres` | Número de plazas que quedan disponibles. |
| `fecha` | Fecha en una cadena con formato `AAAA-MM-DD`. |

Usa las claves exactamente como aparecen: por ejemplo, `plazas_total`, no `plazas_totales`, y `plazas_libres`, no `plazas_disponibles`.

Los datos habituales deben ser coherentes: total positivo y plazas libres entre cero y ese total. Incluye:

- Una misión completa, con `plazas_libres` igual a 0.
- Una misión de dificultad 5.
- Misiones de categorías diferentes.
- Un título con el carácter `<`, para comprobar el escape al mostrarlo.

Este archivo **devuelve datos; no genera una página ni imprime las misiones**. No necesitas una base de datos, un archivo JSON ni un formulario en esta unidad.

### Cómo comprobarlo

Desde el bloque PHP de tu página, carga el archivo y llama a la función:

```php
require_once __DIR__ . '/../src/tablon.php';
$tablon = misiones();
```

Comprueba que hay al menos cuatro elementos, que cada uno tiene las siete claves y que los datos permiten distinguir los casos anteriores. Si usas `var_dump()` como ayuda, colócalo dentro de `<pre>` y retíralo del listado final.

---

## E6.2 — El tablón, generado

**Archivo que creas:** `public/tablon.php`.

### El orden de la página

Mantén la organización que utilizaste en DW5:

| Orden | Bloque |
|---|---|
| 1 | Declaración de tipos estrictos, zona horaria y configuración de errores de desarrollo. |
| 2 | Carga de la configuración: `$cfg = require __DIR__ . '/../src/config.php';`. |
| 3 | Carga de `src/funciones.php` y `src/tablon.php`, con rutas basadas en `__DIR__`. |
| 4 | Obtención del tablón y preparación del resumen. |
| 5 | Inclusión de `plantillas/cabecera.php`. |
| 6 | HTML del resumen, mensaje de vacío y recorrido de las misiones. |
| 7 | Inclusión de `plantillas/pie.php`. |

### Qué tiene que aparecer

Recorre el array con **un `foreach`**. No escribas cuatro fichas a mano ni copies el mismo bloque HTML para cada posición.

Cada misión debe estar dentro de un `<div class="mision">` y mostrar:

- Título y categoría, escapados con `h()`.
- Plazas libres y plazas totales.
- Estado: `abierta` si quedan plazas o `COMPLETA` si no quedan.
- Porcentaje de ocupación y barra de dificultad, usando las funciones de E6.4.

Antes del recorrido, muestra un resumen. Por ejemplo, si tus cuatro misiones tienen 2, 0, 3 y 5 plazas libres:

```text
4 de 4 misiones · 10 plazas libres en total
```

En este ejercicio se muestran todas. En E6.3, el primer número pasará a indicar cuántas cumplen los filtros.

Prepara los cálculos generales antes del HTML. Dentro de cada vuelta del `foreach`, prepara los valores de esa misión antes de mostrar su bloque. Utiliza `<?= ... ?>` para presentar los resultados; no construyas toda la página concatenando cadenas con `echo`.

### El caso vacío también forma parte del ejercicio

Si no hay misiones para mostrar, debe aparecer un mensaje, por ejemplo:

```html
<p class="vacio">No hay misiones que mostrar.</p>
```

Para probarlo, sustituye temporalmente la obtención de datos por `$tablon = [];`. Debes ver el mensaje y un resumen de cero misiones y cero plazas, sin avisos de PHP.

**Después restaura la llamada a `misiones()`**. Entrega los datos de E6.1, no un tablón que hayas dejado vacío al hacer la prueba.

---

## E6.3 — Los dos filtros, con entradas conocidas

**Archivos que modificas:** `public/tablon.php` y `src/funciones.php`.

### Qué tienes que hacer

Escribe `filtrar()` en `src/funciones.php`, con la firma indicada en E6.4. La función recibe el tablón original y devuelve otro array con las misiones admitidas.

En la página, distingue estas dos variables:

| Variable | Para qué se utiliza |
|---|---|
| `$tablon` | Conserva todas las misiones. Sirve para calcular la cantidad original y las plazas libres totales. |
| `$visibles` | Contiene el resultado del filtro. Es la colección que recorre el `foreach`. |

Por ejemplo:

```php
$tablon = misiones();
$visibles = filtrar($tablon, 'exploracion', true);
```

El filtro de categoría admite solo coincidencias con la categoría solicitada. Si el argumento es `null`, admite todas las categorías.

El filtro de plazas admite solo misiones con plazas libres cuando su argumento es `true`. Si es `false`, también admite las completas.

Cuando se activan los dos, la misión debe cumplir **ambas condiciones**. Filtrar no significa borrar elementos del tablón original.

### Qué llamadas debes probar

Prueba cada caso sustituyendo la llamada de la página. Adapta `exploracion` a una categoría que exista en tus datos.

| Prueba | Llamada |
|---|---|
| Sin filtros | `filtrar($tablon)` |
| Solo categoría | `filtrar($tablon, 'exploracion')` |
| Solo plazas libres | `filtrar($tablon, null, true)` |
| Los dos filtros | `filtrar($tablon, 'exploracion', true)` |
| Categoría inexistente | `filtrar($tablon, 'inventada')` |

En el último caso debe aparecer el mensaje de lista vacía, no un error. Asegúrate de que la categoría utilizada en esa prueba realmente no existe.

Si el filtro deja visibles dos de las cuatro misiones del ejemplo anterior, el resumen será:

```text
2 de 4 misiones · 10 plazas libres en total
```

**Las 10 plazas siguen siendo las del tablón completo.** No calcules ese total a partir de `$visibles`.

Deja una llamada activa y puedes conservar las otras comentadas para facilitar la comprobación. No se pide un formulario, botones de filtrado ni lectura de `$_GET`: la conexión con la URL llega en DW7.

---

## E6.4 — Las funciones propias

**Archivo que amplías:** `src/funciones.php`.

Conserva `h()` y `dias_entre()` de DW5. Añade estas **cinco funciones**, definidas una sola vez:

| Firma | Qué debe devolver |
|---|---|
| `hay_plazas(array $m): bool` | `true` cuando la misión tenga más de cero plazas libres; `false` en caso contrario. |
| `ocupacion(array $m): int` | El porcentaje de plazas ocupadas, redondeado a entero y protegido contra la división por cero. |
| `barra(int $dificultad): string` | Una cadena de cinco caracteres: `*` para las posiciones llenas y `.` para las restantes. |
| `filtrar(array $tablon, ?string $categoria = null, bool $solo_libres = false): array` | Una nueva colección con las misiones que cumplen los filtros de E6.3. |
| `plazas_libres_totales(array $tablon): int` | La suma de las plazas libres de la colección recibida; 0 si está vacía. |

`ocupacion()` calcula un **porcentaje**, no el número de personas apuntadas. `barra()` representa la **dificultad**, no la ocupación.

### Qué significa «calcular y devolver»

Ninguna de estas funciones debe usar `echo`, generar etiquetas HTML ni imprimir mensajes. Su resultado sale mediante `return`; la página decide dónde mostrarlo.

Por ejemplo, la página puede guardar el retorno de `ocupacion($m)` en `$porcentaje` y mostrar después esa variable en un párrafo.

### Documentación obligatoria

Justo encima de cada función, incluye un bloque `/** ... */` con:

- Una descripción de lo que hace.
- Un `@param` por cada parámetro, indicando qué recibe.
- Un `@return` que explique qué devuelve.

En `ocupacion()`, explica también qué decides devolver cuando el total sea cero. Se admite 0 o 100 si justificas la elección; lo imprescindible es evitar la división por cero. Los datos habituales de E6.1 seguirán teniendo un total positivo.

### Casos que debes comprobar

| Caso | Resultado esperado |
|---|---|
| 6 plazas totales y 2 libres | Ocupación del `67 %`. |
| Todas las plazas ocupadas | Ocupación del `100 %`. |
| Todas las plazas libres | Ocupación del `0 %`. |
| Total 0 y libres 0 | El valor documentado, sin error de división. |
| `barra(-2)` | `.....` |
| `barra(3)` | `***..` |
| `barra(9)` | `*****` |
| Total de plazas de `[]` | `0` |

La dificultad se limita a 0–5 para construir la barra. Incluso ante `9` o `-2`, la cadena debe tener cinco posiciones y no provocar un error.

---

## E6.5 — Reutilizadas en dos páginas

**Archivo que modificas:** `public/ficha.php`, la ficha que entregaste en DW5.

### Qué conservas

Mantén el arranque de la página, la carga de `$cfg`, las plantillas, el escape con `h()` y el cálculo de días con `dias_entre()`.

La ficha sigue mostrando una misión. No necesitas convertirla en otro tablón ni elegir el identificador mediante la URL.

### Qué cambias

1. Agrupa los datos de la misión en un array asociativo con las claves de E6.1. Puedes adaptar tus datos de DW5 o utilizar una misión de `misiones()`.
2. Sustituye el cálculo de ocupación escrito en la ficha por una llamada a `ocupacion()`.
3. Sustituye la construcción de la barra por una llamada a `barra()`.
4. Utiliza `hay_plazas()` para decidir el texto del estado: `abierta` o `COMPLETA`.
5. Mantén `$pronostico` en `null` para probar la ausencia y prepara el texto `sin dato` cuando no haya pronóstico. Puede seguir siendo una variable aparte; no tienes que añadir una octava clave a las misiones.
6. Muestra los resultados en HTML, con los cálculos preparados y los textos escapados.

**No copies las definiciones de las funciones dentro de la ficha.** Tanto la ficha como el tablón deben cargar el mismo `src/funciones.php`.

### Cómo comprobar la reutilización

Busca `function ocupacion` y `function barra` en el proyecto: cada definición debe aparecer una sola vez. Después comprueba que ambas se llaman desde **las dos páginas**.

Con 6 plazas totales, 2 libres y dificultad 4, la ficha debe mostrar `67 %`, `****.` y `abierta`. Si pruebas cero plazas libres, el estado debe pasar a `COMPLETA`. Prueba también el total cero y restaura después los datos habituales.

---

## Cómo debe quedar tu repositorio

Esta es la parte relevante del árbol al terminar DW6. **Conserva también los demás archivos que ya existían** en el repositorio, aunque no aparezcan aquí.

```text
proyecto/
├── public/
│   ├── index.php                         # Se conserva
│   ├── ficha.php                         # MODIFICADO: E6.5
│   └── tablon.php                        # NUEVO: E6.2 y E6.3
├── src/
│   ├── config.php                        # Se conserva
│   ├── funciones.php                     # AMPLIADO: E6.3 y E6.4
│   └── tablon.php                        # NUEVO: E6.1
├── plantillas/
│   ├── cabecera.php                      # Sin cambios
│   └── pie.php                           # Sin cambios
├── documentacion/
│   └── tecnologias_servidor.md           # Se conserva de DW5
└── BITACORA_PROMPTS.md                   # Actualizada
```

Al terminar, `src/funciones.php` contiene **siete funciones compartidas**: las dos de apoyo de DW5 y las cinco de E6.4. `misiones()` está en `src/tablon.php`.

No crees copias como `funciones_ficha.php` y `funciones_tablon.php`. La reutilización consiste precisamente en que ambas páginas carguen el mismo archivo.

---

## Lo que se entrega

Los cinco archivos de trabajo de DW6 son:

```text
src/tablon.php
src/funciones.php
public/tablon.php
public/ficha.php
```

Se entregan **dentro del repositorio existente**, con la configuración, las plantillas y el trabajo anterior conservados. Mantén `BITACORA_PROMPTS.md` al día según el protocolo de IA del curso: registra la ayuda utilizada, las decisiones que tomaste y las comprobaciones que ejecutaste realmente. Si no utilizaste ayuda externa, indícalo.

### Lista de comprobación antes de subir

- [ ] `misiones()` devuelve al menos cuatro misiones con las siete claves acordadas y datos variados.
- [ ] El tablón utiliza `foreach` y cada misión está dentro de `div.mision`.
- [ ] Los textos están escapados; el `<` del título se ve como texto.
- [ ] El resumen diferencia visibles, total de misiones y plazas del tablón completo.
- [ ] He probado el tablón vacío y he restaurado los datos.
- [ ] He probado los cinco casos de filtrado mediante llamadas directas, sin `$_GET`.
- [ ] Las cinco funciones tienen descripción, `@param` y `@return`, y ninguna imprime.
- [ ] He comprobado los límites de la barra y la ocupación con total cero.
- [ ] La ficha y el tablón usan las mismas definiciones de `ocupacion()` y `barra()`.
- [ ] La ficha conserva los días naturales, decide el estado y trata el pronóstico ausente.
- [ ] La configuración y las plantillas anteriores siguen en su sitio.
- [ ] He actualizado la bitácora y subido los cambios al repositorio remoto.

### Subida al repositorio

Haz commits durante el trabajo, con mensajes que expliquen los cambios.
