-- ============================================================
-- gbCorpus — actualización: SC-49, verso liberado
-- Esquema: 1
-- Origen: prueba de Alberto en Mint y decisión sobre JATS
-- Fecha:  2026-10-09
--
-- CAMBIO:
--   SC-49  el pendiente pasa a lo que falta después de la prueba en
--          Mint; el shortcode se libera (gbShortcodes datos-v5-011).
--          El XML JATS y sus sabores se prueban en la fase de JATS,
--          con todos los shortcodes desarrollados (decisión de Alberto).
--
-- REQUIERE gbcorpus-act-12.sql APLICADO. INDEPENDIENTE DE act-13.
-- ============================================================

BEGIN TRANSACTION;

-- ------------------------------------------------------------
-- 1. SC-49: PENDIENTE
--    EL WHERE EXIGE EL PENDIENTE DE act-12: SI NO ESTÁ, 0 FILAS
-- ------------------------------------------------------------

UPDATE entradas
   SET pendiente = 'Probado en Mint (2026-10) con prueba-verso.md: PDF, HTML y EPUB en libros y revistas, correctos; el shortcode se liberó (gbShortcodes datos-v5-011). Falta: el ODT; la inserción desde el panel; los casos que frenan (prueba/frena); epubcheck sobre un EPUB completo. El XML JATS, sus sabores (SciELO, Redalyc) y packtools con un verse-group se prueban en la fase de JATS, cuando estén todos los shortcodes desarrollados (decisión de Alberto).',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-49'
   AND instr(pendiente, 'Probar en Mint: libro y revista (PDF, HTML, EPUB, ODT)') = 1;

COMMIT;

-- ============================================================
-- VERIFICACIÓN POSTERIOR: 1
-- ============================================================

SELECT codigo, instr(pendiente, 'Probado en Mint (2026-10)') = 1 AS pendiente_nuevo
  FROM entradas
 WHERE codigo = 'SC-49';
