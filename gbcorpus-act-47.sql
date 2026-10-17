-- ============================================================
-- gbCorpus — actualización 47: RF-14, la puntuación norteamericana de
--            biblatex-ieee
-- Esquema: 1
-- Origen: hallazgo de Alberto (17/10) en las tres salidas de Duek con IEEE:
--         la coma de cierre de los títulos sale antes de la comilla. Fuente:
--         ieee.bbx v1.3f, línea 34; biblatex.def (3.19), \uspunctuation y
--         \stdpunctuation. Medido en el contenedor. Numerado contra la base
--         de Alberto (~/.gbcorpus/corpus.sqlite, 17/10, con act-46 aplicado).
-- Fecha:  2026-10-17
-- Aplicar: después de act-46
--
-- MODIFICA:
--   RF-14  datos del fuente: \uspunctuation y su corrección
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'act-46 aplicado (RF-14)', COUNT(*) = 1 FROM entradas WHERE codigo = 'RF-14';
INSERT INTO verificacion SELECT 'RF-14 ancla', instr(cuerpo, '- Cadenas propias: `ieee.bbx` declara `presentedat` y `patentjp` y las define solo en inglés. En castellano salen en negrita (GV-106); `cita-ieee-config.tex` las define (SC-59).') > 0 FROM entradas WHERE codigo = 'RF-14';
INSERT INTO verificacion SELECT 'RF-14 sin la puntuación', instr(cuerpo, 'uspunctuation') = 0 FROM entradas WHERE codigo = 'RF-14';

-- ------------------------------------------------------------
-- 2. RF-14: LA PUNTUACIÓN
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo,
         '- Cadenas propias: `ieee.bbx` declara `presentedat` y `patentjp` y las define solo en inglés. En castellano salen en negrita (GV-106); `cita-ieee-config.tex` las define (SC-59).',
         '- Cadenas propias: `ieee.bbx` declara `presentedat` y `patentjp` y las define solo en inglés. En castellano salen en negrita (GV-106); `cita-ieee-config.tex` las define (SC-59).
- Puntuación: `ieee.bbx` llama a `\uspunctuation` sin distinguir idioma (línea 34), la convención norteamericana que mete la coma y el punto dentro de las comillas: «título,». En castellano van después: «título»,. `cita-ieee-config.tex` agrega `\DefineBibliographyExtras{spanish}{\stdpunctuation}`: `\stdpunctuation` (`biblatex.def`) deshace lo de `\uspunctuation`, y como extra del español solo actúa en un libro en español; uno en inglés conserva la convención de IEEE. Ningún otro estilo de la aplicación llama a `\uspunctuation` (philosophy, apa, iso690: medido con grep). MEDIDO con el `.bib` de Duek: 87 comas y 5 puntos pasan detrás de la comilla, sin ningún otro cambio en el texto; la pasada de tex4ht hereda la corrección (69 «»,» en `citas.html`, ninguna «,»»); vnu y epubcheck sin errores. Hallazgo de Alberto en las tres salidas de Duek.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'RF-14';
INSERT INTO verificacion SELECT 'RF-14 con la puntuación', instr(cuerpo, '\DefineBibliographyExtras{spanish}{\stdpunctuation}') > 0 FROM entradas WHERE codigo = 'RF-14';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo = 'RF-14';
