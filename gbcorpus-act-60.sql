-- ============================================================
-- gbCorpus — actualización 60: los cuadros (SC-66, lote 2 de SC-64),
--            entrega 1; el escritor DocBook y las celdas unidas
-- Esquema: 1
-- Origen: conversación del 22/10. Decisiones de Alberto: el archivo
--         del cuadro con su encabezado YAML, el estilo de la casa (los
--         filetes, «una marca del diseño de la editorial»), los anchos en
--         centímetros, el título y la nota separados, las filas de total
--         como filas comunes, el diseño de libros manda en revistas (que
--         suman el ancho total), el corte y la rotación siempre del
--         maquetador.
-- Fecha:  2026-10-22
-- Aplicar: después de act-59
--
-- ALTAS:
--   GV-126  pandoc 3.1.3: el escritor DocBook pierde las celdas unidas
--   SC-66   Cuadros: el archivo del cuadro, el estilo de la casa y la cadena
-- MODIFICA:
--   SC-64   pendiente: el lote 2 pasa a SC-66
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-125 última GV', MAX(numero) = 125 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-65 última SC', MAX(numero) = 65 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-126 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-126' OR (prefijo = 'GV' AND numero = 126);
INSERT INTO verificacion SELECT 'SC-66 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-66' OR (prefijo = 'SC' AND numero = 66);
INSERT INTO verificacion SELECT 'SC-64 con el pendiente de act-59', pendiente = 'Lote 1 (cifras) implementado y probado en Mint (SC-65). Lote 2 (cadena del cuadro) y lote 3 (FTabla y vista previa), cada uno con su SC y probado en Mint.' FROM entradas WHERE codigo = 'SC-64';

-- ------------------------------------------------------------
-- 2. GV-126
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 126, 'GV-126', 'pandoc 3.1.3: el escritor DocBook pierde las celdas unidas; el de JATS las conserva',
   'Medido con pandoc 3.1.3 sobre una grid table con celdas unidas: dos filas de encabezado, una celda que abarca dos columnas y una que abarca dos filas, en el encabezado y en el cuerpo.

    lector Markdown     las uniones llegan al AST: RowSpan y ColSpan en cada Cell
    escritor JATS       las conserva: <th rowspan="2">, <th colspan="2">, <td rowspan="2">
    escritor DocBook    las pierde: cada celda unida sale como una <entry> suelta y
                        se agregan <entry> vacías; la segunda fila del encabezado
                        pasa a <tbody>

La pipe table no admite celdas unidas: cada línea es una fila y cada `|`, una columna.

Una tabla con un pie de Pandoc (`: pie`) sale `<table><title>…</title>` en DocBook; sin pie, `<informaltable>`. Ninguno de los dos escritores lleva una nota debajo de la tabla.

EN EL PROYECTO: la tabla del cuadro la escribe `cuadro-armar.lua` y no el escritor de Pandoc (SC-66).',
   'vigente', 'empirica',
   'pandoc 3.1.3 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-66',
   NULL,
   1260, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-126 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-126';

-- ------------------------------------------------------------
-- 3. SC-66
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 66, 'SC-66', 'Cuadros: el archivo del cuadro, el estilo de la casa y la cadena (lote 2 de SC-64)',
   'DECISIÓN CERRADA (decisiones de Alberto, 22/10), y lo implementado en la entrega 1. Es el lote 2 de SC-64: la cadena del cuadro. El diseño de los cuadros del libro manda también en las revistas. Todo lo anterior sobre tablas se revisa contra este.

EL ARCHIVO DEL CUADRO

Cada cuadro vive en un archivo propio, `cuadros/tbl-nombre.md`, en la raíz del proyecto, como `media/`, en libros y revistas. El .md solo lo nombra:

    ::: {.cuadro #tbl-procedencia}
    [/cuadro]: # ()
    :::

El id lleva el prefijo `tbl-`, el de las referencias cruzadas (`[@tbl-procedencia]` en libros), y es el nombre del archivo. El archivo tiene un encabezado YAML con las decisiones y, debajo, la tabla y nada más:

    ---
    titulo: Procedencia de los tesistas por décadas
    nota: "Nota: este cuadro y los que siguen son de elaboración propia."
    cuerpo: normal        # normal = \footnotesize · chico = \scriptsize
    separacion: normal    # normal = 4 pt · estrecha = 2 pt
    rotar: no
    agrupar: no           # sí: la primera celda vacía continúa el grupo
    cortes: []            # filas del cuerpo tras las que corta
    columnas:
      - {tipo: texto}
      - {tipo: cifra}
      - {tipo: texto, ancho: 2.4, alinear: centro}
    ---

    | | 1890-1899 | Observaciones |
    |---|---|---|
    | Capital Federal | 42 | … |

- `titulo` es obligatorio y puede ir vacío. `titulo` y `nota` van separados (decisión de Alberto): en JATS, `caption/title` y `table-wrap-foot`; en DocBook, `title` y `caption`. En el PDF se componen juntos en el `\caption`, como hasta ahora. A la lista de cuadros va solo el título. Los dos admiten Markdown en línea, cifras y citas: pasan por la cadena como el resto del texto (medido: una cita de la nota sale `<biblioref>`).
- `columnas`, una entrada por columna. `cifra` da una columna `S` con su `table-format` calculado de los datos. `texto` con `ancho` (en centímetros, con punto decimal) da `m{ancho}` con `\raggedright` o, con `alinear: centro`, `\centering`. Sin ancho da `l` o `c`. Anchos en centímetros, la práctica de Alberto: el control lo da la vista previa con `showframe` (lote 3).
- La tabla es pipe table, o grid table cuando hay celdas unidas (GV-126). El encabezado sale en negrita sin marcarlo. Una fila de total es una fila común.
- En una columna de cifras, una celda que es solo una cifra se escribe con la entrada de siunitx (SC-64); lo que no es una cifra («—», «s/d») sale entre llaves, como texto.

EL ESTILO DE LA CASA (decisión de Alberto: «es una marca del diseño de la editorial»)

Letra sin serifa; `[!ht]`; centrado; `\toprule`, `\midrule` entre todas las filas, `\bottomrule`; filete vertical entre todas las columnas; encabezado en negrita; pie debajo; la letra y el cuerpo alcanzan también al pie. Lo que una editorial puede cambiar va en macros del contrato (versión 16) y del preámbulo de la revista, gemelas: `\gbCuadroLetra`, `\gbCuadroCuerpoNormal`, `\gbCuadroCuerpoChico`, `\gbCuadroSepNormal`, `\gbCuadroSepEstrecha`. booktabs deja aire en los cruces de los filetes verticales: se acepta.

LIBROS Y REVISTAS

El mismo diseño y el mismo criterio: el maquetador decide dónde corta y si rota, nunca el compilador. La única diferencia es el ancho: en libros hay uno, el de la caja; en revistas, dos: el de la columna y el total (columna, calle y columna derecha). En revistas el maquetador decide además si usa el ancho total (decisión de Alberto, 22/10).

LA CADENA

- `cuadro-leer.lua`, PRIMERO en las tres cadenas: trae el archivo (con `-M gb-proyecto`), controla el encabezado y la tabla, y deja un Div `.cuadro` con las decisiones en sus atributos, el título, la nota y la tabla. Así el contenido pasa por todos los filtros: comillas, volada, cifras, citas. Una cifra sola en una columna de cifras pasa a `\num{…}`, que traduce `cifras.lua` (SC-65). Frena el viejo `::: {.table}`.
- `cuadro-armar.lua` escribe el cuadro: en libros, antes de `fenced-divs-to-elements-db.lua`; en revistas, después de `cite-to-xref.lua`; en el ODT, antes de `--citeproc`. Lo escribe el filtro y no Pandoc porque el escritor DocBook pierde las celdas unidas (GV-126) y ninguno lleva la nota ni las decisiones.
- `table-to-end.lua` sale de la cadena de la revista: solo marcaba el viejo `.table`.

EL CANÓNICO

    DocBook  <table xml:id="tbl-…"><title>…</title>
             <?gb-cuadro cuerpo="normal" separacion="normal" columnas="texto cifra texto:2.4:centro"?>
             <tgroup> <colspec align="left|center|char" char="."/> … </tgroup>
             <caption><para>NOTA</para></caption></table>
    JATS     <table-wrap id="tbl-…"><caption><title>…</title></caption> <?gb-cuadro …?>
             <table> <col align="…"/> … <th|td align="…" char="."> … </table>
             <table-wrap-foot><p>NOTA</p></table-wrap-foot></table-wrap>

Las decisiones de composición van en la instrucción `gb-cuadro`, sin LaTeX (SC-38); SciELO y Redalyc la quitan como a toda `gb-`. La columna de cifras va alineada por el punto (`align="char"`). Validado: DocBook contra el RNG 5.2; JATS contra la DTD 1.4.

LAS SALIDAS

- PDF: plantillas en `docbook-to-latex.xsl` y `jats-to-latex.xsl` (GV-117); funciones en `tex-comun.xsl`: `f:pi-valor`, `f:cuadro-columna`, `f:cuadro-formato` (el `table-format`: signo si hay una cifra negativa, los enteros y decimales más largos) y `f:cuadro-pie`. Una cifra sola va como la lee la columna `S`; el encabezado de una columna de cifras va entre llaves.
- HTML y EPUB: la tabla completa y derecha; debajo, «Cuadro N» con el título, y la nota. El número es el del PDF (`nl:numero-cuadro`, misma regla que la figura). Los navegadores no aplican `align="char"`: la columna de cifras va a la derecha, con cifras tabulares.
- Referencias cruzadas en libros: `cite-to-biblioref-db.lua` admite `tbl-`; el HTML y el EPUB muestran el número del cuadro. En revistas no hay referencias cruzadas (SC-32).
- ODT: el título en negrita, la tabla y la nota.

QUÉ FRENA

Un id sin `tbl-`; el bloque con contenido o con otros atributos; el archivo que no existe; una clave desconocida; `titulo` ausente; un valor fuera de la lista; `columnas` que no coincide con la tabla; un ancho con coma; ancho o alineación en una columna de cifras; algo más que una tabla debajo del encabezado; el pie de Pandoc (`: pie`); una nota al pie (decisión de Alberto: un flotante no la lleva); HTML; una orden de LaTeX que no es de las admitidas; una cifra con coma o con punto de miles en una columna de cifras.

ENTREGA 1 (IMPLEMENTADA)

El cuadro simple, en libros y revistas: el archivo, el canónico, las columnas de texto y de cifras, el PDF con el estilo de la casa, el HTML, el EPUB y el ODT. Frenan con un mensaje hasta la entrega 2: las celdas unidas, el encabezado de dos niveles, `agrupar`, `cortes`, `rotar` y el ancho total de la revista.

MEDIDO: un cuadro con cifras enteras, negativas y decimales, «—» en una columna de cifras, volada, comillas, `\SI` y una cita en la nota; un `\num` en el título. Libro: canónico válido (RNG), PDF compilado (`l | S[table-format=3.0] | S[table-format=5.0] | S[table-format=-2.2] | >{\centering\arraybackslash}m{3cm}`), «Cuadro 1.1» en el pie y en la referencia del HTML y del EPUB. Revista: JATS válido (DTD), PDF, HTML, EPUB, SciELO y Redalyc. ODT. Un cuadro dentro de un bloque `::: intro`. Los casos que frenan, uno por uno.',
   'vigente', 'empirica',
   'pandoc 3.1.3 / Saxon-HE / xmllint / LuaHBTeX 1.17.0, TeX Live 2023, siunitx 3.3.10 / gbc3 3.19 / contenedor Ubuntu 24.04',
   '2026-10', 'vinculo:SC-64,vinculo:SC-65,vinculo:SC-38,vinculo:SC-32,vinculo:SC-31,vinculo:SC-54,apoya:GV-126,apoya:GV-117,apoya:GV-116,apoya:GV-124',
   'Entrega 2: celdas unidas (grid table → \multicolumn, \cmidrule), encabezado de dos niveles, agrupar (\cmidrule{2-n} entre las filas de un grupo), cortes (un flotante por tramo, encabezado repetido, «Continúa en la página siguiente» / «Viene de la página anterior», el pie en el último), rotar (sidewaystable) y el ancho total de la revista. Los controles de avisos (SC-54) sobre el archivo del cuadro. Las filas viejas table-wrap, table-fullwidth y table-landscape de gbShortcodes, con el lote 3. Una tabla suelta en el .md, sin archivo: decidir. Probar en Mint la entrega 1.',
   660, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-66 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-66';

-- ------------------------------------------------------------
-- 4. SC-64: EL LOTE 2 PASA A SC-66
-- ------------------------------------------------------------
UPDATE entradas
   SET pendiente = 'Lote 1 (cifras) implementado y probado en Mint (SC-65). Lote 2 (cadena del cuadro) en SC-66: entrega 1 implementada. Lote 3 (FTabla y vista previa), con su SC y probado en Mint.',
       relaciones = relaciones || ',vinculo:SC-66',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-64';
INSERT INTO verificacion SELECT 'SC-64 actualizada', pendiente = 'Lote 1 (cifras) implementado y probado en Mint (SC-65). Lote 2 (cadena del cuadro) en SC-66: entrega 1 implementada. Lote 3 (FTabla y vista previa), con su SC y probado en Mint.' AND instr(relaciones, ',vinculo:SC-66') > 0 FROM entradas WHERE codigo = 'SC-64';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-126', 'SC-64', 'SC-66')
 ORDER BY prefijo, numero;
