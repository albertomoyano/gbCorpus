-- ============================================================
-- gbCorpus — actualización 54: SC-62 probada entera en Mint; GV-120
--            confirmada
-- Esquema: 1
-- Origen: Alberto, 21/10, en Mint: los casos que frenan
--         (n.\sptext{e}, n\sptext{K}) cortan la generación del canónico
--         con su mensaje y n\sptext{k} genera bien; el resaltado de
--         ***texto*** queda bien con el Markdown.highlight de act-53.
-- Fecha:  2026-10-21
-- Aplicar: después de act-53
--
-- MODIFICA:
--   SC-62   pendiente: solo el ODT
--   GV-120  confirmada en Mint, sin pendiente
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: act-53 APLICADA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-62 pendiente de act-53', instr(pendiente, 'Falta en Mint: un caso que frene.') = 1 FROM entradas WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'GV-120 con pendiente', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-120' AND pendiente IS NOT NULL;

-- ------------------------------------------------------------
-- 2. SC-62
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = cuerpo || '

Los casos que frenan, también en Mint (Alberto, 21/10): `n.\sptext{e}` (punto antes) y `n\sptext{K}` (mayúscula) cortan la generación del canónico con su mensaje; `n\sptext{k}` genera. La inserción desde el panel deja `\sptext{•}` con el marcador para escribir encima. Liberada con gbShortcodes `datos-v5-015.sql`.',
       pendiente = 'El ODT, cuando se encare (decisión de Alberto, 21/10).',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'SC-62 solo ODT', pendiente = 'El ODT, cuando se encare (decisión de Alberto, 21/10).' FROM entradas WHERE codigo = 'SC-62';

-- ------------------------------------------------------------
-- 3. GV-120
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = cuerpo || '

Confirmado en Mint con 3.22 (Alberto, 21/10): ***texto*** se colorea entero y el texto que sigue queda normal.',
       entorno = entorno || '; confirmado por Alberto en Mint',
       pendiente = NULL,
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'GV-120';
INSERT INTO verificacion SELECT 'GV-120 sin pendiente', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-120' AND pendiente IS NULL;

COMMIT;

SELECT codigo, pendiente FROM entradas WHERE codigo IN ('SC-62', 'GV-120');
