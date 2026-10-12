-- ============================================================
-- gbCorpus — actualización 22: rangos numéricos con guion simple
-- Esquema: 1
-- Origen: Alberto, al revisar el patrón rango-paginas: la norma de la
--         editorial es un solo guion en los rangos de páginas y de años
--         («pp. 23-55», «1990-2000»), no la semirraya `--`. El patrón de
--         SC-51 hacía lo contrario.
-- Fecha:  2026-10-10
--
-- MODIFICA:
--   SC-40  sección nueva: rangos numéricos con guion simple
--   SC-51  los patrones de ejemplo: rango-paginas invertido, rango-anios
--          nuevo, pagina-sin-espacio ve también --- y la raya
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: LOS PASAJES EXISTEN UNA SOLA VEZ
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-51 bloque de patrones', (length(cuerpo) - length(replace(cuerpo, '    pagina-sin-espacio   (?<![\p{L}\p{N}])p\.(\d+)(?!\d|\s*(?:--|-|–)\s*\d)     ->  p. $1
    rango-paginas        (?<![\p{L}\p{N}])(?!pp\. \d+--\d)pp?\.\s*(\d+)\s*(?:--|-|–)\s*(\d+)   ->  pp. $1--$2

El lookbehind exige que delante de la `p` no haya letra ni dígito, en cualquier alfabeto: quedan fuera `Exp.2` y `ap.3`, y entra `(p.135)`. El primero deja los rangos para el segundo, así que el orden no importa. El segundo no toca un `pp. 20--24` ya correcto, y lleva el rango a `--` (SC-40): delante de `pp.` el contexto confirma el rango que `limpiar_docx.lua` solo puede avisar (`aviso_guion_entre_digitos`). Probados con `engine/buscar_regex.pl`, modo `probar`.', ''))) = length('    pagina-sin-espacio   (?<![\p{L}\p{N}])p\.(\d+)(?!\d|\s*(?:--|-|–)\s*\d)     ->  p. $1
    rango-paginas        (?<![\p{L}\p{N}])(?!pp\. \d+--\d)pp?\.\s*(\d+)\s*(?:--|-|–)\s*(\d+)   ->  pp. $1--$2

El lookbehind exige que delante de la `p` no haya letra ni dígito, en cualquier alfabeto: quedan fuera `Exp.2` y `ap.3`, y entra `(p.135)`. El primero deja los rangos para el segundo, así que el orden no importa. El segundo no toca un `pp. 20--24` ya correcto, y lleva el rango a `--` (SC-40): delante de `pp.` el contexto confirma el rango que `limpiar_docx.lua` solo puede avisar (`aviso_guion_entre_digitos`). Probados con `engine/buscar_regex.pl`, modo `probar`.') FROM entradas WHERE codigo = 'SC-51';
INSERT INTO verificacion SELECT 'SC-40 título de elisión', (length(cuerpo) - length(replace(cuerpo, 'ELISIÓN: (...), NUNCA [...]', ''))) = length('ELISIÓN: (...), NUNCA [...]') FROM entradas WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-40 sin la sección', instr(cuerpo, 'RANGOS NUMÉRICOS') = 0 FROM entradas WHERE codigo = 'SC-40';

-- ------------------------------------------------------------
-- 2. SC-40
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'ELISIÓN: (...), NUNCA [...]', 'RANGOS NUMÉRICOS: GUION SIMPLE, NUNCA SEMIRRAYA

Norma de la editorial (decisión de Alberto): los rangos de páginas y de años se escriben con un solo guion, `pp. 23-55`, `1990-2000`. No es la semirraya de arriba: un guion simple no lo convierte el `smart` de Pandoc, y todas las salidas imprimen un guion.

El filtro no lo resuelve: pasa U+2013 a `--` en cualquier lugar, también entre cifras, y un guion entre cifras lo cuenta como aviso (`aviso_guion_entre_digitos`), porque sin contexto no distingue un rango de una fecha, un ISBN o un teléfono. Los rangos se llevan al guion simple con los patrones `rango-paginas` y `rango-anios` de la búsqueda con expresiones regulares (SC-51), revisando la grilla antes de reemplazar.

ELISIÓN: (...), NUNCA [...]'),
       relaciones = relaciones || ',vinculo:SC-51',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-40';

-- ------------------------------------------------------------
-- 3. SC-51
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, '    pagina-sin-espacio   (?<![\p{L}\p{N}])p\.(\d+)(?!\d|\s*(?:--|-|–)\s*\d)     ->  p. $1
    rango-paginas        (?<![\p{L}\p{N}])(?!pp\. \d+--\d)pp?\.\s*(\d+)\s*(?:--|-|–)\s*(\d+)   ->  pp. $1--$2

El lookbehind exige que delante de la `p` no haya letra ni dígito, en cualquier alfabeto: quedan fuera `Exp.2` y `ap.3`, y entra `(p.135)`. El primero deja los rangos para el segundo, así que el orden no importa. El segundo no toca un `pp. 20--24` ya correcto, y lleva el rango a `--` (SC-40): delante de `pp.` el contexto confirma el rango que `limpiar_docx.lua` solo puede avisar (`aviso_guion_entre_digitos`). Probados con `engine/buscar_regex.pl`, modo `probar`.', '    pagina-sin-espacio   (?<![\p{L}\p{N}])p\.(\d+)(?!\d|\s*(?:---|--|-|–|—)\s*\d)     ->  p. $1
    rango-paginas        (?<![\p{L}\p{N}])(?!pp\. \d+-\d)pp?\.\s*(\d+)\s*(?:---|--|-|–|—)\s*(\d+)   ->  pp. $1-$2
    rango-anios          (?<![\p{L}\p{N}])(\d{4})(?:\s*(?:---|--|–|—)\s*|\s+-\s*|-\s+)(\d{4})(?![\p{L}\p{N}])   ->  $1-$2

El lookbehind exige que delante de la `p` no haya letra ni dígito, en cualquier alfabeto: quedan fuera `Exp.2` y `ap.3`, y entra `(p.135)`. El primero deja los rangos para el segundo, así que el orden no importa. Los dos de rango llevan el rango a un GUION SIMPLE, la norma de la editorial (SC-40), desde cualquier forma en que llegue de Word: dos o tres guiones, semirraya o raya Unicode, con o sin espacios. Ninguno toca la forma ya correcta (`pp. 20-24`, `1990-2000`). El de años exige cuatro cifras de cada lado y nada pegado: deja afuera `12345--67890`, `199--200` y un ISBN, pero un número de cuatro cifras separado por un guion entre espacios (un teléfono, por ejemplo) coincide igual; la grilla está para revisarlo antes de reemplazar. Delante de `pp.` o entre dos años, el contexto confirma el rango que `limpiar_docx.lua` solo puede avisar (`aviso_guion_entre_digitos`). Probados con `engine/buscar_regex.pl`, modo `probar`, y cargados con `m_PatronesRegex`.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-51';

INSERT INTO verificacion SELECT 'SC-40 actualizada', instr(cuerpo, 'RANGOS NUMÉRICOS: GUION SIMPLE') > 0 AND instr(relaciones, 'vinculo:SC-51') > 0 FROM entradas WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-51 actualizada', instr(cuerpo, 'rango-anios') > 0 AND instr(cuerpo, '->  pp. $1--$2') = 0 FROM entradas WHERE codigo = 'SC-51';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-40', 'SC-51') ORDER BY prefijo, numero;
