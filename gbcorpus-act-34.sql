-- ============================================================
-- gbCorpus — actualización 34: SC-55, los frenos de las salidas
--            confirmados en Mint
-- Esquema: 1
-- Origen: prueba de Alberto en Mint, libro 7: un código repetido forzado
--         por SQL directo (bm-11-indice-autores junto a bm-11-referencias),
--         sin pasar por el formulario. Frenaron el PDF, el canónico/HTML y
--         el EPUB, con el código y sus dos piezas en el mensaje. Nombre
--         restituido después.
-- Fecha:  2026-10-14
-- Aplicar: sqlite3 -bail ~/.gbcorpus/corpus.sqlite < gbcorpus-act-34.sql
--          (DESPUÉS DE act-31, act-32 Y act-33)
--
-- MODIFICA:
--   SC-55  por qué los frenos de las salidas siguen aunque el formulario
--          bloquee; evidencia; pendiente: solo el Tooltip
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-55 viene de act-33', instr(pendiente, 'Falta en Mint: el freno de las tres salidas') > 0 FROM entradas WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-55 ancla salidas, una vez', (length(cuerpo) - length(replace(cuerpo, '`m_GenerarEpubLibro.GenerarEpubLibro` (2).', ''))) / length('`m_GenerarEpubLibro.GenerarEpubLibro` (2).') = 1 FROM entradas WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-55 sin el apartado nuevo', instr(cuerpo, 'Por qué siguen los frenos de las salidas') = 0 FROM entradas WHERE codigo = 'SC-55';

-- ------------------------------------------------------------
-- 2. SC-55
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, '`m_GenerarEpubLibro.GenerarEpubLibro` (2).', '`m_GenerarEpubLibro.GenerarEpubLibro` (2).
- Por qué siguen los frenos de las salidas, si el formulario ya no deja salir con el orden roto: son la última barrera, no la principal. Cubren lo que no pasa por el formulario: los libros cargados antes de este control y nunca reabiertos, los cambios en `capitulos` hechos fuera de él (SQL directo, scripts de actualización, otra herramienta) y el fallo de lectura al cerrar, que a propósito deja el botón habilitado. Cuestan una consulta por salida.'),
       evidencia = 'empirica',
       pendiente = 'Probado en el contenedor: gbc3 compila el proyecto (con gb.db en lugar de gb.db2, que 3.19 no trae); ProblemaOrdenFinales, con gbs3, en siete casos; la consulta de códigos repetidos, en MySQL 8.0.46 con ONLY_FULL_GROUP_BY, desde gbs3 con gb.db. Confirmado por Alberto en Mint: los avisos de R1, el aviso de códigos repetidos, el botón Cerrar deshabilitado y el freno de las tres salidas (PDF, canónico/HTML, EPUB) con un código repetido forzado por SQL en un libro real. Falta solo ver si el Tooltip se muestra sobre el botón deshabilitado; si no, el motivo igual llega por la X y por el aviso al guardar. Hecho eso, quitar este pendiente.',
       fecha_verificacion = '2026-10',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-55 actualizada', instr(cuerpo, 'Por qué siguen los frenos de las salidas') > 0 AND instr(pendiente, 'Falta solo ver si el Tooltip') > 0 AND instr(pendiente, 'Falta en Mint: el freno') = 0 FROM entradas WHERE codigo = 'SC-55';

COMMIT;

SELECT codigo, estado, evidencia, titulo FROM entradas WHERE codigo = 'SC-55';
