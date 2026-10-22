-- ============================================================
-- gbCorpus — actualización 56: SC-63 probada en Mint
-- Esquema: 1
-- Origen: Alberto, 21/10, en Mint con un libro y una revista: el corte
--         de los títulos de sección en el PDF, y HTML y EPUB sin corte,
--         según lo esperado.
-- Fecha:  2026-10-21
-- Aplicar: después de act-55
--
-- MODIFICA:
--   SC-63   sección PROBADO EN MINT; pendiente con lo que falta
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: act-55 APLICADA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-63 con su pendiente', instr(pendiente, 'Probar en Mint con un libro y una revista reales') = 1 FROM entradas WHERE codigo = 'SC-63';
INSERT INTO verificacion SELECT 'SC-63 sin la sección nueva', instr(cuerpo, 'PROBADO EN MINT') = 0 FROM entradas WHERE codigo = 'SC-63';

-- ------------------------------------------------------------
-- 2. SC-63
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = cuerpo || '

PROBADO EN MINT

Alberto, 21/10, con un libro y una revista reales: el PDF corta en la apertura del título de sección; el HTML y el EPUB, sin corte.',
       pendiente = 'Falta en Mint: un caso que frene (corte al final, dos seguidos o dentro de una bastardilla) y el control corte_fuera_de_titulo. El ODT, cuando se encare (decisión de Alberto, 21/10).',
       entorno = entorno || '; gbpublisher en Linux Mint (prueba de Alberto, 21/10)',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-63';
INSERT INTO verificacion SELECT 'SC-63 probada', instr(cuerpo, 'PROBADO EN MINT') > 0 AND instr(pendiente, 'Falta en Mint: un caso que frene') = 1 FROM entradas WHERE codigo = 'SC-63';

COMMIT;

SELECT codigo, pendiente FROM entradas WHERE codigo = 'SC-63';
