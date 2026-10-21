-- ============================================================
-- gbCorpus — actualización 49: alineación de párrafos en el PDF
--            (SC-61), primera instrucción de composición de un
--            tramo; SC-38 distingue las de punto y las de tramo
-- Esquema: 1
-- Origen: pedido de Alberto (21/10) surgido del uso real: una fecha y
--         un lugar a la derecha, un renglón centrado. Diseño acordado en
--         la conversación del 21/10: solo PDF, tres clases, una ficha
--         por párrafo, \noindent en las tres, sin corte de palabra y sin
--         espacio propio. Mini-tests en el contenedor (Pandoc 3.1.3,
--         SaxonJ-HE 12.5, LuaLaTeX de TeX Live 2023, xmllint). Numerado
--         contra ~/.gbcorpus/corpus.sqlite de Alberto (último aplicado:
--         act-48; SC-60 y GV-112 son las últimas).
-- Fecha:  2026-10-21
-- Aplicar: después de act-48
--
-- ALTAS:
--   GV-113  LaTeX: \raggedright, \centering y \raggedleft no parten palabras
--   GV-114  LaTeX: una nota al pie hereda las penalidades de corte del párrafo
--   GV-115  Pandoc: un RawInline al comienzo de un Para llega intacto a
--           <para> y <p>
--   SC-61   Alineación de párrafos en el PDF: alinear-izq, alinear-centro,
--           alinear-der
-- MODIFICA:
--   SC-38   instrucciones de punto y de tramo; el modo del catálogo dice
--           cuál es cuál; relación con SC-61
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-112 última GV', MAX(numero) = 112 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-60 última SC', MAX(numero) = 60 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-113 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-113' OR (prefijo = 'GV' AND numero = 113);
INSERT INTO verificacion SELECT 'GV-114 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-114' OR (prefijo = 'GV' AND numero = 114);
INSERT INTO verificacion SELECT 'GV-115 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-115' OR (prefijo = 'GV' AND numero = 115);
INSERT INTO verificacion SELECT 'SC-61 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-61' OR (prefijo = 'SC' AND numero = 61);
INSERT INTO verificacion SELECT 'SC-38 ancla de LAS REGLAS (una vez)', (length(cuerpo) - length(replace(cuerpo, '

LAS REGLAS

', ''))) = length('

LAS REGLAS

') FROM entradas WHERE codigo = 'SC-38';
INSERT INTO verificacion SELECT 'SC-38 ancla de la regla 6 (una vez)', (length(cuerpo) - length(replace(cuerpo, 'El grupo entró con el esquema 5 de gbShortcodes.', ''))) = length('El grupo entró con el esquema 5 de gbShortcodes.') FROM entradas WHERE codigo = 'SC-38';
INSERT INTO verificacion SELECT 'SC-38 sin la sección nueva', instr(cuerpo, 'DE UN PUNTO Y DE UN TRAMO') = 0 FROM entradas WHERE codigo = 'SC-38';
INSERT INTO verificacion SELECT 'SC-38 sin relación con SC-61', instr(relaciones, 'SC-61') = 0 FROM entradas WHERE codigo = 'SC-38';

-- ------------------------------------------------------------
-- 2. GV-113
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 113, 'GV-113', 'LaTeX: \raggedright, \centering y \raggedleft no parten palabras',
   'Las tres declaraciones de LaTeX ponen pegamento infinito (`0pt plus 1fil`) en `\rightskip`, en `\leftskip` o en los dos. Con ese pegamento, cualquier corte de línea es aceptable en la primera pasada de TeX, que no intenta partir palabras. La segunda pasada, la que sí parte, no llega a correr.

MEDIDO (LuaLaTeX, babel spanish, `book` 11 pt), un párrafo largo con palabras largas y una compuesta con guion (`socio-económicamente`), en cada declaración y justificado, a 4,5 cm, 6 cm y 9 cm de caja, contando los guiones a fin de línea con `pdftotext -raw`:

    justificado                     4,5 cm: 42 guiones; 6 cm: 32; 9 cm: 17
    \raggedright, \centering
      o \raggedleft                  0 guiones y 0 líneas desbordadas en los tres anchos
    las mismas con \hyphenpenalty=10000
      y \exhyphenpenalty=10000        0 guiones (4,5 cm)

El guion de una palabra compuesta tampoco se usa como corte.

LÍMITES

- Depende de que `\pretolerance` no sea negativo: con `-1`, TeX saltea la primera pasada. El proyecto no lo toca (ni `preambulo-*.tex` ni `m_XML`).
- Una palabra más ancha que la línea no tiene corte posible en la primera pasada, y la segunda la partiría. Con la caja del proyecto no ocurre.

Por esto SC-61 no agrega penalidades de corte: no hacen falta y tienen un costo (GV-114).',
   'vigente', 'empirica',
   'LuaHBTeX 1.17.0 / TeX Live 2023 (Debian) / babel spanish / poppler pdftotext / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-61,vinculo:GV-114',
   'Medido con la clase book y no con el preámbulo del proyecto: confirmar en Mint con un libro y una revista reales.',
   1130, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-113 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-113';

-- ------------------------------------------------------------
-- 3. GV-114
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 114, 'GV-114', 'LaTeX: una nota al pie hereda las penalidades de corte del párrafo, no su alineación',
   'El texto de `\footnote` se compone dentro de un `\insert`, con los parámetros vigentes en el lugar de la llamada. `\@parboxrestore`, que LaTeX ejecuta al abrir la nota, devuelve a su valor `\leftskip`, `\rightskip` y `\parfillskip`, pero no toca `\hyphenpenalty` ni `\exhyphenpenalty`.

MEDIDO (LuaLaTeX, babel spanish, caja de 6 cm), una nota larga dentro de `\begingroup\centering … \par\endgroup`:

    sin penalidades en el grupo              la nota sale justificada, 12 guiones
    con \hyphenpenalty=10000
      y \exhyphenpenalty=10000               la nota sale justificada, 0 guiones

En el segundo caso la nota se justifica sin poder partir: líneas flojas.

CONSECUENCIA: una declaración de alineación dentro de un grupo no le llega a una nota del párrafo, y la nota sale como cualquier otra. Una penalidad de corte, sí le llega. SC-61 no las usa (GV-113).',
   'vigente', 'empirica',
   'LuaHBTeX 1.17.0 / TeX Live 2023 (Debian) / babel spanish / poppler pdftotext / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-61,vinculo:GV-113',
   NULL,
   1140, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-114 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-114';

-- ------------------------------------------------------------
-- 4. GV-115
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 115, 'GV-115', 'Pandoc: un RawInline al comienzo de un Para llega intacto a <para> y a <p>',
   'Un filtro que inserta `pandoc.RawInline(''docbook'', ''<?gb-alinear der?>'')` como primer elemento de un `Para` (o `''jats''` en la cadena de revista) obtiene, sin cambios en el texto crudo:

    DocBook   <para>
                <?gb-alinear der?>19 de octubre de 2026, Ciudad de México
              </para>
    JATS      <p><?gb-alinear der?>19 de octubre de 2026, Ciudad de México</p>

A diferencia de un `RawBlock` (GV-95), el escritor DocBook no toca el texto de un `RawInline`. Sí indenta el contenido del `<para>`: antes de la instrucción queda un nodo de texto en blanco. Quien busque la instrucción como primer hijo tiene que saltear ese nodo (`node()[not(self::text()[normalize-space() = ''''])][1]`).

La instrucción pasa intacta por `cite-to-xref.lua` (revista) y por `ensamblar-capitulo-canonico.xsl` (libro). El capítulo valida contra el RNG de DocBook 5.2 con xmllint y el artículo contra la DTD Archiving 1.4: una instrucción de procesamiento dentro de un párrafo no cambia la validez.',
   'vigente', 'empirica',
   'Pandoc 3.1.3 / SaxonJ-HE 12.5 / xmllint / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-61,vinculo:GV-95,vinculo:SC-38',
   NULL,
   1150, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-115 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-115';

-- ------------------------------------------------------------
-- 5. SC-61
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 61, 'SC-61', 'Alineación de párrafos en el PDF: alinear-izq, alinear-centro, alinear-der',
   'DECISIÓN CERRADA (decisión de Alberto, 21/10). Segundo caso de las instrucciones de composición (SC-38) y primero de un tramo: alinea uno o más párrafos a la izquierda, al centro o a la derecha. Solo PDF, de libros y de revistas. En el EPUB y el HTML el párrafo sale como cualquier otro: una fecha y un lugar se leen mejor a la izquierda en una pantalla, y a la derecha en la página impresa.

    ::: alinear-der

    19 de octubre de 2026, Ciudad de México

    [/alinear-der]: # ()
    :::

TRES CLASES Y NO UNA CON ATRIBUTO

`alinear-izq`, `alinear-centro` y `alinear-der`. Con el modo `envolver`, el panel inserta el bloque directo sobre la selección, sin escribir nada a mano. Un atributo hubiera pedido un modo nuevo o escribirlo en la apertura, como `patron` en el verso (SC-49), que además significa otra cosa.

UNA FICHA POR PÁRRAFO

`alinear.lua` desenvuelve el bloque y pone `<?gb-alinear izq|centro|der?>` como primer nodo de cada párrafo, en JATS y en DocBook (GV-115). No es un par apertura/cierre alrededor del tramo: el grupo de LaTeX abre y cierra dentro del mismo párrafo y nunca queda desbalanceado, aunque el canónico se edite. Un par de instrucciones hermanas se habría partido con cualquier cosa que se metiera entre ellas (en libro, un título, porque Pandoc arma las secciones al escribir).

PDF

La plantilla de párrafo de cada hoja (`para` en `docbook-to-latex.xsl`, `p` en `jats-to-latex.xsl`) toma la ficha con `f:alinear-ficha`, no se la pasa a `apply-templates` y envuelve el párrafo con `f:alinear-abre` y `f:alinear-cierra` (`tex-comun.xsl`):

    izq      \begingroup\raggedright\noindent TEXTO\par\endgroup
    centro   \begingroup\centering\noindent TEXTO\par\endgroup
    der      \begingroup\raggedleft\noindent TEXTO\par\endgroup

- El `\par` va dentro del grupo: TeX lee `\leftskip` y `\rightskip` al cerrar el párrafo.
- Declaraciones y no los entornos `flushleft`, `center` y `flushright`. Los entornos son listas (`trivlist`) y agregan espacio arriba y abajo. El aire lo pone `espaciov` (SC-39): cada shortcode hace una sola cosa.
- `\noindent` en las tres, también en `izq` (decisión de Alberto).
- Sin corte de palabra en las tres (decisión de Alberto). Las declaraciones ya no parten (GV-113). No se agregan penalidades: una nota al pie del párrafo las heredaría y perdería su corte (GV-114). La alineación, en cambio, no le llega a la nota.

Una ficha desconocida en `f:alinear-abre`, o una `gb-alinear` que llegue a la plantilla de la instrucción (a mitad de un párrafo, en una nota, un pie, un ítem, un resumen), corta la transformación con un mensaje. El filtro ya lo impide; esto cubre un canónico armado por otro camino.

FRENA LA CONVERSIÓN (CON MENSAJE)

Un bloque vacío; algo que no sea un párrafo (título, lista, figura, cita, otro bloque); un salto de línea manual en un párrafo (SC-49: hoy no sirve en prosa, y en libro volvería el párrafo un `<literallayout>`, donde la ficha quedaría fuera de un `<para>`); dos clases en la apertura; un identificador o un atributo; una alineación dentro de otra; un bloque que no esté en el primer nivel (dentro de otro bloque, una lista, una tabla o una nota). Como en `espaciov`, en revista el filtro corre después de `unwrap-structural-divs.lua`, así que dentro de una sección estructural vale.

Cada renglón es su propio párrafo, separado por una línea en blanco. Por eso un lugar, una fecha o una firma en varios renglones no necesitan el salto manual.

SALIDAS

- Canónico: la ficha al comienzo de cada `<para>` o `<p>` del bloque.
- PDF: el párrafo en su grupo, como arriba.
- HTML y EPUB, de libros y de revistas: el párrafo común. La regla incorporada de XSLT no escribe nada para la instrucción (SC-38).
- SciELO y Redalyc: la plantilla vacía de SC-38. Crossref y DOAJ no llevan el cuerpo.
- ODT: los párrafos, sin el bloque ni la ficha.

CADENAS

`alinear.lua` corre justo después de `espacio-vertical.lua` en las tres: `generar_canonicos_capitulos.sh` (libro, antes de `fenced-divs-to-elements-db.lua`), `m_XML` (revista, después de `unwrap-structural-divs.lua` y antes de `cite-to-xref.lua`) y `m_GenerarODT`.

ANÁLISIS DEL PROYECTO

`m_AnalizarProyecto.Destino` dejaba fuera de los conteos todo el grupo `composicion`. El texto de un bloque de alineación es cuerpo. Ahora decide por el modo del catálogo: `envolver` es cuerpo, el resto (`separador-valor`, `espaciov`) no se cuenta (SC-38).

CATÁLOGO

Tres filas de gbShortcodes, grupo `composicion`, modo `envolver`, después de `espaciov`.

VERIFICADO EN EL CONTENEDOR

Pandoc 3.1.3 con las cadenas reales de libro y de revista, incluidos los casos que frenan; SaxonJ-HE 12.5 con `ensamblar-capitulo-canonico.xsl`, `docbook-to-latex.xsl`, `jats-to-latex.xsl`, `jats-to-html.xsl`, `jats-to-epub.xsl`, `jats-to-scielo.xsl` y `jats-to-redalyc.xsl`; el capítulo valida contra el RNG de DocBook 5.2 y el artículo contra la DTD Archiving 1.4; el cuerpo del .tex compila con LuaLaTeX en la clase book y se ve alineado (no con el preámbulo del proyecto); gbpublisher compila con gbc3 3.19.',
   'vigente', 'empirica',
   'Pandoc 3.1.3 / SaxonJ-HE 12.5 / xmllint / LuaLaTeX (TeX Live 2023) / gbc3 3.19 / contenedor Ubuntu 24.04',
   '2026-10', 'vinculo:SC-38,vinculo:SC-39,vinculo:SC-33,vinculo:SC-34,vinculo:SC-49,vinculo:GV-113,vinculo:GV-114,vinculo:GV-115',
   'Probar en Mint con un libro y una revista reales: inserción desde el panel, PDF compilado con el preámbulo del proyecto (alineación, sin corte, nota al pie normal), HTML y EPUB sin rastro, ODT, y el conteo de m_AnalizarProyecto. Las hojas de HTML y EPUB de libros no se corrieron sueltas (piden el manifiesto del libro): el resultado se apoya en la regla incorporada y en que su plantilla de para hace apply-templates sin copy-of.',
   610, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-61 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-61';

-- ------------------------------------------------------------
-- 6. SC-38: DE UN PUNTO Y DE UN TRAMO; EL MODO; RELACIÓN
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(replace(cuerpo,
         '

LAS REGLAS

',
         '

DE UN PUNTO Y DE UN TRAMO

- De un punto: van entre dos bloques y no tienen texto. `espaciov` (SC-39). Pierden validez cuando cambia el texto de arriba.
- De un tramo: rodean párrafos del cuerpo y dicen cómo se componen. La alineación (SC-61). No pierden validez cuando se reescribe el texto: una fecha a la derecha sigue a la derecha. Tienen en común con las de un punto que solo afectan al PDF.
- La ficha de un tramo va al comienzo de cada párrafo, no en un par apertura/cierre: el grupo de LaTeX nunca queda desbalanceado (SC-61).

LAS REGLAS

'),
         'El grupo entró con el esquema 5 de gbShortcodes.',
         'El grupo entró con el esquema 5 de gbShortcodes. El modo dice qué es cada una: las de un punto se insertan como separador (`separador-valor`); las de un tramo, con `envolver`. `m_AnalizarProyecto` cuenta como cuerpo el texto de las de un tramo y no cuenta las de un punto.'),
       relaciones = relaciones || ',vinculo:SC-61',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-38';
INSERT INTO verificacion SELECT 'SC-38 con la sección nueva', instr(cuerpo, 'DE UN PUNTO Y DE UN TRAMO') > 0 FROM entradas WHERE codigo = 'SC-38';
INSERT INTO verificacion SELECT 'SC-38 con LAS REGLAS después', instr(cuerpo, 'DE UN PUNTO Y DE UN TRAMO') < instr(cuerpo, 'LAS REGLAS') FROM entradas WHERE codigo = 'SC-38';
INSERT INTO verificacion SELECT 'SC-38 con el modo en la regla 6', instr(cuerpo, 'El modo dice qué es cada una') > 0 FROM entradas WHERE codigo = 'SC-38';
INSERT INTO verificacion SELECT 'SC-38 con relación a SC-61', instr(relaciones, ',vinculo:SC-61') > 0 FROM entradas WHERE codigo = 'SC-38';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-113', 'GV-114', 'GV-115', 'SC-61', 'SC-38')
 ORDER BY prefijo, numero;
