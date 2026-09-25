#!/bin/bash
# ============================================================
# Script    : importar_corpus.sh
# Propósito : Aplica un script SQL sobre la base de gbCorpus, con
#             respaldo previo, transacción envolvente, verificaciones
#             posteriores e informe legible en consola.
#
#             Es infraestructura, no configuración: vive junto al
#             proyecto y no se copia a ~/.gbcorpus (criterio de SC-11).
#
#             Corre igual en el TerminalView embebido de gbCorpus o en
#             una terminal cualquiera: no hace nada que dependa de una.
#
# Uso       : importar_corpus.sh ARCHIVO.sql [RUTA_BASE]
#             Sin RUTA_BASE usa ~/.gbcorpus/corpus.sqlite
#
# Salida    : 0 si la importación se aplicó, 1 si no. Ese código es lo
#             único que gbCorpus necesita para saber si recargar.
# ============================================================

set -uo pipefail

# --- 1. PARÁMETROS Y RUTAS ---

SCRIPT_SQL="${1:-}"
BASE="${2:-$HOME/.gbcorpus/corpus.sqlite}"
CARPETA_BASE="$(dirname "$BASE")"
CARPETA_RESPALDOS="$CARPETA_BASE/respaldos"
SELLO="$(date +%Y%m%d-%H%M%S)"

# Versión de esquema que este corpus maneja. Si algún día sube, sube acá.
ESQUEMA_ESPERADO=1

# Cuántos respaldos se conservan antes de empezar a borrar los viejos.
RESPALDOS_A_CONSERVAR=20

# --- 2. UTILIDADES DE PRESENTACIÓN ---

# Los colores se apagan solos si la salida no es una terminal, para que
# el archivo de resultado no se llene de secuencias de escape.
if [ -t 1 ]; then
  ROJO=$'\033[1;31m'; VERDE=$'\033[1;32m'; AMARILLO=$'\033[1;33m'
  AZUL=$'\033[1;34m'; NEUTRO=$'\033[0m'
else
  ROJO=''; VERDE=''; AMARILLO=''; AZUL=''; NEUTRO=''
fi

titulo() { printf '\n%s== %s ==%s\n' "$AZUL" "$1" "$NEUTRO"; }
ok()     { printf '%s  ✓%s %s\n' "$VERDE" "$NEUTRO" "$1"; }
aviso()  { printf '%s  !%s %s\n' "$AMARILLO" "$NEUTRO" "$1"; }
falla()  { printf '%s  ✗%s %s\n' "$ROJO" "$NEUTRO" "$1"; }

# Cierra el informe y termina. El código de salida es el contrato con
# gbCorpus: 0 aplicado, 1 no aplicado. No se escribe ningún archivo de
# resultado, y no hay pausa final: la salida queda en la pestaña
# Terminal, que no se cierra sola.
terminar() {
  local estado="$1" motivo="$2"

  if [ "$estado" = "OK" ]; then
    printf '\n%s IMPORTACIÓN COMPLETADA %s\n' "$VERDE" "$NEUTRO"
    [ -n "${RESPALDO:-}" ] && printf '  Respaldo previo: %s\n' "$RESPALDO"
    exit 0
  fi

  printf '\n%s IMPORTACIÓN ABORTADA %s — %s\n' "$ROJO" "$NEUTRO" "$motivo"
  [ -n "${RESPALDO:-}" ] && printf '  Respaldo previo: %s\n' "$RESPALDO"
  exit 1
}

# Ejecuta una consulta de una sola celda y devuelve el valor.
consultar() {
  sqlite3 -noheader -batch "$BASE" "$1" 2>/dev/null
}

# ============================================================
# 3. VALIDACIONES PREVIAS. NADA SE TOCA HASTA QUE PASEN TODAS.
# ============================================================

titulo "Verificaciones previas"

if ! command -v sqlite3 >/dev/null 2>&1; then
  falla "sqlite3 no está instalado (apt install sqlite3)"
  terminar "ERROR" "falta el binario sqlite3"
fi
ok "sqlite3 $(sqlite3 --version | cut -d' ' -f1)"

if [ -z "$SCRIPT_SQL" ]; then
  falla "Falta el archivo SQL"
  echo "  Uso: $(basename "$0") ARCHIVO.sql [RUTA_BASE]"
  terminar "ERROR" "no se indicó archivo"
fi

if [ ! -r "$SCRIPT_SQL" ]; then
  falla "No se puede leer: $SCRIPT_SQL"
  terminar "ERROR" "archivo ilegible"
fi
ok "Script: $SCRIPT_SQL ($(wc -l < "$SCRIPT_SQL") líneas)"

if [ ! -w "$BASE" ]; then
  falla "La base no existe o no es escribible: $BASE"
  terminar "ERROR" "base inaccesible"
fi
ok "Base: $BASE"

# El archivo puede existir y no ser una base: integrity_check lo dice.
INTEGRIDAD="$(consultar 'PRAGMA integrity_check;')"
if [ "$INTEGRIDAD" != "ok" ]; then
  falla "La base no pasa integrity_check: ${INTEGRIDAD:-sin respuesta}"
  terminar "ERROR" "base corrupta o ilegible"
fi
ok "Integridad de la base: correcta"

# --- Versión de esquema: la de la base contra la que este script maneja ---
ESQUEMA_BASE="$(consultar 'SELECT MAX(version) FROM esquema_version;')"
if [ -z "$ESQUEMA_BASE" ]; then
  falla "No se pudo leer esquema_version: puede no ser una base de corpus"
  terminar "ERROR" "sin esquema_version"
fi

if [ "$ESQUEMA_BASE" != "$ESQUEMA_ESPERADO" ]; then
  falla "La base está en esquema v$ESQUEMA_BASE y este script maneja v$ESQUEMA_ESPERADO"
  terminar "ERROR" "esquema incompatible"
fi
ok "Esquema de la base: v$ESQUEMA_BASE"

# --- Versión declarada en la cabecera del .sql, si la declara ---
# Se acepta "-- Esquema: version 1", "-- esquema: 1" y variantes.
ESQUEMA_DECLARADO="$(grep -iEm1 '^[[:space:]]*--[[:space:]]*esquema' "$SCRIPT_SQL" \
  | grep -oE '[0-9]+' | head -n1)"

if [ -z "$ESQUEMA_DECLARADO" ]; then
  aviso "El script no declara versión de esquema en su cabecera"
elif [ "$ESQUEMA_DECLARADO" != "$ESQUEMA_BASE" ]; then
  falla "El script fue escrito para v$ESQUEMA_DECLARADO y la base está en v$ESQUEMA_BASE"
  terminar "ERROR" "el script no corresponde a esta base"
else
  ok "El script declara v$ESQUEMA_DECLARADO: coincide"
fi

# ============================================================
# 4. CABECERA DEL SCRIPT Y CONFIRMACIÓN
# ============================================================

titulo "Qué dice el script"

# Las líneas de comentario del principio son la descripción que yo mismo
# escribo al redactarlo: se muestran para poder decir que no a tiempo.
sed -n '1,/^[[:space:]]*[^-[:space:]]/p' "$SCRIPT_SQL" \
  | grep -E '^[[:space:]]*--' \
  | sed 's/^[[:space:]]*--[[:space:]]*/  /' \
  | grep -vE '^[[:space:]]*-+[[:space:]]*$' \
  | head -n 20

# Conteo aproximado de sentencias: cuenta los puntos y coma a fin de
# línea fuera de comentario. Es orientativo y así se presenta.
SENTENCIAS="$(grep -vE '^[[:space:]]*--' "$SCRIPT_SQL" | grep -cE ';[[:space:]]*$')"

titulo "Estado actual del corpus"
ENTRADAS_ANTES="$(consultar 'SELECT COUNT(*) FROM entradas;')"
FAMILIAS_ANTES="$(consultar 'SELECT COUNT(*) FROM familias;')"
printf '  Entradas: %s     Familias: %s\n' "$ENTRADAS_ANTES" "$FAMILIAS_ANTES"
printf '  Sentencias a aplicar (aproximado): %s\n' "$SENTENCIAS"

if [ -t 0 ]; then
  printf '\n¿Aplicar? [s/N] '
  read -r RESPUESTA
  case "$RESPUESTA" in
    s|S|si|SI|Si) ;;
    *) terminar "ERROR" "cancelado por el usuario" ;;
  esac
fi

# ============================================================
# 5. RESPALDO. ES LO ÚLTIMO ANTES DE ESCRIBIR Y NO ES OPCIONAL.
# ============================================================

titulo "Respaldo"

mkdir -p "$CARPETA_RESPALDOS" || terminar "ERROR" "no se pudo crear la carpeta de respaldos"
RESPALDO="$CARPETA_RESPALDOS/corpus-$SELLO.sqlite"

# VACUUM INTO produce una copia consistente sin depender del estado del
# journal, cosa que un cp no garantiza si algo dejó la base a medias.
if sqlite3 -batch "$BASE" "VACUUM INTO '$RESPALDO';" 2>/dev/null; then
  ok "Respaldo: $RESPALDO ($(du -h "$RESPALDO" | cut -f1))"
else
  aviso "VACUUM INTO falló; se intenta copia directa"
  if cp "$BASE" "$RESPALDO"; then
    ok "Respaldo por copia: $RESPALDO"
  else
    falla "No se pudo respaldar. No se importa nada."
    terminar "ERROR" "respaldo imposible"
  fi
fi

# Rotación: los respaldos viejos se borran de a uno, nunca en bloque.
ls -1t "$CARPETA_RESPALDOS"/corpus-*.sqlite 2>/dev/null \
  | tail -n +$((RESPALDOS_A_CONSERVAR + 1)) \
  | while read -r VIEJO; do rm -f "$VIEJO"; done

# ============================================================
# 6. APLICACIÓN
# ============================================================

titulo "Aplicando"

# Si el script no trae su propia transacción, se le envuelve una: sin
# eso, un fallo a mitad de camino deja el corpus a medio importar.
if grep -qiE '^[[:space:]]*BEGIN([[:space:]]+TRANSACTION)?[[:space:]]*;' "$SCRIPT_SQL"; then
  ok "El script trae su propia transacción"
  ABRE=""; CIERRA=""
else
  aviso "El script no trae transacción: se le envuelve una"
  ABRE="BEGIN;"; CIERRA="COMMIT;"
fi

SALIDA_SQL="$(mktemp)"

# Momento de arranque, leído del MISMO reloj que va a escribir el script
# (el de SQLite, en hora local). Sirve para que el listado final muestre
# lo que acaba de entrar y no todo lo tocado hoy.
MOMENTO="$(consultar "SELECT datetime('now','localtime');")"

# .bail on detiene en el primer error, y al salir sqlite3 con una
# transacción abierta, SQLite la deshace. Ahí está la atomicidad.
# .changes on imprime las filas afectadas por cada sentencia: es lo
# único que distingue un UPDATE aplicado de uno cuyo WHERE no matcheó.
# Los envoltorios van en bloques if y no en "[ ... ] && echo": un && que
# no se ejecuta devuelve 1, y si es el último comando del grupo, con
# pipefail la tubería entera reporta un fallo que nunca ocurrió.
{
  echo "PRAGMA foreign_keys = ON;"
  echo ".bail on"
  echo ".changes on"
  if [ -n "$ABRE" ]; then echo "$ABRE"; fi
  cat "$SCRIPT_SQL"
  if [ -n "$CIERRA" ]; then echo "$CIERRA"; fi
} | sqlite3 -batch "$BASE" > "$SALIDA_SQL" 2>&1

# El código que importa es el de sqlite3, no el de la tubería.
CODIGO_SQLITE=${PIPESTATUS[1]}

# La salida del CLI se muestra entera: es el detalle por sentencia.
if [ -s "$SALIDA_SQL" ]; then
  sed 's/^/  /' "$SALIDA_SQL"
fi

if [ "$CODIGO_SQLITE" -ne 0 ]; then
  falla "sqlite3 terminó con código $CODIGO_SQLITE"
  rm -f "$SALIDA_SQL"

  # No se AFIRMA que la base quedó como estaba: se comprueba. Decir que
  # hubo rollback sin mirar es exactamente el tipo de dato falso que un
  # informe de error no puede permitirse.
  echo
  ENTRADAS_AHORA="$(consultar 'SELECT COUNT(*) FROM entradas;')"
  FAMILIAS_AHORA="$(consultar 'SELECT COUNT(*) FROM familias;')"
  printf '  Entradas: %s antes → %s ahora\n' "$ENTRADAS_ANTES" "$ENTRADAS_AHORA"
  printf '  Familias: %s antes → %s ahora\n' "$FAMILIAS_ANTES" "$FAMILIAS_AHORA"
  echo

  if [ "$ENTRADAS_AHORA" = "$ENTRADAS_ANTES" ] && [ "$FAMILIAS_AHORA" = "$FAMILIAS_ANTES" ]; then
    ok "La base quedó como estaba: la transacción se deshizo"
  else
    aviso "LA BASE CAMBIÓ pese al error"
    echo "      Puede que el fallo sea posterior al COMMIT y la importación"
    echo "      haya entrado igual. Revisar el detalle de arriba ANTES de"
    echo "      reimportar: hacerlo dos veces choca contra UNIQUE."
    echo
    echo "      Para volver al estado previo:"
    echo "        cp '$RESPALDO' '$BASE'"
  fi

  echo
  echo "  Recordar que el driver colapsa todas las restricciones en un"
  echo "  mismo mensaje (GV-29): el texto dice CÓMO falló, no POR QUÉ."
  terminar "ERROR" "sqlite3 devolvió $CODIGO_SQLITE"
fi

rm -f "$SALIDA_SQL"
ok "Sentencias aplicadas sin error"

# ============================================================
# 7. VERIFICACIONES POSTERIORES
# ============================================================

titulo "Después de importar"

ENTRADAS_DESPUES="$(consultar 'SELECT COUNT(*) FROM entradas;')"
FAMILIAS_DESPUES="$(consultar 'SELECT COUNT(*) FROM familias;')"

printf '  Entradas: %s → %s (%+d)\n' \
  "$ENTRADAS_ANTES" "$ENTRADAS_DESPUES" \
  "$((ENTRADAS_DESPUES - ENTRADAS_ANTES))"
printf '  Familias: %s → %s (%+d)\n' \
  "$FAMILIAS_ANTES" "$FAMILIAS_DESPUES" \
  "$((FAMILIAS_DESPUES - FAMILIAS_ANTES))"

# --- Integridad física y referencial ---
INTEGRIDAD="$(consultar 'PRAGMA integrity_check;')"
if [ "$INTEGRIDAD" = "ok" ]; then
  ok "Integridad de la base: correcta"
else
  falla "integrity_check: $INTEGRIDAD"
fi

FK_ROTAS="$(sqlite3 -batch "$BASE" 'PRAGMA foreign_key_check;' 2>/dev/null)"
if [ -z "$FK_ROTAS" ]; then
  ok "Claves foráneas: sin violaciones"
else
  falla "Claves foráneas violadas:"
  echo "$FK_ROTAS" | sed 's/^/      /'
fi

# --- Vínculos muertos en la columna relaciones ---
# La columna no tiene integridad referencial (RF-08): una relación a un
# código inexistente se guarda igual y nadie avisa. El CTE parte la
# lista por comas y descarta el prefijo "tipo:" de cada par.
titulo "Vínculos de la columna relaciones"

VINCULOS_ROTOS="$(sqlite3 -noheader -batch "$BASE" "
WITH RECURSIVE
  partes(origen, resto, token) AS (
    SELECT codigo, relaciones || ',', ''
      FROM entradas
     WHERE relaciones <> ''
    UNION ALL
    SELECT origen,
           substr(resto, instr(resto, ',') + 1),
           substr(resto, 1, instr(resto, ',') - 1)
      FROM partes
     WHERE resto <> ''
  ),
  destinos(origen, destino) AS (
    SELECT origen,
           trim(CASE WHEN instr(token, ':') > 0
                     THEN substr(token, instr(token, ':') + 1)
                     ELSE token END)
      FROM partes
     WHERE trim(token) <> ''
  )
SELECT origen || ' → ' || destino
  FROM destinos d
 WHERE NOT EXISTS (SELECT 1 FROM entradas e WHERE e.codigo = d.destino)
 ORDER BY origen, destino;
" 2>/dev/null)"

if [ -z "$VINCULOS_ROTOS" ]; then
  ok "Todos los vínculos apuntan a códigos existentes"
else
  aviso "Vínculos a códigos inexistentes:"
  echo "$VINCULOS_ROTOS" | sed 's/^/      /'
  echo
  echo "  No invalidan la importación: se corrigen en gbCorpus, en el"
  echo "  campo Relaciones de cada entrada de la izquierda."
fi

# --- Entradas tocadas por ESTA importación ---
# El filtro es el sello tomado antes de aplicar, no la fecha del día: un
# corpus que ya recibió otra importación hoy, o ediciones desde gbCorpus,
# listaría de más. Decir de más es la misma falta que decir de menos.
titulo "Entradas escritas por esta importación"

TOCADAS="$(sqlite3 -noheader -batch "$BASE" "
SELECT '  ' || codigo || '  ' || substr(titulo, 1, 62)
  FROM entradas
 WHERE fecha_modificacion >= '$MOMENTO'
 ORDER BY prefijo, numero;
" 2>/dev/null)"

if [ -n "$TOCADAS" ]; then
  echo "$TOCADAS"
else
  # Un script que escribe date('now') deja solo la fecha, sin hora, y
  # queda por debajo del sello. No es un error: es que ese script no
  # permite distinguir una corrida de otra. Se dice y se lista por día.
  aviso "El script escribe la fecha sin hora: no se puede aislar esta corrida"
  echo "      Para que el listado sea exacto, los scripts deben usar"
  echo "      datetime('now','localtime') en fecha_modificacion."
  echo
  echo "  Entradas con modificación de hoy (todas, no solo estas):"
  sqlite3 -noheader -batch "$BASE" "
  SELECT '    ' || codigo || '  ' || substr(titulo, 1, 60)
    FROM entradas
   WHERE date(fecha_modificacion) = date('now')
   ORDER BY prefijo, numero;
  " 2>/dev/null
fi

terminar "OK" "importación aplicada"
