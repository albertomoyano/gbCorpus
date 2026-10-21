-- ============================================================
-- gbCorpus — actualización 55: corte de línea en los títulos de
--            sección del .md (SC-63), con la marca de SC-28
-- Esquema: 1
-- Origen: pedido de Alberto (21/10): «## Corte de\\ subtítulo» salía
--         «Corte de\ subtítulo». Diseño acordado en la conversación del
--         21/10: solo PDF, la marca y el canónico de SC-28, varios
--         cortes por título, y un control para \\ fuera de un título.
--         Mini-tests en el contenedor (Pandoc 3.1.3, SaxonJ-HE 12.5,
--         xmllint, LuaLaTeX de TeX Live 2023 con titlesec y hyperref,
--         qpdf, gbc3 3.19).
-- Fecha:  2026-10-21
-- Aplicar: después de act-54
--
-- ALTAS:
--   GV-121  Pandoc: \\ en el .md es una barra literal en un Str
--   SC-63   Corte de línea en los títulos de sección del .md
-- MODIFICA:
--   SC-28   alcance: también los títulos del .md (SC-63)
--   SC-54   control corte_fuera_de_titulo
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-120 última GV', MAX(numero) = 120 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-62 última SC', MAX(numero) = 62 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-121 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-121' OR (prefijo = 'GV' AND numero = 121);
INSERT INTO verificacion SELECT 'SC-63 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-63' OR (prefijo = 'SC' AND numero = 63);
INSERT INTO verificacion SELECT 'SC-28 ancla de ALCANCE (una vez)', (length(cuerpo) - length(replace(cuerpo, 'El título traducido no: si trae la marca, sale un espacio.', ''))) = length('El título traducido no: si trae la marca, sale un espacio.') FROM entradas WHERE codigo = 'SC-28';
INSERT INTO verificacion SELECT 'SC-54 ancla de la tabla (una vez)', (length(cuerpo) - length(replace(cuerpo, '                                      comentarios <!-- … -->
', ''))) = length('                                      comentarios <!-- … -->
') FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 sin el control nuevo', instr(cuerpo, 'corte_fuera_de_titulo') = 0 FROM entradas WHERE codigo = 'SC-54';

-- ------------------------------------------------------------
-- 2. GV-121
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 121, 'GV-121', 'Pandoc: \\ en el .md es una barra literal en un Str',
   'En el lector `markdown` de Pandoc, `\\` es una barra escapada: llega como una `\` dentro del `Str`, pegada al texto que la rodea. No es un salto de línea (el salto es la barra al final de la línea) ni LaTeX crudo.

MEDIDO (Pandoc 3.1.3):

    ## Corte de\\ subtítulo      Str "Corte", Space, Str "de\", Space, Str "subtítulo"
    ## Pegado\\sin espacio       Str "Pegado\sin", Space, Str "espacio"
    *bastardilla*\\ y            Emph […], Str "\", Space, Str "y"

Los escritores la escriben como una barra: «Corte de\ subtítulo» en las tres salidas. En cambio, una barra sola delante de letras (`\sin`) es LaTeX crudo (GV-116), y delante de un espacio es un espacio duro.

El identificador que Pandoc arma para un título no lleva la barra («corte-de-subtítulo», «pegadosin-espacio»).',
   'vigente', 'empirica',
   'Pandoc 3.1.3 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-63,vinculo:GV-116,vinculo:SC-28',
   NULL,
   1210, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-121 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-121';

-- ------------------------------------------------------------
-- 3. SC-63
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 63, 'SC-63', 'Corte de línea en los títulos de sección del .md: \\, como en la base',
   'DECISIÓN CERRADA (decisión de Alberto, 21/10). La regla de SC-28 vale también para los títulos de sección que se escriben en el .md (`##` y siguientes en libros; todos los niveles en revistas): el editor marca el corte con `\\` y el corte se cumple solo en la apertura del PDF.

    ## Corte de\\ subtítulo

En el sumario, el folio, los marcadores, el HTML, el EPUB, el ODT y los indexadores, el corte es un espacio. En libros el `#` del .md no llega al canónico: el título del capítulo sale de la base y ya tiene su regla (SC-28).

LA REGLA

- Varios cortes por título (decisión de Alberto): `Uno\\ dos\\ tres`.
- Frena si un corte queda al principio o al final del título, si hay dos seguidos o si va dentro de una bastardilla, una negrita u otra marca. Un `<break/>` dentro de `<italic>` partiría la marca en el PDF.
- El espacio después de `\\` es opcional: `Pegado\\sin` corta igual.
- Fuera de un título no hay corte: el control `corte_fuera_de_titulo` (SC-54) lo informa. Para un salto fuera de un título está `espaciov` (SC-39).

CANÓNICO, EL DE SC-28

`corte-titulo.lua` (GV-121) escribe la marca de SC-28 con UN espacio, antes:

    JATS      <title>Corte de <break/>subtítulo</title>
    DocBook   <title>Corte de <?gb-corte?>subtítulo</title>

SC-28 pone un espacio a cada lado porque sus títulos van planos a muchos destinos. Acá basta uno: el valor de texto de la marca es vacío, así que una salida que lee el título como cadena ve «Corte de subtítulo», y una plantilla vacía para la marca no deja dos espacios. El `<break/>` dentro del `<title>` de un `<sec>` valida contra la DTD Archiving 1.4 (medido). La instrucción de procesamiento, contra el RNG de DocBook 5.2.

PDF

Las plantillas de título de sección de las dos hojas arman el título dos veces (SC-29): la apertura y el argumento opcional que va al sumario, al folio y a los marcadores (`notasTitulo`).

- `docbook-to-latex.xsl`: una plantilla para `processing-instruction(''gb-corte'')` escribe `\gbCorteTitulo` en la apertura y nada en el sumario. Los títulos que vienen de la base no pasan por ella: los arman `f:titulo-compuesto` y `f:titulo-plano`.
- `jats-to-latex.xsl`: `sec/title/break` hace lo mismo. La plantilla general de `break` escribe `\\` sin mirar el contexto, y en un título habría ido también al sumario y a los marcadores.

`\gbCorteTitulo` ya está en el contrato del libro (versión 6) y en el preámbulo de la revista (`m_XML`): no hay contrato nuevo.

MEDIDO: el .tex compila con LuaLaTeX, titlesec (`newlinetospace`) y hyperref, sin errores ni avisos. La apertura corta en dos y en tres líneas; el sumario y los marcadores (leídos con qpdf) salen en una línea. Con una nota en el título (SC-29) y una volada (SC-62), también.

HTML, EPUB E INDEXADORES

`jats-to-html` y `jats-to-epub` no tienen plantilla para `break`, y la regla incorporada no escribe nada para una instrucción de procesamiento: sale «Corte de subtítulo». `jats-to-scielo` y `jats-to-redalyc` quitan `sec/title/break` con una plantilla vacía. No usan `normalize-space`, como en el `article-title` de SC-28, porque un título de sección puede llevar bastardilla.

ODT

Un espacio.

CADENAS

`corte-titulo.lua`, justo después de `volada.lua` en las tres: libro, tercero, antes de `cite-to-biblioref-db.lua`; revista, antes de `cite-to-xref.lua`; ODT.

VERIFICADO EN EL CONTENEDOR

Pandoc 3.1.3 con las cadenas reales de libro, revista y ODT, incluidos los casos que frenan; SaxonJ-HE 12.5 con `ensamblar-capitulo-canonico.xsl`, las dos hojas LaTeX, HTML, EPUB, SciELO y Redalyc; el capítulo valida contra el RNG de DocBook 5.2 y el artículo contra la DTD Archiving 1.4; gbpublisher compila con gbc3 3.19.',
   'vigente', 'empirica',
   'Pandoc 3.1.3 / SaxonJ-HE 12.5 / xmllint / LuaLaTeX (TeX Live 2023) / titlesec / hyperref / qpdf / gbc3 3.19 / contenedor Ubuntu 24.04',
   '2026-10', 'vinculo:SC-28,vinculo:SC-29,vinculo:SC-39,vinculo:SC-54,vinculo:SC-62,vinculo:GV-121',
   'Probar en Mint con un libro y una revista reales: PDF (apertura, sumario y marcadores), HTML, EPUB, un caso que frene y el control corte_fuera_de_titulo. El ODT, cuando se encare (decisión de Alberto, 21/10).',
   630, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-63 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-63';

-- ------------------------------------------------------------
-- 4. SC-28: ALCANCE
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo,
         'El título traducido no: si trae la marca, sale un espacio.',
         'El título traducido no: si trae la marca, sale un espacio. Los títulos de sección que se escriben en el .md siguen la misma regla, con su propio filtro y sus plantillas (SC-63).'),
       relaciones = relaciones || ',vinculo:SC-63',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-28';
INSERT INTO verificacion SELECT 'SC-28 con SC-63', instr(cuerpo, '(SC-63)') > 0 AND instr(relaciones, ',vinculo:SC-63') > 0 FROM entradas WHERE codigo = 'SC-28';

-- ------------------------------------------------------------
-- 5. SC-54: EL CONTROL
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo,
         '                                      comentarios <!-- … -->
',
         '                                      comentarios <!-- … -->
    corte_fuera_de_titulo     error   \\ fuera de un título: sale como una
                                      barra (SC-63); para un salto, espaciov
') || '

EL CORTE FUERA DE UN TÍTULO

`corte_fuera_de_titulo` busca la barra que deja `\\` (GV-121) en los `Str` de los párrafos, las celdas, las líneas de un bloque de líneas y las notas, también las de un título. No mira los títulos, que traduce `corte-titulo.lua` (SC-63), ni el código ni la matemática, que no son `Str`. Medido: un párrafo, una nota y una celda con `\\` dan tres hallazgos; el título y el código, ninguno.',
       relaciones = relaciones || ',vinculo:SC-63',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 con el control', instr(cuerpo, '    corte_fuera_de_titulo     error') > 0 AND instr(cuerpo, 'EL CORTE FUERA DE UN TÍTULO') > 0 FROM entradas WHERE codigo = 'SC-54';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-121', 'SC-63', 'SC-28', 'SC-54')
 ORDER BY prefijo, numero;
