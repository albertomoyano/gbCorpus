-- ============================================================
-- gbCorpus — actualización 20: SC-51, el editor queda en el último
--            archivo cambiado
-- Esquema: 1
-- Origen: prueba de Alberto en Mint: después de reemplazar en varios
--         archivos, el editor seguía en el archivo de partida. Decisión de
--         Alberto: el editor queda en el último archivo con cambios.
-- Fecha:  2026-10-10
--
-- MODIFICA:
--   SC-51  el renglón «Al cerrar…» se reemplaza por tres; relación con GV-78
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: EL RENGLÓN EXISTE UNA SOLA VEZ (act-19 APLICADA)
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-51 renglón a reemplazar', (length(cuerpo) - length(replace(cuerpo, '- Al cerrar, el editor queda en la última coincidencia vista, con el foco.', ''))) = length('- Al cerrar, el editor queda en la última coincidencia vista, con el foco.') FROM entradas WHERE codigo = 'SC-51';

-- ------------------------------------------------------------
-- 2. SC-51
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, '- Al cerrar, el editor queda en la última coincidencia vista, con el foco.', '- Después de reemplazar, el editor queda en el ÚLTIMO archivo cambiado (orden de la grilla, que es el editorial), con su PRIMER cambio seleccionado y el párrafo arriba (decisión de Alberto). Ese cambio no se corrió: los reemplazos van de atrás para adelante. Al volver a llenar la grilla, un `Select` emitido por el código (GV-78) no mueve el editor: lo frena la bandera `$bRepoblando`.
- Al cerrar, el editor queda donde estaba —la última coincidencia vista o el último cambio—, con el foco.
- `MostrarCoincidencia` no tiene salidas mudas (GV-23): si no puede mover el editor, lo dice.'),
       relaciones = relaciones || ',vinculo:GV-78',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-51';

INSERT INTO verificacion SELECT 'SC-51 actualizada', instr(cuerpo, 'ÚLTIMO archivo cambiado') > 0 AND instr(relaciones, 'vinculo:GV-78') > 0 FROM entradas WHERE codigo = 'SC-51';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo = 'SC-51';
