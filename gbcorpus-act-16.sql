-- ============================================================================
-- Script : corpus-sc40-elision.sql
-- Qué hace:
--   MODIFICA SC-40 — agrega el apartado «ELISIÓN: (...), NUNCA [...]» (filtro
--                    1.3), el aviso aviso_corchetes_con_puntos y la clave
--                    elision_corchetes_a_parentesis; cambia el título a
--                    «Rayas, puntos suspensivos y elisión en el .md» y el entorno a la versión 1.3 del filtro
--   No da de alta ninguna entrada.
-- Esquema: 1
-- ============================================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- --- 1. LA ENTRADA ESTÁ COMO SE LA CITA ---
INSERT INTO verificacion SELECT 'SC-40 título', titulo = 'Rayas y puntos suspensivos en el .md: la convención de LaTeX' FROM entradas WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-40 entorno', entorno = 'gbpublisher / Pandoc 3.1.3 / engine/limpiar_docx.lua 1.2 / contenedor' FROM entradas WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-40 sin el apartado', instr(cuerpo, 'ELISIÓN: (...)') = 0 FROM entradas WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-40 ancla de avisos', (length(cuerpo) - length(replace(cuerpo, 'LO QUE NO SE CONVIERTE: AVISOS', ''))) = length('LO QUE NO SE CONVIERTE: AVISOS') FROM entradas WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-40 aviso de enumeración', (length(cuerpo) - length(replace(cuerpo, '- `aviso_enumeracion_punto_guion`: «4.-», «a.-». Es una corrección mal hecha: en la editorial se elimina.', ''))) = length('- `aviso_enumeracion_punto_guion`: «4.-», «a.-». Es una corrección mal hecha: en la editorial se elimina.') FROM entradas WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-40 párrafo de claves', (length(cuerpo) - length(replace(cuerpo, 'Las cuatro conversiones también tienen su clave en el informe: `elipsis_a_tres_puntos`, `semirraya_a_dos_guiones`, `raya_a_tres_guiones` y `guion_aislado_a_semirraya`.', ''))) = length('Las cuatro conversiones también tienen su clave en el informe: `elipsis_a_tres_puntos`, `semirraya_a_dos_guiones`, `raya_a_tres_guiones` y `guion_aislado_a_semirraya`.') FROM entradas WHERE codigo = 'SC-40';

-- --- 2. MODIFICACIÓN ---
UPDATE entradas
   SET titulo = 'Rayas, puntos suspensivos y elisión en el .md',
       entorno = 'gbpublisher / Pandoc 3.1.3 / engine/limpiar_docx.lua 1.3 / contenedor',
       cuerpo = replace(replace(replace(cuerpo,
                  'LO QUE NO SE CONVIERTE: AVISOS', 'ELISIÓN: (...), NUNCA [...]

Norma de la editorial (decisión de Alberto): la supresión dentro de una cita se marca con puntos suspensivos entre paréntesis, `(...)`. Los corchetes quedan para las expresiones del editor, como `[sic]` o `[risas]`, que el filtro no toca.

Desde la versión 1.3, el filtro convierte la elisión entre corchetes en todas sus formas: «[...]», «[…]» (después de pasar U+2026 a `...`), pegada a la palabra o a la puntuación («palabra[…].») y con espacios adentro («[ … ]»), que el lector parte en varios `Str` y se une en uno. Vale también dentro de una cursiva o de una nota; el código en línea no se toca.

LO QUE NO SE CONVIERTE: AVISOS'),
                  '- `aviso_enumeracion_punto_guion`: «4.-», «a.-». Es una corrección mal hecha: en la editorial se elimina.', '- `aviso_enumeracion_punto_guion`: «4.-», «a.-». Es una corrección mal hecha: en la editorial se elimina.
- `aviso_corchetes_con_puntos`: corchetes con dos puntos o con cuatro o más, «[..]», «[....]». Puede ser un error de tipeo o una marca propia del autor.'),
                  'Las cuatro conversiones también tienen su clave en el informe: `elipsis_a_tres_puntos`, `semirraya_a_dos_guiones`, `raya_a_tres_guiones` y `guion_aislado_a_semirraya`.', 'Las conversiones también tienen su clave en el informe: `elipsis_a_tres_puntos`, `semirraya_a_dos_guiones`, `raya_a_tres_guiones`, `guion_aislado_a_semirraya` y `elision_corchetes_a_parentesis`.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-40';

INSERT INTO verificacion SELECT 'SC-40 actualizada',
  instr(cuerpo, 'ELISIÓN: (...)') > 0 AND instr(cuerpo, 'aviso_corchetes_con_puntos') > 0
  AND instr(cuerpo, 'elision_corchetes_a_parentesis') > 0 AND titulo = 'Rayas, puntos suspensivos y elisión en el .md'
  FROM entradas WHERE codigo = 'SC-40';

COMMIT;

SELECT codigo, titulo, entorno FROM entradas WHERE codigo = 'SC-40';
