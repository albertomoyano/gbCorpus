-- ============================================================
-- gbCorpus — actualización 21: la navegación de FRegexResultados pasa
--            a Click (GV-78, SC-51)
-- Esquema: 1
-- Origen: prueba de Alberto en Mint: con FRegexResultados, el editor no
--         cambiaba de archivo. La navegación colgaba de gvResultados_Select
--         en una grilla Select.Multiple, contra la regla de GV-78.
-- Fecha:  2026-10-10
--
-- MODIFICA:
--   GV-78  se agrega el comportamiento de Select en Select.Multiple y el
--          segundo caso del proyecto; relación con SC-51
--   SC-51  dos pasajes: la navegación va en Click; $bRepoblando solo
--          frena el preview
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: LOS PASAJES EXISTEN UNA SOLA VEZ (act-20 APLICADA)
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-51 pasaje 1', (length(cuerpo) - length(replace(cuerpo, '- Elegir una fila de la grilla lleva el editor a la coincidencia (`m_BuscarRegex.MostrarCoincidencia`)', ''))) = length('- Elegir una fila de la grilla lleva el editor a la coincidencia (`m_BuscarRegex.MostrarCoincidencia`)') FROM entradas WHERE codigo = 'SC-51';
INSERT INTO verificacion SELECT 'SC-51 pasaje 2', (length(cuerpo) - length(replace(cuerpo, 'Al volver a llenar la grilla, un `Select` emitido por el código (GV-78) no mueve el editor: lo frena la bandera `$bRepoblando`.', ''))) = length('Al volver a llenar la grilla, un `Select` emitido por el código (GV-78) no mueve el editor: lo frena la bandera `$bRepoblando`.') FROM entradas WHERE codigo = 'SC-51';
INSERT INTO verificacion SELECT 'GV-78 sin la sección', instr(cuerpo, 'EN Select.Multiple') = 0 FROM entradas WHERE codigo = 'GV-78';

-- ------------------------------------------------------------
-- 2. SC-51
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(replace(cuerpo, '- Elegir una fila de la grilla lleva el editor a la coincidencia (`m_BuscarRegex.MostrarCoincidencia`)', '- Un click en una fila de la grilla lleva el editor a la coincidencia (`m_BuscarRegex.MostrarCoincidencia`). Va en `Click`, no en `Select` (GV-78): la primera versión navegaba desde `Select` y el editor no cambiaba de archivo en Mint. El preview de `txtContexto` va en `Change`, que también sigue a las flechas'), 'Al volver a llenar la grilla, un `Select` emitido por el código (GV-78) no mueve el editor: lo frena la bandera `$bRepoblando`.', 'Al volver a llenar la grilla, el editor no se mueve: la navegación cuelga de `Click`, que el código nunca dispara (GV-78). La bandera `$bRepoblando` solo evita que el preview se actualice con una fila movida por el código.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-51';

-- ------------------------------------------------------------
-- 3. GV-78
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = cuerpo || '

EN Select.Multiple, Select NO ES «SE ELIGIÓ UNA FILA»

En modo `Select.Multiple`, `MoveTo` emite `Change` pero no `Select`. `Select` sale de `_RaiseSelect`, cuando cambia el CONJUNTO de filas seleccionadas, y se suprime o se difiere al soltar el botón mientras el mouse arrastra una selección (`$bDoNotRaiseSelect`, `$bMoveRaiseSelect`). Un click sobre una fila que ya está seleccionada —por ejemplo después de Ctrl+A, o al volver a la fila marcada— no cambia la selección y no emite `Select`. Leído en `GridView.class` de `gb.gui.base`, etiqueta 3.22.1 (`ScrollArea_MouseDown`, `AfterMouseUp`). En 3.19, en el banco, un click sobre una fila NO seleccionada sí emitió `Select`: el fallo depende del estado de la selección, y por eso no siempre aparece.

CASO EN EL PROYECTO (2): `FRegexResultados`, que es `Select.Multiple` para elegir qué reemplazar, navegaba desde `gvResultados_Select` y en Mint el editor no cambiaba de archivo. Pasó a `gvResultados_Click`, con el preview en `gvResultados_Change` (SC-51).',
       relaciones = relaciones || ',vinculo:SC-51',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'GV-78';

INSERT INTO verificacion SELECT 'SC-51 actualizada', instr(cuerpo, 'Va en `Click`, no en `Select`') > 0 AND instr(cuerpo, 'solo evita que el preview') > 0 FROM entradas WHERE codigo = 'SC-51';
INSERT INTO verificacion SELECT 'GV-78 actualizada', instr(cuerpo, 'CASO EN EL PROYECTO (2)') > 0 FROM entradas WHERE codigo = 'GV-78';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('GV-78', 'SC-51') ORDER BY prefijo, numero;
