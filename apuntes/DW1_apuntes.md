# DW1 · Visión general

**Desenvolvemento web en contorno servidor · 2º DAW · Apuntes**

---

## 1. El mapa del curso

Veinte unidades. Las cuatro primeras no son PHP: son el suelo.

| | Unidad | Qué te llevas |
|---|---|---|
| DW1 | El punto de partida | Esto |
| DW2 | El entorno | Un servidor Debian tuyo, sirviendo PHP |
| DW3 | Git y la vía de entrega | El repositorio por el que entregas todo el curso |
| DW4 | HTTP y el servidor web | Qué viaja entre el navegador y el servidor |
| DW5 | PHP embebido | Tus primeras páginas generadas |
| DW6 | Estructuras, arrays y funciones | Código que se puede leer |
| DW7 | Formularios | **Sprint 1**: el alta de misiones, validada en el servidor |
| DW8 | Acceso a datos con PDO | La base de datos, sin agujeros |
| DW9 | CRUD y transacciones | **Sprint 2**: la última plaza y el conflicto |
| DW10 | Estado: cookies, sesiones y autenticación | Quién eres y cómo lo sabe el servidor |
| DW11 | Código de cliente generado desde el servidor | Lo que corre en el navegador |
| DW12 | Separar lógica y presentación | **Sprint 3**: tu propio enrutado y tus plantillas |
| DW13 | Laravel | Lo mismo que ya hiciste, hecho por otro |
| DW14 | Django | Dos sesiones para ver otra forma de hacerlo |
| DW15 | Adaptar una aplicación existente | Tocar código que no has escrito tú |
| DW16 | El servicio web del proyecto | **Sprint 4**: tu API |
| DW17 | Consumir el servicio de verdad | El cliente hablando con tu API |
| DW18 | Información que ya existe | El pronóstico, recuperado y procesado |
| DW19 | Librerías y código de terceros | **Sprint 5** |
| DW20 | Reto final y cierre | Código desconocido diagnosticado y proyecto entregado |

**El orden no es negociable y no es casual**: cada unidad usa algo aprendido antes.
Git va en la semana 1 porque sin él no hay forma de entregar. El entorno va antes
que Git porque el repositorio vive dentro de la máquina virtual.

---


## 2. La bitácora de prompts

En cada entrega va un fichero `BITACORA_PROMPTS.md`. No es «qué preguntaste y qué te
contestó»: lo que se anota es el **proceso de verificación** que pide
`PROTOCOLO_IA.md` —qué querías conseguir y cómo ibas a comprobarlo, qué contexto
compartiste y qué dejaste fuera, qué aceptaste, modificaste o rechazaste y por qué,
qué `diff` o commit revisaste y qué prueba ejecutaste de verdad—. Léelo entero antes
de la primera entrada.

**No es una penalización ni una trampa.** Es un requisito de forma, como poner el
nombre: sin él, el sprint no se da por entregado. Usar IA está permitido. Lo que no
se puede es entregar algo que no sabes explicar, y para eso está la defensa de tres
minutos.

En DW19 la bitácora, además, **puntúa como contenido**.

---

## 3. De dónde vienes

Hoy has hecho una prueba. **No cuenta para la nota.** Sirve para
saber cuánto hay que apretar en cada sitio:

- **SQL**: se da por sabido. Si sale bien, DW8 va rápido y se dedica el tiempo a lo
  que sí es nuevo: hacerlo desde PHP y sin agujeros.
- **POO**: se usa en DW12 y DW13. Si sale floja, DW12 necesita más sesiones y se
  sacan de otro sitio.
- **HTML**: no es contenido de este módulo, pero se necesita desde la primera
  página. Si sale flojo, hay un repaso de media sesión en DW5 y no más.

---

## 4. Las tres cosas que hay que tener claras desde hoy

1. **Aquí se programa en el servidor.** Lo que ve el navegador es la consecuencia,
   no el trabajo. Cuando algo no funcione, la primera pregunta siempre es *¿esto lo
   decide el servidor o el cliente?*
2. **Lo que valida el navegador no protege al servidor.** El `required` o el `min="1"`
   de un formulario son comodidad para quien rellena: ayudan, y por eso se ponen. Pero
   quien quiera saltárselos solo tiene que mandar la petición sin pasar por el
   formulario, y entonces la única defensa es la del servidor. Toda validación se
   repite **siempre** en el servidor. Lo vas a ver demostrado con `curl` en DW7 y no se
   te va a olvidar.
3. **Entregar es hacer `push`.** No hay entregas por correo, ni por el aula virtual,
   ni por USB. Por eso Git es la semana 1.

---

