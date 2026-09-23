# -*- coding: utf-8 -*-
"""Comprobador del historial de Git · DWES · DW3.

Revisa el historial del repositorio, no el código. Lo pasa el alumnado antes de
entregar y lo puede pasar el profesor en lote con ``recoger.py``.

Uso::

    python3 comprobar_historial.py <carpeta_del_repositorio>
    python3 comprobar_historial.py <carpeta> --json            # JSON por pantalla
    python3 comprobar_historial.py <carpeta> --json salida.json

Qué examina
    El **último commit de la rama en la que estás** (``HEAD``) y los commits de
    los que viene. Lo que no está confirmado no cuenta, aunque esté en la carpeta.

Qué NO examina
    El código, la bitácora de prompts (la valida el corrector del sprint en
    *Actions*), si has hecho ``push``, ni secretos subidos en commits antiguos:
    solo mira el último commit.

Salida
    Siete comprobaciones OK/MAL, avisos que no cuentan y, al final, la línea
    ``PARTE FUNCIONAL: N de 7``, que es la que lee ``recoger.py``.

Código de salida: 0 si pasan las siete, 1 si falla alguna, 2 si el uso es
incorrecto.

Historial de cambios
    24/08/2026  La detección del conflicto rehace la fusión con ``merge-tree``.
    21/09/2026  Auditoría de DW3: examina el árbol de HEAD y no el índice;
                lista única de ficheros prohibidos; comprueba que no queden
                marcas de conflicto; tolera un mensaje antiguo inválido; avisa
                de rama, cambios pendientes, commits sin subir y clon
                superficial; emite la línea de ``recoger.py``.
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass, field
from pathlib import Path

MINIMO_COMMITS = 8
MINIMO_CARACTERES = 10
MENSAJES_TOLERADOS = 1
RAMA_DE_ENTREGA = "main"

MENSAJES_VACIOS = re.compile(
    r"^(cambios?|arreglos?|fix(es)?|update|actualizaci[oó]n(es)?|pruebas?|test|"
    r"asdf|\.+|wip|commit)\W*$",
    re.IGNORECASE)

MARCA_CONFLICTO = re.compile(r"^(<{7}|>{7})(\s|$)", re.MULTILINE)

PROHIBIDOS_EXACTOS = ("config/credenciales.php",)
PROHIBIDOS_NOMBRE = (".env", "config.local.php")
PROHIBIDAS_CARPETAS = ("vendor", "node_modules")
PROHIBIDO_SQLITE = re.compile(r"^datos/[^/]+\.sqlite$")
DEBEN_IGNORARSE = ("config/credenciales.php", ".env")


class Git:
    """Ejecuta órdenes de Git sobre un repositorio y devuelve texto."""

    def __init__(self, repo: str):
        """Guarda la carpeta del repositorio que se va a examinar."""
        self.repo = repo

    def __call__(self, *args: str) -> tuple[str, int]:
        """Ejecuta ``git -C repo args`` y devuelve ``(salida, código)``."""
        r = subprocess.run(["git", "-C", self.repo, *args],
                           capture_output=True, text=True, encoding="utf-8",
                           errors="replace")
        return r.stdout.strip(), r.returncode

    def lineas(self, *args: str) -> list[str]:
        """Devuelve la salida de la orden como lista de líneas no vacías."""
        salida, _ = self(*args)
        return [l for l in salida.splitlines() if l]

    def contenido(self, commit: str, ruta: str) -> str | None:
        """Devuelve el contenido de ``ruta`` en ``commit`` o None si no existe."""
        r = subprocess.run(["git", "-C", self.repo, "show", f"{commit}:{ruta}"],
                           capture_output=True, text=True, encoding="utf-8",
                           errors="replace")
        return r.stdout if r.returncode == 0 else None


@dataclass
class Informe:
    """Resultado: comprobaciones que cuentan y avisos que no cuentan."""

    filas: list[dict] = field(default_factory=list)
    avisos: list[str] = field(default_factory=list)

    def anota(self, que: str, ok: bool, detalle: str = "") -> None:
        """Añade una comprobación con su resultado y un detalle opcional."""
        self.filas.append({"comprobacion": que, "resultado": "ok" if ok else "mal",
                           "detalle": detalle})

    def avisa(self, texto: str) -> None:
        """Añade un aviso que no cambia el resultado."""
        self.avisos.append(texto)

    @property
    def correctas(self) -> int:
        """Número de comprobaciones en OK."""
        return sum(1 for f in self.filas if f["resultado"] == "ok")

    @property
    def total(self) -> int:
        """Número de comprobaciones anotadas."""
        return len(self.filas)

    def como_dict(self) -> dict:
        """Devuelve el informe listo para volcar a JSON."""
        return {"ok": self.correctas, "total": self.total,
                "detalle": self.filas, "avisos": self.avisos}


class ComprobadorHistorial:
    """Las siete comprobaciones de DW3 sobre el commit HEAD de un repositorio."""

    NOMBRES = (
        "es un repositorio de Git",
        f"al menos {MINIMO_COMMITS} commits",
        "mensajes que dicen algo",
        ".gitignore en el último commit",
        "sin ficheros prohibidos en el último commit",
        "al menos una rama fusionada",
        "un conflicto fusionado sin marcas",
    )

    def __init__(self, repo: str):
        """Prepara el comprobador para la carpeta ``repo``."""
        self.git = Git(repo)
        self.inf = Informe()
        self.arbol: list[str] = []
        self.php = shutil.which("php")

    def comprobar(self) -> Informe:
        """Ejecuta las siete comprobaciones y los avisos, en este orden."""
        if not self._es_repositorio():
            for nombre in self.NOMBRES[1:]:
                self.inf.anota(nombre, False, "no se puede comprobar")
            return self.inf
        self.arbol = self.git.lineas("ls-tree", "-r", "--name-only", "HEAD")
        self._avisos_de_entrega()
        self._numero_de_commits()
        self._mensajes()
        self._gitignore_versionado()
        self._prohibidos()
        fusiones = self._fusiones()
        self._conflicto(fusiones)
        return self.inf

    def _es_repositorio(self) -> bool:
        """Comprobación 1: hay repositorio y al menos un commit."""
        _, codigo = self.git("rev-parse", "--git-dir")
        if codigo != 0:
            self.inf.anota(self.NOMBRES[0], False, "no hay .git en esa carpeta")
            return False
        _, codigo = self.git("rev-parse", "--verify", "--quiet", "HEAD")
        if codigo != 0:
            self.inf.anota(self.NOMBRES[0], False, "todavía no hay ningún commit")
            return False
        self.inf.anota(self.NOMBRES[0], True)
        return True

    def _avisos_de_entrega(self) -> None:
        """Avisa de lo que hace que lo examinado no sea lo entregado."""
        salida, _ = self.git("rev-parse", "--is-shallow-repository")
        if salida == "true":
            self.inf.avisa("clon superficial: falta historial y el resultado no es fiable")
        rama, _ = self.git("rev-parse", "--abbrev-ref", "HEAD")
        if rama != RAMA_DE_ENTREGA:
            self.inf.avisa(f"estás en «{rama}», no en {RAMA_DE_ENTREGA}: "
                           f"se examina esa rama, y se entrega {RAMA_DE_ENTREGA}")
        pendientes = self.git.lineas("status", "--porcelain")
        if pendientes:
            self.inf.avisa(f"{len(pendientes)} fichero(s) con cambios sin confirmar: "
                           "no están en el commit que se examina")
        _, codigo = self.git("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}")
        if codigo != 0:
            self.inf.avisa("esta rama no sigue a ninguna rama de GitHub (¿falta el push?)")
        else:
            sin_subir, _ = self.git("rev-list", "--count", "@{u}..HEAD")
            if sin_subir not in ("", "0"):
                self.inf.avisa(f"{sin_subir} commit(s) sin subir: haz git push")

    def _numero_de_commits(self) -> None:
        """Comprobación 2: número de commits alcanzables desde HEAD."""
        n, _ = self.git("rev-list", "--count", "HEAD")
        self.inf.anota(self.NOMBRES[1], int(n or 0) >= MINIMO_COMMITS, f"{n} commits")

    def _mensajes(self) -> None:
        """Comprobación 3: mensajes inválidos, sin contar el commit de la plantilla.

        Se tolera un mensaje inválido (ya subido, no se reescribe) y se avisa;
        con dos o más, MAL. Los commits sin padre son los de la plantilla.
        """
        malos = []
        for linea in self.git.lineas("log", "--format=%P%x1f%s", "HEAD"):
            padres, _, asunto = linea.partition("\x1f")
            if not padres.strip():
                continue
            asunto = asunto.strip()
            if len(asunto) < MINIMO_CARACTERES or MENSAJES_VACIOS.match(asunto):
                malos.append(asunto)
        lista = ", ".join(f'"{m}"' for m in malos[:3])
        if 0 < len(malos) <= MENSAJES_TOLERADOS:
            self.inf.avisa(f"mensaje inválido tolerado: {lista}. "
                           "Si aún no lo has subido: git commit --amend --only -m \"...\"")
        self.inf.anota(self.NOMBRES[2], len(malos) <= MENSAJES_TOLERADOS,
                       f"inválidos: {lista}" if len(malos) > MENSAJES_TOLERADOS else "")

    def _gitignore_versionado(self) -> None:
        """Comprobación 4: hay .gitignore en la raíz del commit HEAD."""
        self.inf.anota(self.NOMBRES[3], ".gitignore" in self.arbol)

    def _prohibidos(self) -> None:
        """Comprobación 5: nada prohibido en HEAD y el .gitignore ignora los secretos."""
        basura = [r for r in self.arbol if self._es_prohibido(r)]
        sin_regla = self._secretos_no_ignorados()
        partes = []
        if basura:
            partes.append("versionados: " + ", ".join(basura[:3]))
        if sin_regla:
            partes.append("el .gitignore no ignora: " + ", ".join(sin_regla))
        self.inf.anota(self.NOMBRES[4], not basura and not sin_regla, "; ".join(partes))

    @staticmethod
    def _es_prohibido(ruta: str) -> bool:
        """Dice si una ruta del árbol está en la lista común de A, E y C."""
        partes = ruta.split("/")
        return (ruta in PROHIBIDOS_EXACTOS
                or partes[-1] in PROHIBIDOS_NOMBRE
                or any(p in PROHIBIDAS_CARPETAS for p in partes[:-1])
                or ruta.endswith(".log")
                or bool(PROHIBIDO_SQLITE.match(ruta)))

    def _secretos_no_ignorados(self) -> list[str]:
        """Evalúa el .gitignore de HEAD en un repositorio temporal vacío."""
        contenido = self.git.contenido("HEAD", ".gitignore")
        if contenido is None:
            return list(DEBEN_IGNORARSE)
        with tempfile.TemporaryDirectory() as tmp:
            Path(tmp, ".gitignore").write_text(contenido, encoding="utf-8")
            vacio = Path(tmp, ".git-excludes-vacio")
            vacio.write_text("", encoding="utf-8")
            subprocess.run(["git", "init", "-q", tmp], capture_output=True)
            faltan = []
            for ruta in DEBEN_IGNORARSE:
                r = subprocess.run(
                    ["git", "-C", tmp, "-c", f"core.excludesFile={vacio.as_posix()}",
                     "check-ignore", "-q", "--no-index", ruta], capture_output=True)
                if r.returncode != 0:
                    faltan.append(ruta)
            return faltan

    def _fusiones(self) -> list[str]:
        """Comprobación 6: commits de fusión alcanzables desde HEAD."""
        fusiones = self.git.lineas("rev-list", "--merges", "HEAD")
        self.inf.anota(self.NOMBRES[5], len(fusiones) >= 1, f"{len(fusiones)} fusiones")
        return fusiones

    def _conflicto(self, fusiones: list[str]) -> None:
        """Comprobación 7: una fusión que chocó y cuyo resultado no tiene marcas.

        Se rehace la fusión de los dos padres con ``merge-tree``: si Git también
        choca, hubo conflicto, se resolviera como se resolviera. Una fusión
        cuenta como limpia si sus ficheros en conflicto no conservan marcas y,
        con PHP instalado, son PHP válido, tanto en el commit de fusión como en
        HEAD. Además, ningún fichero que estuvo en conflicto puede seguir roto
        en HEAD: eso es lo que se entrega.
        """
        limpias, rotas, en_head, aproximado = [], [], [], False
        for h in fusiones:
            ficheros, estado = self._ficheros_en_conflicto(h)
            if estado == "sin_conflicto":
                continue
            aproximado = aproximado or estado == "aproximado"
            en_fusion, ahora = self._revisar_resolucion(h, ficheros)
            en_head.extend(f for f in ahora if f not in en_head)
            if en_fusion or ahora:
                rotas.append(f"{h[:8]}: {', '.join(en_fusion + ahora)}")
            else:
                limpias.append(h[:8])
        if aproximado:
            self.inf.avisa("Git anterior a 2.38: la detección del conflicto es aproximada")
        if en_head:
            detalle = "roto en HEAD: " + ", ".join(en_head[:3])
        elif limpias:
            detalle = ", ".join(limpias[:3])
        elif rotas:
            detalle = "; ".join(rotas[:2])
        else:
            detalle = "ninguna fusión con conflicto"
        self.inf.anota(self.NOMBRES[6], bool(limpias) and not en_head, detalle)

    def _ficheros_en_conflicto(self, h: str) -> tuple[list[str], str]:
        """Devuelve los ficheros que chocan al rehacer la fusión ``h``."""
        p1, c1 = self.git("rev-parse", f"{h}^1")
        p2, c2 = self.git("rev-parse", f"{h}^2")
        if c1 or c2:
            return [], "sin_conflicto"
        salida, codigo = self.git("merge-tree", "--write-tree", "--name-only",
                                  "--no-messages", p1, p2)
        if codigo == 1:
            nombres = salida.split("\n\n")[0].splitlines()[1:]
            return sorted(set(nombres)), "conflicto"
        if codigo > 1:
            combinado, _ = self.git("show", "--cc", "--format=", h)
            if combinado.strip():
                return self.git.lineas("diff", "--name-only", f"{h}^1", h), "aproximado"
        return [], "sin_conflicto"

    def _revisar_resolucion(self, h: str, ficheros: list[str]) -> tuple[list[str], list[str]]:
        """Devuelve los ficheros con marcas o PHP inválido: en la fusión y en HEAD."""
        resultado = {h: [], "HEAD": []}
        for ruta in ficheros:
            for commit in (h, "HEAD"):
                texto = self.git.contenido(commit, ruta)
                if texto is None:
                    continue
                if MARCA_CONFLICTO.search(texto):
                    resultado[commit].append(f"{ruta} con marcas")
                elif ruta.endswith(".php") and not self._php_valido(texto):
                    resultado[commit].append(f"{ruta} no es PHP válido")
        en_fusion = [f"{f} en la fusión" for f in resultado[h]]
        return en_fusion, resultado["HEAD"]

    def _php_valido(self, texto: str) -> bool:
        """Pasa ``php -l`` por la entrada estándar; sin PHP, lo da por bueno."""
        if not self.php:
            return True
        r = subprocess.run([self.php, "-l"], input=texto, capture_output=True,
                           text=True, encoding="utf-8", errors="replace")
        return r.returncode == 0


def imprimir(repo: str, inf: Informe) -> None:
    """Escribe el informe legible por pantalla."""
    print("HISTORIAL DE GIT ·", repo)
    print("-" * 70)
    for f in inf.filas:
        marca = "OK   " if f["resultado"] == "ok" else "MAL  "
        extra = f"  ({f['detalle']})" if f["detalle"] else ""
        print(f"  {marca} {f['comprobacion']}{extra}")
    for aviso in inf.avisos:
        print(f"  AVISO {aviso}")
    print("-" * 70)
    print(f"{inf.correctas} de {inf.total} correctas")
    print("Solo se examina el historial: la bitácora, el push y el ejemplo de "
          "credenciales se comprueban aparte.")
    print(f"PARTE FUNCIONAL: {inf.correctas} de {inf.total}")


def main(argv: list[str] | None = None) -> int:
    """Lee los argumentos, comprueba el repositorio y devuelve el código de salida."""
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("repo", help="carpeta del repositorio; «.» es la carpeta actual")
    ap.add_argument("--json", nargs="?", const="-", metavar="FICHERO",
                    help="JSON por pantalla, o en FICHERO si se indica")
    args = ap.parse_args(argv)

    inf = ComprobadorHistorial(args.repo).comprobar()
    if args.json == "-":
        print(json.dumps(inf.como_dict(), ensure_ascii=False, indent=2))
    else:
        imprimir(args.repo, inf)
        if args.json:
            Path(args.json).write_text(json.dumps(inf.como_dict(), ensure_ascii=False,
                                                  indent=2), encoding="utf-8")
            print("Escrito", args.json)
    return 0 if inf.correctas == inf.total else 1


if __name__ == "__main__":
    sys.exit(main())
