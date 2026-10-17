-- ============================================================
-- gbCorpus — actualización 40: LaTeX en las referencias (tres órdenes) e
--            ISO 690 con autolang=hyphen
-- Esquema: 1
-- Origen: decisiones de Alberto (17/10). Pruebas en el contenedor (TeX Live
--         2023, biblatex 3.19, biblatex-iso690, biblatex-apa v9.17, make4ht
--         v0.3m, Gambas 3.19, jing con el Relax NG de DocBook 5.2, Chromium)
--         con ref-l-DUEK.bib y ref-l-MOLINARO.bib. Numerado contra la base de
--         Alberto (~/.gbcorpus/corpus.sqlite, 17/10, con act-39 aplicado).
-- Fecha:  2026-10-17
-- Aplicar: después de act-39
--
-- ALTAS:
--   SC-58   Órdenes de LaTeX en las referencias: solo \enquote, \sptext y \emph
--   GV-105  biblatex-iso690 con autolang=other: \sptext indefinido en una
--           entrada que no es del idioma del libro
-- MODIFICA:
--   SC-57   relación con SC-58 y GV-105
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-58 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-58' OR (prefijo = 'SC' AND numero = 58);
INSERT INTO verificacion SELECT 'GV-105 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-105' OR (prefijo = 'GV' AND numero = 105);
INSERT INTO verificacion SELECT 'SC-57 es la última SC', MAX(numero) = 57 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-104 es la última GV', MAX(numero) = 104 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'act-39 aplicado', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-57' AND instr(titulo, '(Verona, APA)') > 0;
INSERT INTO verificacion SELECT 'SC-30 vigente', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-30' AND estado = 'vigente';

-- ------------------------------------------------------------
-- 2. SC-58
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 58, 'SC-58', 'Órdenes de LaTeX en las referencias: solo \enquote, \sptext y \emph',
   'DECISIÓN CERRADA (decisión de Alberto). En los campos de una referencia se admiten tres órdenes de LaTeX y ninguna otra:

    \enquote{…}   cita entre comillas; el nivel lo decide el anidamiento
    \sptext{…}    ordinal de babel-spanish: n\sptext{o} es «n.º»
    \emph{…}      énfasis; dentro de un título en cursiva da redonda (el «enroque»)

Los puntos suspensivos se escriben `...`, como en el Markdown: Markdown no es LaTeX. Las llaves de BibTeX siguen siendo legítimas: agrupan un nombre (`{de la Fuente}`) o protegen una mayúscula (`{I}''ve`).

POR QUÉ HACE FALTA UNA REGLA

Los mismos campos van al `.bib`, que interpreta biblatex, y al `<bibliography>` del canónico, que no es LaTeX. Antes, el canónico quitaba las llaves y nada más: `\enquote{cuestión militar}` llegaba como «\enquotecuestión militar».

LA REGLA ES UNA SOLA: `m_Bibtex.ProblemaOrdenesLatex`

Solo las tres órdenes, cada una con su llave pegada, y las llaves balanceadas. La usan tres controles:

1. EL FORMULARIO, al guardar una referencia nueva, al guardar cambios y al guardar un título repetido (`VerificarOrdenesLatex`). Si un campo no cumple, avisa con un mensaje y la referencia no se guarda.
2. LA EXPORTACIÓN DEL `.bib` (`ExportarBibTeX`): lo que ya estaba en la base o llegó sin pasar por el formulario. Con una sola entrada que no cumple, el `.bib` no se escribe y el mensaje lista todas, con su clave y su campo.
3. EL CANÓNICO (`m_XML.TextoBibDocBook`): si un `.bib` viejo trae una orden no admitida, corta con `Error.Raise`.

EL CANÓNICO DE LIBROS

`m_XML.TextoBibDocBook` reemplaza a `EscaparXML(QuitarLlavesBib(...))` en los campos de texto de `<biblioentry>`:

    \enquote{x}   ->  <quote>x</quote>          (los niveles: quote.xsl)
    \emph{x}      ->  <emphasis>x</emphasis>
    \sptext{x}    ->  .<superscript>x</superscript>

El punto de `\sptext` es el que pone babel-spanish (`\es@orddot`): así el canónico dice lo mismo que el PDF. Los nombres siguen con `QuitarLlavesBib`.

MEDIDO: los tres elementos son válidos en `title`, `citetitle`, `bibliomisc`, `publishername`, `city`, `edition` y `orgname` (jing con el Relax NG de DocBook 5.2, con un control negativo). Con las 16 referencias de Molinaro que usan `\enquote` o `\emph`, el resultado valida; las 2 con `\dots` se rechazan, como corresponde.

EN LAS SALIDAS (medido)

    .bib                                   PDF                    HTML y EPUB (tex4ht)
    \enquote{huelga \enquote{general}}     «huelga “general”»     «huelga “general”»
    El 1\sptext{o} de mayo                 1.º                    1.<sup>o</sup>
    Revista \emph{Nueva} (en cursiva)      Nueva en redonda       <em>Revista <em>Nueva</em></em>

Para el enroque en pantalla, `em em { font-style: normal; }` en `gbpublisher.css` y `gbpublisher-epub-libro.css`: es lo que hace `\emph` en LaTeX. Verificado en Chromium.

ALCANCE

Libros. Revistas arman su `element-citation` de JATS desde el mismo `.bib` sin traducir ni escapar; se resuelve cuando se encare revistas entero, después de libros (decisión de Alberto). Molinaro, que trae `\dots`, sale por legacy y no se corrige.',
   'vigente', 'empirica',
   'TeX Live 2023 / biblatex 3.19 / biblatex-apa v9.17 / make4ht v0.3m / Gambas 3.19 / jing, DocBook 5.2 / Chromium / contenedor Ubuntu 24.04',
   '2026-10',
   'vinculo:SC-57,vinculo:SC-30,vinculo:SC-14,apoya:GV-23',
   'En las hojas de HTML y EPUB, las plantillas por estilo (las de los estilos que todavía no van por tex4ht: ISO 690, IEEE) leen el título con normalize-space y pierden las comillas de un <quote>: se resuelve cuando esos estilos pasen por tex4ht. \sptext es de babel-spanish: un libro cuyo idioma principal no sea el español no lo tiene definido. Sin probar en Mint.',
   580, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-58 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-58' AND orden = 580;

-- ------------------------------------------------------------
-- 3. GV-105
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 105, 'GV-105', 'biblatex-iso690 con autolang=other: \sptext indefinido en una entrada que no es del idioma del libro',
   '`iso.bbx` trae `autolang=other`: cada entrada se compone en el idioma de su `langid`. En un libro en español con babel cargado solo con el español (`\gbidiomas`), una entrada `english` con número de revista corta el PDF:

    ! Undefined control sequence.
    \abx@sstr@number ->n\sptext {o}

Al entrar en la entrada, babel apaga los extras del español, y con ellos `\sptext`. La cadena que imprime biblatex para «número» sigue siendo la española, `n\sptext{o}`.

MEDIDO con `ref-l-DUEK.bib`, compilando entrada por entrada: fallan las dos en inglés que llevan `number` (4203-SMITH2007, 4205-HEID2021); la portuguesa, que no lo lleva, no falla. APA y Verona no fallan porque no activan `autolang`.

Cargar `english` en babel tampoco sirve: la entrada sale mezclada, con «no. 1» en inglés y «págs.» y «Disp. desde» en español.

DECISIÓN DE ALBERTO: `autolang=hyphen` en `cita-iso690-config.tex`, como opción de carga (le gana al valor del estilo; medido). Las cadenas van en el idioma del libro y solo el corte de palabras sigue al de la entrada, como en APA y Verona. El PDF de Duek compiló sin errores ni avisos de biblatex.',
   'vigente', 'empirica',
   'biblatex 3.19 / biblatex-iso690 (TeX Live 2023) / babel-spanish 5.0q / LuaLaTeX / contenedor Ubuntu 24.04; PDF de Duek en Mint',
   '2026-10',
   'vinculo:SC-57,vinculo:SC-58,apoya:GV-23',
   NULL,
   1050, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-105 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-105' AND orden = 1050;

-- ------------------------------------------------------------
-- 4. RELACIONES
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-58,vinculo:GV-105',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-57' AND instr(relaciones, 'SC-58') = 0;
INSERT INTO verificacion SELECT 'SC-57 relacionada', instr(relaciones, 'SC-58') > 0 AND instr(relaciones, 'GV-105') > 0 FROM entradas WHERE codigo = 'SC-57';

COMMIT;

SELECT codigo, estado, orden, titulo FROM entradas WHERE codigo IN ('SC-58', 'GV-105') ORDER BY prefijo DESC;
