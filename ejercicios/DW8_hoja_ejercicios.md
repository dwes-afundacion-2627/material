# DW8 · Hoja de ejercicios · NO ENTREGABLE

**Acceso a datos con PDO · DWES · 2º DAW**

---

## E8.1 — El tablón, contra la base

**Fichero:** `src/misiones.php`

En `public/tablon.php`, sustituye la lectura del JSON/función de misiones() por esta función que lee de MariaDB:

```php
function cargar_misiones(PDO $db): array
```

Tiene que devolver **la misma forma que antes**: un array de arrays asociativos con
las misiones.

---

## E8.2 — Una misión por su id, y el caso que no existe

**Ficheros:** `src/misiones.php` y `public/ficha.php`

```php
function mision_por_id(PDO $db, int $id): ?array
```

- Consulta que recupera una misión por su id.
- Si no existe, `fetch()` devuelve **`false`**: tradúcelo a `null`.
- En `ficha.php`, la URL `/ficha.php?id=7` enseña la ficha; si no existe, **404** y una
  página que lo diga.

Pruébalo con un id que exista y con `id=99999`. Pega los dos códigos de estado.

> Este apartado es el que separa una aplicación de un montón de páginas. Una web que
> se queda en blanco cuando pides algo que no está, está rota.

---

## E8.3 — Buscar misiones por nombre

**Fichero:** `src/misiones.php`

Añade al tablón un formulario GET para buscar misiones por su nombre (campo `titulo`). Implementa esta función:

```php
function buscar_misiones(PDO $db, string $texto): array
```

Utiliza una consulta preparada con `LIKE` para buscar títulos que contengan el texto introducido y muestra los resultados en `public/tablon.php`.

---

## E8.4 — Los filtros, ahora en SQL

**Fichero:** `src/misiones.php`

```php
function filtrar_misiones(PDO $db, ?string $categoria, bool $solo_libres): array
```

Los mismos dos filtros de DW6, pero ahora **filtra la base de datos**, no PHP.

Comprueba las cuatro combinaciones: sin filtros, solo categoría, solo libres, y las
dos.

---

## E8.5 — El alta, contra la base

**Fichero:** `src/misiones.php`

En `public/nueva_mision.php`, sustituye el guardado en JSON por `anadir_mision()`, que hace un `INSERT` preparado.

- **`validar_mision()` no se toca.** Sigue igual que en DW7: valida y devuelve. Que
  ahora se guarde en otro sitio no es asunto suyo.
- Después del `INSERT`, guarda el `lastInsertId()` y redirige a la ficha de la misión
  recién creada (`/ficha.php?id=ID_NUEVO`).
