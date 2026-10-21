-- ============================================================
-- gbCorpus — actualización 50: SC-61 probada en Mint; GV-113
--            confirmada con el preámbulo del proyecto
-- Esquema: 1
-- Origen: prueba de Alberto en Mint (21/10) con un libro y una
--         revista reales: las tres alineaciones con negrita,
--         bastardilla, una referencia y una nota al pie que lleva
--         otra referencia. PDF, HTML y EPUB según lo esperado. El ODT
--         queda para cuando estén terminadas las salidas PDF
--         (decisión de Alberto, 21/10).
-- Fecha:  2026-10-21
-- Aplicar: después de act-49
--
-- MODIFICA:
--   SC-61   sección PROBADO EN MINT; pendiente con lo que falta
--   GV-113  sin pendiente: confirmada con el preámbulo real
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: act-49 APLICADA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-61 existe con pendiente', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-61' AND pendiente IS NOT NULL;
INSERT INTO verificacion SELECT 'SC-61 sin la sección nueva', instr(cuerpo, 'PROBADO EN MINT') = 0 FROM entradas WHERE codigo = 'SC-61';
INSERT INTO verificacion SELECT 'GV-113 existe con pendiente', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-113' AND pendiente IS NOT NULL;

-- ------------------------------------------------------------
-- 2. SC-61
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = cuerpo || '

PROBADO EN MINT

Alberto, 21/10, con un libro y una revista reales: las tres alineaciones, con negrita, bastardilla, una referencia y una nota al pie que lleva otra referencia, junto a `espaciov` y al froufrou. PDF: cada párrafo en su lugar, sin sangría; un párrafo centrado pasa bien de página; la nota sale justificada y con corte, como cualquier otra (GV-114). HTML y EPUB: el párrafo común, a la izquierda y con la separación de los párrafos.',
       pendiente = 'ODT: se encara cuando estén terminadas las salidas PDF (decisión de Alberto, 21/10). Sin confirmar en Mint: la inserción desde el panel, el conteo de m_AnalizarProyecto y el mensaje de un caso que frena (probados solo en el contenedor, los casos que frenan). Las hojas de HTML y EPUB de libros no se corrieron sueltas en el contenedor; en Mint salieron bien.',
       entorno = entorno || '; gbpublisher en Linux Mint (prueba de Alberto, 21/10)',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-61';
INSERT INTO verificacion SELECT 'SC-61 con la sección nueva', instr(cuerpo, 'PROBADO EN MINT') > 0 FROM entradas WHERE codigo = 'SC-61';
INSERT INTO verificacion SELECT 'SC-61 con el pendiente nuevo', instr(pendiente, 'ODT: se encara') = 1 FROM entradas WHERE codigo = 'SC-61';

-- ------------------------------------------------------------
-- 3. GV-113
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = cuerpo || '

Confirmado en Mint con el preámbulo del proyecto (Alberto, 21/10): en un libro y en una revista, los párrafos alineados no parten.',
       pendiente = NULL,
       entorno = entorno || '; gbpublisher en Linux Mint (prueba de Alberto, 21/10)',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'GV-113';
INSERT INTO verificacion SELECT 'GV-113 sin pendiente', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-113' AND pendiente IS NULL AND instr(cuerpo, 'Confirmado en Mint') > 0;

COMMIT;

SELECT codigo, estado, pendiente FROM entradas WHERE codigo IN ('GV-113', 'SC-61') ORDER BY prefijo, numero;
