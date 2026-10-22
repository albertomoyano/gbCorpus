-- ============================================================
-- gbCorpus — actualización 58: las cifras implementadas (lote 1 de
--            SC-64); dos comportamientos medidos; los controles de cifras
-- Esquema: 1
-- Origen: conversación del 22/10. Decisiones de Alberto (a)–(g) sobre el
--         lote 1: la ficha en un atributo del canónico, el idioma del
--         capítulo con gb-idioma-pieza, los controles de cifras como
--         aviso (informan y la salida se genera), tres filas en el panel,
--         el resaltado y latex_en_linea con las tres órdenes.
-- Fecha:  2026-10-22
-- Aplicar: después de act-57
--
-- ALTAS:
--   GV-124  pandoc 3.1.3: una orden de siunitx incompleta queda como texto,
--           o se traga lo que sigue hasta encontrar llaves
--   GV-125  IBM Plex no tiene U+202F; Noto Serif sí
--   SC-65   Cifras y cantidades: implementación (lote 1 de SC-64)
-- MODIFICA:
--   SC-54   latex_en_linea con las órdenes de cifras; porcentaje_suelto
--           y cifra_fuera_de_num; la orden incompleta
--   SC-64   pendiente: el lote 1 pasa a SC-65
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-123 última GV', MAX(numero) = 123 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-64 última SC', MAX(numero) = 64 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-124 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-124' OR (prefijo = 'GV' AND numero = 124);
INSERT INTO verificacion SELECT 'GV-125 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-125' OR (prefijo = 'GV' AND numero = 125);
INSERT INTO verificacion SELECT 'SC-65 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-65' OR (prefijo = 'SC' AND numero = 65);
INSERT INTO verificacion SELECT 'SC-54 ancla latex_en_linea (una vez)', (length(cuerpo) - length(replace(cuerpo, '    latex_en_linea            error   una orden de LaTeX en el texto que no es
                                      \sptext{…} (GV-116)
', ''))) = length('    latex_en_linea            error   una orden de LaTeX en el texto que no es
                                      \sptext{…} (GV-116)
') FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 ancla corte_fuera_de_titulo (una vez)', (length(cuerpo) - length(replace(cuerpo, '    corte_fuera_de_titulo     error   \\ fuera de un título: sale como una
                                      barra (SC-63); para un salto, espaciov
', ''))) = length('    corte_fuera_de_titulo     error   \\ fuera de un título: sale como una
                                      barra (SC-63); para un salto, espaciov
') FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 ancla del LaTeX en el texto (una vez)', (length(cuerpo) - length(replace(cuerpo, '- En el texto, la única orden de LaTeX admitida es `\sptext{…}`, que traduce `volada.lua` (SC-62); su forma la valida ese filtro y no este control.', ''))) = length('- En el texto, la única orden de LaTeX admitida es `\sptext{…}`, que traduce `volada.lua` (SC-62); su forma la valida ese filtro y no este control.') FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 ancla del corte medido (una vez)', (length(cuerpo) - length(replace(cuerpo, 'Medido: un párrafo, una nota y una celda con `\\` dan tres hallazgos; el título y el código, ninguno.', ''))) = length('Medido: un párrafo, una nota y una celda con `\\` dan tres hallazgos; el título y el código, ninguno.') FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-64 ancla del pendiente', pendiente = 'Sin implementar: es la decisión y el plan. Lote 1 (cifras), lote 2 (cadena del cuadro) y lote 3 (FTabla y vista previa), cada uno con su SC y probado en Mint.' FROM entradas WHERE codigo = 'SC-64';

-- ------------------------------------------------------------
-- 2. GV-124
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 124, 'GV-124', 'pandoc 3.1.3: una orden de siunitx incompleta queda como texto, o se traga lo que sigue',
   'Medido con pandoc 3.1.3 (la de Ubuntu 24.04), leyendo el AST con `-t native`. El lector de Markdown reconoce `\SI`, `\SIrange` y `\num` como órdenes de LaTeX con una cantidad fija de argumentos, y cuando faltan no hace lo mismo que con una orden desconocida:

    Texto \SI{3}.                 Str "\\SI{3}."               texto común
    Texto \SIrange{1}{2}.         Str "\\SIrange{1}{2}."       texto común
    Texto \num 3.                 Str "\\num"                  texto común
    Texto \foo{3}.                RawInline tex "\\foo{3}"     LaTeX crudo (GV-116)
    Texto \SI{3}. Y \num{4}.      RawInline tex "\\SI{3}. Y \\num{4}"
    A \SI{3}.  (línea vacía)  Otra \\ barra.
                                  RawInline tex "\\SI{3}.\n\nOtra \\\\ barra"

- Una orden incompleta al final de su párrafo queda como TEXTO COMÚN: un filtro que mira solo los `RawInline` no la ve, y sale literal en las tres salidas.
- Si más adelante hay llaves, el lector las toma como los argumentos que faltan y se traga todo lo que hay en el medio, incluso una línea vacía: dos párrafos quedan unidos en un solo `RawInline`.
- El texto de ese `RawInline` puede traer saltos de línea.

EN EL PROYECTO: `cifras.lua` mira también los `Str` y frena si encuentra `\num` o `\SI` (SC-65); `controles_md.lua` informa como `latex_en_linea` una barra seguida de letras en un `Str` (no es un corte) y limpia los saltos del texto de la orden antes de escribirla en el informe, que es de una línea por hallazgo (SC-54).',
   'vigente', 'empirica',
   'pandoc 3.1.3 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-65,apoya:SC-54,vinculo:GV-116',
   NULL,
   1240, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-124 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-124';

-- ------------------------------------------------------------
-- 3. GV-125
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 125, 'GV-125', 'IBM Plex no tiene el espacio fino U+202F; Noto Serif sí',
   'Leído el mapa de caracteres (`cmap`) de las tipografías que trae gbpublisher, con fontTools:

    IBM Plex Sans y Mono (las ocho)   sin U+202F; con U+2212, U+20AC, °, ³, ⁹, ×
    Noto Serif (las cuatro)           con todos

U+202F es el espacio fino que no corta la línea que usa `cifras.lua` entre los grupos de una cifra y entre la cifra y la unidad (SC-64).

EN EL PROYECTO: la hoja de estilo de la revista (`gbpublisher.css`) compone el cuerpo con IBM Plex Sans (`--font-sans: ''''IBM Plex Sans'''', system-ui, sans-serif`); el navegador toma ese carácter de la siguiente tipografía de la lista. El EPUB del libro compone con Noto Serif, que lo tiene. El PDF no usa U+202F: el espacio lo pone siunitx (`\hspace{0.15em}`). No se midió cómo lo muestra cada lector de EPUB.',
   'vigente', 'empirica',
   'fontTools / tipografías de .hidden/fonts del repositorio (IBM Plex Sans y Mono, Noto Serif) / contenedor Ubuntu 24.04',
   '2026-10', 'vinculo:SC-65,vinculo:SC-64',
   NULL,
   1250, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-125 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-125';

-- ------------------------------------------------------------
-- 4. SC-65
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 65, 'SC-65', 'Cifras y cantidades: implementación (lote 1 de SC-64)',
   'IMPLEMENTACIÓN del lote 1 de SC-64: las cifras y las cantidades en el texto, con `\num`, `\SI` y `\SIrange`, en el libro, la revista y el ODT. Las decisiones de diseño (a)–(g) son de Alberto (22/10).

LA CADENA

El filtro `cifras.lua` corre en las tres cadenas antes de todo filtro que serialice con `pandoc.write`: sin él, el escritor descarta la orden y la cifra se pierde (GV-116).

    libro     4.° de la lista de generar_canonicos_capitulos.sh: después de
              corte-titulo, antes de cite-to-biblioref-db
    revista   m_XML.GenerarBodyXML: después de corte-titulo, antes de recuadros
              y de cite-to-xref
    ODT       m_GenerarODT.GenerarODTunaColumna: después de corte-titulo

EL CANÓNICO (decisión a)

El elemento lleva el texto ya formateado, y la entrada tal como se escribió va en un atributo, la ficha:

    JATS     <named-content content-type="cantidad" specific-use="SI 2.5 kilo metre per hour">2.5 km/h</named-content>
    DocBook  <phrase role="cantidad" remap="SI 2.5 kilo metre per hour">2.5 km/h</phrase>
    ODT      el texto formateado, sin marca

La ficha es la orden y sus argumentos separados por espacios, con las unidades sin barra: `num 1500`, `SI 88 percent`, `SIrange 50 51 degree`. Sin LaTeX en el canónico (SC-38). Validado: `named-content` en `p`, `title`, `td` y `caption` contra la DTD de JATS 1.4; `phrase` con `remap` contra el RNG de DocBook 5.2.

EL PDF

`f:cifra-latex` (`tex-comun.xsl`) rearma la orden desde la ficha, y frena si la ficha no es una de las conocidas. Las plantillas están en cada hoja, no en `tex-comun` (GV-117): `phrase[@role=''''cantidad'''']` en `docbook-to-latex.xsl` y `named-content[@content-type=''''cantidad'''']` en `jats-to-latex.xsl`. En el argumento opcional de un título va dentro de `\texorpdfstring`, con el texto formateado para el marcador (GV-118).

El `\sisetup` de SC-64 y `\DeclareSIUnit\euro{€}` están en el contrato del libro (`preambulo-contrato.tex`, versión 15; `CONTRATO_VERSION = 15` en `m_GenerarPDFLibro`) y en el preámbulo de la revista (`m_XML`), con los mismos valores.

EL HTML, EL EPUB Y EL ODT

El texto lo arma el formateador de `cifras.lua` con las reglas de SC-64: punto decimal, grupos de a tres desde cinco dígitos de un lado del punto, signo menos U+2212, exponente «× 10ⁿ» con superíndice, U+202F entre los grupos y entre la cifra y la unidad, el grado pegado, `/` para `\per`. Las hojas de HTML y EPUB no necesitan plantilla: muestran el texto del elemento.

MEDIDO: los veinticinco casos de la lista de Alberto, compuestos con siunitx 3.3.10 y el `\sisetup` de SC-64, coinciden con el formateador (comparados con `pdftotext`; la única diferencia es el superíndice, que `pdftotext` da como cifra común). De punta a punta, un capítulo con cifras en un párrafo, un título, una nota, una celda y un pie de cuadro, en español y en inglés: canónico válido (RNG y DTD), PDF compilado con el bloque de siunitx del contrato (marcadores «Cifras en 12 000 casos», «Rango de 50° to 51°»), HTML, EPUB, SciELO, Redalyc y ODT con el mismo texto.

EL IDIOMA DEL RANGO (decisión b)

La palabra del rango sale del idioma de la pieza: en la revista, `-M gb-idioma` (`ArgumentoIdiomaPandoc`); en el libro, `-M gb-idioma-pieza`, que el script pasa con el idioma del capítulo solo a la conversión (no `gb-idioma`, que `conversacion.lua` usa con otro fin). Se toman las dos primeras letras. La tabla es la de siunitx 3.3.10 (clave `to (numerical range)`): ca a, de bis, en to, es a, fr à, it a, pl do, pt a, sl do. Otro idioma frena, solo si la pieza tiene un `\SIrange`.

EL DICCIONARIO

Cerrado, el de SC-64. Una cifra con otra forma (coma, punto de miles, letras), una unidad fuera de la lista, un prefijo o una potencia que no van con su unidad, más de un `\per`, el grado o el porcentaje acompañados, o una orden incompleta, frenan la conversión con un mensaje que nombra la orden y dice qué falla. La orden incompleta se busca también en los `Str` (GV-124).

LOS CONTROLES (decisiones c, e, g)

En `controles_md.lua` (SC-54): `latex_en_linea` admite las tres órdenes; `porcentaje_suelto` y `cifra_fuera_de_num` son `aviso`: informan y la salida se genera (decisión de Alberto).

EL PANEL Y EL RESALTADO (decisiones d, f)

Tres filas en línea, modo plantilla, en gbShortcodes (`datos-v5-016`): `\num{•}`, `\SI{•}{}` y `\SIrange{•}{}{}`. En `Markdown.highlight`, el patrón de `\sptext` pasa a ser el de las órdenes admitidas (`$(orden)`), con el estado `latex.orden`; los estados hijos de la bastardilla, la negrita y el tachado lo usan igual (GV-119). Medido con el banco de gb.highlight: las tres órdenes se resaltan sueltas y dentro de la bastardilla y la negrita; los seis archivos de prueba anteriores dan el mismo resultado que antes.

LO QUE NO CUBRE

- El libro no cambia el idioma de babel por capítulo: un capítulo en inglés compone su `\SIrange` con la palabra del idioma principal en el PDF y con «to» en el HTML. Es anterior a este lote: `docbook-to-latex.xsl` no usa el `xml:lang` del capítulo.
- En la revista, los controles todavía no corren (SC-54, pendiente 1): una cifra suelta no avisa. `cifras.lua` frena igual.
- La columna numérica de un cuadro (`S`) es del lote 2.',
   'vigente', 'empirica',
   'pandoc 3.1.3 / Saxon-HE / xmllint / LuaHBTeX 1.17.0, TeX Live 2023, babel-spanish 5.0q, siunitx 3.3.10 / gbc3 3.19 / contenedor Ubuntu 24.04',
   '2026-10', 'vinculo:SC-64,vinculo:SC-38,vinculo:SC-54,vinculo:SC-62,vinculo:SC-63,apoya:GV-116,apoya:GV-117,apoya:GV-118,vinculo:GV-119,apoya:GV-123,apoya:GV-124,vinculo:GV-125',
   'Probar en Mint con un libro y una revista reales: PDF (párrafo, título y su marcador, nota, celda), HTML, EPUB, ODT, un capítulo en inglés con \SIrange, la inserción desde el panel, el resaltado, los avisos y un caso que frene. El cambio de idioma por capítulo en el PDF del libro, que no existe (ver LO QUE NO CUBRE), cuando se encare.',
   650, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-65 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-65';

-- ------------------------------------------------------------
-- 5. SC-54: LOS CONTROLES DE CIFRAS
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(replace(replace(replace(cuerpo,
         '    latex_en_linea            error   una orden de LaTeX en el texto que no es
                                      \sptext{…} (GV-116)
', '    latex_en_linea            error   una orden de LaTeX en el texto que no es
                                      de las admitidas: \sptext, \num, \SI,
                                      \SIrange (GV-116); o una de ellas
                                      incompleta (GV-124)
'),
         '    corte_fuera_de_titulo     error   \\ fuera de un título: sale como una
                                      barra (SC-63); para un salto, espaciov
', '    corte_fuera_de_titulo     error   \\ fuera de un título: sale como una
                                      barra (SC-63); para un salto, espaciov
    porcentaje_suelto         aviso   88% o 88 % escrito suelto (SC-64, SC-65)
    cifra_fuera_de_num        aviso   una cifra con punto o coma de miles fuera
                                      de \num (SC-64, SC-65)
'),
         '- En el texto, la única orden de LaTeX admitida es `\sptext{…}`, que traduce `volada.lua` (SC-62); su forma la valida ese filtro y no este control.', '- En el texto, las órdenes de LaTeX admitidas son `\sptext{…}`, que traduce `volada.lua` (SC-62), y `\num`, `\SI` y `\SIrange`, que traduce `cifras.lua` (SC-65); su forma la valida cada filtro y no este control. El texto de la orden se escribe en el informe sin saltos de línea: puede traerlos (GV-124).'),
         'Medido: un párrafo, una nota y una celda con `\\` dan tres hallazgos; el título y el código, ninguno.', 'Medido: un párrafo, una nota y una celda con `\\` dan tres hallazgos; el título y el código, ninguno. Una barra seguida de letras no es un corte: es una orden que Pandoc dejó como texto porque le faltan argumentos (GV-124), y se informa como `latex_en_linea`.') || '

LAS CIFRAS SUELTAS

Dos controles de nivel `aviso` (decisión de Alberto: informan, y la salida se genera) buscan en los `Str` de los párrafos, las celdas, los títulos, las líneas de un bloque de líneas y las notas lo que la norma de SC-64 escribe con siunitx. No bajan a un enlace ni a una cita: un DOI no es una cifra.

- `porcentaje_suelto`: un dígito seguido de `%`, pegado o con un espacio duro o fino en el mismo `Str`, o un `Str` que termina en dígito, un espacio y otro que empieza con `%`. El mensaje recuerda la forma `\SI{…}{\percent}` y que con una sola cifra va en letras.
- `cifra_fuera_de_num`: un dígito, un punto o una coma y tres dígitos (`1.500`, `12,345`). Un `Str` con barra se saltea: «decreto 2.345/26». Los números de identidad sin barra («ley 34.555») se informan igual: por eso es aviso.

Un decimal suelto (`2.5`, `3,14`) no se informa.

MEDIDO: un .md con `\num{12000}` y «3.500» en un título, «88%», «88 %», «88» con espacio duro y «77» con espacio fino, «1.500», «12,345», «ley 34.555», «decreto 2.345/26», un DOI en un enlace, «2.5» y «3,14», y una nota con «4.000» y «5%»: diez avisos, los esperados; el decreto, el DOI y los decimales, ninguno.',
       relaciones = relaciones || ',vinculo:SC-65,apoya:GV-124',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 con las cifras', instr(cuerpo, 'cifra_fuera_de_num        aviso') > 0 AND instr(cuerpo, 'LAS CIFRAS SUELTAS') > 0 AND instr(cuerpo, 'que traduce `cifras.lua` (SC-65)') > 0 AND instr(cuerpo, 'se informa como `latex_en_linea`') > 0 AND instr(cuerpo, 'incompleta (GV-124)') > 0 AND instr(relaciones, ',vinculo:SC-65,apoya:GV-124') > 0 FROM entradas WHERE codigo = 'SC-54';

-- ------------------------------------------------------------
-- 6. SC-64: EL LOTE 1 PASA A SC-65
-- ------------------------------------------------------------
UPDATE entradas
   SET pendiente = 'Lote 1 (cifras) implementado en SC-65: falta probarlo en Mint. Lote 2 (cadena del cuadro) y lote 3 (FTabla y vista previa), cada uno con su SC y probado en Mint.',
       relaciones = relaciones || ',vinculo:SC-65',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-64';
INSERT INTO verificacion SELECT 'SC-64 pendiente nuevo', pendiente = 'Lote 1 (cifras) implementado en SC-65: falta probarlo en Mint. Lote 2 (cadena del cuadro) y lote 3 (FTabla y vista previa), cada uno con su SC y probado en Mint.' AND instr(relaciones, ',vinculo:SC-65') > 0 FROM entradas WHERE codigo = 'SC-64';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-124', 'GV-125', 'SC-54', 'SC-64', 'SC-65')
 ORDER BY prefijo, numero;
