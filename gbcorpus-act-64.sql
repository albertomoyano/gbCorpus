-- ============================================================
-- gbCorpus — actualización 64: la referencia a un cuadro de otro
--            capítulo; el HTML con el modelo del EPUB (SC-66)
-- Esquema: 1
-- Origen: prueba de Alberto en Mint de la entrega 2 (22/10): la
--         referencia entre capítulos salía «??»; el HTML no se entendía
--         con celdas unidas, el EPUB sí.
-- Fecha:  2026-10-22
-- Aplicar: después de act-63
--
-- MODIFICA:
--   SC-66   el id tbl- global; el estilo del HTML
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

INSERT INTO verificacion SELECT 'SC-66 ancla del HTML (una vez)', (length(cuerpo) - length(replace(cuerpo, 'EL HTML CONSERVA SU ESTILO WEB (decisión de Alberto, 22/10): el encabezado de color y las filas alternas de `gbpublisher.css`, sin los filetes del PDF. El estilo de la casa es del PDF.', ''))) = length('EL HTML CONSERVA SU ESTILO WEB (decisión de Alberto, 22/10): el encabezado de color y las filas alternas de `gbpublisher.css`, sin los filetes del PDF. El estilo de la casa es del PDF.') FROM entradas WHERE codigo = 'SC-66';
INSERT INTO verificacion SELECT 'SC-66 ancla de las referencias (una vez)', (length(cuerpo) - length(replace(cuerpo, '- Referencias cruzadas en libros: `cite-to-biblioref-db.lua` admite `tbl-`;', ''))) = length('- Referencias cruzadas en libros: `cite-to-biblioref-db.lua` admite `tbl-`;') FROM entradas WHERE codigo = 'SC-66';

UPDATE entradas
   SET cuerpo = replace(replace(cuerpo, 'EL HTML CONSERVA SU ESTILO WEB (decisión de Alberto, 22/10): el encabezado de color y las filas alternas de `gbpublisher.css`, sin los filetes del PDF. El estilo de la casa es del PDF.', 'EL HTML TOMA EL MODELO DEL EPUB (decisión de Alberto, 22/10, que reemplaza la de conservar el estilo web: con celdas unidas, las filas alternas no se entendían): un filete entre todas las celdas y el encabezado con fondo; el fondo es el gris azulado de la casa (`--color-tabla-header`), no el gris del EPUB; sin filas alternas. En libros (`gbpublisher.css`) y en revistas (`jats-to-html.xsl`). El modelo es el PDF, que Alberto viene desarrollando en sus libros.'), '- Referencias cruzadas en libros: `cite-to-biblioref-db.lua` admite `tbl-`;', '- Referencias cruzadas en libros: `cite-to-biblioref-db.lua` admite `tbl-`, y `ensamblar-capitulo-canonico.xsl` no le pone el prefijo del capítulo a un id `tbl-` (`db:es-id-global`, como `fig-`): así una referencia a un cuadro de otro capítulo funciona (medido: en la prueba de Alberto salía «??»). El id es único en el proyecto porque es el nombre del archivo;'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-66';
INSERT INTO verificacion SELECT 'SC-66 actualizada', instr(cuerpo, 'EL HTML TOMA EL MODELO DEL EPUB') > 0 AND instr(cuerpo, 'db:es-id-global') > 0 FROM entradas WHERE codigo = 'SC-66';

COMMIT;

SELECT codigo, estado, fecha_modificacion FROM entradas WHERE codigo = 'SC-66';
