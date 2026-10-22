-- ============================================================
-- gbCorpus — actualización 61: el pie del cuadro en el HTML y el EPUB,
--            en un párrafo como en el PDF (SC-66)
-- Esquema: 1
-- Origen: prueba de Alberto en Mint del 22/10 sobre la entrega 1 de los
--         cuadros: el PDF salió como se esperaba; en el HTML y el EPUB la
--         nota salía en un párrafo aparte. El PDF es el modelo.
-- Fecha:  2026-10-22
-- Aplicar: después de act-60
--
-- MODIFICA:
--   SC-66   el pie del HTML y del EPUB
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

INSERT INTO verificacion SELECT 'SC-66 ancla del HTML (una vez)', (length(cuerpo) - length(replace(cuerpo, '- HTML y EPUB: la tabla completa y derecha; debajo, «Cuadro N» con el título, y la nota. El número es el del PDF', ''))) = length('- HTML y EPUB: la tabla completa y derecha; debajo, «Cuadro N» con el título, y la nota. El número es el del PDF') FROM entradas WHERE codigo = 'SC-66';

UPDATE entradas
   SET cuerpo = replace(cuerpo, '- HTML y EPUB: la tabla completa y derecha; debajo, «Cuadro N» con el título, y la nota. El número es el del PDF', '- HTML y EPUB: la tabla completa y derecha; debajo, en un solo párrafo como en el PDF, «Cuadro N», el título y, a continuación, la nota, con punto seguido si el título no termina en . ? ! (decisión de Alberto, 22/10: el PDF es el modelo). El número es el del PDF'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-66';
INSERT INTO verificacion SELECT 'SC-66 actualizada', instr(cuerpo, 'en un solo párrafo como en el PDF') > 0 FROM entradas WHERE codigo = 'SC-66';

COMMIT;

SELECT codigo, estado, fecha_modificacion FROM entradas WHERE codigo = 'SC-66';
