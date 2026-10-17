-- ============================================================
-- gbCorpus — actualización 35: SC-55 cierra; excepción consciente a la
--            contrapartida de SC-20
-- Esquema: 1
-- Origen: el botón Cerrar deshabilitado no decía por qué al abrir un libro
--         que ya llegaba con el orden roto, y la ventana no tiene X por
--         diseño (SC-20). Decisión de Alberto: aviso en Form_Open; Form_Close
--         vuelve a su comportamiento original. Confirmado por Alberto en
--         Mint: el Tooltip se ve con el botón deshabilitado y no aparece con
--         el botón habilitado. Una prueba anterior en la que no aparecía
--         quedó sin explicación.
-- Fecha:  2026-10-14
-- Aplicar: sqlite3 -bail ~/.gbcorpus/corpus.sqlite < gbcorpus-act-35.sql
--          (DESPUÉS DE act-31 A act-34)
--
-- MODIFICA:
--   SC-55  aviso al abrir; Form_Close sin rama para la X; excepción a SC-20;
--          sin pendiente
--   SC-20  remite a SC-55 en la contrapartida
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-55 viene de act-34', instr(pendiente, 'Falta solo ver si el Tooltip') > 0 FROM entradas WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-55 ancla X, una vez', (length(cuerpo) - length(replace(cuerpo, 'con el botón deshabilitado, la X muestra el motivo en vez de «use Cerrar».', ''))) / length('con el botón deshabilitado, la X muestra el motivo en vez de «use Cerrar».') = 1 FROM entradas WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-55 ancla FUERA DEL ALCANCE, una vez', (length(cuerpo) - length(replace(cuerpo, 'FUERA DEL ALCANCE', ''))) / length('FUERA DEL ALCANCE') = 1 FROM entradas WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-20 ancla contrapartida, una vez', (length(cuerpo) - length(replace(cuerpo, 'Un formulario sin botón de cerrar necesita una salida propia en la interfaz: un botón, la tecla Escape, o las dos.', ''))) / length('Un formulario sin botón de cerrar necesita una salida propia en la interfaz: un botón, la tecla Escape, o las dos.') = 1 FROM entradas WHERE codigo = 'SC-20';

-- ------------------------------------------------------------
-- 2. SC-55
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(replace(cuerpo,
     'con el botón deshabilitado, la X muestra el motivo en vez de «use Cerrar».',
     'la ventana no tiene X (SC-20), así que `Form_Close` es solo defensa y conserva su aviso original. Si el libro ya llega con el orden roto, `Form_Open` (apartado 9) muestra el motivo apenas se abre el formulario: sin eso el botón aparecería apagado sin explicación hasta pasar el puntero.'),
     'FUERA DEL ALCANCE',
     'EXCEPCIÓN A LA CONTRAPARTIDA DE SC-20

SC-20 exige que un formulario sin X tenga una salida propia. Deshabilitar `btnCerrar` la quita a propósito, y se acepta por dos razones: la salida vuelve sola al corregir el orden, y un fallo de lectura de la base deja el botón habilitado, así que nunca se queda encerrado por un problema que no se puede resolver desde el formulario. Decisión de Alberto.

FUERA DEL ALCANCE'),
       relaciones = relaciones || ',vinculo:SC-20',
       pendiente = NULL,
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-55 actualizada', instr(cuerpo, 'EXCEPCIÓN A LA CONTRAPARTIDA DE SC-20') > 0 AND instr(cuerpo, 'apartado 9') > 0 AND instr(cuerpo, 'la X muestra el motivo') = 0 AND pendiente IS NULL AND instr(relaciones, 'SC-20') > 0 FROM entradas WHERE codigo = 'SC-55';

-- ------------------------------------------------------------
-- 3. SC-20 REMITE A LA EXCEPCIÓN
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo,
     'Un formulario sin botón de cerrar necesita una salida propia en la interfaz: un botón, la tecla Escape, o las dos.',
     'Un formulario sin botón de cerrar necesita una salida propia en la interfaz: un botón, la tecla Escape, o las dos. Excepción consciente: `FMetadatosCapitulos` deshabilita su botón mientras el orden del libro esté roto (SC-55).'),
       relaciones = relaciones || ',vinculo:SC-55',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-20' AND instr(relaciones, 'SC-55') = 0;
INSERT INTO verificacion SELECT 'SC-20 actualizada', instr(cuerpo, 'Excepción consciente') > 0 AND instr(relaciones, 'SC-55') > 0 FROM entradas WHERE codigo = 'SC-20';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-20', 'SC-55') ORDER BY numero;
