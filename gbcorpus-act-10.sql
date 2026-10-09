-- ============================================================
-- gbCorpus — actualización: tres GV y una SC
-- Esquema: 1
-- Origen: análisis del proyecto (solapa «Escanear», gbpublisher)
-- Fecha:  2026-10-09
--
-- ALTAS:
--   GV-87  Pandoc: pandoc.utils.references solo devuelve las citadas
--   GV-88  Lua: los patrones no reconocen letras fuera de ASCII
--   GV-89  Pandoc: Cite, nota y alt de imagen también son Str
--   SC-46  Análisis del proyecto: conteo sobre el AST de Pandoc
--
-- NUMERACIÓN TOMADA DE docs/corpus.md DEL REPO (e22e052):
-- ÚLTIMAS GV-86 Y SC-45.
-- ============================================================

BEGIN TRANSACTION;

-- ------------------------------------------------------------
-- 1. GV-87
--    EL orden SE DERIVA DEL ÚLTIMO DE LA FAMILIA, NO SE ESCRIBE A MANO
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'GV', 87, 'GV-87',
  'Pandoc: pandoc.utils.references solo devuelve las entradas citadas',
  'Con `--bibliography`, un filtro Lua puede leer las entradas del `.bib` con `pandoc.utils.references(doc)`: cada una trae `id` y, si tiene fecha, `issued`. No hace falta citeproc ni un lector de BibTeX propio.

PERO DEVUELVE SOLO LAS CITADAS. Con un `.bib` de tres entradas y dos citadas en el documento, devuelve dos. Para obtenerlas todas, el documento tiene que llevar `nocite` con `@*`:

    ---
    nocite: |
      @*
    ---

Ese YAML tiene que ir EN UN ARCHIVO de entrada. Pasado como `-M nocite=''@*''` (o `--metadata`) NO funciona: llega como texto y no como cita, y la función sigue devolviendo solo las citadas.

El lector toma el formato por la extensión: `.bib` se lee como biblatex.

Forma de la fecha, medida:

- `date={2020}` y `year={2019}` dan `issued["date-parts"][1][1]` = el año.
- `date={2018/2020}` da DOS fechas en `date-parts`: la primera es el comienzo del rango.
- Sin `date` ni `year`, y con `year={s.f.}`, no hay `date-parts`: el año queda vacío.

Lo usa el análisis del proyecto (SC-46) para cruzar las claves citadas con el `.bib` y detectar las entradas sin citar.',
  'vigente', 'empirica', 'Pandoc 3.1.3 / contenedor Ubuntu 24.04',
  '2026-10', 'apoya:SC-46', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'GV';

-- ------------------------------------------------------------
-- 2. GV-88
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'GV', 88, 'GV-88',
  'Lua: los patrones no reconocen letras fuera de ASCII',
  'El Lua de Pandoc es Lua 5.4 (`_VERSION`). Sus patrones trabajan por BYTES: las clases `%a`, `%w` y `%p` solo conocen ASCII. Medido:

    ("análisis"):match("^%a+$")   ->  nil
    ("año"):find("%w+")           ->  1  1      (solo la «a»)
    #"análisis"                   ->  13        (bytes)
    utf8.len("análisis")          ->  9         (caracteres)

La biblioteca `utf8` SÍ está disponible: `utf8.len` cuenta caracteres y `utf8.codes` recorre por punto de código. Para clasificar un carácter fuera de ASCII hay que hacerlo a mano sobre el punto de código.

Es el mismo problema que llevó a descartar `gb.pcre` (SC-05). En un filtro, lo que exija reconocer letras en castellano —palabras, frecuencias, repeticiones— no se resuelve con patrones de Lua: va a perl con `-CSD`.

`engine/analizar_proyecto.lua` decide si un `Str` es palabra recorriendo `utf8.codes` y tratando como puntuación el ASCII no alfanumérico, ¡ « · » ¿, el espacio duro y el bloque U+2000–U+206F.',
  'vigente', 'empirica', 'Pandoc 3.1.3 / Lua 5.4 (pandoc lua) / contenedor Ubuntu 24.04',
  '2026-10', 'vinculo:SC-05,apoya:SC-46', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'GV';

-- ------------------------------------------------------------
-- 3. GV-89
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'GV', 89, 'GV-89',
  'Pandoc: el texto de un Cite, una nota o el alt de una imagen también son Str',
  'Contar todos los `Str` del documento con el recorrido por defecto (`typewise`) no da las palabras del texto. En un párrafo de unas veinte palabras dio 32. Entran:

- el texto crudo de cada cita: `[@perez2020; @gomez2019, p. 3]` deja `Str "[@perez2020;"`, `Str "@gomez2019,"`… dentro del `Cite`;
- el contenido de las notas al pie (`Note`), que es otro texto;
- el texto alternativo de la imagen de una figura: en Pandoc 3, `![Pie](x.png)` solo en su párrafo da un `Figure` cuyo `caption` y cuyo `Image` interior traen EL MISMO texto.

Para contar hay que recorrer el árbol a mano o con `topdown` (GV-85) y cortar en `Cite` e `Image`, y medir `Note` aparte.

Cómo parte el texto el lector, medido:

- Un `Str` es lo que va entre espacios. La puntuación queda pegada: `Str "«claro»."`.
- «socio-económico» es UN `Str`; la raya de inciso pegada también: `Str "—según"`.
- El espacio duro une: `p.~3` da `Str "p.\160\&3"`.
- El YAML del encabezado va a `meta`, no a `blocks`.
- Una lista compacta da `Plain`, no `Para`.

El documento se manda a `--output /dev/null`, así en stdout queda solo lo que escribe el filtro con `io.write`, NUL incluidos.',
  'vigente', 'empirica', 'Pandoc 3.1.3 / contenedor Ubuntu 24.04',
  '2026-10', 'vinculo:GV-85,apoya:SC-46', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'GV';

-- ------------------------------------------------------------
-- 4. SC-46
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'SC', 46, 'SC-46',
  'Análisis del proyecto: el conteo sale del AST de Pandoc, sin los filtros de producción',
  'DECISIÓN CERRADA para la solapa «Escanear» de FMain (`gvAnalizarProyecto`, `btnAnalizarProyecto`, `btnCancelarAnalizar`).

QUÉ CUENTA CADA PARTE

- `engine/analizar_proyecto.lua` recorre el AST y emite un registro por línea, campos separados por NUL. No modifica el documento. El protocolo está en la cabecera del filtro y no se cambia de un lado solo.
- `m_AnalizarProyecto` lanza Pandoc, agrega los registros, decide el destino de cada texto con el catálogo de shortcodes (RF-11), cruza las claves con el `.bib` y arma la grilla. `CAnalisisArchivo` guarda los conteos de un archivo o del total.
- perl queda para la parte léxica (oraciones, frecuencias): en Lua no se puede (GV-88). El control de cercanía de `m_EscanerTipografico` ya cubre los ecos.

POR QUÉ EL AST Y NO EL TEXTO

Es el mismo lector que genera el XML: un título que el análisis no cuenta tampoco se publica. Con regex, sobre el Markdown o en Gambas, habría que reimplementar el parser.

POR QUÉ SIN LOS FILTROS DE PRODUCCIÓN

`cite-to-xref`, `cite-to-biblioref-db` y `fenced-divs-to-elements-db` serializan el contenido con `pandoc.write` y dejan XML crudo, sin palabras que contar. `dos-partes`, `recuadros`, `codigo` y `conversacion` frenan ante un bloque mal formado, y el análisis se usa sobre borradores. Que un bloque esté bien formado lo controla la producción. Los shortcodes no son un preproceso: son divs y spans con clase, y el lector solo ya los trae.

INVOCACIÓN

- Un proceso por archivo: Pandoc concatena las entradas y se perdería la columna.
- `pandoc ARCHIVO --from markdown --to plain --lua-filter <filtro> --output /dev/null`, con `Exec` y array (SC-05).
- La bibliografía, aparte: un YAML temporal con `nocite` como entrada, `--bibliography referencias/ref-<proyecto>.bib` y `--metadata gb-analisis=bib` (GV-87).
- Asíncrono y cancelable con el patrón de `m_AuditarJats.EjecutarHerramienta`: la sentencia `Wait` entra al bucle de eventos.
- La lista de archivos es `m_BuscarRegex.ObtenerArchivosMD()`, la definición única del proyecto.

CRITERIOS

- Palabra: un `Str` con al menos una letra o un dígito. No cuentan fórmulas, código, el texto de las citas ni el alt de las imágenes (GV-89).
- Destino por la clase del div que contiene el texto: grupo `estructura` del catálogo, cuerpo; `fig` y `table`, pie; grupo `composicion` (`espaciov`), no se cuenta; cualquier otra clase, «bloque especial».
- Párrafo: `Para` del cuerpo. No lo son los ítems de lista, los párrafos de notas y citas en bloque, ni los de bloques especiales.
- Índice de Price: entradas citadas, presentes en el `.bib` y con año, publicadas en los últimos cinco años calendario contando el en curso.

ESTIMACIÓN DE PÁGINAS

Dato empírico del editor, medido sobre muchos libros: 2200 caracteres con espacios por página de libro. En un mismo libro hay páginas de 2400 (llena, da el mínimo) y de 1900 (rala, da el máximo). Pliego de 32 páginas, 16 por cara. Redondeo hacia arriba. Es estimación de texto solo: no reserva lugar para figuras ni tablas, y la grilla lo dice. Las constantes viven en un solo lugar del módulo; pasan a la configuración solo si una colección con otra caja las necesita.

Verificado: compilado con gbc3 3.19 y ejecutado con el módulo, el catálogo y el filtro reales (archivo ilegible y cancelación incluidos); el editor generó el .deb, lo instaló y la prueba sobre un proyecto real funcionó en 3.22.',
  'vigente', 'empirica', 'gbpublisher / Gambas 3.22 / Pandoc 3.1.3',
  '2026-10', 'vinculo:SC-05,vinculo:SC-11,vinculo:RF-11,vinculo:GV-85', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'SC';

COMMIT;

-- ============================================================
-- VERIFICACIÓN POSTERIOR
-- ============================================================

SELECT codigo, titulo, estado, evidencia, orden
  FROM entradas
 WHERE codigo IN ('GV-87', 'GV-88', 'GV-89', 'SC-46')
 ORDER BY prefijo, orden;
