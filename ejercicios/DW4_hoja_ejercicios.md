# DW4 · Hoja de ejercicios

**HTTP y el servidor web · DWES · 2º DAW**
**5 sesiones · se entrega antes de la prueba de la última sesión**

---

Esta hoja contiene **solo lo que se entrega y se corrige**. Todo lo que hace falta para
resolverla está explicado y ensayado en `DW4_apuntes.md`: los recorridos «En directo» y
los dos «Ahora tú» (AT4.1 y AT4.2) se hacen en clase y **no se entregan**.

La entrega es un **cuaderno de peticiones**: `http/cuaderno.md` en tu repositorio, con
el tráfico **pegado** —no descrito— y explicado. Hay una plantilla en
`dwes/recursos/DW4/plantilla_cuaderno.md`: cópiala y rellénala.

Todo se hace contra **tu** servidor, el de DW2: `~/proyecto/public/dw4/`. Los números
que salgan son los tuyos.

---

## E4.4 — El panel de salidas: qué código viaja y dónde se ejecuta

Los dos ficheros están completos en `dwes/recursos/DW4/`: `servidor.php` y
`cliente.html`. **No hay que escribir JavaScript**: el que hay ya está hecho, y es el
patrón del apartado 5 de los apuntes.

Cópialos a `~/proyecto/public/dw4/`. Los dos anuncian lo mismo: *Salida a las 09:00*.
Uno lo hace con PHP y el otro con JavaScript.

1. **Predice antes de ejecutar nada.** Escribe en el cuaderno qué esperas recibir de
   cada uno de los dos ficheros. Esto se escribe primero; si lo escribes después ya no
   es una predicción.

2. **Ejecuta y pega lo recibido.** Pide los dos con `curl -sS` y pega la respuesta
   entera de cada uno, con la orden encima.

3. **Compara fuente y página renderizada.** Abre los dos en el navegador
   (`http://localhost:8080/dw4/…`), mira la página y después *Ver código fuente*
   (`Ctrl+U`). Rellena la tabla de la plantilla: qué pone en la fuente y qué se ve en la
   página, para cada fichero.

4. **Cambia solo el literal.** En cada fichero, cambia `09:00` por `10:00` y nada más.
   Guarda, espera dos segundos, repite la petición de los dos y pega otra vez lo
   recibido.

5. **Explica**, con lo que has pegado delante:

   - **a)** ¿Qué código viaja hasta el navegador en cada caso, y dónde se ejecuta?
   - **b)** En cada fichero, ¿en qué momento y en qué máquina se decide el texto que ve
     la persona que visita la página?
   - **c)** En una frase: por qué una comprobación hecha en el navegador **no protege**
     el servidor.

Deja los dos ficheros otra vez en `09:00` antes de entregar.

---

## E4.5 — El centro deportivo: qué se elige y qué se gana

Un centro deportivo municipal. **No existe ninguna plataforma previa**: cada apartado se
construye desde cero.

Para **A, B y C**, escribe **dos líneas**: la forma que eliges —página estática,
pequeñas inserciones dentro del HTML, o aplicación organizada en el servidor— y **la
ventaja que da esa forma en ese apartado concreto**.

**A.** Un plano de las instalaciones, con las pistas y los vestuarios. Se revisa cuando
hay una obra, y la última fue hace tres años.

**B.** Que en una página fija de avisos aparezca la fecha de hoy al pie.

**C.** Que cada socio entre con sus credenciales, vea las reservas de pista que tiene
hechas y pueda cancelarlas.

**D.** Y la que se piensa de verdad: si el apartado **A** se resolviera construyendo una
aplicación organizada completa, **qué dos costes te estarías echando encima sin
necesidad**. No vale «que estaría mal»: di **qué cuesta de más**.

La misma ventaja repetida en dos apartados no puntúa como dos: significa que se ha
clasificado en lugar de decidir.

---

## Lo que se entrega

`http/cuaderno.md` en tu repositorio, con **estas dos evidencias y nada más**:

| | |
|---|---|
| **E4.4** | Predicción, lo recibido de los dos ficheros antes y después del cambio, la comparación de fuente y página, y las tres respuestas |
| **E4.5** | Las tres formas con su ventaja, y los dos costes del apartado D |

Y la **bitácora al día**: `BITACORA_PROMPTS.md` en la raíz del repositorio, según
[`PROTOCOLO_IA.md`](PROTOCOLO_IA.md), que está en la carpeta `dwes/` del material. En el
cuaderno hay una casilla para declarar si lo has resuelto **sin ayuda externa** o con
ayuda anotada en la bitácora.

**Cuándo.** Antes de la prueba de la última sesión. Se entrega como todo en este
módulo: **commit y push**, según DW3. Lo que no está subido, no está entregado. Commits
por el camino, no uno solo al final.

Este cuaderno **no lleva nota propia**: es la evidencia con la que se prepara la prueba
corta de la última sesión, y es ahí donde se mide si lo has entendido.

---

## Si te sobra tiempo

- Mira las cabeceras de una web grande: `curl -sS -D - -o /dev/null https://www.google.com`.
  ¿Cuántas cabeceras manda? ¿Reconoces `Date`, `Server` y `Content-Type`?
- Pide la misma página con `curl -sS -v` y localiza, en las líneas que empiezan por
  `>`, las cabeceras que **tú** has enviado sin darte cuenta.
- En `eco.php`, manda un par con acentos o espacios y mira cómo llega la línea `Ruta:`.
