-- ============================================================
-- gbCorpus — actualización 62: toda tabla va en su archivo; el HTML
--            conserva su estilo (SC-66)
-- Esquema: 1
-- Origen: decisiones de Alberto del 22/10 sobre la entrega 1 de los
--         cuadros.
-- Fecha:  2026-10-22
-- Aplicar: después de act-61
--
-- MODIFICA:
--   SC-66   las dos decisiones; el pendiente sin ellas
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

INSERT INTO verificacion SELECT 'SC-66 con el pendiente de act-60', pendiente = 'Entrega 2: celdas unidas (grid table → \multicolumn, \cmidrule), encabezado de dos niveles, agrupar (\cmidrule{2-n} entre las filas de un grupo), cortes (un flotante por tramo, encabezado repetido, «Continúa en la página siguiente» / «Viene de la página anterior», el pie en el último), rotar (sidewaystable) y el ancho total de la revista. Los controles de avisos (SC-54) sobre el archivo del cuadro. Las filas viejas table-wrap, table-fullwidth y table-landscape de gbShortcodes, con el lote 3. Una tabla suelta en el .md, sin archivo: decidir. Probar en Mint la entrega 1.' FROM entradas WHERE codigo = 'SC-66';
INSERT INTO verificacion SELECT 'SC-66 ancla QUÉ FRENA (una vez)', (length(cuerpo) - length(replace(cuerpo, 'QUÉ FRENA

', ''))) = length('QUÉ FRENA

') FROM entradas WHERE codigo = 'SC-66';

UPDATE entradas
   SET cuerpo = replace(cuerpo, 'QUÉ FRENA

', 'QUÉ FRENA

TODA TABLA VA EN SU ARCHIVO (decisión de Alberto, 22/10: «rigidez estructural para evitar caos»). Una tabla escrita en el .md de un capítulo o de un artículo, suelta o dentro de otro bloque, frena en las tres cadenas: `cuadro-leer.lua` la busca antes de traer los cuadros y nombra su encabezado para encontrarla.

EL HTML CONSERVA SU ESTILO WEB (decisión de Alberto, 22/10): el encabezado de color y las filas alternas de `gbpublisher.css`, sin los filetes del PDF. El estilo de la casa es del PDF.

'),
       pendiente = 'Entrega 2: celdas unidas (grid table → \multicolumn, \cmidrule), encabezado de dos niveles, agrupar (\cmidrule{2-n} entre las filas de un grupo), cortes (un flotante por tramo, encabezado repetido, «Continúa en la página siguiente» / «Viene de la página anterior», el pie en el último), rotar (sidewaystable) y el ancho total de la revista. Los controles de avisos (SC-54) sobre el archivo del cuadro. Las filas viejas table-wrap, table-fullwidth y table-landscape de gbShortcodes, con el lote 3.',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-66';
INSERT INTO verificacion SELECT 'SC-66 actualizada', instr(cuerpo, 'TODA TABLA VA EN SU ARCHIVO') > 0 AND instr(cuerpo, 'EL HTML CONSERVA SU ESTILO WEB') > 0 AND pendiente = 'Entrega 2: celdas unidas (grid table → \multicolumn, \cmidrule), encabezado de dos niveles, agrupar (\cmidrule{2-n} entre las filas de un grupo), cortes (un flotante por tramo, encabezado repetido, «Continúa en la página siguiente» / «Viene de la página anterior», el pie en el último), rotar (sidewaystable) y el ancho total de la revista. Los controles de avisos (SC-54) sobre el archivo del cuadro. Las filas viejas table-wrap, table-fullwidth y table-landscape de gbShortcodes, con el lote 3.' FROM entradas WHERE codigo = 'SC-66';

COMMIT;

SELECT codigo, estado, pendiente FROM entradas WHERE codigo = 'SC-66';
