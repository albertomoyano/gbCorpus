-- ============================================================
-- gbCorpus — actualización 72: RC-GM-03 vale para los formularios
--            que graban fila por fila
-- Esquema: 1
-- Origen: conversación del 28/10. Al cotejar el corpus para act-71,
--         RC-GM-03 («guardar en el evento, no en el botón») chocaba en la
--         letra con SC-73 (editores en memoria que graban todo junto).
--         Alberto decide matizarla: rige para los formularios que graban
--         fila por fila.
-- Fecha:  2026-10-28
-- Aplicar: después de act-71
--
-- MODIFICA:
--   RC-GM-03  título y alcance; relación con SC-73
--   SC-73     relación con RC-GM-03
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: act-71 APLICADA; TEXTO, UNA VEZ
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-73 existe', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-73';
INSERT INTO verificacion SELECT 'RC-GM-03 título', titulo = 'Guardar en el evento, no en el botón' FROM entradas WHERE codigo = 'RC-GM-03';
INSERT INTO verificacion SELECT 'RC-GM-03 cuerpo: una vez', (length(cuerpo) - length(replace(cuerpo, 'Los campos críticos (por ejemplo `es_autor_correspondencia`) deben guardarse en el evento del control (`CheckBox_Click`) para evitar que una deselección previa al guardado deje el dato sin escribir en la base.', ''))) = length('Los campos críticos (por ejemplo `es_autor_correspondencia`) deben guardarse en el evento del control (`CheckBox_Click`) para evitar que una deselección previa al guardado deje el dato sin escribir en la base.') FROM entradas WHERE codigo = 'RC-GM-03';
INSERT INTO verificacion SELECT 'RC-GM-03 sin SC-73', instr(relaciones, 'SC-73') = 0 FROM entradas WHERE codigo = 'RC-GM-03';
INSERT INTO verificacion SELECT 'SC-73 sin RC-GM-03', instr(relaciones, 'RC-GM-03') = 0 FROM entradas WHERE codigo = 'SC-73';

-- ------------------------------------------------------------
-- 2. RC-GM-03
-- ------------------------------------------------------------
UPDATE entradas
   SET titulo = 'Guardar en el evento, no en el botón: en los formularios que graban fila por fila',
       cuerpo = replace(cuerpo, 'Los campos críticos (por ejemplo `es_autor_correspondencia`) deben guardarse en el evento del control (`CheckBox_Click`) para evitar que una deselección previa al guardado deje el dato sin escribir en la base.', 'Los campos críticos (por ejemplo `es_autor_correspondencia`) deben guardarse en el evento del control (`CheckBox_Click`) para evitar que una deselección previa al guardado deje el dato sin escribir en la base.

ALCANCE: vale para los formularios que graban fila por fila, donde cambiar de fila antes de «Guardar» pierde lo marcado.

No vale para los editores que trabajan en memoria y graban todo junto (SC-73): ahí la marca pasa al objeto en memoria al aceptar el diálogo, al cambiar de idioma o de fila, y se graba con el resto en la transacción del registro. Guardar en el evento rompería esa transacción: dejaría escrita una parte aunque el usuario cierre sin guardar.'),
       relaciones = CASE WHEN relaciones = '' THEN 'contracara:SC-73' ELSE relaciones || ',contracara:SC-73' END,
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'RC-GM-03';
INSERT INTO verificacion SELECT 'RC-GM-03 actualizada', titulo = 'Guardar en el evento, no en el botón: en los formularios que graban fila por fila' AND instr(cuerpo, 'ALCANCE: vale para los formularios que graban fila por fila') > 0 AND instr(relaciones, 'contracara:SC-73') > 0 FROM entradas WHERE codigo = 'RC-GM-03';

-- ------------------------------------------------------------
-- 3. SC-73: RELACIÓN DE VUELTA
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = relaciones || ',contracara:RC-GM-03',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-73';
INSERT INTO verificacion SELECT 'SC-73 actualizada', instr(relaciones, 'contracara:RC-GM-03') > 0 FROM entradas WHERE codigo = 'SC-73';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('RC-GM-03', 'SC-73')
 ORDER BY prefijo, numero;
