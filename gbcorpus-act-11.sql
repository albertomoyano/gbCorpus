-- ============================================================
-- gbCorpus — actualización: corrección de SC-05, dos GV y dos SC
-- Esquema: 1
-- Origen: análisis léxico del proyecto y ventana de variantes
--         (solapa «Escanear», gbpublisher)
-- Fecha:  2026-10-09
--
-- CORRECCIÓN:
--   SC-05  perl-base NO alcanza: hace falta el paquete perl
-- ALTAS:
--   GV-90  perl-base no trae PerlIO ni Encode
--   GV-91  Pandoc: sourcepos no existe para el lector markdown
--   SC-47  Análisis léxico: oraciones y variantes en perl
--   SC-48  Ir del resultado al editor: buscar en el texto actual
-- RELACIÓN:
--   SC-46  suma vinculo:SC-47
--
-- NUMERACIÓN TOMADA DE docs/corpus.md DEL REPO (6a4889f):
-- ÚLTIMAS GV-89 Y SC-46.
-- ============================================================

BEGIN TRANSACTION;

-- ------------------------------------------------------------
-- 1. SC-05: LA AFIRMACIÓN SOBRE perl-base ERA FALSA
--    EL WHERE EXIGE QUE EL TEXTO VIEJO ESTÉ: SI NO ESTÁ, EL INFORME DEL
--    IMPORTADOR MUESTRA 0 FILAS Y NO SE PISA NADA A CIEGAS
-- ------------------------------------------------------------

UPDATE entradas
   SET cuerpo = replace(cuerpo,
         '- `perl-base` es Essential en Debian/Ubuntu: cero dependencias nuevas.',
         '- Hace falta el paquete `perl` completo, NO solo `perl-base`. `perl-base` es Essential, pero no trae `PerlIO` ni `Encode`, y el script abre los archivos con `:encoding(UTF-8)`, que los necesita (GV-90). En el `.deb`: `Depends: perl`, sin versión. `IntegridadSistema` verifica el paquete `perl`, no el binario, que también lo trae `perl-base`.'),
       entorno = 'perl / -CSD / Gambas 3.22',
       relaciones = relaciones || ', vinculo:GV-90',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-05'
   AND instr(cuerpo, '- `perl-base` es Essential en Debian/Ubuntu: cero dependencias nuevas.') > 0;

-- ------------------------------------------------------------
-- 2. GV-90
--    EL orden SE DERIVA DEL ÚLTIMO DE LA FAMILIA, NO SE ESCRIBE A MANO
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'GV', 90, 'GV-90',
  'perl-base no trae PerlIO ni Encode: :encoding(UTF-8) necesita el paquete perl',
  'SC-05 afirmaba que alcanzaba con `perl-base`, que es Essential. No es así para los scripts del proyecto: abren los archivos con `:encoding(UTF-8)`, y ese layer necesita `PerlIO` y `Encode`, que `perl-base` NO trae.

Medido limitando `@INC` a la carpeta de `perl-base`:

    Can''t locate PerlIO.pm in @INC (you may need to install the PerlIO module)

Falla igual `buscar_regex.pl` (modo `probar`) que `analizar_lexico.pl`. Con `perl` completo, los dos andan.

De qué paquete viene cada módulo, medido en la máquina del editor (Linux Mint, base Ubuntu 24.04, Perl 5.38):

    PerlIO.pm            perl-modules-5.38
    PerlIO/encoding.pm   libperl5.38t64
    Encode.pm            libperl5.38t64 (y también libencode-perl, si está)

El paquete `perl` depende de `perl-base`, `perl-modules-5.38` y `libperl5.38t64`.

`libencode-perl` es una versión más nueva de Encode que se distribuye aparte y que instala como dependencia algún otro programa. Si está, perl la prefiere, porque su carpeta va antes en `@INC`; si no está, usa la de `libperl5.38t64`, que también trae `Encode.pm` (verificado con `dpkg -L`). No hace falta declararla.

CONSECUENCIA: en el `.deb`, `Depends: perl`, SIN versión. Los paquetes de los módulos llevan la versión de Perl en el nombre y cambian de una versión de Mint a otra; `perl` es el nombre estable que trae los que correspondan. En `IntegridadSistema` se verifica el PAQUETE `perl` (`DEP_PAQUETE`), no el comando: el binario `perl` lo trae también `perl-base` y la verificación daría verde sin servir.',
  'vigente', 'empirica', 'Perl 5.38 / Linux Mint (base Ubuntu 24.04) / contenedor Ubuntu 24.04',
  '2026-10', 'vinculo:SC-05,apoya:SC-47', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'GV';

-- ------------------------------------------------------------
-- 3. GV-91
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'GV', 91, 'GV-91',
  'Pandoc: la extensión sourcepos no existe para el lector markdown',
  'La extensión `sourcepos`, que anota en el AST la posición de cada elemento en el archivo fuente, NO está disponible para el lector `markdown` de Pandoc, que es el que usa gbpublisher. Medido:

    pandoc -f markdown+sourcepos ...
    The extension sourcepos is not supported for markdown

    pandoc --list-extensions=markdown | grep sourcepos    -> -sourcepos  (no se puede activar)
    pandoc --list-extensions=commonmark | grep sourcepos  -> -sourcepos  (existe, desactivada)

Existe para la familia CommonMark, pero cambiar de lector para obtenerla cambiaría el parseo de todo el proyecto.

CONSECUENCIA: lo que se calcula sobre el AST (SC-46, SC-47) no puede decir en qué línea del `.md` está. Para llevar al usuario al lugar, se busca en el texto (SC-48).',
  'vigente', 'empirica', 'Pandoc 3.1.3 / contenedor Ubuntu 24.04',
  '2026-10', 'apoya:SC-48', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'GV';

-- ------------------------------------------------------------
-- 4. SC-47
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'SC', 47, 'SC-47',
  'Análisis léxico: oraciones y variantes en perl, sobre el texto que separó el AST',
  'DECISIÓN CERRADA. Segunda parte del análisis del proyecto (SC-46): ORACIONES del cuerpo y VARIANTES de una misma palabra en todo el proyecto.

QUIÉN HACE QUÉ

- `engine/analizar_proyecto.lua`, con `--metadata gb-texto=RUTA`, escribe además el texto de cada bloque en RUTA, una línea por bloque: `ctx TAB clase TAB parrafo TAB texto`. Perl NO vuelve a leer el Markdown: recibe el texto que el AST ya separó, sin citas, notas, fórmulas ni código.
- `engine/analizar_lexico.pl` corre UNA SOLA VEZ sobre todos los archivos, al final: las variantes se comparan entre capítulos. Recibe `abreviaturas tildes clases_cuerpo` y luego pares `nombre texto`.
- `m_AnalizarProyecto` arma la carpeta temporal, pasa como clases de cuerpo las presentes en el proyecto que `Destino()` clasifica como cuerpo (el mismo criterio de párrafo que la grilla), lee la salida y la borra.
- Lua no sirve para esto: sus patrones no reconocen letras fuera de ASCII (GV-88).

ORACIONES

Una oración termina en . ? ! o … (con cierres « » ” ’ ) ] detrás) SOLO si la palabra que sigue empieza con mayúscula; admite antes ¿ ¡ « “ ( [ —. No cortan:

- las abreviaturas de `engine/analizar_lexico_abreviaturas.txt` (tratamientos y remisiones que suelen ir seguidos de mayúscula: Dr., Sra., cf., ed., EE. UU.);
- las iniciales de una letra (J. L. Borges);
- un número o una minúscula detrás (p. 23, vol. 3, a. C.): no hace falta listarlas.

La lista es PROPIA DEL PROYECTO: el apéndice de abreviaturas del DPD, que era la fuente prevista, ya no está en línea (la dirección redirige a la portada). «etc.» no se lista a propósito: al final de oración su punto también la cierra.

Se miden solo las oraciones de los párrafos del cuerpo. La mediana va por dos (`mediana_x2`), siempre entera, para no depender del separador decimal regional.

VARIANTES: TRES CLASES, CON FILTROS

Quitar las tildes y agrupar NO sirve en castellano: medido sobre `docs/corpus.md`, dio 99 grupos de tilde y 773 de mayúscula, casi todos pares correctos (como/cómo, el/él, cambio/cambió) o mayúsculas de comienzo de oración.

- Guion: on-line/online. Clave: la forma sin guiones.
- Mayúscula dentro de la oración: Estado/estado. No cuentan la primera palabra de la oración, las palabras escritas todas en mayúsculas ni los títulos.
- Tilde: SOLO la lista cerrada de `engine/analizar_lexico_tildes.txt`. Optativas (solo, demostrativos): se informan si aparecen las dos formas. Suprimidas (esto, eso, aquello; guion, truhan y los demás monosílabos de la Ortografía 2010): se informa toda aparición con tilde. Fuentes en la cabecera del archivo: RAE, Libro de estilo, «Acentuación», y Ortografía, «Palabras con diptongo».
- La falta de tilde en general (boton/botón) NO es variante: la detecta el corrector ortográfico.
- Las citas en bloque NO se analizan: respetan la grafía del original.

No se usa `Unicode::Normalize`: con la lista cerrada no hace falta quitar tildes.

SALIDA Y PRESENTACIÓN

Registros por línea, campos por NUL: `O` por archivo, `OT` total, `V` por forma de cada grupo, `X` por oración de ejemplo (hasta 8 por forma). La grilla suma la sección LÉXICO; las variantes van a `FVariantes` (SC-48).

DEPENDENCIA: el paquete `perl` completo (GV-90).

Verificado: banco con el módulo, el formulario, el filtro y el script reales; el editor lo probó en 3.22 sobre un libro real.',
  'vigente', 'empirica', 'gbpublisher / Gambas 3.22 / Pandoc 3.1.3 / Perl 5.38',
  '2026-10', 'vinculo:SC-46,vinculo:SC-05,vinculo:GV-88,vinculo:GV-90,vinculo:SC-48', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'SC';

-- ------------------------------------------------------------
-- 5. SC-48
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'SC', 48, 'SC-48',
  'Ir de un resultado al editor: buscar en el texto actual, no guardar posiciones',
  'DECISIÓN CERRADA. Para llevar al usuario desde un resultado al lugar en el editor, se BUSCA en el texto que el editor tiene en ese momento. No se guardan posiciones al analizar: mientras se corrige, quedarían viejas. Además, lo que sale del AST no tiene número de línea (GV-91).

EL PATRÓN, como lo aplica `m_AnalizarProyecto.IrAEjemplo`:

1. Abrir el archivo SOLO si no es el que está en el editor, con `m_Estructura.AbrirArchivo(sRel)`: pasa por el combo, con el aviso de cambios sin guardar (SC-06) y sin la recarga inútil de GV-53. Si ya está abierto no se la llama: preguntaría sin motivo. Es pública para esto: es la única forma de abrir un archivo del proyecto desde otro módulo.
2. Buscar con `m_FuncionesGenericas.BuscarEnTexto` sobre `m_EditorPrincipal.Texto()`, distinguiendo mayúsculas y como palabra completa.
3. Si hay varias apariciones, elegir la del párrafo que contiene el comienzo del contexto (las cuatro primeras palabras de la oración de ejemplo). Si ninguno lo contiene —una cursiva o una cita `[@clave]` en el medio cambian el texto del `.md`—, la primera.
4. Saltar con `m_EditorPrincipal.IrA(PosicionDe(línea, columna), largo)`, dejar la forma en `txtBuscarPalabra` para seguir con F3, y poner el foco en el editor.

LA VENTANA

No modal y encima del principal: `Show` y `TopOnly = True`, como `FOrtografia`. Una sola: el módulo guarda la referencia y la suelta cuando la ventana avisa que se cerró. Muestra la hora del análisis y tiene «Actualizar». Se recarga al terminar un análisis nuevo y se cierra al cancelarlo o al cerrar o cambiar de proyecto. Cada análisis crea arrays NUEVOS en lugar de vaciar los viejos: una ventana abierta conserva los suyos hasta que se la recarga.

El salto va en `Click` de la grilla de ejemplos, no en `Select`: asignar `Row` dispara `Select` pero nunca `Click` (GV-78), así que llenar la grilla no mueve el editor.

Verificado en banco con las funciones reales (`AbrirArchivo`, `BuscarEnTexto`, `PosicionDe`): mismo archivo sin aviso, otro archivo con un aviso, elección de la segunda aparición por el contexto, cierre con `Detener`. El editor lo probó en 3.22.',
  'vigente', 'empirica', 'gbpublisher / Gambas 3.22',
  '2026-10', 'vinculo:SC-47,vinculo:GV-91,vinculo:SC-06,vinculo:GV-53,vinculo:GV-78', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'SC';

-- ------------------------------------------------------------
-- 6. SC-46: RELACIÓN CON SU SEGUNDA PARTE
-- ------------------------------------------------------------

UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-47',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-46'
   AND instr(relaciones, 'SC-47') = 0;

COMMIT;

-- ============================================================
-- VERIFICACIÓN POSTERIOR
-- ============================================================

SELECT codigo, titulo, estado, evidencia, orden
  FROM entradas
 WHERE codigo IN ('SC-05', 'GV-90', 'GV-91', 'SC-46', 'SC-47', 'SC-48')
 ORDER BY prefijo, orden;
