# DW5 · Hoja de ejercicios

**PHP embebido: sintaxis, variables y directivas · DWES · 2º DAW**

---

Esta hoja contiene **solo lo que se entrega y cuenta**. Todo lo que hace falta para
resolverla está explicado y ensayado en `DW5_apuntes.md`: los recorridos «En directo»
(G1 a G7) y los «Ahora tú» (E5.1 a E5.5, AT5.2, AT5.3 y AT5.7) se hacen en clase y
**no se entregan**.

Aquí empieza tu aplicación. Todo lo de esta hoja va **dentro de tu repositorio del
sprint 1**, el que clonaste en `~/proyecto` en DW3, y la ficha del ejercicio final es
la primera página propia de tu proyecto.

**Recuerda la ambientación**: el gremio puede ser lo que tú quieras —y lo bautizas en
`src/config.php`—. Los nombres de las variables y la estructura, no.

### Lo que ya está en el repositorio, y no se toca

| Qué | Dónde | Qué haces con él |
|---|---|---|
| Configuración | `src/config.php` | **Cambias** `nombre_app` y `lema`. Nada más |
| Cabecera y pie | `plantillas/cabecera.php`, `plantillas/pie.php` | Los **reutilizas** con `require`. No se editan, no se borran, no se copian con otro nombre |
| Punto de entrada | `public/index.php` | No se toca en esta unidad |

La cabecera que ya está escrita usa `$cfg['nombre_app']` y `$cfg['lema']`: por eso
`$cfg` se carga **antes** de pedirla. Está en `DW5_apuntes.md` §6.

### Las dos funciones que se dan hechas

`h()` y `dias_entre()` están en `dwes/recursos/DW5/apoyo.php`. Las copias a
`src/funciones.php` y las traes con `require`. Escribir y documentar funciones
propias es DW6; aquí se corrige que las **uses** bien.

---

## E5.5b — Las tecnologías de tu servidor *(obligatoria)*

**Fichero:** `documentacion/tecnologias_servidor.md`

Completa esta tabla mirando **tu VM y tu proyecto**, no una lista genérica:

| Pieza | Tecnología concreta | Evidencia en tu máquina |
|---|---|---|
| Servidor web |  |  |
| Mecanismo que ejecuta PHP |  |  |
| Lenguaje en servidor |  |  |
| Almacén de datos |  |  |
| Framework |  |  |

Las **cinco filas** van rellenas. En «evidencia» pega **una orden, una ruta o una
salida** que permita comprobar la respuesta: no vale repetir el nombre de la
tecnología.

Para la segunda fila, la evidencia que lo demuestra es la que viste en G7: lo que
contesta `php_sapi_name()` **pedido por HTTP**, no por terminal. `apache2handler`
significa módulo dentro de Apache; `fpm-fcgi`, el servicio aparte. En los dos casos
el servidor web es Apache.

Si todavía no hay framework, escribe **ninguno** y explica en una línea qué pieza
añadirá cuando llegue DW13.

---

## E5.6 — La ficha de una misión *(el entregable)*

**Fichero:** `public/ficha.php`

Es la primera página propia de tu proyecto. Tienes un punto de partida en
`dwes/recursos/DW5/plantilla_ficha.php`: cópialo a `public/ficha.php` y rellena los
huecos. El arranque y la maquetación ya están puestos; lo que falta son los datos y
los cálculos.

### Los seis bloques, en este orden

| | Bloque |
|---|---|
| 1 | Zona horaria y directivas de error: `error_reporting(E_ALL)`, `display_errors`, `log_errors` |
| 2 | `$cfg = require __DIR__ . '/../src/config.php';` |
| 3 | `require __DIR__ . '/../src/funciones.php';` |
| 4 | **Datos y cálculos** |
| 5 | `require __DIR__ . '/../plantillas/cabecera.php';` |
| 6 | Lo que se pinta, y al final `require __DIR__ . '/../plantillas/pie.php';` |

### Los datos, arriba del todo

En variables: título, categoría, dificultad (1-5), plazas totales, plazas libres,
fecha y pronóstico. Pon **datos coherentes**: `plazas_totales` mayor que cero,
`plazas_libres` entre 0 y el total, y dificultad entre 1 y 5. Los casos límite y las
decisiones llegan en DW6.

Mete un `<` en el título a propósito. Es la forma más rápida de ver si el escape
está puesto.

`$pronostico` se queda en **`null`**.

### Los cálculos, también arriba

| Qué | Cómo |
|---|---|
| Porcentaje de ocupación | Entero y redondeado: `round()` primero, `(int)` después. Con el paréntesis en el numerador |
| Barra de dificultad | **Cinco posiciones**: asteriscos por la dificultad y puntos por lo que falta, con `str_repeat()` |
| Días que faltan | `dias_entre($hoy, $fecha)`. **No** restando marcas de tiempo |

Y dos textos fijos, preparados **arriba** en su variable:

```php
$estado           = 'aberta';
$pronostico_texto = 'sen dato';
```

En DW6 los convertirás en decisiones. Aquí no se usan `if` antes de haberlos
aprendido.

### Abajo solo se pinta

Con `<?= ?>`, y con `h()` en todo lo que sea texto. **Dentro de un `<?= ?>` no hay
ni un cálculo ni un operador**: eso es lo que significa *primero se piensa, después
se pinta*, y es el requisito de forma que se corrige.

### El caso que tiene que dar estos números

Antes de entregar, pon **estos** datos y comprueba que tu página saca **esto**:

| Dato | Valor |
|---|---|
| Plazas totales | 6 |
| Plazas libres | 2 |
| Dificultad | 4 |
| `$hoy` | `'2026-10-05'` |
| Fecha de la misión | `'2026-10-08'` |

| Lo que tiene que salir | |
|---|---|
| Ocupación | `67 %` |
| Barra | `****.` |
| Días | `faltan 3 dias` |
| El `<` del título | en la fuente, como `&lt;` |

Si te sale `66 %`, te falta el `round()`. Si te sale `33 %`, estás midiendo las
plazas libres en vez de las ocupadas.

Con los días, cuidado: en **este** caso la resta de marcas de tiempo también da 3, así
que acertar aquí no demuestra nada. La comprobación que separa una cosa de la otra es
esta, y tiene que dar **2**:

```php
dias_entre('2027-03-27', '2027-03-29')   // 2
```

Si tu código da 1, estás restando marcas de tiempo y dividiendo entre 86400. Usa
`dias_entre()`.

**Cuando lo hayas comprobado, cambia `$hoy` por `date('Y-m-d')`** y deja la fecha de
la misión en una futura. La página tiene que funcionar también así: los días irán
bajando solos.

---

## Lo que se entrega

En tu repositorio del sprint 1, con commits por el camino:

```
public/ficha.php
src/funciones.php                      <- con h() y dias_entre() copiadas
src/config.php                         <- con TU nombre de aplicacion
documentacion/tecnologias_servidor.md
```

Y `BITACORA_PROMPTS.md` al día, según [`PROTOCOLO_IA.md`](PROTOCOLO_IA.md): qué
pediste, qué aceptaste o rechazaste, qué `diff` revisaste y qué prueba ejecutaste de
verdad. Si lo has resuelto **sin ayuda externa**, se declara así, en una línea. Sin
una de las dos cosas, la entrega no se da por entregada.

`plantillas/cabecera.php` y `plantillas/pie.php` tienen que seguir **exactamente
igual** que al clonar.

### Cuándo y cómo

Al terminar la **sesión 7**: `git add`, `git commit` y `git push`, como en DW3 §§4-5.
Lo que no está subido, no está entregado. Y comprueba lo de DW3: que el último commit
que ves en GitHub sea el mismo que te dice `git log -1` en tu máquina.

### Qué comprueba Actions, y qué no

Al hacer `push`, la pestaña *Actions* pasa el corrector del sprint. Ese corrector
mira **que el PHP no tenga errores de sintaxis** y lo que ya comprobaba del sprint 1.

**No comprueba los requisitos de DW5.** Que el porcentaje esté redondeado, que la
barra tenga cinco posiciones, que los días sean naturales, que los cálculos estén
arriba y que el escape esté puesto **no sale en Actions**. Un tick verde no significa
que la ficha esté bien: significa que compila.

### Con qué se relaciona esta entrega

Lo de esta hoja es la base de tres cosas que ya existen y **no añaden ningún
porcentaje nuevo** a los que ya conoces:

| | Cuándo | Sobre qué |
|---|---|---|
| La **prueba corta** de la última sesión | Sesión 8, en papel | Lo de los apuntes y de E5.2 |
| La **mutación individual** | Sesión 8, en tu equipo, 15 minutos | Tu propia `ficha.php` |
| La **entrega del sprint 1** | Su propio plazo | Esta ficha forma parte de ella |

Cómo pesa cada uno está en `evaluacion/como-se-califica/`.

---

## Si te sobra tiempo

- Haz que la barra de dificultad se pinte con otro carácter en vez del asterisco, y
  comprueba que sigue teniendo cinco posiciones.
- Añade una segunda misión en más variables y píntala debajo. Cuenta cuántas líneas
  has tenido que duplicar: eso es exactamente lo que DW6 arregla.
- Prueba `dias_entre()` con una fecha ya pasada y mira el signo.
