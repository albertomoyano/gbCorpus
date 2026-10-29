-- ============================================================
-- gbCorpus — actualización 77: el role del estilo de cita, estilo-cita
-- Esquema: 1
-- Origen: conversación del 29/10. Alberto confirma renombrar
--         <bibliomisc role="csl-style"> a role="estilo-cita": el estilo es
--         un cita-*-config.tex de biblatex y la CSL nunca formó una
--         referencia (SC-57). Cambian m_XML (bloques 2c y 15),
--         ensamblar-libro-canonico.xsl, docbook-to-latex.xsl y comun.sh.
-- Fecha:  2026-10-29
-- Aplicar: después de act-76
--
-- MODIFICA:
--   SC-57  el nombre del role, en sus tres apariciones
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

INSERT INTO verificacion SELECT 'SC-57 texto 1: una vez', (length(cuerpo) - length(replace(cuerpo, 'que no traía `csl-style`:', ''))) = length('que no traía `csl-style`:') FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'SC-57 texto 2: una vez', (length(cuerpo) - length(replace(cuerpo, 'escribe `<bibliomisc role="csl-style">`', ''))) = length('escribe `<bibliomisc role="csl-style">`') FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'SC-57 texto 3: una vez', (length(cuerpo) - length(replace(cuerpo, 'cotejan el `csl-style` de cada canónico', ''))) = length('cotejan el `csl-style` de cada canónico') FROM entradas WHERE codigo = 'SC-57';
UPDATE entradas SET cuerpo = replace(cuerpo, 'que no traía `csl-style`:', 'que no traía el estilo:'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-57';
UPDATE entradas SET cuerpo = replace(cuerpo, 'escribe `<bibliomisc role="csl-style">`', 'escribe `<bibliomisc role="estilo-cita">` (hasta el 29/10 se llamó `csl-style`, un nombre heredado de cuando el estilo era un `.csl`; se renombró como la columna `libros_md.estilo_cita`)'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-57';
UPDATE entradas SET cuerpo = replace(cuerpo, 'cotejan el `csl-style` de cada canónico', 'cotejan el `estilo-cita` de cada canónico'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'SC-57 sin csl-style suelto', instr(replace(cuerpo, 'se llamó `csl-style`', ''), 'csl-style') = 0 FROM entradas WHERE codigo = 'SC-57';

COMMIT;

SELECT codigo, titulo FROM entradas WHERE codigo = 'SC-57';
