-- ============================================================
-- gbCorpus — actualización 32: SC-55 suma los códigos de posición
--            repetidos
-- Esquema: 1
-- Origen: probando SC-55, dos piezas con el mismo NN (bm-20-…) quedaron
--         ordenadas por el resto del nombre. Decisión de Alberto: vale para
--         todo el libro, freno en las salidas y al cerrar el formulario de
--         capítulos, aviso al guardar; apartado de SC-55, no entrada nueva.
-- Fecha:  2026-10-14
-- Aplicar: sqlite3 -bail ~/.gbcorpus/corpus.sqlite < gbcorpus-act-32.sql
--
-- MODIFICA:
--   SC-55  apartado CÓDIGOS REPETIDOS; entorno con MySQL 8.0.46; pendiente
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-55 existe', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-55' AND estado = 'vigente';
INSERT INTO verificacion SELECT 'SC-55 sin el apartado', instr(cuerpo, 'CÓDIGOS REPETIDOS') = 0 FROM entradas WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-55 ancla FUERA DEL ALCANCE, una vez', (length(cuerpo) - length(replace(cuerpo, 'FUERA DEL ALCANCE', ''))) / length('FUERA DEL ALCANCE') = 1 FROM entradas WHERE codigo = 'SC-55';

-- ------------------------------------------------------------
-- 2. SC-55: EL APARTADO, ANTES DE FUERA DEL ALCANCE
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'FUERA DEL ALCANCE', 'CÓDIGOS REPETIDOS

Dos piezas con el mismo código de posición (`bm-20-indice-autores` y `bm-20-referencias`) quedan ordenadas por el resto del nombre, alfabéticamente, y no por el número: el orden puede salir bien por casualidad. Vale para TODO el libro —preliminares, cuerpo y finales— y para todas las salidas, porque todas ordenan por nombre (SC-44).

- La función es `m_PiezasLibro.ProblemaCodigoRepetido(iIdLibro)`. Agrupa por `m_OrdenPiezas.ExpresionCodigo`, la misma definición del código que usan las grillas: no se reescribe en Gambas. `GROUP BY` sobre el alias lo admite MySQL (manual 8.0, B.3.4.4). Lista TODOS los códigos repetidos con sus piezas: renumerar uno puede chocar con otro. Un fallo de lectura devuelve vacío: los generadores leen la misma tabla y fallan con su propio mensaje.
- Va ANTES que `ProblemaOrdenFinales`: con un código repetido, el control de los finales podría dar bien por casualidad.
- Amarillo al guardar: `ProblemaOrdenLibroAbierto` lo consulta primero.
- Rojo al cerrar `FMetadatosCapitulos`: `btnCerrar_Click` no habilita el cierre mientras haya repetidos. Es el único camino de cierre, porque `Form_Close` bloquea la X con `Stop Event`. Al guardar no se frena: al renumerar hay estados intermedios con códigos repetidos; al cerrar ya no.
- Rojo en las salidas: `m_GenerarPDFLibro.ArmarInsumosLaTeX` (2b), `m_GenerarSalidasLibro.PrepararInsumosLibro` (canónico del libro y HTML) y `m_GenerarEpubLibro.GenerarEpubLibro` (2).

FUERA DEL ALCANCE'),
       entorno = entorno || ' / MySQL 8.0.46',
       pendiente = 'Probado en el contenedor: gbc3 compila el proyecto (con gb.db en lugar de gb.db2, que 3.19 no trae); ProblemaOrdenFinales, con gbs3, da lo esperado en siete casos; la consulta de códigos repetidos, en MySQL 8.0.46 con ONLY_FULL_GROUP_BY, desde gbs3 con gb.db (el GROUP_CONCAT llega como String). Alberto confirmó en Mint los avisos de R1 con el orden inverso y con el mismo número. Falta en Mint: el freno al cerrar el formulario de capítulos y el de las tres salidas con un código repetido. Hecho eso, quitar este pendiente.',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-55';
INSERT INTO verificacion SELECT 'SC-55 actualizada', instr(cuerpo, 'CÓDIGOS REPETIDOS') > 0 AND instr(cuerpo, 'FUERA DEL ALCANCE') > instr(cuerpo, 'CÓDIGOS REPETIDOS') AND instr(entorno, 'MySQL 8.0.46') > 0 FROM entradas WHERE codigo = 'SC-55';

COMMIT;

SELECT codigo, estado, entorno FROM entradas WHERE codigo = 'SC-55';
