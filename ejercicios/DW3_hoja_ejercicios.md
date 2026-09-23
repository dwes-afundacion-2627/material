# DW3 · Hoja de ejercicios

**Git y la vía de entrega · DWES · 2º DAW**
**Semana 2 (22/09 a 24/09) 
---

Al final de esta unidad tienes un repositorio con tu proyecto dentro, subido, y
sabes entregar. **Todo lo que hagas de aquí a febrero se entrega por ahí.**

Lo que comprueba el programa de esta unidad **no es el código**: es el historial.
Mira siete cosas, y están todas en esta hoja. Lo demás que se pide —la bitácora, el
ejemplo de credenciales y el `push`— se comprueba aparte, y también está aquí.

**Mensajes de commit:** verbo en **infinitivo** y qué hace (`Añadir…`, `Validar…`,
`Corregir…`), con al menos diez caracteres. Es la convención del curso, no una regla
de Git: apuntes, apartado 4.

---

## E3.1 — Configurar y conectar

1. Tu identidad y dos ajustes, **dentro de la VM**:

   ```bash
   git config --global user.name "Tu Nombre"
   git config --global user.email "el-correo-de-tu-cuenta-de-GitHub"
   git config --global init.defaultBranch main
   git config --global pull.rebase false
   ```

2. **Dentro de la VM**, genera una pareja de claves nueva para GitHub y pega la
   pública en GitHub (*Settings* → *SSH and GPG keys* → *New SSH key*, tipo
   *Authentication key*):

   ```bash
   ssh-keygen -t ed25519 -C "debian-a-github"     # Enter en las tres preguntas
   cat ~/.ssh/id_ed25519.pub
   ```

   No es la de DW2: aquella va de Windows a tu VM y su parte privada está en Windows.
   Aquí quien llama a GitHub es la VM. En este curso va **sin frase de paso**; por eso
   la parte privada no sale nunca de tu VM.

3. Comprueba, **desde el terminal de Debian**:

   ```bash
   ssh -T git@github.com
   ```

   - La primera vez pregunta si confías en el servidor: compara la huella con la que
     publica GitHub (*GitHub's SSH key fingerprints*) y, si coincide, escribe `yes`.
   - Tiene que saludarte por tu nombre de usuario. La coletilla *GitHub does not
     provide shell access* es lo normal, no un error.

4. Acepta la invitación **a tu repositorio**. Llega por correo; si no la encuentras,
   está en `https://github.com/<organización>/<tu-repositorio>/invitations`.

---

## E3.2 — El repositorio, sin perder lo de DW2

**Tu repositorio ya existe**: está creado a tu nombre en la organización del curso, a
partir de una plantilla. Copia su dirección en GitHub: botón verde *Code* → pestaña
*SSH*.

Tu `~/proyecto` de DW2 **se aparta como respaldo** y el repositorio se clona en su
sitio. Así la ruta no cambia y Apache sigue apuntando al mismo `public/`:

```bash
cd ~
mv proyecto proyecto-dw2
git clone <la-dirección-que-copiaste> proyecto
cd proyecto
git remote -v          # comprueba a dónde apunta ANTES de subir nada
git status             # limpio
```

Si VS Code tenía abierta `~/proyecto`, vuelve a abrirla (*File* → *Open Folder* →
`/home/tuusuario/proyecto`) para que enseñe la carpeta clonada y no la vieja.

**No hagas `git init` encima de la carpeta vieja**: saldrían dos historias
independientes y el `push` acabaría rechazado.

**El primer commit tuyo amplía el `.gitignore`.** Es la forma más sencilla de que la
contraseña no entre nunca.

1. El repositorio **ya trae** un `.gitignore` de la plantilla. **No lo sustituyas**:
   ábrelo (`nano .gitignore`), deja lo que tiene y **añade al final** estas líneas:

   ```gitignore
   config/credenciales.php
   node_modules/
   .vscode/
   datos/*.sqlite
   ```

2. Trae tu fichero de credenciales de DW2, el de verdad:

   ```bash
   mkdir -p config
   cp ~/proyecto-dw2/config/credenciales.php config/
   chmod 600 config/credenciales.php
   ```

3. Y ahora **compruébalo de verdad**:

   ```bash
   git status                                    # NO tiene que aparecer
   git check-ignore -v config/credenciales.php   # tiene que decir qué regla lo ignora
   git ls-files config/credenciales.php          # NO tiene que decir nada
   ```

   Si aparece en `status`, o `check-ignore` no dice nada, el `.gitignore` está mal
   escrito o no está en la raíz del repositorio.

4. Confirma solo el `.gitignore`:

   ```bash
   git add .gitignore
   git commit -m "Ampliar el .gitignore del proyecto"
   ```

5. Trae la carpeta `entorno/` de DW2 y confírmala:

   ```bash
   cp -r ~/proyecto-dw2/entorno .
   git add entorno
   git commit -m "Añadir la comprobación del entorno de DW2"
   ```

**De `~/proyecto-dw2` no se trae nada más.** `public/` no se copia: la plantilla trae
el suyo y el `index.html` de DW2 taparía su `index.php`. El respaldo se queda donde
está.

Comprueba que Apache sigue sirviendo:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost/     # 200
```

Y desde Windows, `http://localhost:8080/config/credenciales.php` sigue dando **404**.

---

## E3.3 — El ejemplo sin secretos

Crea `config/credenciales.php.ejemplo` con la misma forma pero **sin la clave**:

```php
<?php
return [
    'servidor' => '127.0.0.1',
    'base'     => 'expediciones',
    'usuario'  => 'app',
    'clave'    => 'PON-AQUI-LA-TUYA',
];
```

Comprueba que es PHP que devuelve la configuración, no texto suelto:

```bash
php -r '$c = require "config/credenciales.php.ejemplo"; var_dump(is_array($c));'
```

Tiene que decir `bool(true)`. Ese **sí** se sube.

El commit lleva un **cuerpo** que explica **por qué se sube el ejemplo y no el
bueno**. El segundo `-m` es el cuerpo:

```bash
git add config/credenciales.php.ejemplo
git commit -m "Añadir el ejemplo de credenciales sin secretos" \
           -m "Escribe aquí, en una o dos frases, por qué se sube este y no el bueno."
```

---

## E3.4 — La vía de entrega

`origin` ya está puesto por el `clone`, y tu `main` ya sigue a la de GitHub:

```bash
git remote -v                 # tiene que salir tu repositorio, con tu usuario
git push
```

Entra en GitHub y **míralo con tus ojos**. Comprueba tres cosas:

- Están tus commits.
- **No está** `config/credenciales.php`.
- Sí está `config/credenciales.php.ejemplo`.

Después, repite el ciclo entero **tres veces** con cosas pequeñas de verdad de tu
proyecto: `editar → git status → git add <fichero> → git commit -m "…" → git push`.
Hasta que salga sin mirar la hoja.

En la pestaña *Actions* de GitHub verás que cada `push` pasa el corrector del
sprint 1. Mira el código del sprint, que todavía no has hecho, así que ahora saldrá
por debajo de 5: es normal. De ahí solo te interesa, por ahora, la línea de la
bitácora.

---

## E3.5 — Ocho commits que digan algo

Al terminar la unidad tu repositorio necesita **ocho commits como mínimo**, y los
mensajes se revisan.

Un mensaje vale si empieza por un verbo en **infinitivo**, tiene **al menos diez
caracteres** y dice **qué hace**:

| Vale | No vale |
|---|---|
| `Ordenar las misiones del tablón por fecha` | `cambios` |
| `Completar la primera entrada de la bitácora` | `fix` |
| `Añadir la comprobación del entorno de DW2` | `.` |

El comprobador lista con su texto los que no pasan: los de menos de diez caracteres y
los de una lista de palabras vacías (`cambios`, `fix`, `wip`…). **El infinitivo no lo
comprueba ninguna máquina**: es la convención del curso y se ve en la defensa.

**Si un mensaje sale mal:**

- **Todavía no has hecho `push`:** `git commit --amend --only -m "El mensaje bueno"`.
- **Ya está subido:** se deja. No se reescribe lo subido. El comprobador **tolera uno**
  y avisa; con dos o más, esa comprobación sale en `MAL`.

`BITACORA_PROMPTS.md` **ya viene en tu repositorio**, con la plantilla de entrada
dentro. No lo borres ni crees otro: **empieza a rellenarlo desde hoy**. Si has usado
una IA, documentación, buscador o ayuda de otra persona, ahí va.

Lee `PROTOCOLO_IA.md` y completa una primera entrada real: define qué vas a
comprobar, excluye secretos del contexto, revisa el cambio y pega la prueba
ejecutada. Si no hubo ayuda externa, usa la declaración prevista en el protocolo.
**Antes de entregar, la bitácora tiene que tener al menos una entrada completa**: la
revisión por pareja de E3.6 cuenta como tal.

---

## E3.6 — Una rama, revisada y fusionada

Se hace **en este orden**, de arriba abajo. La revisión va **antes** de fusionar.

```bash
git status                     # limpio y en main
git switch -c plazas
nano src/config.php            # cambia 'nombre_app' por el nombre de tu aplicación
php -l src/config.php
git add src/config.php
git commit -m "Personalizar el nombre de la aplicación"
git diff main...plazas         # esto es lo que revisa tu pareja
```

**Revisión por pareja**, en tu equipo: no hace falta dar acceso a tu repositorio.

1. Enséñale `git diff main...plazas`. Los tres puntos enseñan lo que has **confirmado**
   en `plazas`; lo que no tenga commit no sale.
2. La pareja señala **un riesgo concreto** y propone **una prueba** (por ejemplo: «¿se
   ve el nombre nuevo en el tablón?»).
3. Ejecuta la prueba o justifica por qué no corresponde.
4. Anótalo en `BITACORA_PROMPTS.md` como una **entrada** con los campos de la
   plantilla:

   | Campo | Qué pones |
   |---|---|
   | Problema o requisito antes de consultar | El riesgo que señaló la pareja |
   | Contexto compartido y datos excluidos | El `diff`; sin credenciales |
   | Qué pedí o consulté | Revisión por pareja de la rama `plazas` |
   | Qué recibí | El riesgo y la prueba propuesta |
   | Qué cambié yo y por qué | Aceptas, modificas o rechazas, y por qué |
   | Diff o commit revisado | `main...plazas` y el hash de tu commit |
   | Prueba ejecutada y resultado | La prueba y lo que salió de verdad |

5. Confirma la bitácora **en la rama** y después fusiona:

   ```bash
   git add BITACORA_PROMPTS.md
   git commit -m "Registrar la revisión de la rama plazas"
   git switch main
   git merge --no-ff -m "Fusionar la rama plazas" plazas
   git branch -d plazas          # ya está fusionada: se borra
   git log --oneline --graph --all
   ```

**El `--no-ff` importa.** Sin él, si `main` no ha cambiado, Git avanza `main` hasta
tu commit sin crear commit de fusión, y en el historial no queda constancia de que
hubo rama. El comprobador busca esa fusión.

No se corrige el estilo ni se exige aceptar la sugerencia. Se practica justificar una
decisión antes de integrar código.

---

## E3.7 — El conflicto, provocado a propósito

Esta no se salta. **Todo el mundo tiene que haber roto y arreglado un conflicto
antes de octubre**, porque el primero que te salga de verdad te va a salir con la
entrega a medio hacer.

Se hace sobre **una línea concreta**: el `'lema'` de `src/config.php`. Es texto tuyo,
no lo mira ningún corrector y cualquier frase entre comillas es PHP válido.

```bash
git status                     # limpio y en main
git switch -c riesgo
```

Si dice `fatal: a branch named 'riesgo' already exists`, mira con `git branch` qué
ramas tienes y usa otro nombre (`riesgo2`). No borres una rama sin saber qué tiene.

1. En `riesgo`: cambia el texto del `'lema'` por uno. Comprueba y confirma:

   ```bash
   php -l src/config.php
   git add src/config.php
   git commit -m "Proponer otro lema en la rama riesgo"
   ```

2. Vuelve a `main` y cambia **esa misma línea** por **otro** texto distinto:

   ```bash
   git switch main
   nano src/config.php
   php -l src/config.php
   git add src/config.php
   git commit -m "Ajustar el lema en main"
   ```

3. Fusiona:

   ```bash
   git merge --no-ff riesgo
   ```

   Git te va a decir esto:

   ```
   Auto-merging src/config.php
   CONFLICT (content): Merge conflict in src/config.php
   Automatic merge failed; fix conflicts and then commit the result.
   ```

4. `git status`: el fichero sale como `UU src/config.php`.
5. Abre el fichero. Vas a ver las marcas `<<<<<<<`, `=======` y `>>>>>>>`.
6. Déjalo como tiene que quedar y **borra las tres líneas de marcas**.
7. **Comprueba que no queda ninguna marca y que el fichero sigue siendo PHP válido:**

   ```bash
   grep -nE '^(<<<<<<<|=======|>>>>>>>)' src/config.php   # no tiene que salir nada
   php -l src/config.php
   ```

8. Confirma la resolución:

   ```bash
   git add src/config.php
   git commit -m "Resolver el conflicto del lema"
   ```

9. Mira lo que has hecho y borra la rama:

   ```bash
   git log --oneline --graph --all
   git branch -d riesgo
   ```

   Tiene que salir la Y dibujada. Los hashes serán otros: son de tu repositorio.

> Quedarte con una de las dos versiones enteras **es una resolución válida**. No hay
> que inventar una mezcla.
>
> **Si te pierdes a mitad**, `git merge --abort` deja todo como antes del `merge`, y
> vuelves al paso 3.

---

## E3.8 — Comprobarlo tú y entregar

Descarga `comprobar_historial.py` de la carpeta `herramientas/` del repositorio
`material` de la organización del curso y cópialo a
la VM en **`~/herramientas/`**, fuera del repositorio (arrástralo a la ventana de VS
Code conectada, a esa carpeta). Si lo dejas dentro de `~/proyecto`, un `git add .` lo
acabaría subiendo.

```bash
mkdir -p ~/herramientas         # si no existe
cd ~/proyecto
git switch main
git status                      # limpio: lo que no tenga commit no se examina
python3 ~/herramientas/comprobar_historial.py .
```

El `.` del final es un argumento: es **la carpeta que se va a examinar**, y `.`
significa «esta en la que estoy».

Las siete comprobaciones examinan **el último commit de la rama en la que estás** y
los commits de los que viene:

| | Qué mira |
|---|---|
| 1 | Que sea un repositorio de Git con algún commit |
| 2 | **Ocho commits** o más |
| 3 | Que los mensajes digan algo (se tolera uno ya subido) |
| 4 | `.gitignore` en el último commit |
| 5 | **Nada prohibido** en el último commit (`config/credenciales.php`, `.env`, `config.local.php`, `vendor/`, `node_modules/`, `*.log`, `datos/*.sqlite`) y un `.gitignore` que ignore las credenciales |
| 6 | Al menos **una rama fusionada** |
| 7 | Al menos **un conflicto fusionado sin marcas** (ni en la fusión ni ahora) |

Debajo pueden salir líneas `AVISO`. No cuentan, pero dicen algo importante: que no
estás en `main`, que tienes cambios sin confirmar, que hay commits sin subir…

**Lo que el comprobador no mira:** el código, la bitácora, si has hecho `push`, ni
contraseñas subidas en commits antiguos. Siete verdes **no** son la entrega completa.

Si sale algo en `MAL`, se arregla y se vuelve a pasar. **Entregar con el comprobador
en rojo es entregar sabiendo que está mal.**

Con las siete en verde, **entrega**:

```bash
git push
git status -sb                  # "## main...origin/main", sin [ahead N]
git log -1 --oneline            # apunta el hash
```

Abre tu repositorio en GitHub y comprueba que el último commit es **ese mismo
hash**.

---

## Lo que se entrega

Tu unidad está terminada cuando se cumplen las cuatro:

1. Las **siete comprobaciones en verde**, en `main`.
2. `BITACORA_PROMPTS.md` con **al menos una entrada completa**, la de la revisión por
   pareja (la valida el corrector del sprint en la pestaña *Actions*).
3. En GitHub **está** `config/credenciales.php.ejemplo` y **no está**
   `config/credenciales.php`.
4. El último commit que ves en GitHub es **el mismo** que tu `git log -1`.

**Y ya está**: no hay memoria ni capturas.

En la defensa relámpago se abre tu `git log --oneline`. Al empezar se asignan en
privado los commits y el cambio que debes localizar, predecir y comprobar. Con la
regla de un commit por cada cosa que funciona, el historial se explica solo.

---

## Si te sobra tiempo

- `git show <hash>` de un commit normal tuyo: fíjate en qué enseña. Después,
  `git show <hash>:src/config.php` de un commit antiguo: es el fichero tal como era.
  La fusión del conflicto puede no enseñar nada si te quedaste con una versión entera;
  para verla, compárala con uno de sus padres: `git diff <hash>^1 <hash>`.
- Rompe a propósito un fichero **sin hacer `add`** y recupéralo con `git restore
  fichero`. Después prepara un cambio con `add`, edita otra vez y repite: verás que
  vuelve a lo **preparado**, no al último commit. Para eso es
  `git restore --source=HEAD -- fichero`.
- Crea `datos/prueba.sqlite` y usa `git check-ignore -v datos/prueba.sqlite` para ver
  **qué línea** del `.gitignore` lo ignora.
- `git init` desde cero, en un repositorio de juguete **aparte**, nunca dentro de
  `~/proyecto`:

  ```bash
  mkdir ~/pruebas-git && cd ~/pruebas-git
  git init
  echo "hola" > leeme.txt
  git add leeme.txt && git commit -m "Crear el primer fichero de prueba"
  git log --oneline
  ```
