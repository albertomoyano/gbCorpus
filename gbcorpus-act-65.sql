-- ============================================================
-- gbCorpus — actualización 65: el formulario de los cuadros y la
--            vista previa (SC-67, lote 3 de SC-64)
-- Esquema: 1
-- Origen: conversación del 23/10. Alberto acepta las tres
--         recomendaciones: la grilla para la pipe table y el texto para
--         la grid table; la nota en una línea; la vista previa arma el
--         preámbulo en el momento. Confirma en Mint la entrega 2 y la
--         referencia entre capítulos («quedó perfecto»).
-- Fecha:  2026-10-23
-- Aplicar: después de act-64
--
-- ALTAS:
--   GV-127  pandoc 3.1.3: el escritor markdown no devuelve el archivo
--   GV-128  LuaLaTeX: linebreaker calla los Overfull; medir sin el .log
--   GV-129  TableView: el editor queda abierto después de Save()
--   SC-67   Cuadros: el formulario y la vista previa
-- MODIFICA:
--   SC-66   pendiente: la entrega 2 probada; las filas viejas, retiradas
--   SC-64   pendiente: el lote 3 en SC-67
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-126 última GV', MAX(numero) = 126 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-66 última SC', MAX(numero) = 66 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-127 a GV-129 libres', COUNT(*) = 0 FROM entradas WHERE codigo IN ('GV-127', 'GV-128', 'GV-129') OR (prefijo = 'GV' AND numero BETWEEN 127 AND 129);
INSERT INTO verificacion SELECT 'SC-67 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-67' OR (prefijo = 'SC' AND numero = 67);
INSERT INTO verificacion SELECT 'SC-66 con el pendiente de act-63', pendiente = 'Probar en Mint la entrega 2. Los controles de avisos (SC-54) sobre el archivo del cuadro. Las filas viejas table-wrap, table-fullwidth y table-landscape de gbShortcodes, con el lote 3.' FROM entradas WHERE codigo = 'SC-66';
INSERT INTO verificacion SELECT 'SC-64 con el pendiente de act-60', pendiente = 'Lote 1 (cifras) implementado y probado en Mint (SC-65). Lote 2 (cadena del cuadro) en SC-66: entrega 1 implementada. Lote 3 (FTabla y vista previa), con su SC y probado en Mint.' FROM entradas WHERE codigo = 'SC-64';

-- ------------------------------------------------------------
-- 2. GV-127
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 127, 'GV-127', 'pandoc 3.1.3: el escritor markdown no devuelve el archivo del cuadro',
   'Medido con pandoc 3.1.3, leyendo y escribiendo markdown (`-f markdown -t markdown`):

    grid table con celdas unidas   sale simple table: las uniones se pierden y las
                                   dos filas del encabezado quedan en una
    pipe table                     sale simple table, con las columnas alineadas
    \num{12000} en una celda       sale `\num{12000}`{=tex}
    x \| y                         se conserva

Leer el archivo por el AST (`-t json`) da las celdas, pero ya no el texto que escribió el editor: la orden de LaTeX llega como RawInline, las comillas como Quoted.

EN EL PROYECTO: el archivo del cuadro (SC-66) no puede pasar por Pandoc para editarlo. Lo lee y lo escribe Gambas con un formato propio (`m_Cuadros`, SC-67); el que controla sigue siendo `cuadro-leer.lua`.',
   'vigente', 'empirica',
   'pandoc 3.1.3 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-67,vinculo:GV-126',
   NULL,
   1270, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-127 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-127';

-- ------------------------------------------------------------
-- 3. GV-128
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 128, 'GV-128', 'LuaLaTeX: linebreaker calla todos los Overfull \hbox; medir un cuadro sin el .log',
   'Medido en LuaHBTeX 1.17.0 (TeX Live 2023) con el preámbulo del libro (`preambulo-estetica.tex`).

LINEBREAKER CALLA LOS DESBORDES

`linebreaker` toma el callback `hpack_quality` (`linebreaker.sty`: «Our overfull box reporting function») y lo usa para su propia cuenta: no informa nada salvo en modo depuración. Con el preámbulo del libro, una celda `m{0.8cm}` con una palabra que no se puede cortar se sale de su columna 20,3 mm y el .log no dice nada; el mismo tabular sin linebreaker da «Overfull \hbox (99.43773pt too wide) in paragraph». No es que «bajen mucho», como decía el comentario de la estética: desaparecen todos. `\linebreakerdisable` no los devuelve: el callback sigue tomado.

LO QUE SÍ SE PUEDE MEDIR

- El ancho y el alto de un tabular: los ganchos del núcleo `env/tabular/before` y `env/tabular/after` lo meten en una caja (`lrbox`) y lo sueltan con `\usebox`; en el medio se lee `\wd`, `\ht` y `\dp`. No cambia la composición.
- El renglón que se sale de su columna: en `post_linebreak_filter`, `node.rangedimensions(renglón, renglón.head)` da el ancho real con el estiramiento que TeX le dio; si supera `renglón.width` en más de `\hfuzz`, desborda. Devolviendo `true`, el párrafo queda como estaba.
- El flotante más alto que la página: «LaTeX Warning: Float too large for page by Xpt», que linebreaker no toca. Es el alto con el pie, que la medida del tabular no ve.
- Dentro de `sidewaystable`, `\textwidth` vale `\textheight` (y `\linewidth` también): el ancho de la página se toma antes, en `\AtBeginDocument`.

EL .log NO SIRVE PARA MEDIDAS: corta las líneas en 79 caracteres y una línea con varias medidas llega partida. Las medidas se escriben en un archivo propio desde Lua.

EN EL PROYECTO: la vista previa de los cuadros (SC-67): `engine/vista_cuadro_medir.lua` y `medidas.txt`.',
   'vigente', 'empirica',
   'LuaHBTeX 1.17.0, TeX Live 2023, linebreaker / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-67',
   NULL,
   1280, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-128 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-128';

-- ------------------------------------------------------------
-- 4. GV-129
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 129, 'GV-129', 'TableView (gb.form, 3.19): el editor no se cierra y repite su Save en otra fila',
   'Medido en Gambas 3.19 (contenedor, xvfb), con `Data` y `Save`, como en `FEditBookmark` de gb.form.

    Edit()                 abre un TextBox en la celda actual
    Edit(Lista, True)      abre un ComboBox de solo lectura con la lista
    Editor                 el control del editor; es Control: .Text va por un Object
    Save()                 lanza Save(Row, Column, Value) con la fila y la columna
                           donde se abrió; sin edición abierta no hace nada
    Cancel()               cierra sin guardar
    Rows[i].Title          se escribe y se lee; sin escribirlo, el número de fila
    Rows.Count + Refresh   alcanza para insertar en el modelo y repintar

LA TRAMPA: el editor no se cierra nunca. Después de `Save()` —y también después de `Cancel()`— sigue abierto (`Editor.Visible` da True siempre) y guarda la fila y la columna donde se abrió. Cuando la grilla cambia de filas (`Rows.Count` y `Refresh`), el próximo `Save()`, o el que dispara la propia grilla al ocultarse o rearmarse, vuelve a lanzar `Save` con el texto viejo en esa fila y esa columna, que ya es otra (medido: la fila insertada quedó con el texto de la de abajo). Y una edición a medio escribir NO se guarda sola cuando el foco sale de la grilla: se guarda recién cuando se abre otra edición, o se pierde.

PATRÓN: una marca propia. El clic que abre la edición anota la fila y la columna; el handler de `Save` descarta todo `Save` que no corresponda a una edición abierta, y la cierra. Antes de cambiar filas o columnas, de cambiar de modo o de leer el modelo: `Save()` solo si la marca está puesta (guarda en su celda lo que se estaba escribiendo) y después `Cancel()`. Medido con una edición sin guardar y una fila insertada: el texto quedó en su celda y la fila nueva, vacía.

DE PASO: `Integer[]` no tiene `Join` («Unknown symbol ''''Join'''' in class ''''Integer[]''''»): es de `String[]`. Y `GridView` admite `ColumnSpan` y `RowSpan` en una celda (medido en 3.19).

EN EL PROYECTO: `FTabla.CerrarEdicion`, `tvDatos_Save` y `tvColumnas_Save`, y `m_Cuadros.UnirEnteros` (SC-67).',
   'vigente', 'empirica',
   'Gambas 3.19 / gb.form / contenedor Ubuntu 24.04, xvfb',
   '2026-10', 'apoya:SC-67,vinculo:GV-15,vinculo:RC-GM-03',
   'Verificar en 3.22.1 (Mint) si el editor de TableView se comporta igual; el patrón sirve en los dos casos.',
   1290, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-129 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-129';

-- ------------------------------------------------------------
-- 5. SC-67
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 67, 'SC-67', 'Cuadros: el formulario y la vista previa (lote 3 de SC-64)',
   'DECISIÓN CERRADA (Alberto acepta las tres recomendaciones, 23/10) y lo implementado. Es el lote 3 de SC-64: el formulario de los cuadros y la vista previa con `showframe`. El archivo del cuadro y su cadena son de SC-66.

LAS TRES DECISIONES

a) LA GRILLA PARA LA PIPE TABLE, EL TEXTO PARA LA GRID TABLE. Una pipe table se edita celda por celda, con el texto de cada celda en Markdown tal cual. Una tabla con celdas unidas (grid table) se edita como texto, con el resaltado del proyecto. No hay conversión automática: «La tabla como texto» pasa de la grilla al texto, para unir celdas; «Pasar a la grilla» vuelve si el texto es una pipe table simple con las columnas del diseño, y si no, no cambia nada.

b) LA NOTA EN UNA LÍNEA. El formulario la edita en un campo de una línea. Un archivo con una nota de varias líneas —o cualquier encabezado que este lector no lea igual que YAML— se abre entero como texto, con el motivo; el diseño queda deshabilitado.

c) LA VISTA PREVIA ARMA EL PREÁMBULO EN EL MOMENTO. No hace falta haber corrido «Solo generar» antes: en libros copia los preámbulos (`CopiarRecursosLatex`) y escribe `preambulo-proyecto.tex` desde la base, como el PDF.

EL FORMATO QUE ESCRIBE GAMBAS

Pandoc no puede escribir el archivo (GV-127): lo lee y lo escribe `m_Cuadros`, con un formato fijo:

    ---
    titulo: ''Procedencia de los tesistas''
    nota: ''Fuente: elaboración propia.''
    cuerpo: normal
    separacion: normal
    rotar: sí              (solo si sí; agrupar, igual)
    cortes: [12]           (solo si hay; bloques, igual)
    ancho: total           (solo si es total)
    columnas:
      - {tipo: texto, ancho: 2.4, alinear: centro}
      - {tipo: cifra}
    ---

    | … | … |
    |---|---|

`titulo` y `nota` van entre comillas simples: adentro la barra es literal (`\num{…}` llega entero) y la comilla se duplica; entre comillas dobles, `\n` sería un salto de línea para YAML. La pipe table va sin alinear con espacios: una celda que crece no cambia las otras líneas del diff. La barra de una celda va escapada (`\|`). La alineación `izq` no se escribe: es la de omisión.

El lector acepta las claves en cualquier orden, los valores sin comillas o con comillas dobles sin barras, y las líneas en blanco. NO ENCAJA, y el archivo se abre como texto: un comentario, un « #» o un «: » en un valor sin comillas, una lista en bloque, una nota de varias líneas, una clave desconocida o repetida, un valor fuera de la lista, `columnas` con otra cantidad que la tabla. Al abrir, lo que difiere solo en la forma (comillas, orden) no cuenta como cambio: el archivo se reescribe en el formato de Gambas recién al guardar.

EL FORMULARIO (FTabla)

A la izquierda, los cuadros de `cuadros/`, con Nuevo (una plantilla de dos columnas) y Duplicar; el nombre lleva `tbl-` y letras sin tilde, cifras o guiones, como lo pide `cuadro-leer.lua`. Dos pestañas:

- Datos: la grilla. La fila «enc.» es el encabezado de la tabla; las demás, el cuerpo, numeradas. El menú de la fila (botón o clic derecho) inserta, quita y marca el corte (✂) o el filete doble (═) después de la fila; el de la columna inserta y quita. Al insertar o quitar una fila, los cortes y los bloques de las filas de abajo se corren y siguen marcando la misma fila de datos. En el modo texto, «Colorear» vuelve a colorear: a pedido y no al escribir (GV-46, SC-18).
- Diseño: título, nota, cuerpo, separación, ancho (columna o total), rotar, agrupar; cortes y bloques como números de fila separados por comas (los mismos que marca el menú); y la grilla de las columnas: tipo, ancho en centímetros (la coma del teclado pasa a punto) y alineación. Una columna de cifras no lleva ancho ni alineación.

Guardar, Vista previa, Insertar y Cerrar; se cierra solo por los botones (SC-20). Cambiar de cuadro, Insertar y Cerrar con cambios sin guardar preguntan: guardar, descartar o quedarse (SC-06). Insertar pone en el cursor el bloque que nombra el cuadro (`::: {.cuadro #tbl-…}`, con su cierre nombrado, SC-33), con la misma validación de la posición que antes; el id vuelve a FMain por `m_Cuadros` (RC-GM-13).

LA VISTA PREVIA

Compone el cuadro solo, con todo lo de la pieza: los mismos filtros en el mismo orden, la misma plantilla de composición y el mismo preámbulo, con la caja a la vista. Lo que se ve es lo que sale; no hay otra composición del cuadro.

- Gambas escribe lo que sale de la base, `tmp/vista-cuadro/preambulo-vista.tex`: en libros, las capas del `main.tex` con `\gbshowframetrue` y sin `preambulo-hyperref` (el contrato se engancha a hyperref con `\AddToHook{package/hyperref/after}` y no lo necesita; la capa registra el .bib, que el cuadro solo no usa): `m_GenerarPDFLibro.PreambuloVistaCuadro`. En revistas, el del PDF en borrador, sin el .bib y sin `\begin{document}`: `m_XML.PreambuloVistaCuadro`. La revista CONSERVA hyperref: va embebido a mitad del preámbulo y seguido de `\pdfstringdefDisableCommands`. El estilo de cita lo lee `m_XML.EstiloCitaRevista`, la misma función que ahora usa `m_GenerarPDF.GenerarPDFunaColumna`.
- `engine/vista_cuadro.sh` (SC-13, lanzado por `EjecutarScriptSalida`, SC-53) hace el resto: el .md mínimo que nombra el cuadro, pandoc con la cadena de la pieza (`FILTROS_LIBRO` y `FILTROS_REVISTA` en `comun.sh`; la de libros la usa también `generar_canonicos_capitulos.sh`, la de revistas es gemela de `m_XML.GenerarBodyXML`), Saxon con `vista-cuadro-libro.xsl` o `vista-cuadro-revista.xsl` (importan la hoja del PDF y solo cambian la raíz), una pasada de LuaLaTeX y el veredicto. El idioma es el de la pieza abierta en el editor.
- EL VEREDICTO (`veredicto.txt`, una línea por hallazgo, `nivel<TAB>mensaje`): por tramo, el ancho y el alto contra la caja, en milímetros (info); un tramo más ancho o más alto que la caja, una celda que se sale de su columna, «Float too large» (el alto con el pie) y un error de LaTeX en el cuadro: error. Un error de LaTeX del preámbulo: aviso, porque no es del cuadro y sale igual en el PDF de la pieza. Las medidas las toma `engine/vista_cuadro_medir.lua` (GV-128): en el libro, linebreaker calla los Overfull y el .log no las daría. Código 0, el cuadro entra; 3, hay observaciones; 1, no salió el PDF, con el motivo del filtro que frenó también en el veredicto.
- El formulario muestra el veredicto y abre `vista.pdf` con el visor del sistema (`Desktop.Open`, sin espera).

LO QUE LA VISTA NO DICE: la paginación real (los tramos caen donde caen junto al texto de la pieza) y el número del cuadro (sale «Cuadro 1»).

SE RETIRAN las filas `table-wrap`, `table-fullwidth` y `table-landscape` de gbShortcodes (`datos-v5-018`): las reemplazan el archivo del cuadro y este formulario.

MEDIDO en el contenedor (gbc3 3.19, LuaHBTeX 1.17.0, Saxon-HE 12.5, pandoc 3.1.3): la vista de libro con el preámbulo que escribe Gambas, y la de revista con el de `ObtenerPreambuloEmbebido` reproducido desde el código (la función necesita FMain y la base); un cuadro que entra, uno más ancho que la caja (13,7 mm), uno más alto (174,2 mm), uno que se pasa solo con el pie (3,0 mm), una celda que desborda (20,3 mm), uno rotado y uno con `ancho: total`, y uno que frena en la cadena (`ancho: total` en un libro). El lector y el escritor sobre los cuadros de prueba: la ida y vuelta da el mismo texto; y siete casos que no encajan, cada uno con su motivo. El formulario bajo xvfb: la lista, la grilla, una grid table en texto, la edición de una celda con una barra, un corte por el menú, una fila insertada con los cortes corridos (también con la edición a medio escribir), guardar, la ida y vuelta grilla–texto, un archivo que no encaja e Insertar.

DE PASO: la revista ya tenía dos errores de LaTeX en su preámbulo, ajenos a los cuadros, que la vista muestra como aviso: «Command \theHpoemline already defined» (verse después de hyperref) y «biblatex Error: \chapter not provided by class» (`citereset=chapter` en `cita-apa-config.tex` con la clase article). Medidos en el contenedor; falta ver si salen igual en Mint.',
   'vigente', 'empirica',
   'gbc3 3.19 / pandoc 3.1.3 / Saxon-HE 12.5 / LuaHBTeX 1.17.0, TeX Live 2023 / contenedor Ubuntu 24.04, xvfb',
   '2026-10', 'vinculo:SC-66,vinculo:SC-64,vinculo:SC-13,vinculo:SC-53,vinculo:SC-15,vinculo:SC-18,vinculo:SC-20,vinculo:SC-06,vinculo:SC-33,vinculo:RC-GM-13,apoya:GV-127,apoya:GV-128,apoya:GV-129,apoya:GV-46',
   'Probar en Mint: el formulario (3.22) y la vista previa en un libro y en una revista. Ver si los dos errores del preámbulo de la revista salen también en Mint y, si salen, resolverlos aparte.',
   670, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-67 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-67';

-- ------------------------------------------------------------
-- 6. SC-66 Y SC-64: LOS PENDIENTES
-- ------------------------------------------------------------
UPDATE entradas
   SET pendiente = 'Los controles de avisos (SC-54) sobre el archivo del cuadro.',
       relaciones = relaciones || ',vinculo:SC-67',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-66';
INSERT INTO verificacion SELECT 'SC-66 actualizada', pendiente = 'Los controles de avisos (SC-54) sobre el archivo del cuadro.' AND instr(relaciones, ',vinculo:SC-67') > 0 FROM entradas WHERE codigo = 'SC-66';

UPDATE entradas
   SET pendiente = 'Lote 1 (cifras) probado en Mint (SC-65). Lote 2 (cadena del cuadro) probado en Mint (SC-66). Lote 3 (formulario y vista previa) implementado en SC-67: falta probarlo en Mint.',
       relaciones = relaciones || ',vinculo:SC-67',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-64';
INSERT INTO verificacion SELECT 'SC-64 actualizada', pendiente = 'Lote 1 (cifras) probado en Mint (SC-65). Lote 2 (cadena del cuadro) probado en Mint (SC-66). Lote 3 (formulario y vista previa) implementado en SC-67: falta probarlo en Mint.' AND instr(relaciones, ',vinculo:SC-67') > 0 FROM entradas WHERE codigo = 'SC-64';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-127', 'GV-128', 'GV-129', 'SC-64', 'SC-66', 'SC-67')
 ORDER BY prefijo, numero;
