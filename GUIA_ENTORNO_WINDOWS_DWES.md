# Guía de entorno · DWES · lo que se instala en tu Windows

**Desenvolvemento web en contorno servidor (MP0613) · 2º DAW**
**Material del alumnado. Curso 2026/27**

---

En DW2 vas a montar un servidor Debian dentro de tu Windows y a programarlo desde
fuera. Esto es lo que hay que tener **antes** de abrir los apuntes de DW2, y cómo
comprobar que está.

Tres piezas, y conviene no confundirlas:

| | Qué es | Dónde vive |
|---|---|---|
| **VirtualBox** | El programa que crea máquinas virtuales | En tu Windows (**anfitrión**) |
| **Debian** | El sistema operativo del servidor, dentro de una de esas máquinas | En la máquina virtual (**invitado**) |
| **Cliente SSH** | Un programa que se conecta a otra máquina por red | En tu Windows |
| **VS Code** + extensión **Remote - SSH** | El editor, y la pieza que le permite editar ficheros que están en la VM | En tu Windows |

Una **extensión** no es un programa aparte: es una pieza que se carga dentro de VS
Code. Un **servicio** sí es un programa que queda corriendo, como el servidor SSH
dentro de Debian.

---

## 1. Antes de instalar nada: la virtualización

Una máquina virtual necesita que el procesador tenga activada la **virtualización
por hardware**. Viene activada en casi todos los equipos modernos, pero no en todos.

**Cómo comprobarlo, en treinta segundos:**

1. `Ctrl+Shift+Esc` abre el Administrador de tareas.
2. Pestaña **Rendimiento** → **CPU**.
3. Busca la línea **Virtualización**. Tiene que poner **Habilitado**.

| Si pone | Qué significa |
|---|---|
| **Habilitado** | Todo bien, sigue |
| **Deshabilitado** | Hay que activarlo en la BIOS/UEFI del equipo |
| No aparece la línea | En algunos equipos con Hyper-V activo se muestra distinto. Avisa al profesor |


**Necesitas además**: unos 25 GB libres en disco y 8 GB de RAM (con 4 GB funciona,
pero justo).

---

## 2. VirtualBox, el cliente SSH y VS Code

### 2.1 VirtualBox

0. Descarga e instala este paquete para que no te de error al instalar VBox: https://aka.ms/vc14/vc_redist.x64.exe
1. Descarga el instalador para *Windows hosts* de
   <https://www.virtualbox.org/wiki/Downloads>.
2. Ejecútalo. Pide **permisos de administrador**.
3. Durante la instalación avisa de que va a **reiniciar la red unos segundos**. Es
   normal: está instalando sus adaptadores.
4. Comprobación: se abre VirtualBox y aparece su ventana principal.

La ISO de Debian se descarga aquí **https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.7.0-amd64-netinst.iso**

### 2.2 El cliente de SSH

Windows 10 y 11 lo traen, pero conviene comprobarlo. Abre **Terminal de Windows** y
escribe:

```powershell
ssh -V
```

Tiene que contestar algo como `OpenSSH_for_Windows_9.5p1`. Si dice que no se
reconoce el comando, se instala así:

*Configuración* → *Sistema* → *Características opcionales* → *Ver características* →
buscar **Cliente de OpenSSH** → instalar. Después, cierra la terminal y abre otra.

### 2.3 VS Code y Remote - SSH

1. Descarga VS Code de <https://code.visualstudio.com/> e instala con las opciones
   por defecto.
2. Ábrelo, ve al icono de **Extensiones** (`Ctrl+Shift+X`), busca **Remote - SSH**
   (de Microsoft) e instálala.
3. Comprobación: pulsa `F1` y escribe `Remote-SSH`. Tienen que aparecer sus
   órdenes en la lista.

La documentación oficial, incluida la resolución de problemas de conexión, está en
<https://code.visualstudio.com/docs/remote/troubleshooting>.

---

## 3. Instalar Debian, pantalla por pantalla

Los apuntes de DW2 explican **las tres pantallas que deciden cómo queda la
máquina**. Aquí está el recorrido completo, para que puedas hacerlo solo.

### 3.1 Crear la máquina

En VirtualBox: *Nueva* → nombre **DEBIAN_DWES**, tipo **Linux**, versión **Debian (64-bit)** → 2048 MB de
memoria → disco de **20 GB**.

Como disco de arranque, la ISO netinst que descargaste.

> **Desmarca «Instalación desatendida»** si VirtualBox la ofrece. Esa opción instala
> Debian sola, con sus propias respuestas, y entonces no controlas ni la contraseña
> de root ni las casillas de programas, que es justo lo que aquí importa.

### 3.2 El instalador

Arranca la máquina. Sale un menú: elige **Graphical install**.

> **«Instalación gráfica» no es «instalar un escritorio».** Es el mismo instalador
> con ratón. El escritorio se desmarca más adelante y la máquina queda sin él.

| Pantalla | Qué poner |
|---|---|
| Language / Country / Locale | Español · España · es_ES.UTF-8 |
| Teclado | Español |
| Nombre de la máquina (*hostname*) | `expediciones` o lo que quieras |
| Dominio | **Déjalo vacío** |
| **Contraseña de root** | **Vacía**, y continuar. Ver el aviso de abajo |
| Usuario y contraseña | El tuyo, con una contraseña que recuerdes (1234) |
| Zona horaria | Madrid |
| **Particionado** | **Guiado - utilizar todo el disco** → el disco `VBOX HARDDISK` de 20 GB → **Todos los ficheros en una partición** → *Finalizar el particionado* → **Sí**, escribir los cambios |
| Réplica de red | España, la que sale por defecto |
| Proxy | Vacío |
| Encuesta de popularidad | No |
| **Selección de programas** | **Desmarca** «Entorno de escritorio» y «GNOME». **Marca** «Servidor SSH» y «Utilidades estándar del sistema» |
| Gestor de arranque GRUB | **Sí**, y elegir el disco `/dev/sda` |

> **El disco que formateas es el disco virtual**, un fichero de 20 GB dentro de tu
> Windows. **No toca nada de tu ordenador.** Antes de confirmar, comprueba que el
> tamaño que aparece son los 20 GB que creaste y no el tamaño de tu disco real.

> **La contraseña de root, vacía.** Si la dejas vacía, el instalador deshabilita la
> cuenta de root, **instala `sudo`** y mete a tu usuario en el grupo `sudo`. Si le
> pones contraseña, hace lo contrario: **no instala `sudo`**. Cómo salir de ahí está
> en «Errores típicos» de los apuntes de DW2.

Al terminar, la máquina reinicia y aparece una pantalla negra con `login:`. **Eso es
lo correcto**, no es un error.

### 3.3 Apagar bien

Para apagarla, dentro de la VM:

```bash
sudo poweroff
```

O desde el menú de VirtualBox: *Máquina* → *Apagar* → **Apagado ACPI**. Cerrar la
ventana a lo bruto puede dejar el disco a medias.

El reenvío de puertos (apartado 2.3 de los apuntes de DW2) **se configura con la VM
apagada**, después de esto.

> **La netinst descarga paquetes durante la instalación**, así que la VM necesita
> salida a internet.

---

## 4. Lista de comprobación

No sigas con el apartado 2 de los apuntes de DW2 hasta poder marcar las seis:

- [ ] El Administrador de tareas dice **Virtualización: Habilitado**.
- [ ] VirtualBox abre y puedo crear una máquina.
- [ ] `ssh -V` contesta en la terminal de Windows.
- [ ] VS Code abre y `F1` → `Remote-SSH` ofrece sus órdenes.
- [ ] Tengo la ISO de Debian copiada en mi disco.


Si algo de esto no depende de ti —permisos de administrador, BIOS bloqueada—,
dilo el primer día. Hay alternativa, pero hay que saberlo antes de la clase en la
que hace falta.
