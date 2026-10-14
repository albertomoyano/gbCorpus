-- ============================================================
-- gbCorpus — actualización 33: SC-55, el cierre del formulario de
--            capítulos se bloquea deshabilitando el botón
-- Esquema: 1
-- Origen: probando act-32, el formulario se cerraba con los finales
--         desordenados: el cierre solo miraba los códigos repetidos.
--         Decisión de Alberto: con cualquier problema de orden, btnCerrar
--         queda deshabilitado hasta corregirlo. Confirmado por Alberto en
--         Mint.
-- Fecha:  2026-10-14
-- Aplicar: sqlite3 -bail ~/.gbcorpus/corpus.sqlite < gbcorpus-act-33.sql
--          (DESPUÉS DE act-31 Y act-32)
--
-- MODIFICA:
--   SC-55  CÓDIGOS REPETIDOS: viñetas de amarillo y rojo al cerrar; pendiente
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-55 ancla amarillo', (length(cuerpo) - length(replace(cuerpo, '- Amarillo al guardar: `ProblemaOrdenLibroAbierto` lo consulta primero.', ''))) / length('- Amarillo al guardar: `ProblemaOrdenLibroAbierto` lo consulta primero.') = 1 FROM entradas WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-55 ancla rojo al cerrar', (length(cuerpo) - length(replace(cuerpo, '- Rojo al cerrar `FMetadatosCapitulos`: `btnCerrar_Click` no habilita el cierre mientras haya repetidos. Es el único camino de cierre, porque `Form_Close` bloquea la X con `Stop Event`. Al guardar no se frena: al renumerar hay estados intermedios con códigos repetidos; al cerrar ya no.', ''))) / length('- Rojo al cerrar `FMetadatosCapitulos`: `btnCerrar_Click` no habilita el cierre mientras haya repetidos. Es el único camino de cierre, porque `Form_Close` bloquea la X con `Stop Event`. Al guardar no se frena: al renumerar hay estados intermedios con códigos repetidos; al cerrar ya no.') = 1 FROM entradas WHERE codigo = 'SC-55';

-- ------------------------------------------------------------
-- 2. SC-55
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(replace(cuerpo,
     '- Amarillo al guardar: `ProblemaOrdenLibroAbierto` lo consulta primero.',
     '- Amarillo al guardar: `m_Metadatos.ProblemaOrdenLibroAbierto` (pública) es el control completo del libro abierto: primero los repetidos, después R1 a R3. El aviso anuncia que el formulario no se va a poder cerrar.'),
     '- Rojo al cerrar `FMetadatosCapitulos`: `btnCerrar_Click` no habilita el cierre mientras haya repetidos. Es el único camino de cierre, porque `Form_Close` bloquea la X con `Stop Event`. Al guardar no se frena: al renumerar hay estados intermedios con códigos repetidos; al cerrar ya no.',
     '- Rojo al cerrar `FMetadatosCapitulos`, para TODAS las reglas —repetidos y R1 a R3—: `ActualizarCierre` deja `btnCerrar.Enabled` en False, con el motivo en el `Tooltip`, mientras `ProblemaOrdenLibroAbierto` devuelva un problema. Se llama al principio de `RefrescarGbCapitulos`, por donde pasan la apertura, el alta, la baja y el guardado: un solo punto. Es el único camino de cierre, porque `Form_Close` bloquea la X con `Stop Event`; con el botón deshabilitado, la X muestra el motivo en vez de «use Cerrar». `btnCerrar_Click` repite el control como defensa. Al guardar no se frena: al renumerar hay estados intermedios inválidos; al cerrar ya no. Un fallo de lectura de la base deja el botón habilitado: un problema de la base no encierra en un formulario modal.'),
       pendiente = 'Probado en el contenedor: gbc3 compila el proyecto (con gb.db en lugar de gb.db2, que 3.19 no trae); ProblemaOrdenFinales, con gbs3, da lo esperado en siete casos; la consulta de códigos repetidos, en MySQL 8.0.46 con ONLY_FULL_GROUP_BY, desde gbs3 con gb.db (el GROUP_CONCAT llega como String). Alberto confirmó en Mint los avisos de R1, el aviso de códigos repetidos y el botón Cerrar deshabilitado. Falta en Mint: el freno de las tres salidas (PDF, canónico/HTML, EPUB) con un código repetido, y ver si el Tooltip se muestra sobre el botón deshabilitado. Hecho eso, quitar este pendiente.',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-55 actualizada', instr(cuerpo, 'ActualizarCierre') > 0 AND instr(cuerpo, 'mientras haya repetidos') = 0 AND instr(pendiente, 'botón Cerrar deshabilitado') > 0 FROM entradas WHERE codigo = 'SC-55';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo = 'SC-55';
