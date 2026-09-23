# Inventario de órdenes · DW2 y DW3

**Desenvolvemento web en contorno servidor (MP0613) · 2º DAW**
**Material del alumnado. Curso 2026/27**

---

Aquí está **todo lo que se teclea** en las dos primeras unidades, explicado por
partes. No es un temario ni hay que estudiárselo: es la página a la que volver
cuando una orden no hace lo que esperabas.

**La regla del módulo: no se copia una orden que no se entiende.** Si una línea de
los apuntes no está aquí y no sabes qué hace, pregunta antes de ejecutarla.

---

## 0. Tres intérpretes distintos, y cómo saber en cuál estás

Lo que escribes no siempre va al mismo sitio. Míralo por el **prompt**:

| Prompt | Dónde estás | Qué entiende | Cómo se sale |
|---|---|---|---|
| `PS C:\Users\...>` | PowerShell, en **tu Windows** | Órdenes de Windows | — |
| `usuario@maquina:~$` | El terminal de **Debian** (por SSH o en la ventana de la VM) | Órdenes de Linux | `exit` |
| `MariaDB [(none)]>` | El cliente de **MariaDB**, dentro de Debian | **SQL**, y termina en `;` | `exit` |

Entrar por SSH no copia nada: **cambia dónde se ejecuta lo que escribes**. Si tienes
dudas de en qué máquina estás, `pwd` (Linux) o `Get-Location` (PowerShell).

## Símbolos que aparecen todo el rato

| Símbolo | Qué significa |
|---|---|
| `~` | Tu carpeta personal. En Debian, `/home/tuusuario` |
| `/` | La raíz del sistema de ficheros de Linux. **Todo** cuelga de ahí |
| `.` | La carpeta en la que estás ahora |
| `..` | La carpeta de arriba |
| `$env:USERPROFILE` | Tu carpeta personal **en Windows**, `C:\Users\tu-usuario` |
| `\|` | **Tubería**: pasa la salida de una orden como entrada de la siguiente |
| `&&` | Encadena: la segunda orden se ejecuta **solo si la primera termina bien** |
| `>` | Manda la salida a un fichero, **borrando** lo que hubiera |
| `>>` | Manda la salida a un fichero, **añadiendo** al final |
| `#` | Comentario: lo que va detrás no se ejecuta |
| `<algo>` | Un **marcador**: se sustituye por tu valor, sin escribir los picos |

## Teclas para salir de un atasco

| Tecla | Cuándo |
|---|---|
| `q` | La pantalla se ha quedado fija enseñando texto (un paginador, como el de `systemctl status`, `git log`, `git diff` o `git show`) |
| `Ctrl+C` | Una orden no termina y quieres recuperar el prompt (`tail -f`, `ping` sin `-c`) |
| `exit` | Cerrar una sesión SSH, salir del cliente de MariaDB o cerrar el terminal |
| `Ctrl+O`, `Enter`, `Ctrl+X` | Guardar y salir en el editor `nano`. Es también el editor que abre Git si haces `commit` o `merge` sin `-m` |

---

## 1. Moverse y mirar

| Orden | Qué hace |
|---|---|
| `pwd` | Dice en qué carpeta estás. **La primera orden cuando algo no aparece** |
| `ls` | Lista lo que hay. `ls -l` con detalles, `ls -a` incluyendo lo oculto |
| `cd carpeta` | Entra. `cd ..` sube, `cd` a secas vuelve a `~` |
| `cat fichero` | Vuelca el contenido de un fichero en pantalla |
| `nano fichero` | Abre un editor sencillo dentro del terminal. Se guarda con `Ctrl+O` y se sale con `Ctrl+X` |
| `mkdir -p a/b/c` | Crea carpetas. `-p` crea las intermedias y no protesta si ya existen |
| `tail -f fichero` | Enseña el final del fichero y **se queda esperando** líneas nuevas. Se sale con `Ctrl+C` |

**Rutas con espacios**: entre comillas. `cd "mis cosas"`.

---

## 2. Administrar el sistema

| Orden | Qué hace |
|---|---|
| `sudo orden` | Ejecuta *esa* orden como administrador. Pide **tu** contraseña, no la de root |
| `su -` | Te conviertes en root del todo. Pide la **contraseña de root**. Se sale con `exit` |
| `apt update` | Refresca la **lista** de paquetes disponibles. **No instala nada** |
| `apt upgrade -y` | Instala las versiones nuevas de lo que ya tienes. `-y` contesta que sí por adelantado |
| `apt install -y paquete` | Instala un paquete |
| `usermod -aG sudo usuario` | Añade un usuario al grupo `sudo`. **No instala `sudo`**: si el programa falta, hay que instalarlo aparte. El cambio de grupo se ve al volver a iniciar sesión |
| `chmod 700 carpeta` | Permisos: `7` para el dueño (leer, escribir, entrar), `0` para el resto |
| `chmod 600 fichero` | El dueño lee y escribe; nadie más ve nada. Lo que necesitan las claves privadas y `credenciales.php` |
| `chmod o+x /home/tuusuario` | Deja que los demás **atraviesen** la carpeta sin poder listarla |
| `stat -c %a fichero` | Dice qué permisos tiene un fichero, en números |
| `free -h` | Memoria. `-h` en unidades legibles (Mi, Gi) |

---

## 3. Servicios

Un **servicio** es un programa que el sistema arranca y mantiene vivo: Apache,
MariaDB, SSH, php-fpm.

| Orden | Qué hace |
|---|---|
| `systemctl status servicio` | Cómo está. Abre paginador: se sale con `q` |
| `systemctl start servicio` | Lo arranca ahora |
| `systemctl stop servicio` | Lo para ahora |
| `systemctl restart servicio` | Lo para y lo vuelve a arrancar: **corta el servicio un instante** |
| `systemctl reload servicio` | Le hace releer la configuración **sin cortar** |
| `systemctl enable servicio` | Que arranque solo al encender la máquina |

`restart` y `reload` no son lo mismo: tras tocar la configuración de Apache basta
`reload`; tras cambiar módulos, hace falta `restart`.

---

## 4. Red

| Orden | Qué hace |
|---|---|
| `ip a` | Lista las interfaces de red y la **IP** de cada una. `lo` es la interna de la propia máquina |
| `ping -c2 destino` | Manda **dos** paquetes y espera respuesta. Sin `-c` no para: `Ctrl+C` |
| `ss -ltn` | Qué puertos están **escuchando** en esta máquina |
| `curl http://localhost/pagina` | Pide una página **sin navegador** y escribe la respuesta |
| `curl -s -o /dev/null -w "%{http_code}\n" URL` | Pide la página, **tira el contenido** (`-o /dev/null`), calla el progreso (`-s`) y escribe solo el **código** de la respuesta (`-w`). `\n` es el salto de línea |

`localhost` significa «esta misma máquina»: **desde la VM** es la VM (puerto 80);
**desde Windows** es Windows, y por eso allí se usa `localhost:8080`, que el reenvío
de puertos lleva al 80 de la VM.

---

## 5. Procesos

| Orden | Qué hace |
|---|---|
| `ps -eo comm` | Lista **todos** los procesos (`-e`) enseñando solo la columna del nombre (`-o comm`) |
| `ps -eo user,pid,ppid,comm` | Lo mismo con cuatro columnas: dueño, número del proceso, número del **padre** y nombre |
| `sort` | Ordena las líneas que le llegan |
| `uniq -c` | Agrupa líneas repetidas **consecutivas** y las cuenta. Por eso va detrás de `sort` |
| `grep texto` | Se queda con las líneas que contienen ese texto |
| `grep -E "apache\|php"` | `-E` activa expresiones regulares, y ahí `\|` significa **o** |

La orden entera de los apuntes se lee de izquierda a derecha:

```bash
ps -eo comm | sort | uniq -c | grep -E "apache|php"
```

«Lista los nombres de todos los procesos, ordénalos, cuenta cuántos hay de cada uno
y enséñame solo los de Apache o PHP.»

**El número que sale no es el dato**: cuántos procesos haya depende de la máquina y
del momento, y los PID no coinciden entre equipos. Lo que se compara son **qué
familias de procesos aparecen** y lo que dice la SAPI.

---

## 6. SSH y claves

| Orden | Qué hace |
|---|---|
| `ssh -p 2222 usuario@localhost` | Se conecta. `-p` es el puerto, antes de la `@` la cuenta, después la máquina |
| `exit` | Cierra la sesión remota y te devuelve a donde estabas |
| `ssh-keygen -t ed25519 -C "para-qué-es"` | Crea una **pareja** de claves. `-t` el tipo, `-C` una etiqueta para reconocerla |
| `ssh -T git@github.com` | Comprueba la identidad contra GitHub sin abrir sesión. La primera vez pide confirmar la **huella** del servidor: se compara con la que publica GitHub antes de escribir `yes`. Termina diciendo que GitHub *does not provide shell access*: es lo esperado |
| `ssh-keygen -R "[localhost]:2222"` | Olvida la huella guardada de esa máquina. Se usa al reinstalar o importar la VM |

**Una pareja son dos ficheros**: `id_ed25519` (**privada**, no sale nunca de su
máquina) e `id_ed25519.pub` (**pública**, se copia al sitio donde quieres entrar). El
servidor guarda las públicas que acepta en `~/.ssh/authorized_keys`.

**Quién llama a quién decide dónde se crea la pareja:**

```
Windows  ──clave de DW2──>  tu VM Debian  ──clave de DW3──>  GitHub
```

Por eso son **dos parejas**: en DW2 quien llama es Windows; en DW3, la VM.

Si `ssh-keygen` avisa de que el fichero ya existe, **contesta `n`**: sobrescribir una
clave te deja fuera de todos los sitios donde la hubieras puesto.

Los permisos importan: `~/.ssh` en `700` y `authorized_keys` en `600`. Si están más
abiertos, el servidor **ignora** el fichero y sigue pidiendo contraseña.

---

## 7. Apache

| Orden | Qué hace |
|---|---|
| `a2enmod modulo` / `a2dismod modulo` | Activa / desactiva un **módulo** (una pieza dentro de Apache) |
| `a2ensite sitio` / `a2dissite sitio` | Activa / desactiva un **sitio** (un fichero de `sites-available`) |
| `a2enconf x` / `a2disconf x` | Activa / desactiva un trozo suelto de **configuración** |
| `apache2ctl configtest` | Comprueba la configuración **sin aplicarla**. Tiene que decir `Syntax OK` |
| `apache2ctl -S` | Enseña qué sitios hay activos y cuál es el `DocumentRoot` de cada uno |

**Ninguno de los cuatro primeros aplica nada por su cuenta**: después hay que
`reload` o `restart`. Y antes de recargar, siempre `configtest`: si la configuración
tiene un fallo, Apache puede no volver a arrancar.

**Módulos incompatibles.** `mpm_prefork` y `mpm_event` son dos formas de que Apache
reparta el trabajo, y solo puede haber una activa. El módulo de PHP integrado
necesita `prefork`; php-fpm trabaja con `event`. Por eso cada camino del apartado 5
de DW2 empieza desactivando lo del otro.

---

## 8. MariaDB

| Orden | Qué hace |
|---|---|
| `sudo mariadb` | Entra como administrador de la base de datos. **Cambia de intérprete**: a partir de ahí se escribe SQL |
| `mariadb-secure-installation` | Asistente de ajustes de seguridad. Las respuestas concretas están en los apuntes: no es «Enter a todo» |
| `CREATE DATABASE x CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;` | Crea la base. La **codificación** dice qué letras admite; la **colación**, cómo se ordena y compara el texto |
| `CREATE USER 'app'@'localhost' IDENTIFIED BY '...';` | Crea una cuenta que solo vale conectando **desde la propia máquina** |
| `GRANT SELECT, INSERT, UPDATE, DELETE ON base.* TO 'app'@'localhost';` | Le da cuatro permisos sobre todas las tablas de esa base |
| `SHOW GRANTS FOR 'app'@'localhost';` | Enseña los permisos que tiene **de verdad**. Es lo que hay que leer |
| `exit` | Sale del cliente y vuelve al terminal de Linux |

**`FLUSH PRIVILEGES` no hace falta** después de `CREATE USER` o `GRANT`: solo se
necesita cuando se tocan a mano las tablas de permisos.

**El root de MariaDB no es el root de Linux.** Se llaman igual y son dos cuentas de
dos sistemas distintos.

---

## 9. Git

| Orden | Qué hace |
|---|---|
| `git config --global user.name "..."` | La **identidad de autor** que se graba en cada commit (texto declarado, no una firma criptográfica). `--global` = para todos tus repositorios |
| `git config --global pull.rebase false` | Que `git pull` junte con una **fusión** cuando tu rama y la de GitHub tienen commits distintos. Sin esto, Git se para y pregunta |
| `mv proyecto proyecto-dw2` | **No es Git**: renombra la carpeta. En DW3 aparta la de DW2 como respaldo para clonar en su sitio |
| `git clone URL carpeta` | Se trae un repositorio entero, deja `origin` configurado y tu `main` enlazada con la de GitHub. La URL se copia del botón *Code* → *SSH* |
| `git status` | En qué rama estás, qué has tocado y qué está preparado. **Ante la duda, esta** |
| `git add fichero` | **Prepara** el contenido actual de ese fichero. `git add .` prepara todo lo de la carpeta actual —nuevos, modificados y borrados—, salvo lo ignorado: `git status` antes del commit |
| `git commit -m "mensaje"` | Registra una versión con lo preparado. `-m` es el mensaje: en este curso, **verbo en infinitivo** (`Añadir…`, `Validar…`). Un segundo `-m` añade un cuerpo |
| `git commit --amend --only -m "..."` | Cambia el mensaje del **último** commit sin meter lo preparado. **Solo si todavía no has hecho `push`** |
| `git check-ignore -v fichero` | Dice **qué línea** del `.gitignore` ignora ese fichero. Si no dice nada, no se ignora |
| `git ls-files fichero` | Dice si Git **sigue** ese fichero. Para una contraseña, tiene que salir vacío |
| `git restore fichero` | Descarta lo que has cambiado **y no has preparado**: vuelve a lo preparado o, si no había, al último commit. **Borra** esos cambios |
| `git restore --source=HEAD -- fichero` | Deja el fichero exactamente como en el último commit |
| `git restore --staged fichero` | Deshace el `add`: deja de estar preparado, y tu fichero no cambia |
| `git diff` | Lo que has cambiado y **aún no has preparado** |
| `git diff --staged` | Lo que está preparado y **entra en el próximo commit** |
| `git log --oneline` | Una línea por versión. El código del principio es el `<hash>`. Se sale con `q` |
| `git show <hash>:ruta` | Cómo era ese fichero en ese commit |
| `git push` | Sube tus commits a GitHub. Tras un `clone` no hace falta más. `git push -u origin main` hace lo mismo y además fija el enlace |
| `git pull` | **Trae y junta**: descarga lo de GitHub y lo fusiona con tu rama. Puede dar conflicto. Antes, `git status` limpio |
| `git switch -c rama` | Crea una rama y se cambia a ella. **Falla si ya existe una con ese nombre** |
| `git switch main` | Vuelve a la rama principal |
| `git merge --no-ff -m "Fusionar la rama X" rama` | Junta el trabajo de la rama. `--no-ff` fuerza un commit de fusión, para que quede constancia; `-m` evita que se abra el editor |
| `git merge --abort` | A mitad de un conflicto: deja todo como estaba antes del `merge` |
| `git branch -d rama` | Borra una rama ya fusionada, y deja el nombre libre |
| `grep -nE '^(<<<<<<<\|=======\|>>>>>>>)' fichero` | **No es Git**: busca marcas de conflicto que se hayan quedado. No tiene que salir nada |
| `php -l fichero.php` | **No es Git**: comprueba que el fichero es PHP válido. Se usa tras resolver un conflicto, antes de commitear |
| `python3 ~/herramientas/comprobar_historial.py .` | **No es Git**: pasa el comprobador, guardado **fuera** del repositorio. El `.` es un argumento: la carpeta a examinar, «esta» |

**Guardar no es versionar.** `Ctrl+S` escribe el fichero en el disco; `git add` lo
prepara; `git commit` registra la versión; `git push` la envía. Son cuatro pasos
distintos.

**El `.gitignore` se amplía antes del primer `add`.** Solo afecta a lo que Git todavía
no sigue, y borrar un fichero en un commit posterior no lo borra de los anteriores.
