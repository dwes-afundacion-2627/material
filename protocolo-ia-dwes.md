# Protocolo de uso profesional de IA en DWES

**Desenvolvemento web en contorno servidor · 2º DAW · Curso 2026/27**

La IA se puede usar durante el trabajo ordinario del módulo. No sustituye la
comprensión, la decisión ni la comprobación: quien entrega sigue siendo responsable
de cada línea y debe poder localizarla, explicarla y modificarla.

No se usa en micropruebas, mutaciones, exámenes, retos ni en cualquier actividad que
se anuncie sin IA. En esos casos se aplican las condiciones del instrumento.

## El ciclo obligatorio

1. **Reproduce o define antes de preguntar.** Escribe el síntoma, el resultado
   esperado y una prueba que permita saber si se ha resuelto. Si aún no hay fallo,
   formula al menos un caso de aceptación y uno de rechazo.
2. **Comparte el contexto mínimo.** Nunca pegues contraseñas, tokens, `.env`, datos
   personales ni consignas privadas. Sustituye los
   datos sensibles por ejemplos ficticios.
3. **Pide una ayuda concreta.** Mejor una explicación, alternativas o casos de prueba
   que «hazme el ejercicio». Indica versión, entorno y restricciones relevantes.
4. **Revisa el cambio.** Lee el `diff` línea por línea. Comprueba en la documentación
   local los nombres, versiones y comportamientos que la respuesta afirme. No instales
   una dependencia ni ejecutes una orden que no entiendas.
5. **Decide y prueba.** Acepta, modifica o rechaza la propuesta y anota por qué. Ejecuta
   la prueba definida al principio y, como mínimo, un caso que debería fallar.
6. **Guarda solo lo comprobado.** Haz commit del cambio que funciona, con un mensaje
   que diga qué hace. La salida inventada o no ejecutada no es evidencia.

## Qué se anota en `BITACORA_PROMPTS.md`

Por cada consulta externa relevante:

- problema o requisito comprobable antes de consultar;
- contexto compartido y datos o secretos que se excluyeron;
- qué se pidió y qué se recibió;
- qué se aceptó, modificó o rechazó, y por qué;
- `diff` o commit revisado;
- prueba ejecutada y resultado real.

Si no se usó IA, buscador, documentación ni ayuda de otra persona, se escribe
`## Declaración sin ayuda externa` y se conserva la prueba que validó la decisión.
No usar ayuda externa es válido; ocultarla, no.

## Ejemplos de anotaciones


### Bien hecha (1): fallo reproducido, contexto limpio, prueba real


#### 2026-11-04 · Validación de plazas duplicadas en EXPEDICIONES

**Problema comprobable:** al reservar la última plaza de una expedición dos
peticiones seguidas, la segunda debería devolver 409 y no lo hace: devuelve 201
y dejo la expedición con -1 plazas. Caso de aceptación: 2ª reserva → HTTP 409,
plazas_disponibles no baja de 0. Caso de rechazo: 1ª reserva → HTTP 201.

**Contexto compartido:** el método `reservar()` de `ExpedicionController.php`
(pegado sin el namespace real de la empresa) y el esquema de la tabla
`expediciones`. Sin credenciales de BD, sin `.env`.

**Qué pedí:** por qué un `UPDATE ... WHERE plazas_disponibles > 0` seguido de un
`SELECT` para comprobar el resultado puede dejar pasar dos reservas a la vez, y
qué alternativa evita la condición de carrera en MariaDB con transacciones.

**Qué recibí:** explicación de la condición de carrera (el `SELECT` de
comprobación no está en la misma transacción que el `UPDATE`) y dos alternativas:
`SELECT ... FOR UPDATE` dentro de una transacción, o comprobar
`affected_rows` del propio `UPDATE` sin `SELECT` previo.

**Qué acepté / modifiqué / rechacé:** acepté la segunda opción (más simple, sin
bloqueo explícito) porque el proyecto ya usa PDO sin transacciones manuales en
el resto del controlador y no quiero introducir un patrón nuevo solo aquí.
Rechacé el `FOR UPDATE` por eso mismo, no porque esté mal.

**Diff revisado:** commit `a3f21c9`, `ExpedicionController.php` líneas 42-58.

**Prueba ejecutada:** script `pruebas/doble_reserva.sh` (dos peticiones `curl`
lanzadas con `&` para forzar la concurrencia) contra la BD de pruebas: 5
repeticiones, siempre 1×201 + 1×409, plazas_disponibles nunca baja de 0. Antes
del cambio, en 3 de 5 repeticiones se colaban las dos reservas.


Por qué funciona: el fallo estaba definido antes de preguntar, la pregunta era
concreta (no «arréglame esto»), se explica por qué se eligió una alternativa y no
la otra, y la prueba compara el comportamiento antes/después con un método que
fuerza el caso límite, no solo «funciona en el navegador».

### Bien hecha (2): declaración sin ayuda externa


#### 2026-10-14 · Ruta `/expediciones/{id}/pdf` sin ayuda externa

No usé IA, buscador ni documentación externa para escribir el `Content-Disposition`
del PDF de confirmación: ya lo había hecho en DW9 y quería comprobar si lo recordaba
sin apoyo. Prueba: descargado en Firefox y Chrome, el nombre de archivo sugerido
es `expedicion-{id}.pdf` en los dos, sin acentos rotos.


Por qué funciona: dice explícitamente que no hubo ayuda externa, da un motivo (no
solo lo omite) y deja la prueba que respalda que la decisión fue correcta sin
consultar a nadie.

### Mal hecha (1): sin problema definido, sin revisión, sin prueba


#### 2026-11-04 · Laravel

Le pregunté a la IA cómo hacer la validación de plazas y me dio el código. Lo
puse y ya funciona.


Qué falta: no hay síntoma ni caso de aceptación/rechazo antes de preguntar («la
validación» no es un problema comprobable); no dice qué se compartió ni si había
datos sensibles; «me dio el código... lo puse» no es un diff revisado ni una
decisión razonada — es copiar sin filtrar; «ya funciona» no es una prueba, es una
impresión sin caso límite ni resultado real. Si esto se hubiera revisado según el
ciclo obligatorio, habría aparecido el mismo fallo de condición de carrera del
ejemplo bueno.

### Mal hecha (2): contexto sensible compartido y anotación retroactiva vacía


#### 2026-11-05

Le pasé el .env con la contraseña de la BD del centro para que la IA me
ayudase a conectar Laravel con MariaDB, me dio la configuración y listo.


Qué falta: comparte exactamente lo que el protocolo prohíbe (`.env`, credenciales
reales) en vez de sustituirlo por datos ficticios; no hay problema comprobable
formulado, no hay diff revisado línea por línea, no hay prueba ejecutada ni caso
que debiera fallar, y «me dio la configuración y listo» no dice qué se aceptó,
modificó o rechazó ni por qué. Además de ser una anotación mal hecha, es en sí
misma la infracción que el paso 2 del ciclo (contexto mínimo) intenta evitar.

## Puntos de control del curso

| Código | Qué se practica sin añadir una tarea nueva |
|---|---|
| **DW3** | Primera entrada de bitácora y revisión por pareja de un `diff` antes de fusionar |
| **DW7** | Definir los casos inválidos antes de pedir ayuda y probarlos contra el servidor |
| **DW9** | Predecir el estado de las tablas antes de modificar una transacción |
| **DW13** | Distinguir código propio, código generado y piezas del framework; escribir una prueba propia |
| **DW18** | Validar campos y fallos de un servicio con el doble local, sin compartir secretos |
| **DW19** | Incorporar código de terceros con procedencia, adaptación, prueba e historial sellado |
