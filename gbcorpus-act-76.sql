-- ============================================================
-- gbCorpus — actualización 76: cierre de las pruebas de la entrega 1
-- Esquema: 1
-- Origen: conversación del 29/10. Alberto probó en Linux Mint lo que
--         quedaba pendiente de SC-75 y SC-53: el botón deshabilitado en una
--         revista, «Todos los canónicos» en Califa (bibliografía
--         consolidada: remisiones en tenue, ningún aviso por ellas),
--         «Ensamblar» negándose con un canónico borrado y la versión de
--         libxml (2.9.14, la misma que en el contenedor).
-- Fecha:  2026-10-29
-- Aplicar: después de act-75
--
-- MODIFICA:
--   SC-75  pendiente: queda solo la entrega 2; entorno: libxml en Mint
--   SC-53  pendiente resuelto
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: act-75 APLICADA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-75 con el pendiente de act-75', pendiente LIKE '(1) Probar en Mint que el botón queda deshabilitado%' FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-53 con el pendiente de act-75', pendiente LIKE 'Probado en Mint con libros reales%' FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-75 entorno de act-75', instr(entorno, 'libxml 2.9.14 (contenedor)') > 0 FROM entradas WHERE codigo = 'SC-75';

-- ------------------------------------------------------------
-- 2. SC-75
-- ------------------------------------------------------------
UPDATE entradas
   SET pendiente = 'Entrega 2: discutir regla por regla el Schematron propio de gbpublisher (remisiones que jing no ve, reglas del proyecto) y los formatos de imagen admitidos por salida.',
       entorno = replace(entorno, 'libxml 2.9.14 (contenedor)', 'libxml 2.9.14 (contenedor y Linux Mint)'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 actualizada', pendiente LIKE 'Entrega 2:%' AND instr(entorno, 'contenedor y Linux Mint') > 0 FROM entradas WHERE codigo = 'SC-75';

-- ------------------------------------------------------------
-- 3. SC-53
-- ------------------------------------------------------------
UPDATE entradas
   SET pendiente = NULL,
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 sin pendiente', pendiente IS NULL FROM entradas WHERE codigo = 'SC-53';

COMMIT;

SELECT codigo, estado, evidencia, pendiente FROM entradas
 WHERE codigo IN ('SC-53', 'SC-75')
 ORDER BY prefijo, numero;
