#!/usr/bin/env bash

set -uo pipefail

RAIZ="${HOME}/proyecto"
CRED="${RAIZ}/config/credenciales.php"
PUB="${RAIZ}/public"

OK=0
MAL=0
DETALLE=""

comprobar() {
    local que="$1"
    shift

    if "$@" >/dev/null 2>&1; then
        printf "  OK    %s\n" "$que"
        OK=$((OK+1))
        DETALLE="$DETALLE{\"comprobacion\":\"$que\",\"resultado\":\"ok\"},"
    else
        printf "  MAL   %s\n" "$que"
        MAL=$((MAL+1))
        DETALLE="$DETALLE{\"comprobacion\":\"$que\",\"resultado\":\"mal\"},"
    fi
}

echo "ENTORNO DE DWES · comprobacion"
echo "------------------------------------------------------------------"
echo "DW2 · lo que cuenta para esta unidad"
echo

comprobar "existe ~/proyecto/public" test -d "$PUB"
comprobar "existe ~/proyecto/config" test -d "${RAIZ}/config"
comprobar "hay una pagina estatica index.html" test -s "${PUB}/index.html"

comprobar "Apache instalado" test -x /usr/sbin/apache2ctl
comprobar "Apache en ejecucion" pgrep -x apache2
comprobar "escucha en el puerto 80" bash -c 'ss -ltn 2>/dev/null | grep -q ":80 " || netstat -ltn 2>/dev/null | grep -q ":80 "'

comprobar "el DocumentRoot es ~/proyecto/public" bash -c '
grep -RqsE "^[[:space:]]*DocumentRoot[[:space:]]+'"\"$PUB\""'\s*$" /etc/apache2/sites-enabled/
'

comprobar "sirve la pagina estatica (HTTP 200)" bash -c '
[ "$(curl -s -o /dev/null -w "%{http_code}" http://localhost/index.html)" = "200" ]'

comprobar "PHP instalado" command -v php
comprobar "PHP 8.1 o superior" bash -c 'php -r "exit(version_compare(PHP_VERSION, \"8.1\", \">=\") ? 0 : 1);"'
comprobar "extension PDO" bash -c 'php -m | grep -qi "^PDO$"'
comprobar "extension pdo_mysql" bash -c 'php -m | grep -qi "^pdo_mysql$"'

comprobar "Apache EJECUTA PHP (peticion HTTP real)" bash -c '
pub="'"$PUB"'"
testigo="comprueba_$$.php"
esperado=$(( ( $$ % 1000 ) * 7 + 13 ))
printf "<?php echo ( ( %s %% 1000 ) * 7 ) + 13;" "$$" > "$pub/$testigo" 2>/dev/null || exit 1
cuerpo=$(curl -s --max-time 5 "http://localhost/$testigo")
rm -f "$pub/$testigo"
[ "$cuerpo" = "$esperado" ]'

comprobar "la SAPI de Apache es apache2handler o fpm-fcgi" bash -c '
pub="'"$PUB"'"
testigo="sapi_$$.php"
printf "<?php echo php_sapi_name();" > "$pub/$testigo" 2>/dev/null || exit 1
sapi=$(curl -s --max-time 5 "http://localhost/$testigo")
rm -f "$pub/$testigo"
case "$sapi" in
    apache2handler|fpm-fcgi) exit 0 ;;
    *) exit 1 ;;
esac'

comprobar "existe config/credenciales.php" test -s "$CRED"

comprobar "credenciales.php NO es accesible por web (404)" bash -c '
[ "$(curl -s -o /dev/null -w "%{http_code}" http://localhost/config/credenciales.php)" = "404" ]'

comprobar "credenciales.php solo lo lee su dueno (600)" bash -c '
[ "$(stat -c %a "'"$CRED"'" 2>/dev/null)" = "600" ]'

comprobar "MariaDB instalado" bash -c 'command -v mariadb || command -v mysql'
comprobar "MariaDB en ejecucion" bash -c 'pgrep -x mariadbd || pgrep -x mysqld || pgrep -f mariadbd-safe'

comprobar "el usuario app conecta a expediciones" bash -c '
php -r "
\$c = require getenv(\"HOME\").\"/proyecto/config/credenciales.php\";
new PDO(
    \"mysql:host=\".\$c[\"servidor\"].\";dbname=\".\$c[\"base\"].\";charset=utf8mb4\",
    \$c[\"usuario\"],
    \$c[\"clave\"],
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);
"'

comprobar "app tiene SELECT, INSERT, UPDATE y DELETE y nada mas" bash -c '
php -r "
\$c = require getenv(\"HOME\").\"/proyecto/config/credenciales.php\";
\$p = new PDO(
    \"mysql:host=\".\$c[\"servidor\"].\";dbname=\".\$c[\"base\"].\";charset=utf8mb4\",
    \$c[\"usuario\"],
    \$c[\"clave\"],
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);
\$texto = implode(\" \", \$p->query(\"SHOW GRANTS FOR CURRENT_USER\")->fetchAll(PDO::FETCH_COLUMN));

if (stripos(\$texto, \"ALL PRIVILEGES\") !== false) exit(1);

foreach ([\"SELECT\",\"INSERT\",\"UPDATE\",\"DELETE\"] as \$g)
    if (stripos(\$texto, \$g) === false) exit(1);

foreach ([\"DROP\",\"CREATE\",\"ALTER\",\"GRANT OPTION\"] as \$g)
    if (stripos(\$texto, \$g) !== false) exit(1);

exit(0);
"'

comprobar "servidor SSH en ejecucion" bash -c 'pgrep -x sshd'
comprobar "SSH escucha en el 22" bash -c 'ss -ltn 2>/dev/null | grep -q ":22 " || netstat -ltn 2>/dev/null | grep -q ":22 "'
comprobar "clave publica autorizada" bash -c '[ -s ~/.ssh/authorized_keys ]'

echo
echo "------------------------------------------------------------------"
printf "DW2: %d correctas, %d pendientes de arreglar\n" "$OK" "$MAL"

if [ "${1:-}" = "--json" ]; then
    printf '{"ok":%d,"mal":%d,"detalle":[%s]}\n' \
        "$OK" "$MAL" "${DETALLE%,}" > entorno.json
    echo "Escrito entorno.json (es lo que se sube al repositorio)"
fi

[ "$MAL" -eq 0 ] && exit 0 || exit 1
