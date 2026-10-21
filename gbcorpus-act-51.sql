-- ============================================================
-- gbCorpus — actualización 51: letra volada en el texto (SC-62),
--            la misma notación que SC-58 fijó para las referencias
-- Esquema: 1
-- Origen: pedido de Alberto (21/10): uniformar n.º, 1.ª, 3.er, que los
--         Word de los autores traen de todas las formas. Diseño
--         acordado en la conversación del 21/10: n\sptext{o} en el .md,
--         regla abierta, frena fuera del español. Mini-tests en el
--         contenedor (Pandoc 3.1.3, SaxonJ-HE 12.5, LuaLaTeX de TeX
--         Live 2023, xmllint, qpdf).
-- Fecha:  2026-10-21
-- Aplicar: después de act-50
--
-- ALTAS:
--   GV-116  Pandoc: una orden de LaTeX en línea se pierde sin aviso en
--           JATS, DocBook y HTML
--   GV-117  XSLT: una plantilla importada pierde contra la de la hoja
--           que importa, aunque tenga más prioridad
--   GV-118  hyperref: \sptext en un título rompe el marcador;
--           \texorpdfstring lo resuelve
--   SC-62   Letra volada en el texto: n\sptext{o}
-- MODIFICA:
--   SC-58   relación con SC-62
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-115 última GV', MAX(numero) = 115 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-61 última SC', MAX(numero) = 61 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-116 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-116' OR (prefijo = 'GV' AND numero = 116);
INSERT INTO verificacion SELECT 'GV-117 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-117' OR (prefijo = 'GV' AND numero = 117);
INSERT INTO verificacion SELECT 'GV-118 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-118' OR (prefijo = 'GV' AND numero = 118);
INSERT INTO verificacion SELECT 'SC-62 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-62' OR (prefijo = 'SC' AND numero = 62);
INSERT INTO verificacion SELECT 'SC-58 sin relación con SC-62', instr(relaciones, 'SC-62') = 0 FROM entradas WHERE codigo = 'SC-58';

-- ------------------------------------------------------------
-- 2. GV-116
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 116, 'GV-116', 'Pandoc: una orden de LaTeX en línea se pierde sin aviso en JATS, DocBook y HTML',
   'El lector `markdown` de Pandoc tiene activa la extensión `raw_tex`: una orden de LaTeX dentro de un párrafo (`n\sptext{o}`) llega como `RawInline (Format "tex") "\\sptext{o}"`, pegada al `Str` anterior. Los escritores que no son LaTeX descartan un `RawInline` de otro formato, sin advertencia.

MEDIDO:

    .md         El n\sptext{o} 3 y la 1\sptext{a} edición
    JATS        <p>El n 3 y la 1 edición</p>
    DocBook     <para>El n 3 y la 1 edición</para>
    HTML        <p>El n 3 y la 1 edición</p>

Como el PDF del proyecto sale del canónico, la orden también se pierde en el PDF.

Lo mismo vale para cualquier orden de LaTeX en línea que no traduzca un filtro. Para `\sptext` la traduce `volada.lua` (SC-62). Las demás siguen perdiéndose sin aviso: lo cubriría un control en `controles_md.lua`.

El orden de los filtros importa: un filtro que serializa con `pandoc.write` (las notas en `cite-to-biblioref-db.lua`, los bloques en `fenced-divs-to-elements-db.lua`) hace la misma pérdida dentro de lo que serializa. Medido: con `volada.lua` después de `cite-to-biblioref-db.lua`, la nota decía «la 2 edición».',
   'vigente', 'empirica',
   'Pandoc 3.1.3 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-62,vinculo:SC-58,vinculo:SC-46',
   'Falta el control general en controles_md.lua (un aviso por cada orden de LaTeX en línea fuera de las traducidas).',
   1160, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-116 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-116';

-- ------------------------------------------------------------
-- 3. GV-117
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 117, 'GV-117', 'XSLT: una plantilla importada pierde contra la de la hoja que importa, aunque tenga más prioridad',
   'Cuando dos plantillas coinciden con el mismo nodo, XSLT mira primero la precedencia de importación y después la prioridad. Una plantilla de una hoja importada con `xsl:import` tiene menos precedencia que cualquiera de la hoja que importa.

MEDIDO con SaxonJ-HE 12.5:

    imp-base.xsl (importada)   match="text()[ends-with(., ''.'')]" priority="10"
    imp-main.xsl               match="text()"           (prioridad por omisión)
    entrada <a>n.</a>          gana imp-main.xsl

CONSECUENCIA EN EL PROYECTO: `tex-comun.xsl` se importa desde `docbook-to-latex.xsl` y `jats-to-latex.xsl`, que tienen su propia plantilla `text()`, `superscript` y `sup`. Una plantilla que tenga que ganarles va en cada hoja; `tex-comun.xsl` solo puede aportar funciones o plantillas para lo que las hojas no atrapan, como las instrucciones `gb-espacio` y `gb-alinear`. Así está la letra volada (SC-62).',
   'vigente', 'empirica',
   'SaxonJ-HE 12.5 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-62',
   NULL,
   1170, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-117 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-117';

-- ------------------------------------------------------------
-- 4. GV-118
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 118, 'GV-118', 'hyperref: \sptext en un título rompe el marcador; \texorpdfstring lo resuelve',
   'El argumento opcional de `\section` va al sumario, al folio y a los marcadores del PDF. hyperref convierte el título en cadena PDF y no sabe convertir `\sptext`: avisa «Token not allowed in a PDF string (Unicode)» y deja restos de la definición de babel.

MEDIDO (LuaLaTeX, babel spanish, hyperref), leyendo los marcadores con qpdf:

    \section{Capítulo sobre el n\sptext{o} 1}
        marcador: «Capítulo sobre el n.8-1.5ex o 1»
    \section[Capítulo sobre el n\texorpdfstring{\sptext{o}}{.º} 1]{…}
        marcador: «Capítulo sobre el n.º 1», sin avisos

En el sumario y en el título compuesto, `\sptext` sale bien. La o y la a voladas tienen su carácter en Unicode (º U+00BA, ª U+00AA); para las otras, el marcador lleva el punto y las letras sin volar.',
   'vigente', 'empirica',
   'LuaHBTeX 1.17.0 / TeX Live 2023 (Debian) / babel spanish / hyperref / qpdf / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-62,vinculo:SC-29',
   'Medido con la clase book: confirmar en Mint con el preámbulo del proyecto.',
   1180, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-118 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-118';

-- ------------------------------------------------------------
-- 5. SC-62
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 62, 'SC-62', 'Letra volada en el texto: n\sptext{o}',
   'DECISIÓN CERRADA (decisión de Alberto, 21/10). La letra volada de los ordinales y las abreviaturas (n.º, 1.ª, 3.er, C.ía, V.º B.º) se escribe en el .md como en LaTeX y como en las referencias (SC-58): `n\sptext{o}`. Una sola notación en todo el proyecto. Los Word de los autores la traen de todas las formas (nº, n°, Nº, n.º, superíndice de Word); esta es la que se fija.

    El n\sptext{o} 3, la 1\sptext{a} edición, el 3\sptext{er} piso.

No es un bloque `:::` ni un span: va pegada a su base, dentro del texto. Sin un filtro, Pandoc la descartaba en las tres salidas (GV-116).

LA REGLA, ABIERTA (decisión de Alberto)

- Adentro, una o más minúsculas, con o sin tilde, diéresis o virgulilla: `o`, `a`, `er`, `os`, `ía`.
- Antes, pegada, una letra (también mayúscula o con tilde) o una cifra: `n`, `1`, `21`, `V`, `D`. Nunca un punto: el punto lo pone `\sptext` (babel-spanish, `\es@orddot`), y `n.\sptext{o}` saldría «n..º».
- Solo en texto en español: `\sptext` es de babel-spanish y en otro idioma el PDF no compila (GV-105). Frena (decisión de Alberto): el editor o el corrector deben saber que es exclusiva del español.

Vale en cualquier lugar del texto: párrafos, títulos de sección, notas, pies, celdas, recuadros, versos, epígrafes, conversaciones, bloques alineados.

FRENA LA CONVERSIÓN (CON MENSAJE)

`volada.lua`, en las tres cadenas: una volada vacía, con mayúsculas, cifras u otros signos adentro; sin base pegada (un espacio, un comienzo de párrafo, una bastardilla antes); con un punto antes; en un artículo cuyo `-M gb-idioma` no es español; dentro de un tramo marcado en otro idioma (`[…]{lang=en}`).

Las hojas LaTeX repiten dos controles sobre el canónico: el idioma, con `fn:lang` sobre el `xml:lang` más cercano, y el punto antes. En el libro, el del idioma es el único: la cadena del libro no le pasa el idioma del capítulo a Pandoc, y no se puede usar `gb-idioma`, porque `conversacion.lua` lo usa para otra cosa. Un capítulo en otro idioma con una volada se genera en HTML y EPUB y frena en el PDF.

CANÓNICO, COMO SC-58

    JATS      n.<sup specific-use="volada">o</sup>
    DocBook   n.<superscript role="volada">o</superscript>

El punto queda en el texto: un indexador o un lector de pantalla lee «n.º». En JATS, `<sup>` admite `specific-use` y no `content-type` (DTD 1.4, `JATS-format1-4.ent`).

PDF

`f:volada-latex` (`tex-comun.xsl`) devuelve `\sptext{o}`. La plantilla del texto que precede a la volada le quita el punto final (`f:sin-punto-final`). Las dos plantillas, la de la volada y la del texto, van en `docbook-to-latex.xsl` y en `jats-to-latex.xsl`, no en `tex-comun.xsl`: una importada pierde contra `text()`, `superscript` y `sup` de la hoja (GV-117).

En el argumento opcional de un título, que va a los marcadores (`notasTitulo = sumario`), sale `\texorpdfstring{\sptext{o}}{.º}` (GV-118).

HTML Y EPUB

`n.<sup>o</sup>`, con las plantillas de superíndice que ya existen. SciELO y Redalyc copian el `<sup specific-use="volada">`, que es JATS válido.

ODT

El punto y la volada en superíndice.

CADENAS

`volada.lua` corre antes de todo filtro que serialice con `pandoc.write`, que la descartaría (GV-116). Libro: segundo, después de `guillemets-to-quoted-db.lua` y antes de `cite-to-biblioref-db.lua`, que serializa las notas. Revista: después de `alinear.lua` y antes de `cite-to-xref.lua`. ODT: después de `alinear.lua`.

CATÁLOGO

Una fila de gbShortcodes: `sptext`, en línea, grupo `comun`, modo `plantilla`. El panel inserta `\sptext{•}` con el marcador seleccionado.

VERIFICADO EN EL CONTENEDOR

Pandoc 3.1.3 con las cadenas reales de libro, revista y ODT, en todos los lugares de arriba, incluidos los casos que frenan; SaxonJ-HE 12.5 con `ensamblar-capitulo-canonico.xsl`, las dos hojas LaTeX, HTML, EPUB, SciELO y Redalyc; el capítulo valida contra el RNG de DocBook 5.2 y el artículo contra la DTD Archiving 1.4; el cuerpo del .tex compila con LuaLaTeX en la clase book, con hyperref y el sumario; los marcadores leídos con qpdf; el control del idioma frena con un capítulo y un artículo en inglés; gbpublisher compila con gbc3 3.19.

FUERA DE ESTA DECISIÓN

- La normalización al ingresar el Word (`limpiar_docx.lua`): «nº», «Nº», «n.º» y el superíndice de Word se podrían escribir como `n\sptext{o}`, pero «n°» y «1°» llegan con el signo de grado, que también es legítimo («20 °C»). Queda para decidir.
- El control general de las órdenes de LaTeX en línea que se pierden (GV-116).',
   'vigente', 'empirica',
   'Pandoc 3.1.3 / SaxonJ-HE 12.5 / xmllint / LuaLaTeX (TeX Live 2023) / babel-spanish 5.0q / hyperref / qpdf / gbc3 3.19 / contenedor Ubuntu 24.04',
   '2026-10', 'vinculo:SC-58,vinculo:GV-105,vinculo:GV-116,vinculo:GV-117,vinculo:GV-118,vinculo:SC-29,vinculo:SC-21',
   'Probar en Mint con un libro y una revista reales: PDF con el preámbulo del proyecto (también en un título y su marcador), HTML, EPUB, inserción desde el panel y un caso que frene. El ODT, cuando se encare (decisión de Alberto, 21/10).',
   620, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-62 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-62';

-- ------------------------------------------------------------
-- 6. SC-58: RELACIÓN
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-62',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-58 con relación a SC-62', instr(relaciones, ',vinculo:SC-62') > 0 FROM entradas WHERE codigo = 'SC-58';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-116', 'GV-117', 'GV-118', 'SC-62', 'SC-58')
 ORDER BY prefijo, numero;
