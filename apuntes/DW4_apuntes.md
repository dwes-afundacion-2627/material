# DW4 · HTTP y el servidor web

**Desenvolvemento web en contorno servidor · 2º DAW · Apuntes**

---

## Al terminar esta unidad vas a saber

- Qué viaja exactamente entre el navegador y tu servidor, en las dos direcciones, y
  con qué orden se ve cada parte.
- Provocar y leer los cinco códigos de estado que se usan en este módulo: 200, 301,
  403, 404 y 500.
- Explicar la diferencia entre ejecutar en el servidor y ejecutar en el cliente
  mirando lo que llega al navegador.
- Decidir, ante un encargo concreto, si se resuelve con una página estática, con
  pequeñas inserciones de código dentro del HTML o con una aplicación organizada en el
  servidor, y decir **qué ganas** con la forma que has elegido.

Y aquí se siembra lo que en **enero** hace falta para el servicio web: métodos,
códigos de estado y JSON.

---

## Cómo están escritos estos apuntes

Cada apartado tiene hasta tres partes:

| Parte | Qué es |
|---|---|
| **La explicación** | Lo que hay que saber antes de tocar el teclado |
| **En directo** | Un recorrido corto que se hace en clase **a la vez**, en la pantalla y en tu equipo. Pasos numerados, lo que tienes que ver en cada uno y los fallos más frecuentes |
| **Ahora tú** | Un ejercicio del mismo patrón, con otro dato u otro contexto, para hacerlo solo. Trae su autocomprobación: puedes saber si está bien sin preguntar |

Solo dos apartados tienen «Ahora tú». El resto se practica en el recorrido guiado.

Lo que se entrega y se corrige está en `DW4_hoja_ejercicios.md`, y es un caso
**distinto** de los de aquí.

Los ficheros de esta unidad están en `dwes/recursos/DW4/`: `eco.php`,
`servidor.php`, `cliente.html` y `plantilla_cuaderno.md`. Cópialos a tu proyecto; no
hace falta teclearlos.

---

## 0. El sitio con el que se trabaja, y las dos direcciones

Todo esto se hace **sobre el sitio que ya montaste en DW2**. No se crea ningún
servidor nuevo ni se cambia la configuración que tienes funcionando.

Recuerda de **DW2, apartado 4.3**:

| Cosa | Dónde |
|---|---|
| Carpeta de trabajo del curso | `~/proyecto`, es decir `/home/tuusuario/proyecto` |
| Raíz pública (*DocumentRoot*) | `/home/tuusuario/proyecto/public` |
| Fichero del sitio en Apache | `/etc/apache2/sites-available/proyecto.conf` |
| Registro de accesos | `/var/log/apache2/proyecto_access.log` |
| Registro de errores | `/var/log/apache2/proyecto_error.log` |

Los dos registros son **los de tu sitio**, no los de fábrica: se llaman así porque en
DW2 pusiste `ErrorLog` y `CustomLog` con ese nombre dentro del `VirtualHost`.

**Todo lo de esta unidad se hace dentro de una carpeta nueva, `public/dw4/`**, para no
tocar nada de lo que ya tienes servido:

```bash
mkdir -p ~/proyecto/public/dw4
```

### Las dos direcciones, que no son la misma

Esto es de **DW2, apartado 5.0**, y aquí se paga si se confunde:

| Desde dónde pides | Dirección | Por qué |
|---|---|---|
| **Terminal de Debian** (dentro de la VM, con `curl`) | `http://localhost/` | Dentro de la VM, `localhost` es la VM, y Apache escucha en el puerto 80 |
| **Navegador de Windows** | `http://localhost:8080/` | En Windows, `localhost` es Windows. Se llega a la VM por el reenvío de puertos de DW2 (apartado 2.3): 8080 en Windows → 80 en la VM |

Los ejemplos de estos apuntes usan `curl` **dentro de la VM**, así que escriben
`http://localhost/…`. Cuando digan «ábrelo en el navegador», la dirección lleva
`:8080`.

---

## 1. Una petición y una respuesta

Todo lo que hace la web es esto, repetido millones de veces:

```
navegador  ──── petición ────>  servidor
navegador  <──── respuesta ───  servidor
```

La petición tiene tres partes: **línea de petición**, **cabeceras** y, a veces,
**cuerpo**.

```
GET /dw4/hola.html HTTP/1.1     <- linea: metodo, ruta, version
Host: localhost                 <- cabeceras
User-Agent: curl/8.5.0
Accept: */*
                                <- linea en blanco: separa cabeceras de cuerpo
                                <- cuerpo (en un GET no hay)
```

La respuesta tiene la misma forma:

```
HTTP/1.1 200 OK                        <- linea de estado: version, codigo, texto
Date: Mon, 28 Sep 2026 15:43:57 GMT    <- cabeceras
Server: Apache/2.4.58 (Debian)
Content-Length: 154
Content-Type: text/html

<!doctype html><html>...               <- cuerpo
```

### Tres órdenes distintas, porque enseñan tres cosas distintas

Éste es el punto donde más se confunde la gente. **Una sola orden no lo enseña todo.**

| Qué quieres ver | Orden |
|---|---|
| La **respuesta completa**: cabeceras **y** cuerpo | `curl -sS -i URL` |
| El **intercambio entero**: lo que se envía y lo que se recibe | `curl -sS -v URL` |
| **Solo las cabeceras** de la respuesta, tirando el cuerpo | `curl -sS -D - -o /dev/null URL` |

Qué significa cada trozo:

- `-s` calla la barra de progreso; `-S` deja que los errores se sigan viendo. Van
  juntos siempre: `-sS`.
- `-i` («include») añade las cabeceras de la respuesta **delante del cuerpo**.
- `-v` («verbose») enseña el diálogo: `>` es **lo que curl envía**, `<` es **lo que
  el servidor devuelve**, y `*` son comentarios de `curl` sobre la conexión.
- `-D -` («dump headers») escribe las cabeceras donde le digas; el `-` significa «en
  la pantalla». `-o /dev/null` tira el cuerpo.

> **La orden de cabeceras no enseña el cuerpo ni la petición.** Con
> `-D - -o /dev/null` el cuerpo se ha tirado a propósito, y de la petición no se ve
> nada. Si quieres el cuerpo, `-i`. Si quieres la petición, `-v`.

### Las cuatro cabeceras que hay que saber leer

| Cabecera | En qué mensaje | Qué dice |
|---|---|---|
| `Date` | Respuesta | La fecha y hora **del servidor** en el momento de responder, en GMT |
| `Server` | Respuesta | Qué programa ha respondido. En tu VM: `Apache/2.4.x (Debian)` |
| `Content-Type` | Respuesta | **Cómo hay que interpretar el cuerpo**: `text/html`, `text/plain`, `application/json`… Sin ella el navegador adivina, y adivina mal |
| `User-Agent` | **Petición** | Quién pide. `curl/8.5.0` en tres caracteres; un navegador manda una línea larguísima |

Las tres primeras las pone el servidor; la última la pone **quien pide**. Es la
primera pista de una idea que recorre el curso: **lo que manda el cliente lo decide
el cliente**, y por tanto no es de fiar.

### La pestaña Red del navegador: dónde está cada cosa

En Windows, con la página abierta en `http://localhost:8080/dw4/hola.html`: **F12** →
pestaña **Red** (*Network*) → recargar con **F5** → clic en la primera línea de la
lista. Dentro verás las mismas tres partes que en `curl -v`:

| En la pestaña Red | Qué es |
|---|---|
| *Encabezados de solicitud* / *Request headers* | La **petición**: lo que tu navegador ha enviado, incluido su `User-Agent` |
| *Encabezados de respuesta* / *Response headers* | La **respuesta**: `Date`, `Server`, `Content-Type`… |
| *Respuesta* / *Response* o *Vista previa* | El **cuerpo**: el HTML que ha llegado |

El navegador manda **muchas más cabeceras** que `curl` (`Accept-Language`, `Cookie`,
`Referer`, `Accept-Encoding`…). Ésa es la diferencia que hay que poder nombrar.

### En directo: la primera página y sus tres vistas

**Paso previo.** Crea la página con la que se trabaja:

```bash
mkdir -p ~/proyecto/public/dw4
nano ~/proyecto/public/dw4/hola.html
```

```html
<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Hola</title></head>
<body><p>Esta pagina existe y se sirve tal cual.</p></body></html>
```

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `curl -sS -i http://localhost/dw4/hola.html` | `HTTP/1.1 200 OK`, las cabeceras, **una línea en blanco** y debajo el HTML entero |
| 2 | `curl -sS -v -o /dev/null http://localhost/dw4/hola.html` | Líneas con `>` (`GET /dw4/hola.html HTTP/1.1`, `Host`, `User-Agent`, `Accept`) y líneas con `<` (`HTTP/1.1 200 OK`, `Date`, `Server`, `Content-Type`) |
| 3 | `curl -sS -D - -o /dev/null http://localhost/dw4/hola.html` | Solo las cabeceras de la respuesta. **Ni cuerpo ni petición** |
| 4 | En Windows, abre `http://localhost:8080/dw4/hola.html`, F12 → Red → F5 → clic en la petición | Las mismas tres partes. Compara el `User-Agent` con el del paso 2 |
| 5 | `curl -sS -o /dev/null -w "%{http_code}\n" http://localhost/dw4/hola.htm` | **404**: falta la `l` final. La ruta que se pide se escribe entera y exacta |
| 6 | `sudo tail -2 /var/log/apache2/proyecto_access.log` | Las dos últimas peticiones, con su ruta y su código: un 200 y un 404 |

Salida real del paso 1:

```
$ curl -sS -i http://localhost/dw4/hola.html
HTTP/1.1 200 OK
Date: Mon, 28 Sep 2026 15:43:57 GMT
Server: Apache/2.4.58 (Ubuntu)
Last-Modified: Mon, 28 Sep 2026 15:43:56 GMT
ETag: W/"9a-65c8ce99f7a8a"
Accept-Ranges: bytes
Content-Length: 154
Vary: Accept-Encoding
Content-Type: text/html

<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Hola</title></head>
<body><p>Esta pagina existe y se sirve tal cual.</p></body></html>
```

Y del paso 2, quedándose solo con las líneas del diálogo:

```
$ curl -sS -v -o /dev/null http://localhost/dw4/hola.html
*   Trying 127.0.0.1:80...
* Connected to localhost (127.0.0.1) port 80
> GET /dw4/hola.html HTTP/1.1
> Host: localhost
> User-Agent: curl/8.5.0
> Accept: */*
>
< HTTP/1.1 200 OK
< Date: Mon, 28 Sep 2026 15:43:57 GMT
< Server: Apache/2.4.58 (Ubuntu)
< Content-Length: 154
< Content-Type: text/html
<
```

> Estas salidas se capturaron en la máquina donde se preparó la unidad, que es Ubuntu.
> En tu VM la línea `Server` dirá **Debian**, y la fecha y el `ETag` serán otros. La
> forma es la misma.

**Si falla:**

- *`curl: (7) Failed to connect to localhost port 80`.* Apache no está arrancado:
  `sudo systemctl status apache2`, y si está parado, `sudo systemctl start apache2`.
- *Sale 404 y el fichero existe.* Comprueba la ruta completa: el fichero tiene que
  estar en `~/proyecto/public/dw4/`, y en la URL va `/dw4/` delante.
- *Sale 403 en una página recién creada.* Faltan permisos de lectura para Apache:
  `chmod o+r ~/proyecto/public/dw4/hola.html`.
- *Desde el navegador de Windows no carga nada.* Te falta el `:8080`, o la VM está
  apagada.

---

## 2. Los métodos: GET y POST

De todos los que existen, en este módulo se usan cuatro, y en la 1ª evaluación dos.

| Método | Para qué | ¿Lleva cuerpo? |
|---|---|---|
| **GET** | Pedir algo. Los datos suelen ir **en la URL** | No |
| **POST** | Mandar algo que cambia el estado. Los datos suelen ir **en el cuerpo** | Sí |
| PUT / PATCH | Modificar (enero, en el servicio web) | Sí |
| DELETE | Borrar (enero) | No |

**La regla práctica**: si la petición **cambia algo** —dar de alta, reservar,
cancelar—, POST. Si solo **consulta**, GET.

### `eco.php`: un fichero que dice qué ha recibido

Está en `dwes/recursos/DW4/eco.php`. Cópialo a `~/proyecto/public/dw4/`:

```php
<?php
header('Content-Type: text/plain; charset=utf-8');
echo "Metodo: ", $_SERVER['REQUEST_METHOD'], "\n";
echo "Ruta:   ", $_SERVER['REQUEST_URI'], "\n";
echo "GET:    ", json_encode($_GET), "\n";
echo "POST:   ", json_encode($_POST), "\n";
```

Las cuatro líneas que escribe, una por una:

| Línea | De dónde sale | Qué te dice |
|---|---|---|
| `Metodo:` | `$_SERVER['REQUEST_METHOD']` | El método de la línea de petición: `GET`, `POST`… |
| `Ruta:` | `$_SERVER['REQUEST_URI']` | La ruta **tal y como llegó**, con la parte de interrogación si la había |
| `GET:` | `$_GET` | Los pares que venían **en la URL**, después de la `?` |
| `POST:` | `$_POST` | Los pares que venían **en el cuerpo** de la petición |

La primera línea, `header('Content-Type: text/plain; charset=utf-8')`, dice al
navegador que lo que llega es texto normal y no HTML. Sin ella, el navegador
intentaría interpretarlo como etiquetas.

`json_encode` **no es un formato de datos aquí: es una forma de mirarlos**. Convierte
el array de PHP en una línea de texto que se lee de un golpe: `{}` o `[]` es «no hay
nada» y `{"clave":"valor"}` es «hay esto». En enero, en el servicio web, el mismo JSON
pasa de ser una forma de mirar a ser la respuesta misma.

Las opciones de `curl` que hacen falta aquí:

| Opción | Qué hace |
|---|---|
| `-X POST` | Cambia el método de la línea de petición a POST |
| `-d "clave=valor&otra=algo"` | Añade **cuerpo** a la petición. Con `-d`, `curl` ya usa POST aunque no pongas `-X` |

### En directo: la misma dirección, dos métodos

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | Copia `eco.php` a `~/proyecto/public/dw4/` y dale permiso de lectura | `ls -l ~/proyecto/public/dw4/eco.php` enseña `-rw-r--r--` |
| 2 | `curl -sS "http://localhost/dw4/eco.php?mision=7&dificultad=4"` | `Metodo: GET`; la **ruta lleva los parámetros**; `GET:` con los dos pares; `POST: []` |
| 3 | `curl -sS -X POST -d "mision=7&dificultad=4" http://localhost/dw4/eco.php` | `Metodo: POST`; la **ruta no lleva parámetros**; `GET: []`; `POST:` con los dos pares |
| 4 | `curl -sS -X POST http://localhost/dw4/eco.php` (**sin `-d`**, a propósito) | `Metodo: POST` pero `GET: []` y `POST: []`. El método cambió; los datos no viajaron |
| 5 | `sudo tail -3 /var/log/apache2/proyecto_access.log` | En la línea del GET se leen los datos; en la del POST, solo la ruta |

Las comillas del paso 2 **no son decorativas**: sin ellas, la terminal se queda el
`&` e interpreta que quieres lanzar la orden en segundo plano.

Salidas reales de los pasos 2, 3 y 4:

```
$ curl -sS "http://localhost/dw4/eco.php?mision=7&dificultad=4"
Metodo: GET
Ruta:   /dw4/eco.php?mision=7&dificultad=4
GET:    {"mision":"7","dificultad":"4"}
POST:   []

$ curl -sS -X POST -d "mision=7&dificultad=4" http://localhost/dw4/eco.php
Metodo: POST
Ruta:   /dw4/eco.php
GET:    []
POST:   {"mision":"7","dificultad":"4"}

$ curl -sS -X POST http://localhost/dw4/eco.php
Metodo: POST
Ruta:   /dw4/eco.php
GET:    []
POST:   []
```

**Fíjate en la ruta.** Con GET los datos están a la vista: se quedan en el historial,
en los marcadores y escritos en el registro del servidor. Con POST viajan en el cuerpo
y no aparecen ahí.

> **Eso no significa que POST cifre nada.** Los dos viajan legibles por la red. Lo que
> cifra es HTTPS. Con POST solo evitas que los datos queden **escritos** en el
> historial, en los marcadores y en el registro.

Y dos precisiones que se caen si se generaliza de más:

- **POST también puede llevar parámetros en la URL.** Las dos cosas a la vez son
  legales: parte en la ruta y parte en el cuerpo. Lo verás en el «Ahora tú».
- **Lo de «en el registro del POST no se ven los datos» vale para este formato de
  registro y este ejemplo.** El formato `combined` que configuraste en DW2 escribe la
  línea de petición, que no incluye el cuerpo. Otro formato, u otro programa delante,
  pueden guardar más.

### Ahora tú · AT4.1 · Los mismos datos por los dos caminos (8 minutos)

Manda `actividad=12` y `turno=tarde` al **mismo** `/dw4/eco.php`, primero por GET y
después por POST. Pega las **salidas completas** de las dos, con la orden encima.

**Autocomprobación.** Lo tienes bien si, sin cambiar nada más:

| | En GET | En POST |
|---|---|---|
| La línea `Ruta:` | **contiene** `?actividad=12&turno=tarde` | **no** contiene parámetros |
| La línea `GET:` | contiene **los dos** pares | está **vacía** (`[]`) |
| La línea `POST:` | está **vacía** (`[]`) | contiene **los dos** pares |

Si tu `POST:` sale vacío en la segunda orden, te falta `-d`.

**Si acabas pronto:** manda `actividad=12` **en la URL** y `turno=tarde` **en el
cuerpo**, en una sola petición POST. Antes de ejecutarla, escribe qué esperas en cada
una de las cuatro líneas; después compruébalo.

---

## 3. Los cinco códigos de estado

Los códigos van por familias, y la familia es lo primero que se lee:

| Familia | Qué significa |
|---|---|
| **2xx** | Salió bien |
| **3xx** | Redirección: el servidor no da el contenido, da **instrucciones** sobre dónde seguir |
| **4xx** | El problema está en la petición: quien pide se ha equivocado o no tiene permiso |
| **5xx** | El problema está en el servidor: la petición era buena y no ha podido contestarla |

Cuidado con la familia 3xx: **no todos los 3xx significan «la página está en otra
dirección»**. Hay 3xx que dicen «no ha cambiado desde la última vez, usa tu copia». En
este módulo se estudia **uno concreto**, el **301**, que sí significa que se ha mudado,
y para siempre.

Los cinco que se provocan y se leen en esta unidad:

| Código | Qué significa | Cómo se provoca aquí |
|---|---|---|
| **200 OK** | Aquí está lo que pediste | Pedir una página que existe y se puede leer |
| **301 Moved Permanently** | Se ha mudado, para siempre. La dirección nueva va en `Location` | Una regla `Redirect 301` en la configuración del sitio |
| **403 Forbidden** | Existe, pero no te lo doy | Cerrar el permiso de lectura de un fichero que existe |
| **404 Not Found** | No está | Pedir una ruta que no existe |
| **500 Internal Server Error** | Se ha roto el servidor, no tú | Un error de PHP sin capturar |

La forma corta de ver solo el código:

```bash
curl -sS -o /dev/null -w "%{http_code}\n" URL
```

`-w` («write out») escribe un dato al terminar; `%{http_code}` es el código de estado.

### 3.1 · 200: crear y servir un HTML conocido

Ya lo tienes del apartado 1: `hola.html`.

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `curl -sS -o /dev/null -w "%{http_code}\n" http://localhost/dw4/hola.html` | `200` |

**Fallo típico:** 403 en lugar de 200 porque el fichero se creó sin permiso de lectura
para los demás. Se arregla con `chmod o+r`.

**Restauración:** ninguna. No se ha cambiado nada.

### 3.2 · 301: una redirección puesta y retirada a mano

**Fichero que se toca:** `/etc/apache2/sites-available/proyecto.conf`, el de DW2.
**Máquina:** la VM, con `sudo`.

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `sudo nano /etc/apache2/sites-available/proyecto.conf` | El `<VirtualHost *:80>` que escribiste en DW2 |
| 2 | Dentro del `<VirtualHost>`, debajo de `DocumentRoot`, añade una línea: `Redirect 301 /dw4/vieja.html /dw4/hola.html`. Guarda y sal | La línea dentro del bloque, **nunca** dentro de `<Directory>` |
| 3 | `sudo apache2ctl configtest` | `Syntax OK`. Si dice otra cosa, **no recargues**: vuelve al fichero |
| 4 | `sudo systemctl reload apache2` | Ninguna salida. Ninguna salida es buena señal |
| 5 | `curl -sS -D - -o /dev/null http://localhost/dw4/vieja.html` | `HTTP/1.1 301 Moved Permanently` y la cabecera `Location:` con la dirección nueva |
| 6 | `curl -sS -L -o /dev/null -w "%{num_redirects} redirecciones, final %{http_code}\n" http://localhost/dw4/vieja.html` | `1 redirecciones, final 200` |
| 7 | Vuelve al fichero y **borra únicamente esa línea** (y la línea en blanco que le pusiste delante). Guarda | El fichero queda como estaba antes del paso 2 |
| 8 | `sudo apache2ctl configtest` y `sudo systemctl reload apache2` | `Syntax OK` y ninguna salida |
| 9 | `curl -sS -o /dev/null -w "%{http_code}\n" http://localhost/dw4/vieja.html` | `404`. La redirección ya no existe y ese fichero nunca existió |

Salida real del paso 5:

```
$ curl -sS -D - -o /dev/null http://localhost/dw4/vieja.html
HTTP/1.1 301 Moved Permanently
Date: Mon, 28 Sep 2026 15:43:57 GMT
Server: Apache/2.4.58 (Ubuntu)
Location: http://localhost/dw4/hola.html
Content-Length: 313
Content-Type: text/html; charset=iso-8859-1
```

**`Location` es la parte importante**: dice a dónde ir. El navegador va solo. `curl`
no, salvo que se lo pidas con `-L`. Ésa es la diferencia entre un navegador y un
programa: el programa hace lo que le has escrito.

**Fallos típicos:**

- *`configtest` dice `Redirect takes two or three arguments`.* Falta una de las dos
  rutas, o hay un espacio de más partiendo una de ellas.
- *Sigue saliendo 404 después de recargar.* La línea se ha quedado fuera del
  `<VirtualHost>`, o se ha editado un fichero del sitio que no está activado.
- *Sale 301 pero `Location` apunta a una dirección rara.* La segunda ruta de la regla
  tiene que empezar por `/`.

**Restauración:** el paso 7 es la restauración, y el 9 la comprueba. Cuando termines,
`proyecto.conf` tiene que estar **exactamente** como lo dejaste en DW2.

### 3.3 · 403: un fichero que existe y no se puede leer

**Fichero que se toca:** uno nuevo, de prueba. **Máquina:** la VM.

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `mkdir -p ~/proyecto/public/dw4/privado` y `echo "Nota interna de prueba." > ~/proyecto/public/dw4/privado/nota.txt` | El fichero creado |
| 2 | `chmod 755 ~/proyecto/public/dw4/privado` y `chmod 644 ~/proyecto/public/dw4/privado/nota.txt` | Permisos normales |
| 3 | `curl -sS -o /dev/null -w "%{http_code}\n" http://localhost/dw4/privado/nota.txt` | `200`. **Este paso no se salta**: sin él no sabes si el 403 de después es por permisos o por otra cosa |
| 4 | `chmod 600 ~/proyecto/public/dw4/privado/nota.txt` | Ahora solo lo lee su dueño |
| 5 | Repite la petición del paso 3 | `403` |
| 6 | `ls -l ~/proyecto/public/dw4/privado/nota.txt` | `-rw-------`. **El fichero sigue ahí.** Existe y no se entrega: eso es un 403 |
| 7 | `chmod 644 ~/proyecto/public/dw4/privado/nota.txt` | Restaurado |
| 8 | Repite la petición | `200` otra vez |

Salida real de los pasos 3, 5 y 8:

```
antes de cerrar permisos -> 200
con el fichero en 600     -> 403
restaurado a 644          -> 200
```

**Fallo típico, y es el de la mitad de la clase:** provocar el 403 **borrando** el
fichero. Eso es un **404**. La diferencia entera de este recorrido está en el paso 6:
el fichero existe.

**Restauración:** paso 7. La carpeta `privado/` puede quedarse; no molesta.

### 3.4 · 404: una ruta que no existe

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `curl -sS -o /dev/null -w "%{http_code}\n" http://localhost/dw4/no-existe.html` | `404` |
| 2 | `sudo tail -1 /var/log/apache2/proyecto_access.log` | La línea con la ruta pedida y el `404` al final |

**Fallo típico:** dar por hecho que un 404 es un error del servidor. No lo es: el
servidor ha funcionado perfectamente y ha contestado que eso no está.

**404 y 403 no son lo mismo:** uno dice *no está* y el otro *está, pero no*. En enero,
en tu servicio web, vas a tener que **elegir a propósito** cuál devolver, y verás que a
veces se contesta 404 aunque la cosa exista, precisamente para no contar qué hay
dentro.

**Restauración:** ninguna.

### 3.5 · 500: un PHP que se rompe, y el registro que lo explica

**Fichero que se toca:** uno nuevo, `~/proyecto/public/dw4/roto.php`.
**Máquina:** la VM.

El fichero completo, con el fallo puesto a propósito:

```php
<?php
// Fallo deliberado: la funcion no existe en PHP. Se llama "resumir_turno".
$turno = 'tarde';
echo resumir_turno($turno);
```

**Qué está mal y por qué revienta:** `resumir_turno` no existe en ninguna parte. PHP no
sabe qué código ejecutar, así que lanza un error que nadie recoge, corta la ejecución y
no escribe nada. Apache se queda sin respuesta que dar y contesta 500.

Fíjate en que **no es un error de sintaxis**: el fichero está bien escrito y
`php -l` lo da por bueno. El fallo aparece al **ejecutarlo**.

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | Crea `roto.php` con ese contenido | — |
| 2 | `php -l ~/proyecto/public/dw4/roto.php` | `No syntax errors detected`. La sintaxis es correcta |
| 3 | `curl -sS -o /dev/null -w "%{http_code}\n" http://localhost/dw4/roto.php` | `500` |
| 4 | `curl -sS http://localhost/dw4/roto.php` | **Nada.** Cuerpo vacío. El visitante no se entera de qué ha pasado, y así tiene que ser |
| 5 | `sudo tail -1 /var/log/apache2/proyecto_error.log` | La línea que lo explica, con **el fichero y el número de línea** |
| 6 | Arregla el fichero definiendo la función antes de llamarla (abajo) | — |
| 7 | `php -l` otra vez y repite la petición del paso 3 | `No syntax errors detected` y `200` |
| 8 | `curl -sS http://localhost/dw4/roto.php` | `Turno: tarde` |

La línea real del registro, en el paso 5:

```
[Mon Sep 28 17:43:58.427359 2026] [php:error] [pid 7368] [client 127.0.0.1:35496]
PHP Fatal error:  Uncaught Error: Call to undefined function resumir_turno()
in /home/alumno/proyecto/public/dw4/roto.php:4
```

Ahí está todo: **qué** ha pasado (`undefined function`), **dónde** (`roto.php`) y **en
qué línea** (`:4`). En tu VM la ruta llevará **tu** nombre de usuario en vez de
`alumno`, que es el de la máquina donde se preparó la unidad.

El arreglo del paso 6:

```php
<?php
// Reparado: la funcion se define antes de llamarla.
function resumir_turno(string $turno): string {
    return "Turno: $turno";
}
$turno = 'tarde';
echo resumir_turno($turno);
```

**Aprende a mirar ese registro desde hoy.** Las próximas quince semanas, cada vez que
algo «no funcione», el motivo va a estar en ese fichero.

**Fallos típicos:**

- *Miro `/var/log/apache2/error.log` y está vacío.* Tu sitio escribe en
  `proyecto_error.log`, que es el que configuraste en DW2.
- *En lugar de 500 sale 200 con un aviso en la página.* Tienes `display_errors` en
  `On`. En tu máquina de desarrollo no es un problema, pero la costumbre que se instala
  aquí es **mirar el registro**, porque el corrector automático no tiene pantalla.
- *`tail` no enseña nada nuevo.* Estás mirando antes de provocar el error. Deja
  `sudo tail -f /var/log/apache2/proyecto_error.log` abierto en una terminal, provoca
  el error en otra, y sal con `Ctrl+C`.

**Restauración:** paso 6. **No dejes en el repositorio un fichero que no se ejecuta.**
Cuando el recorrido esté hecho y el 200 comprobado, `roto.php` queda arreglado o se
borra.

---

## 4. Los dos registros de tu sitio

Cada petición deja una línea en el registro de accesos:

```
127.0.0.1 - - [28/Sep/2026:17:42:27 +0200] "GET /dw4/eco.php?actividad=12&turno=tarde HTTP/1.1" 200 285 "-" "curl/8.5.0"
127.0.0.1 - - [28/Sep/2026:17:42:27 +0200] "POST /dw4/eco.php HTTP/1.1" 200 260 "-" "curl/8.5.0"
```

De izquierda a derecha: **quién** pidió, **cuándo**, **qué pidió** (entre comillas: el
método, la ruta y la versión), el **código**, los **bytes** del cuerpo, de dónde venía
el enlace y el `User-Agent`.

| Registro | Qué guarda | Cuándo se mira |
|---|---|---|
| `proyecto_access.log` | **Una línea por petición**, con su código | Para saber qué se ha pedido y qué se contestó |
| `proyecto_error.log` | Solo lo que ha fallado, con fichero y línea | Siempre que algo no funcione |

En la línea del GET **se leen los datos**, porque van dentro de la ruta. En la del
POST, no: la línea de petición no incluye el cuerpo. Ahí tienes, escrito por tu propio
servidor, el motivo para no mandar una contraseña por GET.

Otra vez con cuidado: **eso vale para este formato de registro** —el `combined` que
configuraste en DW2— **y para este ejemplo**. No es una propiedad general de POST.

### En directo: leer tu propio tráfico

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `sudo tail -f /var/log/apache2/proyecto_access.log` en una terminal | Se queda esperando |
| 2 | En otra terminal, lanza el GET y el POST de `eco.php` del apartado 2 | Dos líneas nuevas apareciendo en la primera terminal |
| 3 | Lee las dos líneas y señala en cada una: ruta, código y bytes | En el GET la ruta lleva los datos; en el POST no |
| 4 | Pide `/dw4/no-existe.html` | Una tercera línea, con `404` |
| 5 | `Ctrl+C` para recuperar el cursor | El cursor vuelve |

**Si falla:**

- *`tail -f` no enseña nada.* Estás mirando el registro de fábrica
  (`/var/log/apache2/access.log`) y no el de tu sitio.
- *`Permission denied`.* Los registros son de root: hace falta `sudo`.
- *La terminal se queda colgada.* `tail -f` es así a propósito. `Ctrl+C`.

---

## 5. Servidor o cliente: qué código viaja (¡¡¡ATENCIÓN!!! 4.4 de http/cuaderno.md)
Dos ficheros que producen **el mismo aviso en la pantalla** y funcionan de forma
completamente distinta. Los dos están en `dwes/recursos/DW4/`.

**`servidor.php`** — el texto lo pone PHP, en el servidor:

```php
<?php
// El texto que se anuncia. Es lo unico que se cambia en la practica.
$hora = '09:00';
?>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Panel de salidas</title>
</head>
<body>
  <h1>Panel de salidas</h1>
  <p id="aviso">Salida a las <?php echo $hora; ?></p>
</body>
</html>
```

**`cliente.html`** — el texto lo pone JavaScript, en el navegador:

```html
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Panel de salidas</title>
</head>
<body>
  <h1>Panel de salidas</h1>
  <p id="aviso"></p>
  <script>
    // El texto que se anuncia. Es lo unico que se cambia en la practica.
    const hora = '09:00';
    document.getElementById('aviso').textContent = 'Salida a las ' + hora;
  </script>
</body>
</html>
```

Ése es **el patrón de JavaScript de esta unidad**: coger el elemento por su `id` con
`document.getElementById` y escribir su texto con `textContent`. No hay que saber
escribir JavaScript en este módulo; hay que **saber leer estas dos líneas y decir dónde
se ejecutan**.

### Lo que llega en cada caso

Salidas reales:

```
$ curl -sS http://localhost/dw4/servidor.php
...
  <p id="aviso">Salida a las 09:00</p>
...

$ curl -sS http://localhost/dw4/cliente.html
...
  <p id="aviso"></p>
  <script>
    const hora = '09:00';
    document.getElementById('aviso').textContent = 'Salida a las ' + hora;
  </script>
...
```

**En `servidor.php` el navegador nunca ve el `<?php`.** Lo ejecutó el servidor y mandó
**el resultado**. En `cliente.html` el JavaScript **llega entero**: se puede leer,
cambiar y desactivar.

| | En el servidor (PHP) | En el cliente (JavaScript) |
|---|---|---|
| Dónde se ejecuta | En tu máquina | En la de quien visita la página |
| ¿Llega el código al navegador? | **No** | **Sí, entero** |
| ¿Puede tocar la base de datos? | Sí | No directamente |
| ¿Se puede desactivar? | No | Sí |
| Quién decide el texto, y cuándo | El servidor, **al responder** | El navegador, **al cargar la página** |
| ¿Sirve para comprobar datos? | **Sí** | Solo para avisar antes |

### Fuente y página renderizada no son lo mismo

Dos cosas que se confunden constantemente:

| | Qué es |
|---|---|
| **La fuente** (*Ver código fuente*, `Ctrl+U`) | **Lo que llegó**, tal cual. Es exactamente lo que enseña `curl` |
| **La página renderizada** | Lo que se ve después de que el navegador interprete el HTML **y ejecute el JavaScript** |

En `cliente.html` las dos **no coinciden**: en la fuente, el párrafo está vacío; en la
página se lee «Salida a las 09:00». El texto lo puso el navegador después. Si abres el
inspector de elementos verás el párrafo **ya rellenado**: el inspector enseña la página
viva, no lo que llegó.

### En directo: predecir, ejecutar, comparar

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | Copia los dos ficheros a `~/proyecto/public/dw4/` | `ls` los enseña |
| 2 | **Antes de ejecutar nada**, escribe qué esperas recibir de cada uno | Tu predicción, escrita. Sin esto el recorrido no enseña nada |
| 3 | `curl -sS http://localhost/dw4/servidor.php` | HTML con `Salida a las 09:00` **ya puesto**. Ni `<?php` ni `$hora` |
| 4 | `curl -sS http://localhost/dw4/cliente.html` | HTML con el párrafo **vacío** y el `<script>` entero debajo |
| 5 | Abre los dos en el navegador de Windows (`http://localhost:8080/dw4/…`) | Las **dos páginas se ven igual**: «Salida a las 09:00» |
| 6 | `Ctrl+U` en cada una | En `servidor.php`, la fuente es igual que el paso 3. En `cliente.html`, el párrafo está vacío aunque en la página se lea el aviso |
| 7 | En **los dos** ficheros, cambia solo el literal `09:00` por `10:00`. Guarda | Un único cambio por fichero |
| 8 | Espera dos segundos y repite los pasos 3 y 4 | `servidor.php` trae `Salida a las 10:00`; `cliente.html` trae `const hora = '10:00'` y el párrafo sigue vacío |
| 9 | Contesta: ¿qué código ha viajado en cada caso y dónde se ha ejecutado? | En uno viajó el resultado; en el otro, las instrucciones |
| 10 | Deja los dos ficheros otra vez en `09:00` | — |

En el paso 8, **los dos segundos son de verdad**: PHP guarda una versión compilada del
fichero y comprueba si ha cambiado cada dos segundos. Si pides la página
inmediatamente después de guardar, puede contestarte con la anterior. Comprobado: la
petición inmediata devolvió `09:00` y la de tres segundos después, `10:00`.

**Si falla:**

- *En `servidor.php` veo el `<?php` en la respuesta.* PHP no se está ejecutando: es el
  apartado 5 de DW2.
- *En `cliente.html` no se ve ningún aviso en la página.* El `id` del párrafo y el del
  `getElementById` no coinciden, o el `<script>` está antes del párrafo.
- *He cambiado el PHP y sigue saliendo lo de antes.* Espera dos segundos y vuelve a
  pedirlo. Si persiste, no has guardado.
- *Comparo la página renderizada de las dos y concluyo que son iguales.* Son iguales
  **en la pantalla**. La comparación de este apartado es entre **lo que llega**, no
  entre lo que se ve.

### Las dos consecuencias que marcan el curso entero

1. **Lo que se ejecuta en el cliente, el cliente lo controla.** Puede leerlo,
   cambiarlo, desactivarlo o no usar un navegador en absoluto: con `curl` manda lo que
   quiera. Por eso una comprobación hecha en el navegador **no protege el servidor**.
   En DW7 lo vas a saltar tú mismo en treinta segundos.
2. **Lo que se ejecuta en el servidor no viaja.** Ahí van las contraseñas, las
   consultas y las reglas que no se pueden negociar.

---

## 6. Estática, pequeñas inserciones o aplicación organizada (En practica_dw4, 5 · Ahora tú · AT4.2 · El museo)

Tres formas de producir una página. **Las tres pueden dar contenido que cambia**: lo
que las distingue no es eso.

| Forma | Qué es | Cuándo encaja |
|---|---|---|
| **Página estática** | Un `.html` guardado. El servidor lo manda tal cual | El contenido **no depende de nada**: ni de la fecha, ni de quién pide, ni de ningún dato guardado |
| **Pequeñas inserciones** | HTML con trozos de código dentro (`<?php … ?>`). Es lo que hace `servidor.php` | La página es **casi toda fija** y solo cambian uno o dos trozos, calculables ahí mismo |
| **Aplicación organizada en el servidor** | El programa **prepara los datos primero y compone la respuesta después**: decide qué mostrar, con qué datos y con qué plantilla | La respuesta depende de **quién pide**, de datos guardados o de varias decisiones combinadas |

> **Lo que no distingue a estas formas.** «Generar contenido dinámico» no es lo que
> separa las dos últimas: `servidor.php` es PHP embebido y también genera contenido
> dinámico. Y «separar la lógica de la presentación» **no pasa sola** por escribir una
> aplicación organizada: se separa porque se diseña así. Se puede escribir una
> aplicación con capas perfectamente enredadas, y se puede escribir PHP embebido
> ordenado. Lo que cambia entre una forma y otra es **cuánta estructura hace falta para
> que el resultado siga siendo legible y comprobable cuando crezca**.

### Cómo se decide, en cuatro pasos

Para cada encargo, en este orden:

1. **Necesidad**: ¿de qué depende lo que hay que mostrar? ¿De nada, de un dato
   calculable en el momento, o de quién pide y de datos guardados?
2. **Elección**: la forma más pequeña que cubra esa necesidad.
3. **Ventaja**: qué ganas **con esa forma en este encargo**.
4. **Coste evitado**: qué te habrías echado encima con la forma de más arriba.

La decisión se juzga contra **las condiciones que el encargo dice**, no contra lo que
sería técnicamente imposible: casi todo es técnicamente posible de las tres maneras.

### En directo: los tres encargos de la asociación

Una asociación de vecinos. No tiene ninguna página todavía: **se parte de cero en los
tres casos**.

**Encargo A.** Una página con la dirección, el teléfono y el horario. Cambia una vez al
año.

| | |
|---|---|
| **Necesidad** | No depende de nada: el mismo contenido para todo el mundo, todo el día, todo el año |
| **Elección** | **Página estática** |
| **Ventaja aquí** | No hay nada que ejecutar, así que no hay nada que se pueda romper ni que haya que mantener, y el servidor la entrega tal cual |
| **Coste evitado** | Montar y mantener una aplicación entera —estructura, configuración, despliegue— para devolver siempre lo mismo |

**Encargo B.** Que abajo salga «Hoy estamos abiertos» o «Hoy estamos cerrados», según
el día y la hora.

| | |
|---|---|
| **Necesidad** | Depende de **un** dato, el momento actual, que el servidor tiene a mano. Nada más cambia |
| **Elección** | **Pequeñas inserciones** dentro del HTML que ya tenías |
| **Ventaja aquí** | La página sigue siendo casi toda fija: unas líneas dentro del HTML resuelven el encargo completo, sin añadir ninguna estructura nueva |
| **Coste evitado** | Introducir capas y plantillas para calcular un solo valor |

**Encargo C.** Que los socios entren con usuario y contraseña, vean las actividades a
las que están apuntados y puedan apuntarse a otras.

| | |
|---|---|
| **Necesidad** | Depende de **quién pide** y de datos guardados que además **se modifican**. Hay identidad, consultas y cambios de estado |
| **Elección** | **Aplicación organizada en el servidor** |
| **Ventaja aquí** | Cada petición se puede resolver en pasos separados —quién eres, qué te corresponde, cómo se muestra—, de modo que las comprobaciones están en un sitio identificable y se pueden probar sin abrir el navegador |
| **Coste evitado** | Repetir el control de identidad y las consultas dentro de cada página, donde es imposible comprobar que está en todas |

**Y la pregunta que de verdad hace pensar:** si el encargo **A** se resolviera con una
aplicación organizada completa, ¿qué costaría **de más**? Dos respuestas buenas:

1. **Trabajo que no hace falta**: estructura, configuración y despliegue para una
   página que cambia una vez al año.
2. **Superficie de fallo**: lo que no se ejecuta no se puede romper. Un `.html` no
   devuelve un 500 nunca.

Y una tercera, de coste continuo: cada visita ejecuta código para devolver siempre lo
mismo.

> Fíjate en que la respuesta del encargo **B** es correcta **para ese encargo**, y es
> exactamente la que se vuelve un problema cuando el encargo crece. Eso es lo que
> justifica DW12.

### Ahora tú · AT4.2 · El museo (5 minutos)

Un museo municipal, **sin ninguna plataforma previa**: los tres apartados se
construyen desde cero.

| | Encargo |
|---|---|
| **A** | Un plano de las salas, que se revisa una vez al año |
| **B** | Que al pie de la página del plano aparezca la fecha de hoy |
| **C** | Que cada visitante registrado consulte sus reservas de visita guiada y pueda cancelarlas |

Para cada uno, **dos líneas**: la forma elegida y la ventaja que da en ese apartado.

**Autocomprobación.** Lo tienes bien si:

- A es **página estática**, B es **pequeñas inserciones** y C es **aplicación
  organizada en el servidor**;
- cada ventaja está **atada a la necesidad de su apartado**: en A, que no hay nada que
  ejecutar ni mantener; en B, que solo cambia un trozo de una página fija; en C, que la
  respuesta depende de quién pide y de datos que se modifican.

Si has escrito la misma ventaja en dos apartados, todavía no has decidido: has
clasificado.

**Si acabas pronto:** escribe **una** condición que, añadida al encargo A, cambiaría tu
elección, y di a qué forma la cambiaría.

---

## 7. Del URL al fichero

```
http://localhost:8080/dw4/actividades/lista.php
                     └──────────────┬──────────┘
                              esta parte
```

Apache la busca dentro de la **raíz pública** de tu sitio, la que pusiste en
`DocumentRoot`:

```apache
DocumentRoot /home/tuusuario/proyecto/public
```

→ `/home/tuusuario/proyecto/public/dw4/actividades/lista.php`

Dos casos que conviene saber:

- **Si pides una carpeta** (`/dw4/actividades/`), Apache busca dentro el fichero que
  diga `DirectoryIndex`: `index.html`, `index.php` y algunos más. Si no encuentra
  ninguno, tiene dos salidas: **listar el contenido** de la carpeta, o **devolver
  403**. Lo decide `Options`: en DW2 escribiste `Options -Indexes`, que apaga el
  listado, así que tu sitio devuelve **403**.
- **Si el fichero no existe**, **404**.

El 403 de una carpeta sin índice **no es un problema de permisos**: los permisos están
bien. Es que no hay nada que servir y el listado está apagado a propósito, porque
enseñar el contenido de una carpeta es regalar información.

### En directo: la raíz real y las dos respuestas de una carpeta

| Paso | Qué haces | Qué tienes que ver |
|---|---|---|
| 1 | `grep -r DocumentRoot /etc/apache2/sites-enabled/` | Una sola línea, la de tu sitio: `/home/tuusuario/proyecto/public` |
| 2 | Crea `~/proyecto/public/dw4/actividades/lista.php` con el contenido de abajo | — |
| 3 | `php -l ~/proyecto/public/dw4/actividades/lista.php` | `No syntax errors detected` |
| 4 | `curl -sS http://localhost/dw4/actividades/lista.php` | La lista con las tres actividades en `<li>` |
| 5 | Pide **la carpeta**: `curl -sS -o /dev/null -w "%{http_code}\n" http://localhost/dw4/actividades/` | `403`. Hay ficheros dentro, pero ninguno se llama `index.…` |
| 6 | `sudo tail -1 /var/log/apache2/proyecto_error.log` | `No matching DirectoryIndex … and server-generated directory index forbidden by Options directive` |
| 7 | `cp lista.php index.php` dentro de esa carpeta y repite el paso 5 | `200`. Ahora sí hay índice |
| 8 | `curl -sS -o /dev/null -w "%{http_code}\n" http://localhost/dw4/actividad/` | `404`. Falta la parte final del nombre: `actividad` no es `actividades` |
| 9 | `curl -sS -o /dev/null -w "%{http_code}\n" http://localhost/dw4/actividades/3` | `404`: no existe ningún fichero ni carpeta que se llame `3` |

El fichero del paso 2:

```php
<?php
$actividades = ['Senderismo', 'Piragua', 'Escalada'];
?>
<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Actividades</title></head>
<body>
  <h1>Actividades</h1>
  <ul>
<?php foreach ($actividades as $actividad): ?>
    <li><?php echo $actividad; ?></li>
<?php endforeach; ?>
  </ul>
</body>
</html>
```

Salida real del paso 4:

```
$ curl -sS http://localhost/dw4/actividades/lista.php
<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Actividades</title></head>
<body>
  <h1>Actividades</h1>
  <ul>
    <li>Senderismo</li>
    <li>Piragua</li>
    <li>Escalada</li>
  </ul>
</body>
</html>
```

Y la línea real del paso 6 (con el usuario de la máquina de preparación; en la tuya
saldrá el tuyo):

```
[autoindex:error] AH01276: Cannot serve directory
/home/alumno/proyecto/public/dw4/actividades/: No matching DirectoryIndex
(index.html,index.cgi,index.pl,index.php,index.xhtml,index.htm) found,
and server-generated directory index forbidden by Options directive
```

**Si falla:**

- *`grep` no devuelve nada.* Estás mirando `sites-available` en vez de
  `sites-enabled`, o el sitio no está activado.
- *El paso 5 da un listado de ficheros en vez de 403.* Tu `<Directory>` tiene
  `Options +Indexes`. Vuelve a DW2, apartado 4.3: la línea correcta es
  `Options -Indexes +FollowSymLinks`.
- *El paso 8 da 403 en lugar de 404.* Has escrito una carpeta que sí existe.

> **El paso 9 es la pregunta que abre DW12.** En unas semanas `/dw4/actividades/3` va a
> funcionar sin que exista ningún fichero llamado `3`: una sola puerta de entrada
> (`index.php`) que decide qué enseñar según la ruta pedida. Eso es el enrutado.

---

## Errores típicos

| Síntoma | Qué pasa |
|---|---|
| Veo mi código PHP en la respuesta | PHP no se está ejecutando: es DW2, apartado 5 |
| Cambio el PHP y sale lo de antes | Espera dos segundos: PHP revalida el fichero compilado cada dos segundos. Si sigue, no has guardado |
| Cambio el HTML y sale lo de antes | Caché del navegador: `Ctrl+F5`, o pruébalo con `curl` |
| `curl -D - -o /dev/null` y no veo el cuerpo | Correcto: lo has tirado. Para verlo, `-i` |
| No veo la petición en ningún sitio | Solo la enseña `-v`, en las líneas que empiezan por `>` |
| 403 al pedir una carpeta | No hay `index.…` dentro y `Options -Indexes` apaga el listado. No es de permisos |
| 403 al pedir un fichero recién creado | Ése sí es de permisos: `chmod o+r` |
| 500 y página en blanco | Mira `proyecto_error.log`. **Siempre** |
| El registro está vacío | Estás mirando `access.log` o `error.log` en vez de los `proyecto_*.log` de tu sitio |
| Puse la regla de redirección y sigue el 404 | Ha quedado fuera del `<VirtualHost>`, o no has recargado Apache |
| «Mi comprobación funciona» pero llega basura | La comprobación está en el navegador. DW7 |
| El formulario manda por GET sin querer | Falta `method="post"` en el `<form>` |
| Desde Windows no carga nada | Falta el `:8080`, o la VM está apagada |

---

## Resumen en una página

- Todo pasa sobre el sitio de DW2: `~/proyecto/public`, y los registros
  `proyecto_access.log` y `proyecto_error.log`. Las prácticas, en `public/dw4/`.
- Dentro de la VM, `http://localhost/`. Desde el navegador de Windows,
  `http://localhost:8080/`.
- Tres órdenes, tres cosas: `-i` la respuesta completa, `-v` el intercambio,
  `-D - -o /dev/null` solo las cabeceras.
- `Date`, `Server` y `Content-Type` los pone el servidor; `User-Agent` lo pone quien
  pide, y por eso no es de fiar.
- **GET** consulta y suele ir en la URL; **POST** cambia cosas y suele ir en el cuerpo.
  POST **también** puede llevar parámetros en la URL, y **no cifra nada**.
- **2xx** bien · **3xx** el servidor da instrucciones, no contenido (el 301 dice que se
  ha mudado, y `Location` dice a dónde) · **4xx** el problema está en la petición ·
  **5xx** el problema está en el servidor.
- 403 es «existe y no te lo doy»; 404 es «no está». El 403 de una carpeta sin índice no
  es de permisos.
- El 500 se lee en `proyecto_error.log`, no en la pantalla.
- **El navegador nunca ve tu PHP.** Ve lo que tu PHP escribió. El JavaScript, en
  cambio, llega entero: lo que corre en el cliente, el cliente lo controla.
- La fuente es lo que llegó; la página renderizada es lo que se ve después de ejecutar
  el JavaScript.
- Estática, pequeñas inserciones o aplicación organizada: se elige por **de qué depende
  el contenido**, y hay que saber decir qué se gana y qué coste se evita.
