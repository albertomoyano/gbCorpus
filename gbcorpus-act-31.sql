-- ============================================================
-- gbCorpus — actualización 31: el orden de los finales tiene control
-- Esquema: 1
-- Origen: un libro de autor con bibliografía consolidada sacó el índice de
--         autores antes de la bibliografía. Dos causas: la bibliografía no
--         declarada va al final, después de todas las piezas; y declarada,
--         la numeración la puso después del índice (bm-20 índice, bm-21
--         referencias). Ninguna de las dos falla: compila y da un libro
--         equivocado. Decisión de Alberto: semáforo (aviso en el ABM, freno
--         en el generador del PDF), reglas R1, R2 y R3, entrada nueva.
--         Cotejado con gbCorpus en GitHub (último script: act-30).
-- Fecha:  2026-10-14
-- Aplicar: sqlite3 -bail ~/.gbcorpus/corpus.sqlite < gbcorpus-act-31.sql
--          (SIN -bail, UNA VERIFICACIÓN QUE FALLA NO CORTA EL SCRIPT)
--
-- ALTAS:
--   SC-55  Orden de los finales: la bibliografía antes de los índices, el
--          colofón último; aviso en el ABM, freno en el PDF
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-55 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-55' OR (prefijo = 'SC' AND numero = 55);
INSERT INTO verificacion SELECT 'SC-54 es la última SC', MAX(numero) = 54 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'SC-44 existe', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-44' AND estado = 'vigente';

-- ------------------------------------------------------------
-- 2. SC-55
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 55, 'SC-55', 'Orden de los finales: la bibliografía antes de los índices, el colofón último; aviso en el ABM, freno en el PDF',
   'DECISIÓN CERRADA (decisión de Alberto). Libros, salida PDF. El orden de las piezas sale del nombre de archivo (SC-44), y hay errores de orden en los finales que compilan sin fallar y dan un libro equivocado. Esos se controlan; el resto del orden de los finales no.

EL CASO QUE LO ORIGINÓ

Un libro de autor con bibliografía consolidada sacó el índice de autores antes de la bibliografía. Con bibliografía por capítulo no se ve: cada pieza trae la suya y el índice después del último capítulo es lo correcto. Dos caminos llevan al error:
- La bibliografía consolidada sin pieza declarada: `ArmarInsumosLaTeX` (apartado 8) emite `\printbibliography[heading=bibintoc]` al final, después de TODAS las piezas declaradas, índices incluidos.
- La pieza declarada pero numerada después del índice (`bm-20-indice-autores`, `bm-21-referencias`).

LAS REGLAS

La función es `m_PiezasLibro.ProblemaOrdenFinales(aNombre, aTipo, bConsolidada)`: recibe las piezas en el orden del libro y devuelve vacío o el mensaje del PRIMER problema, con qué está mal y cómo corregirlo.
- R1. Ningún `indice_*` (onomastico, concepto, autores) antes de la pieza `bibliografia`. Si hay más de una, manda la primera, como en el EPUB.
- R2. Bibliografía consolidada, sin pieza `bibliografia` y con algún índice declarado: hay que declararla. Sin índices no se exige: el respaldo del apartado 8 da el orden correcto y los libros anteriores siguen compilando.
- R3. Si hay pieza `colofon`, es la última.

No se controlan `glosario`, `sobre_autores` ni `cronologia`: su lugar es tradición editorial, no error, y una regla rígida frenaría libros bien compuestos.

POR QUÉ UN SEMÁFORO

Es una regla del LIBRO, no de una pieza, y por eso no va en `ProblemaPosicion` (la de la dedicatoria, que con el nombre de la pieza alcanza). Al renumerar dos piezas hay un estado intermedio inválido que no se puede evitar; un freno al guardar obligaría a pasar por un nombre provisorio.
- Amarillo: `m_Metadatos.GuardarMetadatosDeCapitulo` (apartado 7), DESPUÉS de guardar, lee todas las piezas con nombre del libro abierto en el orden de `m_OrdenPiezas.ClausulaOrden` (`ProblemaOrdenLibroAbierto`) y muestra `Message.Warning`. Un fallo de lectura no se informa: el aviso es ayuda.
- Rojo: `m_GenerarPDFLibro.ArmarInsumosLaTeX` (apartado 2b, después de `VerificarPosiciones`) frena con `Message.Error` antes de escribir nada.

La regla está escrita una sola vez, en `m_PiezasLibro`; los dos lugares la llaman.

FUERA DEL ALCANCE

EPUB y HTML: los índices no se generan (`m_PiezasLibro.Tratamiento`), así que el orden respecto de la bibliografía no cambia nada. El EPUB ubica su colofón solo.',
   'vigente', 'empirica', 'gbpublisher / Gambas 3.19 (gbc3, gbs3) / contenedor Ubuntu', '2026-10',
   'vinculo:SC-44,vinculo:SC-45,vinculo:RC-GM-17',
   'Probado en el contenedor: gbc3 compila el proyecto (con gb.db en lugar de gb.db2, que 3.19 no trae) y ProblemaOrdenFinales, con gbs3, da lo esperado en siete casos (el error que lo originó, el corregido, R2 con y sin índices, por capítulo, R3 con y sin error). Falta en Mint con gbpublisher: el aviso del ABM al renumerar y el freno del PDF con un libro real. Hecho eso, quitar este pendiente.',
   550, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-55 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-55' AND orden = 550 AND estado = 'vigente';

-- ------------------------------------------------------------
-- 3. SC-44 REMITE A SC-55
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-55',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-44' AND instr(relaciones, 'SC-55') = 0;
INSERT INTO verificacion SELECT 'SC-44 relación', instr(relaciones, 'SC-55') > 0 FROM entradas WHERE codigo = 'SC-44';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-44', 'SC-55') ORDER BY numero;
