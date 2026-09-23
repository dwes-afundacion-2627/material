# DW3 · Git y la vía de entrega

**Desenvolvemento web en contorno servidor · 2º DAW · Apuntes**

---

## Al terminar esta unidad vas a saber

- Guardar el historial de tu proyecto y leerlo.
- Entregar: es `push`, y no hay otro camino en todo el curso.
- Dejar fuera del repositorio lo que **nunca** debe subirse: las credenciales.
- Trabajar con ramas y **resolver un conflicto** sin que te entre el pánico.


---

## 1. Qué problema resuelve

Sin control de versiones acabas aquí, y lo sabes:

```
proyecto/
proyecto_v2/
proyecto_v2_bueno/
proyecto_FINAL/
proyecto_FINAL_ESTE_SI/
```

Y el día que algo se rompe no sabes cuál funcionaba ni qué tocaste.

Git guarda **el historial completo**: qué cambió, cuándo y por qué. Y en este módulo
hace además otras tres cosas:

- **Es la entrega.** No hay correo ni aula virtual.
- **Es la evidencia del proceso.** En la defensa relámpago se abre tu historial. Un
  proyecto con un único commit de 900 líneas no enseña cómo se hizo: eso lo cuenta
  una serie de commits pequeños con mensajes claros.
- **Es donde vive la bitácora de prompts**, que va dentro del repositorio como un
  fichero más.

El uso de IA y de cualquier ayuda externa sigue `PROTOCOLO_IA.md`: primero se define
qué demostrar, después se comparte contexto sin secretos, se revisa el `diff` y se
ejecuta una prueba. Copiar una salida no es comprobarla.

---

## 2. Dónde se hace todo esto

**Dentro de la máquina virtual.** El repositorio vive en la VM, junto al código que
sirve Apache. Se maneja desde el **terminal integrado** de VS Code, que ya es un
terminal de Debian.

Si abres una terminal de Windows y haces `git` ahí, estás en otro sitio.

---

## 3. Una vez, y ya

### 3.1 Quién eres

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu.correo@ejemplo.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

- `git config` guarda **ajustes**. `--global` los guarda para tu usuario de Debian
  entero, en `~/.gitconfig`, y no para un solo proyecto: por eso se hace una vez.
- `user.name` y `user.email` son **la identidad de autor** que Git graba en cada
  commit. No son una cuenta, ni una contraseña, ni una firma criptográfica: son texto
  que tú declaras, y se pueden poner mal. Usa el correo de tu cuenta de GitHub (o la
  dirección privada `…@users.noreply.github.com` que te da GitHub).
- `init.defaultBranch main` dice cómo se llamará la **rama** principal de los
  repositorios que crees con `git init`. Una rama es una línea de trabajo; la
  principal se llama `main` por convenio. Tu proyecto se clona y ya trae la suya.
- `pull.rebase false` dice qué hace `git pull` cuando tu rama y la de GitHub tienen
  commits distintos: **juntarlas con una fusión**. Sin este ajuste, Git se para con
  `fatal: Need to specify how to reconcile divergent branches`.

### 3.2 Una clave para GitHub, **creada en Debian**

La clave de DW2 va **de Windows a tu VM**, y su parte privada está en Windows. Aquí
quien llama es **la VM**, que tiene que conectarse a GitHub, así que necesita una
pareja propia. Son dos recorridos distintos:

```
Windows  ──clave de DW2──>  tu VM Debian  ──clave nueva, de DW3──>  GitHub
```

La alternativa —reenviar el agente de claves de Windows— existe, pero añade una pieza
más que puede fallar. **En este curso se usan dos parejas**, y no se copia nunca una
clave privada de una máquina a otra.

Dentro de la VM:

```bash
ssh-keygen -t ed25519 -C "debian-a-github"     # Enter en las tres preguntas
cat ~/.ssh/id_ed25519.pub                      # esta es la PÚBLICA: una sola línea
```

**Enter en las tres preguntas** significa: fichero por defecto y **sin frase de
paso**. Es una decisión del curso para no añadir otra pieza (el agente de claves).
Esa clave da acceso a tu cuenta de GitHub: la VM es tuya, no se comparte, y la parte
privada (`id_ed25519`, sin `.pub`) no se copia a ningún sitio.

> Si dice `id_ed25519 already exists. Overwrite (y/n)?`, contesta **`n`** y usa la que
> tienes: sobrescribirla rompería cualquier acceso que ya dependiera de ella.

Se copia esa línea entera y se pega en GitHub → *Settings* → *SSH and GPG keys* →
*New SSH key*, con tipo **Authentication key**.

Y se comprueba, **desde el terminal de Debian**:

```bash
ssh -T git@github.com
```

**La primera vez** pregunta *Are you sure you want to continue connecting
(yes/no/[fingerprint])?*: Debian todavía no conoce a GitHub. Compara la huella que
enseña con la que publica GitHub en su documentación (*GitHub's SSH key
fingerprints*) y, si coincide, escribe `yes`. No se acepta una huella sin mirarla.

Tiene que contestar `Hi tuusuario! You've successfully authenticated, but GitHub does
not provide shell access.` Esa segunda parte es lo esperado: GitHub te reconoce, pero
no te deja abrir un terminal allí. La orden devuelve un código de error (1) aunque
todo esté bien.

Si contesta *Permission denied (publickey)*: la clave pública no está pegada en
GitHub, estás en Windows en vez de en la VM, la generaste con otro nombre de fichero
o con otro usuario de Debian, o la pegaste en otra cuenta. Autenticarte bien tampoco
garantiza acceso a tu repositorio: para eso hay que aceptar la invitación (apartado 5).

---

## 4. Las cinco órdenes

```bash
git status                                 # ¿en qué situación estoy?
git add public/index.php                   # preparar el contenido que quiero versionar
git commit -m "Mostrar las misiones en el tablón"  # registrar una versión, con un mensaje
git log --oneline                          # ver las versiones registradas
git diff                                   # ver lo que he cambiado y aún no he preparado
```

`git status` es la que más se usa y la que nunca sobra: dice en qué rama estás, qué
ficheros has tocado, cuáles están preparados y qué orden te toca. **Ante la duda,
`git status`.**

> **Orden obligatorio: el `.gitignore` se amplía antes del primer `git add`.** Está en
> el apartado 6, y el motivo es el del propio apartado: borrar un fichero en un
> commit posterior no lo borra de los anteriores. Léelo antes de preparar nada.

### Guardar no es versionar

Son dos cosas distintas y aquí se confunden siempre:

| Acción | Qué hace |
|---|---|
| **Guardar en el editor** (`Ctrl+S`) | Escribe el fichero en el disco. `git status` ve que ha cambiado, pero todavía no hay ninguna versión registrada |
| `git add` | **Prepara** ese contenido: copia el estado actual del fichero a la zona de preparación |
| `git commit` | **Registra una versión** con todo lo preparado, y le pone mensaje, fecha y autor |
| `git push` | Envía las versiones registradas al repositorio de GitHub |

```
   tu carpeta   ──git add──>   zona de preparación   ──git commit──>   historial
   (guardas)                   (lo que va a entrar)                    (versiones)
```

Esa separación sirve: puedes registrar una versión con dos ficheros terminados y
dejar fuera un tercero que está a medias.

Así lo cuenta `git status --short`, con una columna para lo preparado y otra para lo
que no:

```
$ git status --short
M  src/misiones.php        <- preparado (columna izquierda): entra en el commit
 M public/estilo.css       <- modificado y NO preparado (columna derecha)
?? notas.txt               <- nuevo: Git no lo sigue todavía
```

`git diff` no enseña el contenido de los ficheros nuevos (`??`): todavía no hay
versión con la que compararlos.

`git add .` prepara **todo lo de la carpeta en la que estás**: ficheros nuevos,
modificados y borrados, salvo lo ignorado. No es «subir todo»: es preparar todo. Por
eso, en este curso se prefiere `git add <fichero>`, y **siempre** `git status` antes
del commit para ver qué va a entrar.

> **`git add` prepara una foto, no el fichero.** Si haces `add` y después sigues
> editando, lo que entra en el commit es lo que estaba cuando hiciste `add`. Por eso
> hay dos maneras de mirar los cambios:
>
> - `git diff` — lo que has cambiado y **todavía no has preparado**.
> - `git diff --staged` — lo que está **preparado** y va a entrar en el próximo commit.

### La regla del curso

> **Un commit por cada cosa que funciona.**

No uno al día. No uno al final con todo. Cuando una parte hace lo que debe, commit.

### El mensaje

Tiene que decir **qué hace**, no «cambios».

**Convención del curso: el asunto empieza por un verbo en infinitivo.** No es una
regla de Git —Git acepta cualquier texto—, es la norma de este módulo, para que todo
el historial se lea igual:

| Bien | Mal |
|---|---|
| `Ordenar las misiones del tablón por fecha` | `cambios` |
| `Validar la dificultad en el servidor` | `.` |
| `Corregir las plazas negativas de la reserva` | `asdf` |

- Breve y concreto, sin punto final.
- Si hace falta explicar **por qué**, se añade un cuerpo con un segundo `-m`:
  `git commit -m "Añadir el ejemplo de credenciales" -m "La clave real no sale de la VM."`
- El comprobador de la unidad exige **al menos diez caracteres** y rechaza una lista
  de palabras vacías (`cambios`, `fix`, `wip`…). Es una regla del curso, no de Git, y
  no entiende el significado: el infinitivo no lo comprueba ninguna máquina.

En noviembre se abre tu historial en clase, en la defensa. Un historial con commits
pequeños y mensajes que dicen qué hace cada uno se explica solo.

---

## 5. La vía de entrega

**El repositorio no lo creas tú: ya está creado a tu nombre** dentro de la
organización del curso, a partir de una plantilla. Se llama
`<tarea>-<tu-usuario-de-github>` —por ejemplo `dwes-s1-mlopez`— y te llega por correo
una invitación **a ese repositorio** que hay que aceptar. Si no encuentras el correo,
entra en `https://github.com/<organización>/<tu-repositorio>/invitations`.

La dirección para clonarlo **no se escribe a mano**: en la página del repositorio,
botón verde *Code* → pestaña *SSH* → copiar. Empieza por `git@github.com:`.

**Tu `~/proyecto` de DW2 ya existe**, con el entorno y tu contraseña dentro. No se
borra ni se convierte en repositorio: se aparta como respaldo y se clona en su sitio.
Así la ruta no cambia, y Apache, VS Code y el resto del curso siguen apuntando a
`~/proyecto`:

```bash
cd ~
mv proyecto proyecto-dw2                         # respaldo: no se pierde nada
git clone <la-dirección-que-copiaste> proyecto   # misma ruta que en DW2
cd proyecto
git remote -v                 # comprobar a dónde apunta antes de subir nada
git status                    # limpio: solo lo que trae la plantilla
```

`git clone` se trae el repositorio entero y **deja `origin` ya configurado**: no hay
que hacer `git remote add`. El último argumento, `proyecto`, es el nombre que le das a
la carpeta local.

De `~/proyecto-dw2` solo se traen dos cosas: tu `config/credenciales.php` (apartado
6) y la carpeta `entorno/` (hoja de ejercicios, E3.2). **`public/` no se copia**: la
plantilla ya trae el suyo, y el `index.html` de DW2 taparía su `index.php`, porque
Apache sirve primero el `.html`.

> **Lo que no se hace nunca** es `git init` encima de la carpeta vieja y
> `git remote add`: el repositorio de GitHub ya tiene su propio primer commit venido
> de la plantilla, y juntar dos historias independientes a la fuerza es el camino
> corto a un `push` rechazado.

A partir de ahí:

```bash
git push                      # subir lo que has registrado
git pull                      # traer lo de GitHub y juntarlo con tu rama
```

`origin` es el nombre corto del repositorio remoto y `main`, la rama. Al clonar, tu
`main` ya queda enlazada con la de `origin`, así que basta `git push`. Si ves
`git push -u origin main` en otros sitios, hace lo mismo y además fija ese enlace: no
hace daño repetirlo.

`git pull` no solo descarga: **trae y junta**. Si en GitHub hay commits que tú no
tienes y tú tienes otros que GitHub no tiene, hace una fusión (por el ajuste
`pull.rebase false` del apartado 3), y esa fusión puede dar un conflicto, que se
resuelve como en el apartado 10. Antes de `pull`, `git status` limpio.

El ciclo completo, de memoria:

```
        escribes código
              ↓
         ¿funciona? ──no──> lo arreglas
              ↓ sí
          git add
              ↓
     git commit -m "..."
              ↓
          git push
              ↓
   en GitHub, pestaña Actions: el corrector del sprint
```

El corrector de *Actions* mira el **código del sprint** y la bitácora. El historial
de esta unidad lo compruebas tú con `comprobar_historial.py` (hoja de ejercicios,
E3.8).

**Ensáyalo hasta que salga sin mirar el papel.** Todo el curso se entrega así.

---

## 6. `.gitignore`: lo que NUNCA se sube

Un fichero llamado `.gitignore` en la raíz del repositorio dice qué se ignora. **Tu
repositorio ya trae uno**, de la plantilla. No se sustituye: **se amplía**, dejando lo
que tiene y añadiendo al final lo que falta. Queda así (las líneas con `#` son
comentarios y son opcionales):

```gitignore
# de la plantilla: no se borra nada
datos/misiones.json
vendor/
*.log
.env
config.local.php

# añadido en DW3
config/credenciales.php
node_modules/
.vscode/
datos/*.sqlite
```

- `config/credenciales.php` y `.env`: **contraseñas**. Nunca.
- `vendor/` y `node_modules/`: dependencias. Se reinstalan, no se guardan.
- `.vscode/`: ajustes de tu editor.
- `*.log`, `datos/*.sqlite`, `datos/misiones.json`: datos y registros que genera la
  aplicación al funcionar.

**Lo de las credenciales no es una recomendación.** Tu repositorio es privado, pero si
subes la contraseña de tu base de datos, la has compartido con quien tenga acceso a
él y hay que tratarla como expuesta. Y borrarla en un commit posterior **no la borra
de los anteriores**: el historial sirve justo para eso. Si pasa, lo primero es
**cambiar la contraseña en la base de datos** y lo segundo, avisar al profesor, que es
quien decide qué se hace con el historial.

Ahora se traen tus credenciales de DW2 y se comprueba que Git las ignora **de
verdad**:

```bash
mkdir -p config
cp ~/proyecto-dw2/config/credenciales.php config/
chmod 600 config/credenciales.php
git status                                    # no tiene que aparecer
git check-ignore -v config/credenciales.php   # tiene que decir qué regla lo ignora
git ls-files config/credenciales.php          # NO tiene que decir nada
```

`git status` solo no basta: un fichero que ya estuviera confirmado y sin cambios
tampoco sale ahí. `check-ignore -v` enseña la línea del `.gitignore` que lo excluye, y
`ls-files` dice si Git lo está siguiendo.

La forma correcta de compartir la configuración es subir un **ejemplo sin secretos**:

```php
<?php
// config/credenciales.php.ejemplo   <- este SÍ se sube
return [
    'servidor' => '127.0.0.1',
    'base'     => 'expediciones',
    'usuario'  => 'app',
    'clave'    => 'PON-AQUI-LA-TUYA',
];
```

Quien clone tu repositorio copia el ejemplo a `config/credenciales.php` y pone su
clave **en la copia**. El ejemplo no se toca: nunca lleva una clave real.

> **Ojo con el orden.** `.gitignore` solo afecta a lo que Git **todavía no está
> siguiendo**. Si ya hiciste commit del fichero, añadirlo al `.gitignore` no lo
> saca: `git rm --cached config/credenciales.php` deja tu copia en la carpeta y
> prepara su retirada, que hay que **confirmar con un commit**. Aun así, sigue en los
> commits anteriores. Si solo lo habías **preparado** (sin commit), basta
> `git restore --staged config/credenciales.php`. Por eso el `.gitignore` se amplía
> lo primero.

---

## 7. Leer tu propio historial

```bash
git log --oneline                 # una línea por commit
git log --oneline --graph --all   # con las ramas dibujadas
git show <hash>                   # qué cambió exactamente en ese commit
git show <hash>:src/config.php    # cómo era ese fichero en ese commit
git diff                          # qué he cambiado y todavía no he preparado
git diff --staged                 # qué está preparado y entra en el próximo commit
```

`<hash>` es un marcador: se sustituye por el identificador del commit, los primeros
caracteres que enseña `git log --oneline` al principio de cada línea (suelen ser
siete, pero pueden ser más).

Si una orden llena la pantalla y se queda parada, estás en un **paginador**: se sale
con `q`.

### Revisar antes de integrar

Una revisión pequeña empieza por el cambio, no por todo el proyecto:

```bash
git diff main...mi-rama
```

Los **tres puntos** enseñan lo que se ha confirmado en `mi-rama` desde que se separó
de `main`. Lo que tengas sin commit no sale: primero se confirma y después se revisa.

La persona que revisa busca un riesgo y propone una prueba. Quien escribió el cambio
decide si acepta, modifica o rechaza la sugerencia, explica por qué y prueba antes de
fusionar. En DW3 se hace por parejas en el equipo del propietario, sin cambiar los
permisos del repositorio privado.

---

## 8. Deshacer

| Situación | Orden |
|---|---|
| Quiero descartar lo que he cambiado y **no he preparado** | `git restore fichero.php` (vuelve a lo preparado o, si no había nada preparado, al último commit) |
| Quiero el fichero **exactamente como en el último commit** | `git restore --source=HEAD -- fichero.php` (no toca lo preparado) |
| He hecho `add` y no quería | `git restore --staged fichero.php` (deja tu fichero como está) |
| El mensaje del último commit está mal y **todavía no he hecho `push`** | `git commit --amend --only -m "El bueno"` |
| Quiero ver cómo era un fichero hace tres commits | `git log --oneline`, coger el hash, `git show <hash>:ruta/fichero.php` |

**Cuidado:** los dos `restore` sin `--staged` **borran** los cambios que no estaban en
un commit. No hay papelera.

**`--amend` sustituye el último commit.** Úsalo solo si no lo has subido y siempre con
`--only`: sin esa opción, además del mensaje mete en el commit todo lo que tengas
preparado. Antes, `git status`. Si el commit ya está en GitHub, **se deja como está**:
un mensaje malo no se arregla reescribiendo lo subido (el comprobador tolera uno).

**No hace falta más.** Nada que reescriba commits ya subidos: ni `--amend` después de
`push`, ni `push --force`.

---

## 9. Ramas

Una rama es una línea de trabajo paralela. Sirve para tocar algo sin romper lo que
funciona. **No es otra carpeta**: al cambiar de rama, Git cambia los ficheros de tu
carpeta para que coincidan con esa rama. Por eso se empieza siempre con `git status`
limpio: lo que no está confirmado viaja contigo de una rama a otra, o impide el
cambio.

```bash
git status                                      # limpio, y en main
git switch -c reserva-plazas                    # crear y cambiarme a ella
# ... trabajo, add, commit ...
git switch main                                 # volver
git merge --no-ff -m "Fusionar la rama reserva-plazas" reserva-plazas
git branch -d reserva-plazas                    # borrarla, ya está fusionada
```

**Por qué `--no-ff`.** Si `main` no ha cambiado mientras trabajabas en la rama, Git
puede hacer un **avance rápido** (*fast-forward*): mueve `main` hasta el último commit
de la rama y no deja rastro de que hubo rama. Con `--no-ff` crea siempre un **commit
de fusión**, y el historial conserva la forma:

```
sin --no-ff                       con --no-ff
* c3 Validar las plazas           *   c4 Fusionar la rama reserva-plazas
* c2 Crear la reserva             |\
* c1 Mostrar el tablón            | * c3 Validar las plazas
                                  | * c2 Crear la reserva
                                  |/
                                  * c1 Mostrar el tablón
```

Si la rama no tiene nada nuevo que traer, no hay nada que fusionar: `--no-ff`
contesta `Already up to date` y no crea ningún commit.

El `-m` pone el mensaje. Sin él, Git abre un editor con el mensaje ya escrito
(`nano` en Debian): se guarda con `Ctrl+O`, `Enter`, y se sale con `Ctrl+X`.

En este módulo la usarás de verdad: cada sprint tiene una parte arriesgada —la
transacción, el enrutado propio— que conviene hacer en una rama.

---

## 10. El conflicto

Pasa cuando las dos ramas han hecho **cambios incompatibles** en el mismo sitio. El
caso típico, y el que se practica aquí: las dos cambian **la misma línea** de forma
distinta. Git no adivina cuál quieres, así que para y te lo pregunta.

Esto es un conflicto de verdad, con las salidas reales:

```
$ git merge rama-plazas
Auto-merging mision.php
CONFLICT (content): Merge conflict in mision.php
Automatic merge failed; fix conflicts and then commit the result.

$ git status --short
UU mision.php
```

Y el fichero queda así:

```php
<?php
$titulo = "A torre baixo a tormenta";
<<<<<<< HEAD
$plazas = 5;
=======
$plazas = 8;
>>>>>>> rama-plazas
```

Se lee así:

- Entre `<<<<<<< HEAD` y `=======` está **lo que hay en la rama donde estás**.
- Entre `=======` y `>>>>>>>` está **lo que viene de la otra**.

Se arregla editando el fichero: se deja como tiene que quedar —una de las dos, o una
mezcla— y **se borran las tres líneas de marcas**. Puede haber **varios ficheros** en
conflicto, y varios bloques de marcas en cada uno: `git status` los lista con `UU`, y
se resuelven todos.

```bash
# se edita el fichero, se quitan <<<<<<<, ======= y >>>>>>>
grep -nE '^(<<<<<<<|=======|>>>>>>>)' mision.php   # no tiene que salir nada
php -l mision.php                                   # tiene que ser PHP válido
git add mision.php
git commit -m "Resolver el conflicto: quedan 8 plazas"
```

Y el historial queda con la Y dibujada:

```
$ git log --oneline --graph --all
*   e15d827 Resolver el conflicto: quedan 8 plazas
|\
| * 171df6a Subir las plazas a 8
* | fea5095 Bajar las plazas a 5
|/
* d022be7 Mostrar la primera misión en el tablón
```

**Si te pierdes a mitad**, `git merge --abort` deja todo como estaba antes del
`merge`. Funciona porque se empieza con `git status` limpio.

> **El fallo más caro:** hacer commit **sin quitar las marcas**. El fichero queda con
> `<<<<<<<` dentro, PHP deja de ser válido y la página muere. Antes de commitear un
> conflicto resuelto: el `grep` de arriba y `php -l fichero.php`.
>
> Y lo que ninguna orden comprueba: que el resultado sea **el que querías**. El dibujo
> de `log` demuestra que hubo dos ramas; `php -l`, que la sintaxis es correcta. Que la
> página haga lo que debe se comprueba abriéndola.

---

## Errores típicos

| Síntoma | Qué pasa |
|---|---|
| `Permission denied (publickey)` | La clave pública no está en GitHub, estás en otra máquina, o la clave tiene otro nombre o es de otro usuario (apartado 3.2) |
| `fatal: not a git repository` | No estás dentro de la carpeta del proyecto |
| `rejected … (fetch first)` al hacer push | Hay commits en GitHub que tú no tienes. Con `git status` limpio: `git pull`, resolver si hay conflicto, y `git push` |
| `Permission to … denied` o `403` al hacer push | No es un problema de commits: no tienes permiso en ese repositorio. Mira `git remote -v` y si aceptaste la invitación |
| `fatal: Need to specify how to reconcile divergent branches` | Falta `git config --global pull.rebase false` (apartado 3.1) |
| Se abre una pantalla de texto al hacer `merge` o `commit` | Es el editor, con el mensaje ya escrito: `Ctrl+O`, `Enter`, `Ctrl+X`. Para evitarlo, `-m "mensaje"` |
| `refusing to merge unrelated histories` | Hiciste `git init` en vez de clonar, y hay dos historias distintas. No se fuerza: se clona el repositorio asignado y se copian dentro tus ficheros |
| Subí la contraseña sin querer | **Cámbiala en la base de datos** y avisa al profesor. Borrarla en un commit nuevo no basta: sigue en los anteriores |
| `git status` enseña cientos de ficheros | Falta ampliar el `.gitignore`, y probablemente estás a punto de subir `vendor/` o `node_modules/` |
| El corrector del sprint (pestaña *Actions*) dice que falta la bitácora | `BITACORA_PROMPTS.md` va **dentro** del repositorio, en la raíz, con al menos una entrada completa |

---

## Resumen en una página

```bash
git config --global user.name "..."      # una vez (y user.email, pull.rebase false)
git clone git@github.com:ORG/repo.git    # una vez por proyecto: el tuyo ya existe
git status                               # ¿en qué situación estoy?
git add src/config.php                   # preparar ese fichero
git commit -m "Validar la dificultad en el servidor"   # registrar una versión
git push                                 # entregar
git pull                                 # traer y juntar
git log --oneline --graph --all          # mirar (se sale con q)

git switch -c rama                       # crear una rama y cambiarme a ella
git switch main                          # volver a la principal
git merge --no-ff -m "Fusionar la rama …" rama     # juntar el trabajo de la rama
git branch -d rama                       # borrarla cuando ya está fusionada
```

Cada línea es **una** orden: no se pegan dos en la misma.

- Un commit por cada cosa que funciona, con un mensaje en infinitivo que diga qué hace.
- Credenciales **fuera** del repositorio, y un `.ejemplo` dentro.
- Un conflicto es Git preguntando, no Git rompiéndose. Se editan las líneas, se
  quitan las marcas, `add` y `commit`.
- **Entregar es hacer push.** Lo que no está subido, no está entregado.
