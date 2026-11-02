# DW8 · Acceso a datos con PDO

**Desarrollo web en entorno servidor · 2.º DAW · Apuntes**

## Qué vamos a aprender

Vamos a conectar PHP con MariaDB, consultar un catálogo, buscar y filtrar productos, mostrar una ficha y crear un producto desde un formulario. Practicaremos con productos y categorías. El proyecto de misiones sigue siendo el contexto en el que aplicarás después lo aprendido.

PDO significa *PHP Data Objects*: es la interfaz de PHP para comunicarse con bases de datos. MariaDB conserva los datos y ejecuta SQL; PDO permite enviarle consultas y recuperar resultados. El controlador `pdo_mysql` hace posible esa comunicación con MariaDB.

```text
Navegador → petición → PHP → PDO → MariaDB
                         ↑          ↓
Navegador ← HTML ← plantilla ← arrays con los resultados
```

PDO no sustituye la validación del formulario ni el escape al generar HTML. Las consultas preparadas separan SQL y valores, pero no deciden si un precio es admisible ni convierten un nombre en HTML seguro.


| Apartado | Guiado |
|---|---|
| Tecnología, tablas y datos iniciales | G1 |
| Conexión, credenciales y errores | G2 |
| Recuperar un listado | G3 |
| Consultar un producto por ID | G4 |
| Consultas preparadas y búsqueda | G5 |
| Precio máximo y disponibilidad | G6 |
| Formulario, INSERT y redirección | G7 |

## Organización

Los ejemplos utilizan rutas diferentes a las de los antiguos guiados:

```text
proyecto/
├── config/
│   └── credenciales.php             # Conserva las cuatro claves de DW2
├── sql/
│   ├── dw8_esquema.sql
│   └── dw8_semilla.sql
├── src/
│   ├── funciones.php               # Reutiliza h()
│   ├── bd.php                      # conectar(), una sola definición
│   ├── productos_bd.php            # Funciones acumulativas de G3–G7
│   ├── precio_producto.php         # Apoyo de importes desde G6
│   └── validacion_producto.php     # G7
└── public/
    └── DW8/
        ├── g2.php
        ├── g3.php
        ├── g4.php
        ├── g5.php
        ├── g6.php
        └── g7.php
```

Mantén el resto del proyecto.

## 1. Preparar la base de prácticas

### PDO frente a las alternativas

| Tecnología | Qué ofrece |
|---|---|
| mysqli | API de PHP específica para MySQL/MariaDB, con SQL visible. |
| PDO | API común con controladores para distintos motores y consultas preparadas. |
| ORM, como Eloquent | Modelos y operaciones que generan parte del SQL; requiere otra biblioteca y sus convenciones. |

Elegimos PDO para practicar la comunicación con la base sin ocultar SQL. Cambiar de controlador no hace portable todo el SQL: algunas funciones, tipos y sintaxis dependen del motor.

### En directo · G1 · Crear el catálogo de prácticas

**Enunciado:** añade `categoria_producto` y `producto` a la base `expediciones` y carga la semilla de los guiados. Las tablas del proyecto de misiones se conservan.

#### Paso 1 · Comprobar el servidor

En el terminal de la VM Debian/Ubuntu, no en PowerShell:

```bash
cd ~/proyecto
mariadb --version
sudo systemctl is-active mariadb
php -r "print_r(PDO::getAvailableDrivers());"
```

El servicio debe responder `active` y entre los controladores PHP debe aparecer `mysql`. Si MariaDB está instalado pero detenido, utiliza `sudo systemctl start mariadb`. Si faltan las piezas del entorno de DW2:

```bash
sudo apt update
sudo apt install mariadb-server mariadb-client php-mysql
sudo systemctl enable --now mariadb
```

Si acabas de instalar la extensión PHP, reinicia el proceso que ejecuta PHP: vuelve a arrancar `php -S`; con Apache y PHP como módulo, utiliza `sudo systemctl restart apache2`. Con FPM, reinicia el servicio de la versión configurada en DW2. El PHP del terminal y el de la web pueden tener configuraciones diferentes.

#### Paso 2 · Colocar los SQL

Copia los tres archivos de la carpeta `sql` que acompañan a estos apuntes a `~/proyecto/sql` **dentro de la VM**. Puedes utilizar el explorador remoto de VS Code. Después comprueba:

```bash
mkdir -p ~/proyecto/sql
ls -l ~/proyecto/sql/dw8_esquema.sql ~/proyecto/sql/dw8_semilla.sql ~/proyecto/sql/dw8_comprobar.sql
```

Si descargaste los archivos en `~/Descargas` de la propia VM, puedes copiarlos así, antes de repetir el `ls`:

```bash
cp ~/Descargas/dw8_esquema.sql ~/proyecto/sql/
cp ~/Descargas/dw8_semilla.sql ~/proyecto/sql/
```

No ejecutes el esquema ni la semilla originales de las misiones para preparar estos guiados. El nuevo esquema crea las dos tablas si faltan; la nueva semilla **reinicia solo productos y categorías**, por lo que elimina las altas anteriores de productos. Las misiones permanecen intactas.

#### Paso 3 · Entrar como administrador e importar

En el terminal:

```bash
cd ~/proyecto
sudo mariadb
```

Ahora estás dentro del cliente MariaDB. Los comandos SQL terminan en `;`:

```sql
SELECT CURRENT_USER();
SOURCE sql/dw8_esquema.sql;
USE expediciones;
SOURCE sql/dw8_semilla.sql;
```

`root@localhost` es normal en esta sesión. `SOURCE` busca los archivos respecto a la carpeta desde la que abriste el cliente, por eso hemos hecho `cd ~/proyecto`. Si hay errores de importación, resuélvelos antes de continuar.

Si ya tenías tablas llamadas `producto` o `categoria_producto` de otro trabajo, comprueba que sean estas antes de cargar la semilla. `CREATE TABLE IF NOT EXISTS` no transforma una tabla antigua con otra estructura. No borres tablas ajenas para resolver una incompatibilidad.

#### Paso 4 · Entender las dos tablas

`categoria_producto` contiene `id` y `nombre`. `producto` contiene `id`, `nombre`, `descripcion`, `precio`, `stock` y `categoria_id`. Cada producto pertenece a una categoría existente.

`categoria_id` es una clave foránea: almacena el ID, no el nombre de la categoría. MariaDB impide insertar un ID de categoría inexistente. El precio usa `DECIMAL(8,2)`: hasta seis cifras enteras y dos decimales, sin usar un tipo de coma flotante para almacenarlo. Permitiremos precios desde 0.00 hasta 999999.99 y stock entero de 0 a 9999.

Con la semilla:

| ID | Producto | Precio | Stock | Categoría |
|---|---|---:|---:|---|
| 1 | Cuaderno | 2.50 | 12 | Papelería |
| 2 | Mochila | 24.90 | 5 | Accesorios |
| 3 | Lámpara | 18.00 | 0 | Electrónica |
| 4 | Auriculares | 35.50 | 8 | Electrónica |
| 5 | Estuche "Azul" <Mini> | 6.75 | 3 | Papelería |

Existe además la categoría Hogar, sin productos. Hay 5 productos y 28 unidades de stock. Estos resultados se refieren a la semilla recién cargada; cambiarán cuando añadas productos.

#### Paso 5 · Reutilizar la cuenta de DW2

En la sesión administradora:

```sql
SELECT User, Host FROM mysql.user WHERE User = 'app';
```

Si no existe `app@localhost`, créala como en DW2, sustituyendo la clave de ejemplo:

```sql
CREATE USER 'app'@'localhost' IDENTIFIED BY 'una-clave-larga';
GRANT SELECT, INSERT, UPDATE, DELETE ON expediciones.* TO 'app'@'localhost';
SHOW GRANTS FOR 'app'@'localhost';
```

Si ya existe, conserva su contraseña y consulta sus permisos con `SHOW GRANTS FOR 'app'@'localhost';`. El permiso sobre `expediciones.*` cubre las tablas nuevas. Si faltan esos cuatro permisos, el administrador puede concederlos con el GRANT anterior. No se necesita `FLUSH PRIVILEGES`.

La cuenta de la aplicación debe tener esos cuatro permisos de datos, sin DROP, permisos administrativos ni roles que los concedan. Si la cuenta dedicada de prácticas tiene permisos adicionales, revísalos antes de usarla; no cambies cuentas compartidas con otras aplicaciones. No ejecutes PHP con la cuenta root.

#### Paso 6 · Comprobar con la cuenta de aplicación

Como administrador, prepara una tabla vacía para la prueba de permisos y sal:

```sql
CREATE TABLE IF NOT EXISTS expediciones.dw8_prueba_permisos (id INT);
exit;
```

En el terminal, sin sudo:

```bash
cd ~/proyecto
mkdir -p documentacion
mariadb -h localhost -u app -p expediciones
```

Escribe la contraseña cuando se solicite. El último argumento selecciona directamente `expediciones`. Crear `app` no cambia la identidad de la sesión de root: por eso es necesario salir y conectarse otra vez.

Dentro de MariaDB como `app`:

```sql
SELECT CURRENT_USER();
SELECT DATABASE();
SHOW GRANTS FOR CURRENT_USER;
SELECT COUNT(*) AS productos FROM producto;
DROP TABLE dw8_prueba_permisos;
exit;
```

Se espera `app@localhost`, base `expediciones`, recuento 5 y rechazo del DROP. Si el DROP funciona, revisa los permisos: no es el resultado correcto. No pruebes a borrar una tabla real del proyecto.

Elimina la tabla de prueba como administrador:

```bash
sudo mariadb expediciones
```

```sql
DROP TABLE IF EXISTS dw8_prueba_permisos;
exit;
```

El archivo de evidencia contiene las consultas y sus resultados. No registres contraseñas en él.

## 2. Conectar PHP con MariaDB

### Qué es la conexión

`new PDO(...)` crea un objeto que representa una conexión. Lo guardamos en `$db` y lo pasamos a las funciones que necesitan consultar. La variable no contiene todas las filas de la base: sirve para enviarle operaciones.

El DSN (Data Source Name) indica el controlador, el servidor, la base y la codificación:

```text
mysql:host=localhost;dbname=expediciones;charset=utf8mb4
```

Usamos `mysql:` también con MariaDB. En Linux, `localhost` suele usar el socket local; `127.0.0.1` fuerza TCP. Si cambias el entorno o el servidor es remoto, adapta tanto el DSN como la cuenta y los permisos de conexión.

| Opción | Para qué la fijamos |
|---|---|
| `PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION` | Una operación SQL fallida lanza una excepción que podemos tratar. |
| `PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC` | Cada fila se recupera con claves de columna, sin índices numéricos duplicados. |
| `PDO::ATTR_EMULATE_PREPARES => false` | El controlador usa las consultas preparadas nativas cuando están disponibles. |

En PHP 8, el modo de errores por defecto ya es el de excepciones. Lo fijamos explícitamente para dejar claro el comportamiento; quitar la opción no demuestra por sí solo que los errores se silencien. Para comparar modos en una prueba, configura expresamente el modo alternativo y restaura después la configuración.

### En directo · G2 · Conexión con respuesta HTML

**Enunciado:** centraliza la conexión en `src/bd.php` y crea una página que indique si pudo conectarse sin publicar contraseñas ni detalles internos del error.

**Paso 1. Reutiliza la configuración de DW2.** Conserva `config/credenciales.php` con sus cuatro claves: `servidor`, `base`, `usuario` y `clave`. No sobrescribas la contraseña que ya utilizas. Crea o adapta `config/credenciales.php.ejemplo` con la misma estructura, pero con una contraseña ficticia:

**Archivo completo:** `config/credenciales.php.ejemplo`.

```php
<?php
return [
    'servidor' => 'localhost',
    'base' => 'expediciones',
    'usuario' => 'app',
    'clave' => 'CAMBIA_ESTA_CLAVE_LOCAL',
];
```

Si todavía no tienes el archivo real, copia el `.ejemplo` a `config/credenciales.php` y escribe allí la contraseña elegida en G1. PHP carga el archivo real; el `.ejemplo` es una plantilla para otras personas y no debe contener tu contraseña.

Añade `/config/credenciales.php` al `.gitignore`. El archivo `.ejemplo` sí se sube. Si el archivo real ya estaba versionado, añadirlo al `.gitignore` no lo retira del seguimiento ni borra secretos de su historial.

**Paso 2. Centraliza la conexión y construye el DSN.** La configuración mantiene separados el servidor y la base, como en DW2. Dentro de `conectar()` los unimos al prefijo `mysql:` y a la codificación. No necesitas añadir una clave `dsn` al archivo de credenciales.

**Archivo completo:** `src/bd.php`.

```php
<?php
declare(strict_types=1);

function conectar(): PDO
{
    $cfg = require __DIR__ . '/../config/credenciales.php';

    // Construir el DSN a partir de la configuración de DW2.
    $dsn = 'mysql:host=' . $cfg['servidor']
         . ';dbname=' . $cfg['base']
         . ';charset=utf8mb4';

    return new PDO($dsn, $cfg['usuario'], $cfg['clave'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
}
```

**Paso 3. Crea la página de prueba.** `try` contiene la operación que puede fallar. `catch` recoge una excepción de PDO: respondemos con 500, registramos el detalle y mostramos un mensaje general.

**Archivo completo:** `public/DW8/g2.php`.

```php
<?php
declare(strict_types=1);
require __DIR__ . '/../../src/funciones.php';
require __DIR__ . '/../../src/bd.php';
$mensaje = 'Conexión establecida correctamente.';
try {
    $db = conectar();
} catch (PDOException $e) {
    http_response_code(500);
    error_log($e->getMessage());
    $mensaje = 'No se ha podido conectar con la base de datos.';
}
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>G2 · Conexión</title></head>
<body><h1>Conexión</h1><p><?= h($mensaje) ?></p></body>
</html>
```

**Comprueba:** abre la página. Cambia temporalmente el nombre de la base por uno inexistente: debe aparecer el mensaje general y un estado 500. Restaura la configuración. El detalle se consulta en el registro del servidor o el terminal del servidor integrado.

## 3. Recuperar datos y generar HTML

### Qué significa la flecha `->`

`$db` es un objeto PDO que representa una conexión. `->` permite llamar a un método de ese objeto: `$db->query(...)` ejecuta su método `query()`. Una función como `h($texto)` se llama directamente; un método pertenece a un objeto.

```php
$consulta = $db->query('SELECT id, nombre FROM producto ORDER BY id');
$productos = $consulta->fetchAll();
```

`query()` devuelve un objeto `PDOStatement`. `fetchAll()` obtiene sus filas como un array. Con `FETCH_ASSOC`, cada fila es un array asociativo: `$productos[0]` es un producto y `$productos[0]['nombre']` es su nombre. Si no hay filas, el resultado es `[]`.

Una consulta no convierte el archivo PHP en una página automáticamente: tú recorres los resultados y construyes HTML con las mismas herramientas de DW6. Los datos de la base también se escapan con `h()` al mostrarlos.

### En directo · G3 · Catálogo con precio y stock

**Enunciado:** consulta los productos y muestra nombre, precio y stock en una tabla HTML. Incluye un mensaje si la colección está vacía y otro diferente si falla el acceso a datos.

**Paso 1. Crea el archivo acumulativo de funciones.** La consulta es fija, sin entradas del usuario; por eso podemos usar `query()`.

**Archivo completo:** `src/productos_bd.php`.

```php
<?php
declare(strict_types=1);

function listar_productos(PDO $db): array
{
    $consulta = $db->query(
        'SELECT id, nombre, descripcion, precio, stock, categoria_id
         FROM producto ORDER BY id'
    );
    return $consulta->fetchAll();
}
```

**Archivo completo:** `public/DW8/g3.php`.

```php
<?php
declare(strict_types=1);
require __DIR__ . '/../../src/funciones.php';
require __DIR__ . '/../../src/bd.php';
require __DIR__ . '/../../src/productos_bd.php';
$productos = [];
$error = '';
try {
    $db = conectar();
    $productos = listar_productos($db);
} catch (PDOException $e) {
    http_response_code(500);
    error_log($e->getMessage());
    $error = 'No se pudo cargar el catálogo.';
}
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>G3 · Catálogo</title></head>
<body>
<h1>G3 · Catálogo</h1>
<?php if ($error !== ''): ?>
    <p role="alert"><?= h($error) ?></p>
<?php elseif ($productos === []): ?>
    <p>No hay productos que mostrar.</p>
<?php else: ?>
    <p>Resultados: <?= count($productos) ?></p>
    <table>
        <thead><tr><th>Nombre</th><th>Precio</th><th>Stock</th></tr></thead>
        <tbody>
        <?php foreach ($productos as $p): ?>
            <tr>
                <td><a href="/DW8/g4.php?id=<?= (int) $p['id'] ?>"><?= h($p['nombre']) ?></a></td>
                <td><?= h((string) $p['precio']) ?> €</td>
                <td><?= (int) $p['stock'] ?></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>
<?php endif; ?>
</body>
</html>
```

**Paso 2. Ejecuta:** deben aparecer 5 productos. El enlace a la ficha se resolverá al completar G4. El nombre `Estuche "Azul" <Mini>` debe mostrarse literalmente, no como HTML.

**Paso 3. Prueba el vacío sin borrar filas:** añade temporalmente `WHERE 1 = 0` antes de `ORDER BY` en la consulta. Aparecerá el mensaje de vacío. Restaura después el SQL.

## 4. Una fila: ficha de producto

`fetch()` recupera la siguiente fila; si no hay ninguna devuelve `false`. Nuestra función traducirá ese `false` a `null`, para devolver `?array` y expresar claramente «producto inexistente».

Una entrada como `id=abc` es un identificador mal formado: 400. Un entero positivo sin producto asociado produce 404. Un fallo de base de datos produce 500. Son situaciones distintas.

### En directo · G4 · Ficha por ID

**Enunciado:** consulta un producto por su ID y muestra su nombre, descripción, precio y stock. Valida el ID antes de consultar.

**Paso 1. Añade esta función a `src/productos_bd.php`.**

**Añadir al archivo existente:** `src/productos_bd.php`.

```php
function producto_por_id(PDO $db, int $id): ?array
{
    $consulta = $db->prepare(
        'SELECT id, nombre, descripcion, precio, stock, categoria_id
         FROM producto WHERE id = ?'
    );
    $consulta->execute([$id]);
    $producto = $consulta->fetch();
    if ($producto === false) {
        return null;
    }
    return $producto;
}
```

**Archivo completo:** `public/DW8/g4.php`.

```php
<?php
declare(strict_types=1);
require __DIR__ . '/../../src/funciones.php';
require __DIR__ . '/../../src/bd.php';
require __DIR__ . '/../../src/productos_bd.php';
$recibido = $_GET['id'] ?? '';
$id = is_string($recibido) ? filter_var($recibido, FILTER_VALIDATE_INT) : false;
$producto = null;
$error = '';
if ($id === false || $id < 1) {
    http_response_code(400);
    $error = 'El ID debe ser un entero positivo.';
} else {
    try {
        $db = conectar();
        $producto = producto_por_id($db, $id);
        if ($producto === null) {
            http_response_code(404);
            $error = 'El producto no existe.';
        }
    } catch (PDOException $e) {
        http_response_code(500);
        error_log($e->getMessage());
        $error = 'No se pudo consultar el producto.';
    }
}
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>G4 · Ficha de producto</title></head>
<body>
<h1>G4 · Ficha de producto</h1>
<?php if ($error !== ''): ?>
    <p><?= h($error) ?></p>
<?php elseif ($producto !== null): ?>
    <h2><?= h($producto['nombre']) ?></h2>
    <p><?= h($producto['descripcion']) ?></p>
    <p>Precio: <?= h((string) $producto['precio']) ?> €</p>
    <p>Stock: <?= (int) $producto['stock'] ?></p>
    <p><?= (int) $producto['stock'] > 0 ? 'Disponible' : 'Agotado' ?></p>
<?php endif; ?>
<p><a href="/DW8/g3.php">Volver al catálogo</a></p>
</body>
</html>
```

**Paso 2. Prueba:** `id=1` → 200; `id=99999` → 404 si no existe; `id=abc`, `id=0` o ausencia de ID → 400. Comprueba los códigos en la pestaña Red.

**Antes de seguir:** explica qué contiene cada variable: `$db`, `$consulta` y `$producto`. No representan lo mismo: conexión, consulta y fila recuperada.

## 5. Consultas preparadas y buscador

### Preparar, ejecutar y recuperar

```php
$consulta = $db->prepare('SELECT nombre FROM producto WHERE id = ?');
$consulta->execute([$id]);
$fila = $consulta->fetch();
```

`prepare()` recibe SQL con un marcador. `execute()` recibe los valores en un array, en el mismo orden que las interrogaciones. `fetch()` recupera una fila. `execute()` no devuelve la fila.

No escribas `'?'` entre comillas: el marcador no es un texto literal. Con dos marcadores, envía dos valores. También puedes usar nombres como `:precio` con un array asociativo; no mezcles ambos estilos en una consulta.

Los parámetros son valores. No sustituyen nombres de tabla o columna: si el usuario elige una columna de ordenación, comprueba la elección contra una lista cerrada de columnas permitidas antes de construir ese fragmento.

### En directo · G5 · Buscar productos por nombre

**Enunciado:** recibe `q` mediante GET, busca nombres que lo contengan y conserva el texto en el formulario.

En LIKE, `%` significa cualquier secuencia. Construimos `%texto%` como parámetro, no concatenando el texto dentro de la sentencia SQL. En este buscador `%` y `_` escritos por el usuario conservan su significado de comodines; buscar esos signos de forma literal requeriría un tratamiento adicional.

**Añadir al archivo existente:** `src/productos_bd.php`.

```php
function buscar_productos(PDO $db, string $texto): array
{
    $consulta = $db->prepare(
        'SELECT id, nombre, descripcion, precio, stock, categoria_id
         FROM producto WHERE nombre LIKE ? ORDER BY id'
    );
    $consulta->execute(['%' . trim($texto) . '%']);
    return $consulta->fetchAll();
}
```

**Archivo completo:** `public/DW8/g5.php`.

```php
<?php
declare(strict_types=1);
require __DIR__ . '/../../src/funciones.php';
require __DIR__ . '/../../src/bd.php';
require __DIR__ . '/../../src/productos_bd.php';
$texto = $_GET['q'] ?? '';
$texto = is_string($texto) ? trim($texto) : '';
$productos = [];
$error = '';
try {
    $db = conectar();
    $productos = buscar_productos($db, $texto);
} catch (PDOException $e) {
    http_response_code(500);
    error_log($e->getMessage());
    $error = 'No se pudo realizar la búsqueda.';
}
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>G5 · Buscar productos</title></head>
<body>
<h1>G5 · Buscar productos</h1>
<form method="get" action="/DW8/g5.php">
    <p><label for="q">Nombre</label>
    <input id="q" name="q" value="<?= h($texto) ?>">
    <button type="submit">Buscar</button></p>
</form>
<?php if ($error !== ''): ?>
    <p role="alert"><?= h($error) ?></p>
<?php elseif ($productos === []): ?>
    <p>No hay productos que mostrar.</p>
<?php else: ?>
    <p>Resultados: <?= count($productos) ?></p>
    <table>
        <thead><tr><th>Nombre</th><th>Precio</th><th>Stock</th></tr></thead>
        <tbody>
        <?php foreach ($productos as $p): ?>
            <tr>
                <td><a href="/DW8/g4.php?id=<?= (int) $p['id'] ?>"><?= h($p['nombre']) ?></a></td>
                <td><?= h((string) $p['precio']) ?> €</td>
                <td><?= (int) $p['stock'] ?></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>
<?php endif; ?>
</body>
</html>
```

**Pruebas:** vacío → 5; `cuaderno` → 1 con la intercalación de la semilla; `zzzz` → 0; comillas dobles → el estuche; una comilla simple → ningún error SQL. Comprueba siempre datos y comportamiento, no solo si la página carga.

## 6. Filtrar en SQL y validar un importe

La base puede seleccionar las filas necesarias antes de enviarlas a PHP. Así evitas cargar una colección completa para descartar la mayoría después. Los índices y la consulta también influyen en el rendimiento; usar SQL no hace rápida automáticamente cualquier consulta.

### Precio decimal: una diferencia respecto a los enteros

Para el precio admitiremos punto o coma decimal, hasta dos decimales y un máximo de seis cifras enteras. No aceptaremos separadores de miles, números negativos ni notación como `1e3`. La entrada se normaliza a una cadena con punto y dos decimales, adecuada para DECIMAL: `12,5` se transforma en `12.50`.

El siguiente apoyo resuelve la lectura del importe. No necesitas memorizar la expresión regular para comprender PDO. Se evita convertir a float para validar o construir el valor almacenado.

**Archivo completo:** `src/precio_producto.php`.

```php
<?php
declare(strict_types=1);

function normalizar_precio(string $texto): ?string
{
    $texto = str_replace(',', '.', trim($texto));
    if (preg_match('/\A(0|[1-9][0-9]{0,5})(?:\.[0-9]{1,2})?\z/', $texto) !== 1) {
        return null;
    }
    $partes = explode('.', $texto);
    $decimales = $partes[1] ?? '';
    return $partes[0] . '.' . str_pad($decimales, 2, '0');
}
```

Ejemplos: `0` → `0.00`; `6,75` → `6.75`; `12.5` → `12.50`; `-1`, `tres`, `1.234` y `1000000` → `null`. No confundas un precio de cero con un error.

### En directo · G6 · Precio máximo y productos con stock

**Enunciado:** muestra productos con precio menor o igual al máximo indicado y, opcionalmente, solo los que tengan stock. Un máximo vacío significa que no se aplica ese filtro. Una entrada incorrecta debe producir 400 y no ejecutar la consulta.

**Paso 1. Añade la función de consulta.** Recibe `null` o un precio ya normalizado; no interpreta directamente GET.

**Añadir al archivo existente:** `src/productos_bd.php`.

```php
function filtrar_productos(PDO $db, ?string $precio_maximo, bool $con_stock): array
{
    $sql = 'SELECT id, nombre, descripcion, precio, stock, categoria_id
            FROM producto WHERE 1 = 1';
    $parametros = [];
    if ($precio_maximo !== null) {
        $sql .= ' AND precio <= ?';
        $parametros[] = $precio_maximo;
    }
    if ($con_stock) {
        $sql .= ' AND stock > 0';
    }
    $sql .= ' ORDER BY precio, id';
    $consulta = $db->prepare($sql);
    $consulta->execute($parametros);
    return $consulta->fetchAll();
}
```

`WHERE 1 = 1` es una condición siempre cierta que permite añadir cada filtro con AND. `.=` añade texto a la cadena y `$parametros[]` añade un valor al array. Los fragmentos SQL son fijos del programa; el valor externo se envía por separado.

**Paso 2. Conecta GET con la validación y la consulta.**

**Archivo completo:** `public/DW8/g6.php`.

```php
<?php
declare(strict_types=1);
require __DIR__ . '/../../src/funciones.php';
require __DIR__ . '/../../src/bd.php';
require __DIR__ . '/../../src/productos_bd.php';
require __DIR__ . '/../../src/precio_producto.php';
$recibido = $_GET['maximo'] ?? '';
$texto_maximo = is_string($recibido) ? trim($recibido) : '';
$precio_maximo = null;
$con_stock = isset($_GET['stock']);
$productos = [];
$error = '';
if (!is_string($recibido)) {
    $error = 'El precio máximo debe ser un valor de texto.';
} elseif ($texto_maximo !== '') {
    $precio_maximo = normalizar_precio($texto_maximo);
    if ($precio_maximo === null) {
        $error = 'Introduce un precio de 0 a 999999.99, con hasta dos decimales.';
    }
}
if ($error !== '') {
    http_response_code(400);
} else {
    try {
        $db = conectar();
        $productos = filtrar_productos($db, $precio_maximo, $con_stock);
    } catch (PDOException $e) {
        http_response_code(500);
        error_log($e->getMessage());
        $error = 'No se pudo filtrar el catálogo.';
    }
}
?>
<!doctype html>
<html lang="es">
<head><meta charset="utf-8"><title>G6 · Filtrar catálogo</title></head>
<body>
<h1>G6 · Filtrar catálogo</h1>
<form method="get" action="/DW8/g6.php">
    <p><label for="maximo">Precio máximo (opcional)</label>
    <input id="maximo" name="maximo" inputmode="decimal" value="<?= h($texto_maximo) ?>"></p>
    <p><label><input type="checkbox" name="stock" value="1" <?= $con_stock ? 'checked' : '' ?>> Solo con stock</label></p>
    <p><button type="submit">Filtrar</button></p>
</form>
<?php if ($error !== ''): ?>
    <p role="alert"><?= h($error) ?></p>
<?php elseif ($productos === []): ?>
    <p>No hay productos que mostrar.</p>
<?php else: ?>
    <p>Resultados: <?= count($productos) ?></p>
    <table>
        <thead><tr><th>Nombre</th><th>Precio</th><th>Stock</th></tr></thead>
        <tbody>
        <?php foreach ($productos as $p): ?>
            <tr>
                <td><a href="/DW8/g4.php?id=<?= (int) $p['id'] ?>"><?= h($p['nombre']) ?></a></td>
                <td><?= h((string) $p['precio']) ?> €</td>
                <td><?= (int) $p['stock'] ?></td>
            </tr>
        <?php endforeach; ?>
        </tbody>
    </table>
<?php endif; ?>
</body>
</html>
```

**Comprueba las combinaciones:**

| Máximo | Solo con stock | Resultado con la semilla |
|---|---|---|
| Vacío | No | 5 productos |
| 20 | No | 3 productos |
| Vacío | Sí | 4 productos |
| 20 | Sí | 2 productos |
| 0 | No | 0 productos, sin error |
| `tres` | Cualquiera | 400, sin consulta |

La casilla se interpreta por presencia mediante `isset()`. Por tanto, una URL escrita a mano con `stock=0` también la activa. Ninguno de estos filtros modifica los registros almacenados.
