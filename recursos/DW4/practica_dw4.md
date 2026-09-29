# DW4 · Evidencias de práctica guiada

**HTTP y el servidor web · DWES · 2º DAW**

**Nombre:** _______________________ · **Usuario de GitHub:** _______________________

Este fichero se guarda como:

`http/practica_dw4.md`

Sirve únicamente para dejar una **evidencia mínima de que has realizado los recorridos «En directo» y los ejercicios «Ahora tú» de los apuntes**.

No sustituye a `http/cuaderno.md`.

**No tiene nota propia.** La comprensión de la unidad se comprobará mediante los ejercicios de entrega y la prueba de la última sesión.

## Reglas

- Pega únicamente **salidas obtenidas de verdad en tu máquina**.
- Cuando se pida una salida, escribe también la orden que la produjo.
- No hacen falta capturas de pantalla.
- No repitas aquí evidencias que ya aparecen en `http/cuaderno.md`.
- Realiza varios commits durante el trabajo, no uno único al final.

---

# 1 · Primera petición HTTP

Ejecuta contra tu `hola.html` la orden que permite ver el intercambio entre `curl` y Apache.

**Orden:**

```bash

```

**Pega únicamente las líneas de la petición y de la respuesta que empiezan por `>` y `<`:**

```text

```

Localiza dentro de ellas:

- método y ruta solicitada:
- código HTTP recibido:
- `User-Agent` enviado:

---

# 2 · Ahora tú · AT4.1 · GET y POST

Envía al mismo `/dw4/eco.php`:

- `actividad=12`
- `turno=tarde`

primero mediante GET y después mediante POST.

## GET

**Orden:**

```bash

```

**Salida completa:**

```text

```

## POST

**Orden:**

```bash

```

**Salida completa:**

```text

```

Comprueba antes de continuar:

- [ ] En GET, `Ruta:` contiene `?actividad=12&turno=tarde`.
- [ ] En GET, los datos aparecen en `GET:` y `POST:` está vacío.
- [ ] En POST, `Ruta:` no contiene esos parámetros.
- [ ] En POST, `GET:` está vacío y los datos aparecen en `POST:`.

---

# 3 · Los cinco códigos HTTP

Realiza los recorridos de los apuntes hasta haber provocado los cinco códigos.

Completa únicamente los resultados:

| Situación | Código obtenido |
|---|---:|
| Recurso existente y accesible | |
| Redirección permanente | |
| Recurso existente pero sin permiso de lectura | |
| Ruta inexistente | |
| Error durante la ejecución de PHP | |

## Evidencia del error 500

Pega la orden con la que consultaste `proyecto_error.log`:

```bash

```

Y la línea o líneas donde aparece el error de `roto.php`:

```text

```

Identifica:

- error:
- fichero:
- número de línea:

Antes de continuar:

- [ ] He restaurado los permisos de `nota.txt`.
- [ ] He retirado la redirección temporal.
- [ ] `roto.php` vuelve a funcionar o ha sido eliminado.

---

# 4 · Leer el registro de accesos

Genera:

1. una petición GET a `eco.php` con datos;
2. una petición POST a `eco.php` con datos.

Pega únicamente las dos líneas correspondientes de:

`/var/log/apache2/proyecto_access.log`

```text

```

Completa:

| Petición | Ruta que aparece | Código | Bytes |
|---|---|---:|---:|
| GET | | | |
| POST | | | |

¿Por qué en el GET pueden aparecer los datos dentro de la ruta del registro y en el POST no aparecen los enviados en el cuerpo?

> 

---

# 5 · Ahora tú · AT4.2 · El museo

Un museo municipal parte de cero.

Indica para cada caso la **forma elegida** y la **ventaja concreta que aporta en ese encargo**.

| | Encargo | Forma elegida | Ventaja que da aquí |
|---|---|---|---|
| **A** | Plano de las salas, revisado una vez al año | | |
| **B** | Fecha de hoy al pie de la página del plano | | |
| **C** | Cada visitante consulta y cancela sus reservas | | |

Comprueba:

- [ ] La ventaja de cada caso está relacionada con su necesidad concreta.
- [ ] No he usado la misma justificación para varios casos distintos.

---

# 6 · Evidencias que ya están en `cuaderno.md`

No se vuelven a copiar aquí.

El recorrido de `servidor.php` y `cliente.html` queda demostrado en **E4.4 de `http/cuaderno.md`**.

La decisión entre página estática, pequeñas inserciones y aplicación organizada vuelve a trabajarse en **E4.5 de `http/cuaderno.md`**.

- [ ] He realizado el recorrido servidor/cliente antes de completar E4.4.
- [ ] He realizado el recorrido de las tres formas antes de completar E4.5.

---

# 7 · Antes de terminar

- [ ] He realizado los recorridos «En directo» de los apuntes.
- [ ] He realizado AT4.1.
- [ ] He realizado AT4.2.
- [ ] Las salidas pegadas son de mi propia máquina.
- [ ] He restaurado los cambios temporales realizados durante las pruebas.
- [ ] `http/practica_dw4.md` está en el repositorio.
- [ ] `http/cuaderno.md` está terminado.
- [ ] `BITACORA_PROMPTS.md` está al día si he usado ayuda externa.
- [ ] Hay varios commits realizados durante el trabajo.
- [ ] He hecho `git push`.

**Lo que no está subido al repositorio no está entregado.**