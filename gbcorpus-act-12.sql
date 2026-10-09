-- ============================================================
-- gbCorpus — actualización: el verso (SC-49) y su evidencia
-- Esquema: 1
-- Origen: shortcode verse con el paquete verse de LaTeX; mediciones
--         en contenedor (Pandoc 3.1.3, SaxonJ-HE 12.5, LuaLaTeX de
--         TeX Live 2023 con verse 2.4a, la misma versión que Mint)
-- Fecha:  2026-10-09
--
-- ALTAS:
--   SC-49  Verso: estrofas, versos y sangría por patrón
--   GV-92  Pandoc: un bloque entre las llaves del epígrafe pide
--          líneas en blanco alrededor
--   GV-93  verse: \\ lee el carácter que sigue
--   GV-94  verse dentro de \gbepigrafe: \@listi local
--   GV-95  Pandoc: el escritor DocBook sangra las líneas de un
--          RawBlock según la profundidad de la sección
-- CAMBIOS:
--   RC-DB-04  el verso pasa a <blockquote role="verso"> con un
--             <literallayout> por estrofa
--   SC-35     el texto del epígrafe puede ser un verso
--
-- NUMERACIÓN TOMADA DE docs/corpus.md DEL REPO (00433ae):
-- ÚLTIMAS GV-91 Y SC-48.
-- ============================================================

BEGIN TRANSACTION;

-- ------------------------------------------------------------
-- 1. SC-49
--    EL orden SE DERIVA DEL ÚLTIMO DE LA FAMILIA, NO SE ESCRIBE A MANO
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'SC', 49, 'SC-49',
  'Verso: estrofas, versos y sangría por patrón; el paquete verse en el PDF',
  'DECISIÓN CERRADA (decisión de Alberto). El verso se escribe con un verso por línea y las estrofas separadas por una línea en blanco. La sangría se da con un PATRÓN en la apertura, no con espacios en el texto:

    ::: {.verse patron="01"}

    Caminante, son tus *huellas*
    el camino y nada más;

    caminante, no hay camino,
    se hace camino al andar.

    [/verse]: # ()
    :::

EL PATRÓN

- Un dígito por verso: cuántas sangrías lleva, de 0 a 9.
- Un grupo vale para todas las estrofas, empezando de nuevo en cada una. Varios, separados por espacio, van uno por estrofa (un soneto: `patron="0110 0110 010 010"`). Otra cantidad de grupos frena.
- Los versos que exceden su grupo van sin sangría, como en `patverse`.
- `patron="alterno"`: los versos pares de cada estrofa, una sangría (el `altverse` del paquete).
- A diferencia de `patverse`, el primer dígito CUENTA: el paquete lo ignora siempre; acá no se usa `patverse` (ver PDF).
- Sin patrón, todo a cero.

El patrón es solo la forma de escribir. El canónico guarda el nivel de cada verso, y ninguna salida interpreta patrones.

Se descartó el bloque de líneas de Pandoc (`| ` al principio de cada verso): obliga a marcar cada línea y a fijar cuántos espacios son un nivel.

QUIÉN HACE QUÉ

- `verso.lua` controla y normaliza, con una sola regla para las tres cadenas (revista, libro y ODT), después de `conversacion.lua`. Deja un Div `.estrofa` por estrofa y un Div `.linea` por verso con el atributo `nivel`. Una marca que cruza versos (una bastardilla de dos versos) se parte en dos marcas iguales: ningún elemento del canónico cruza un fin de verso. Las notas, las citas, el código y las fórmulas no se parten.
- `cite-to-xref.lua` (revista) y `fenced-divs-to-elements-db.lua` (libro) solo serializan.
- `verso-comun.xsl`, incluido en las seis hojas como `conversacion-comun.xsl`, dice cuáles son las estrofas de un poema, los versos de una estrofa y el nivel de cada verso. Devuelve los nodos del canónico, no copias: las notas y las citas se numeran y resuelven en su lugar.

FRENA LA CONVERSIÓN, CON UN MENSAJE QUE CITA EL BLOQUE

- Algo que no es una estrofa: una lista, un título, una cita. El caso típico es una estrofa que empieza con «- », «# », «> » o «1. »; se escribe `\-`, `\#`, `\>` o `1\.`. En medio de la estrofa no pasa: Pandoc no abre una lista dentro de un párrafo (medido).
- Un verso dentro de otro, un verso vacío.
- Un identificador, otra clase u otro atributo que `patron` (un «patrón» con tilde también): se perderían sin aviso.
- Un patrón que no es `alterno` ni grupos de dígitos, o con una cantidad de grupos que no es uno ni la de estrofas.

EL CANÓNICO

- DocBook 5.2 base no tiene `<poetry>` ni `<line>` (RC-DB-04): `<blockquote role="verso">` con un `<literallayout role="verse">` por estrofa; cada verso, un `<phrase role="linea">`, con dos espacios por nivel delante. `<literallayout>` reproduce los espacios tal cual, así que cualquier procesador DocBook muestra la sangría. El `<phrase>` permite tomar el verso con sus marcas. El fin de verso se escribe `&#10;` y no como salto: el escritor DocBook de Pandoc sangra cada línea de un RawBlock según la profundidad de la sección, y esa sangría se sumaría a la del verso (GV-95). Valida contra el RNG de 5.2, con una nota adentro.
- JATS 1.4: `<verse-group>` (el poema) con un `<verse-group>` por estrofa, aunque haya una sola; cada verso, un `<verse-line>` con `indent-level` si lleva sangría. Valida contra la DTD Archiving 1.4; `<verse-line>` admite énfasis, `<xref>` y `<fn>`.
- Un canónico de libro anterior a esta decisión (`<literallayout role="verse">` sin `<phrase>`) frena las hojas con un mensaje: hay que regenerar el XML.

PDF (CONTRATO 14)

El paquete `verse` de Peter Wilson (en Mint, la 2.4a de 2009; lo que se usa existe desde la 2.2). Lo carga el contrato de libros y el preámbulo de revistas (`m_XML.ObtenerPreambuloEmbebido`), gemelos; en revistas reemplaza el `verse` que se redefinía ahí.

- Cada verso termina en `\\`; el último de cada estrofa, en `\\!`, que deja `\stanzaskip` (0,75 de línea); el último del poema, en nada.
- La sangría es `\vin` (`\vgap`, 1,5 em) una vez por nivel, delante del verso. Un verso que no entra sigue a `\vindent` (3 em) del margen del poema.
- Cada verso empieza con `\relax`: `\\` lee el carácter que sigue, y un verso que empieza con [, * o ! se rompería (GV-93).
- `gbverso`: el poema, en bastardilla, a `\leftmargini` del margen (2,5 em en libros; 14 pt en revistas, como la cita).
- `gbversoepigrafe`: el verso de un epígrafe, dentro del primer argumento de `\gbepigrafe`, con la letra del epígrafe y sin margen ni `\topsep` propios (GV-94).
- `\poemtitle` y la numeración no se usan (ver DIFERIDO).

HTML Y EPUB

`div.verso` con un `div.estrofa` por estrofa y un `span.verso-linea` por verso; la sangría es la clase `nivel-N`. El CSS reproduce el PDF: bastardilla, 0,75 em entre estrofas, cada verso un bloque con `padding-left: 3em` y `text-indent` de -3 em más 1,5 em por nivel, así que la primera línea queda en su sangría y la continuación a 3 em. En un epígrafe, `div.verso.verso-epigrafe`: la letra del epígrafe, sin bastardilla ni margen. Mismas reglas en `gbpublisher.css`, `gbpublisher-epub-libro.css`, `jats-to-html.xsl` y `m_GenerarEpub`; las clases son las mismas en libros y revistas. Antes eran `verse-group` y `verse-line` en revistas, con diseños distintos en cada salida y un filete a la izquierda en libros.

ODT

`verso.lua` lo resuelve en un párrafo por estrofa, con salto de línea entre versos y la sangría como un espacio eme y uno ene por nivel (1,5 em). Sin estilo propio: el ODT es para revisar.

EN UN EPÍGRAFE

El verso puede ser la primera parte del epígrafe (SC-35), solo, con las llaves en su propio párrafo y líneas en blanco alrededor (GV-92):

    ::: epigraph

    {

    ::: {.verse patron="01"}

    Versos…

    [/verse]: # ()
    :::

    }{Atribución}

    [/epigraph]: # ()
    :::

`dos-partes.lua` lo acepta y lo marca con la clase `en-epigrafe`: con ella `fenced-divs-to-elements-db.lua` emite los `<literallayout>` sin el `<blockquote>`, que `<epigraph>` no admite. JATS no cambia: `<disp-quote>` admite `<verse-group>`. Frena si el verso va con prosa al lado, si hay dos, si quedó fuera de las llaves o si está en la atribución.

DIFERIDO (decisión de Alberto: se encara más adelante)

    función                    PDF          HTML/EPUB              JATS                    DocBook base
    numeración de versos       \poemlines   contar en el XSLT;     sin lugar: verse-line   sin lugar: no hay
    y primer número                         margen angosto en EPUB no admite label         elemento por verso
    remisión a un verso        \label/\ref  ancla y enlace         id en verse-line + xref anchor en el phrase
    \flagverse (marca de       nativo       posible                label del verse-group   sin lugar
    estrofa)                                                       de la estrofa
    \\> (un verso en dos       nativo       br con sangría         no se puede expresar    no se puede expresar
    renglones)
    título y atribución del    \poemtitle*  h o p con clase        verse-group/title       blockquote/title y
    poema suelto                                                   y attrib                attribution
    poema en el sumario        \poemtitle   nav                    —                       —                (choca con SC-25)

El título y la atribución en Markdown pedirían el formato de dos partes (un atributo no admite bastardilla). Hoy la atribución la da el epígrafe, y en el cuerpo la referencia va en la prosa.

FUERA DE ESTA DECISIÓN

La dedicatoria en verso (SC-45): un verso corto se escribe como texto con saltos de línea manuales (decisión de Alberto).',
  'vigente', 'empirica',
  'Pandoc 3.1.3 / SaxonJ-HE 12.5 / LuaLaTeX, TeX Live 2023, verse 2.4a / xmllint (RNG DocBook 5.2, DTD JATS Archiving 1.4) / contenedor Ubuntu 24.04',
  '2026-10',
  'vinculo:RC-DB-04,vinculo:SC-35,vinculo:SC-33,vinculo:SC-34,vinculo:SC-43,vinculo:SC-45,vinculo:SC-25,vinculo:RF-11,vinculo:GV-92,vinculo:GV-93,vinculo:GV-94,vinculo:GV-95,vinculo:GV-85,vinculo:GV-86',
  'Probar en Mint: libro y revista (PDF, HTML, EPUB, ODT), con el verso suelto y en un epígrafe; la inserción desde el panel; los casos que frenan; epubcheck sobre un EPUB completo; los sabores JATS de revista (SciELO, Redalyc) y packtools con un verse-group. En el contenedor se probaron los filtros, las seis hojas (las de HTML y EPUB de libro con la plantilla aislada), el PDF con el contrato real y el ODT.',
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'SC';

-- ------------------------------------------------------------
-- 2. GV-92
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'GV', 92, 'GV-92',
  'Pandoc: un bloque entre las llaves de un bloque de dos partes pide líneas en blanco alrededor',
  'Un bloque cercado (`:::`) dentro de las llaves de un epígrafe (SC-35) solo se lee como bloque si tiene una línea en blanco antes y después, y la llave de apertura y la de cierre van en su propio párrafo.

MEDIDO CON Pandoc 3.1.3

Con las líneas en blanco:

    ::: epigraph

    {

    ::: {.verse patron="01"}

    Versos…

    [/verse]: # ()
    :::

    }{Atribución}

    [/epigraph]: # ()
    :::

da `Div epigraph [ Para "{", Div verse […], Para "}{Atribución}" ]`: el verso es un bloque, con su atributo, y las dos anclas desaparecen del árbol.

Sin ellas (`{` pegado a `::: {.verse …}`, y `:::` pegado a `}{…}`):

- `::: {.verse patron="0101"}` queda como texto del párrafo de la llave;
- el `:::` del verso cierra el epígrafe;
- el cierre del epígrafe queda suelto, como un párrafo «:::».

No pasa en silencio: la llave de cierre quedó fuera del bloque y `dos-partes.lua` frena con «hay una llave de apertura sin cerrar».

Es la misma regla que SC-33 (la línea en blanco antes del ancla es obligatoria), aplicada a un bloque dentro de las llaves.',
  'vigente', 'empirica', 'Pandoc 3.1.3 / contenedor Ubuntu 24.04',
  '2026-10', 'apoya:SC-49,vinculo:SC-35,vinculo:SC-33', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'GV';

-- ------------------------------------------------------------
-- 3. GV-93
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'GV', 93, 'GV-93',
  'verse: \\ lee el carácter que sigue; un verso que empieza con [, * o ! se rompe',
  'Dentro del entorno `verse` del paquete `verse`, `\\` mira el carácter siguiente para decidir su forma: `\\!` (fin de estrofa), `\\*` (sin corte de página), `\\>` (verso partido) y `\\[…]` (espacio extra). El salto de línea del archivo no lo impide: `\@ifnextchar` saltea los espacios.

MEDIDO (verse 2.4a, LuaLaTeX), con el verso anterior terminado en `\\`:

    [sic] dos     ! Missing number, treated as zero / Illegal unit of measure;
                  sale «sicdos»: lo que estaba entre corchetes se perdió
    *seis         sin error: el asterisco se pierde (lo tomó como \\*)
    !el camino    sin error: el signo se pierde y se abre una estrofa nueva

Los dos últimos son pérdidas silenciosas.

REGLA: cada verso empieza con `\relax` (`\relax[sic] dos`, `\relax\vin seis`). `\@ifnextchar` ve `\relax`, no el texto, y `\relax` no hace nada. Medido: los tres casos salen bien. Lo escriben `docbook-to-latex.xsl` y `jats-to-latex.xsl` (SC-49).',
  'vigente', 'empirica', 'LuaLaTeX / TeX Live 2023 / verse 2.4a / contenedor Ubuntu 24.04',
  '2026-10', 'apoya:SC-49', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'GV';

-- ------------------------------------------------------------
-- 4. GV-94
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'GV', 94, 'GV-94',
  'verse dentro de \gbepigrafe: el margen y el \topsep se quitan redefiniendo \@listi',
  '`verse` es una lista: toma el margen de `\leftmargini` y deja `\topsep` antes y después. Dentro de la minipágina de `\gbepigrafe` (SC-35) el verso tiene que alinearse con el bloque y quedar a la misma distancia del filete que un epígrafe en prosa.

MEDIDO (verse 2.4a, LuaLaTeX, coordenadas con pdftotext -bbox):

- `verse` sin cambios: arriba bien (al comienzo de una minipágina LaTeX no pone el `\topsep`); abajo, el `\topsep` separa el último verso del filete más que en prosa.
- `\vspace{-\topsep}` antes y después: abajo, el último verso queda 2 pt más cerca del filete que en prosa; arriba, el bloque sube sobre el texto anterior. Descartado.
- `\@listi` redefinido local al entorno, con `\leftmargin`, `\topsep`, `\partopsep`, `\itemsep` y `\parsep` en cero: del cuerpo al primer verso, 2,22 pt, igual que en prosa; del último verso a la atribución, 2,11 pt, igual que en prosa.

POR QUÉ \@listi: `\list` la ejecuta al abrir, antes de las declaraciones de `verse`. `verse` suma `\vindent` al margen y pone después `\parsep` = `\stanzaskip`, así que el espacio entre estrofas se conserva.

`\setlength{\leftmargini}{…}` antes de `\begin{verse}` también funciona para el margen (medido: 14 pt en revistas, `gbverso`), pero no toca el `\topsep`.

Aplicado en `gbversoepigrafe` (preambulo-contrato.tex, contrato 14, y su gemelo en m_XML).',
  'vigente', 'empirica', 'LuaLaTeX / TeX Live 2023 / verse 2.4a / poppler 24.02 / contenedor Ubuntu 24.04',
  '2026-10', 'apoya:SC-49,vinculo:SC-35', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'GV';

-- ------------------------------------------------------------
-- 4b. GV-95
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'GV', 95, 'GV-95',
  'Pandoc: el escritor DocBook sangra las líneas de un RawBlock según la profundidad de la sección',
  'Un `RawBlock` que devuelve un filtro no sale tal cual en el DocBook: el escritor de Pandoc lo mete en la sangría de la sección que lo contiene, dos espacios por nivel, en CADA línea del texto crudo menos la primera. `--wrap=none` no lo cambia: es la sangría del documento, no el corte de línea.

MEDIDO CON Pandoc 3.1.3, un verso con dos espacios delante del segundo verso:

    sin título antes (sin <section>):
    <literallayout role="verse"><phrase role="linea">Uno</phrase>
      <phrase role="linea">dos</phrase>

    después de un ## (dentro de una <section>):
      <literallayout role="verse"><phrase role="linea">Uno</phrase>
        <phrase role="linea">dos</phrase>

El segundo verso pasó de dos espacios a cuatro: en un `<literallayout>`, donde el espacio es contenido, la sangría del documento se suma a la del texto.

En un elemento donde el espacio no es contenido no importa. Donde sí lo es, el salto va como la referencia `&#10;`: el texto crudo queda en una sola línea, el escritor no tiene dónde sangrar, y el parser XML convierte la referencia en el salto. Medido: con `&#10;`, los espacios quedan iguales con y sin sección.

Caso del proyecto: `fenced-divs-to-elements-db.lua` (6.5) escribe así el verso (SC-49).',
  'vigente', 'empirica', 'Pandoc 3.1.3 / contenedor Ubuntu 24.04',
  '2026-10', 'apoya:SC-49,vinculo:RC-DB-04', NULL,
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'GV';

-- ------------------------------------------------------------
-- 5. RC-DB-04: EL VERSO
--    EL WHERE EXIGE QUE EL TEXTO VIEJO ESTÉ: SI NO ESTÁ, EL INFORME DEL
--    IMPORTADOR MUESTRA 0 FILAS Y NO SE PISA NADA A CIEGAS
-- ------------------------------------------------------------

UPDATE entradas
   SET cuerpo = replace(cuerpo,
         'Para verso: `<literallayout role="verse">`.',
         'Para verso (SC-49): `<blockquote role="verso">` con un `<literallayout role="verse">` por estrofa y un `<phrase role="linea">` por verso, con dos espacios por nivel de sangría delante y el fin de verso como `&#10;` (GV-95). En un epígrafe, los `<literallayout>` van sueltos dentro de `<epigraph>`, que no admite `<blockquote>`.'),
       relaciones = relaciones || ',vinculo:SC-49',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'RC-DB-04'
   AND instr(cuerpo, 'Para verso: `<literallayout role="verse">`.') > 0;

-- ------------------------------------------------------------
-- 6. SC-35: EL TEXTO DEL EPÍGRAFE PUEDE SER UN VERSO
-- ------------------------------------------------------------

UPDATE entradas
   SET cuerpo = replace(cuerpo,
         'UN FILTRO QUE FRENA SE VE',
         'EL TEXTO PUEDE SER UN VERSO (SC-49)

La primera parte puede ser un bloque `::: verse`, solo, con las llaves en su propio párrafo y líneas en blanco alrededor (GV-92). `dos-partes.lua` lo acepta (`verso1` en su tabla, sin gemelo en `m_Shortcodes.ProblemaDosPartes`, que controla las llaves y no los bloques) y lo marca con la clase `en-epigrafe`. Libro: los `<literallayout>` del verso dentro de `<epigraph>`. Revista: el `<verse-group>` dentro del `<disp-quote>`. PDF: el entorno `gbversoepigrafe` dentro de `\gbepigrafe`. HTML y EPUB: `div.verso.verso-epigrafe` dentro de `div.epigrafe`, con su letra y sin bastardilla.

UN FILTRO QUE FRENA SE VE'),
       relaciones = relaciones || ',vinculo:SC-49',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-35'
   AND instr(cuerpo, 'UN FILTRO QUE FRENA SE VE') > 0
   AND instr(cuerpo, 'EL TEXTO PUEDE SER UN VERSO') = 0;

COMMIT;

-- ============================================================
-- VERIFICACIÓN POSTERIOR
-- ============================================================

SELECT codigo, titulo, estado, evidencia, orden
  FROM entradas
 WHERE codigo IN ('SC-49', 'GV-92', 'GV-93', 'GV-94', 'GV-95', 'RC-DB-04', 'SC-35')
 ORDER BY prefijo, orden;

SELECT codigo, instr(cuerpo, 'SC-49') > 0 AS cita_sc49
  FROM entradas
 WHERE codigo IN ('RC-DB-04', 'SC-35');
