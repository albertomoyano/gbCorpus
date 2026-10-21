-- ============================================================
-- gbCorpus — actualización 53: resaltado de negrita y bastardilla
--            juntas (GV-120); GV-119 confirmada en Mint
-- Esquema: 1
-- Origen: Alberto, 21/10, en Mint: el resaltado de \sptext funciona y el
--         panel inserta \sptext{•} con el marcador para escribir encima.
--         Encontró que ***texto*** rompía el coloreado: todo lo que seguía
--         salía en el color de la bastardilla. Medido en el contenedor con
--         el banco de GV-119 (gb.highlight 3.19).
-- Fecha:  2026-10-21
-- Aplicar: después de act-52
--
-- ALTAS:
--   GV-120  gb.highlight: el primer estado que coincide gana; un
--           lookbehind no ve lo anterior a la posición; \p{L} sí anda
-- MODIFICA:
--   GV-119  confirmada en Mint, sin pendiente
--   SC-62   pendiente: el panel ya está probado
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-119 última GV', MAX(numero) = 119 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'GV-120 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-120' OR (prefijo = 'GV' AND numero = 120);
INSERT INTO verificacion SELECT 'GV-119 con pendiente', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-119' AND pendiente IS NOT NULL;
INSERT INTO verificacion SELECT 'SC-62 pendiente de act-52', instr(pendiente, 'Falta en Mint: la inserción desde el panel, un caso que frene y el resaltado (GV-119).') = 1 FROM entradas WHERE codigo = 'SC-62';

-- ------------------------------------------------------------
-- 2. GV-120
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 120, 'GV-120', 'gb.highlight: el primer estado que coincide gana; un lookbehind no ve lo anterior a la posición',
   'En cada posición del texto, gb.highlight prueba los estados en el orden del archivo y se queda con el primero que coincide. Un `from … to` sin cerrar deja el estado abierto: en Mint con 3.22 el color sigue en las líneas siguientes (lo vio Alberto); en el banco con 3.19, hasta el fin de la línea.

EL CASO: ***texto***

    bold.double  from ** to **    abre en los dos primeros asteriscos y cierra en
                                  los dos primeros del final; el tercero abre una
                                  bastardilla que no cierra
    MEDIDO (antes):  [Keyword:***negrita y bastardilla**][Comment:* después normal.]

Remedio: `bold.italic.star` (`from *** to ***`) y `bold.italic.underscore` (`from ___ to ___`) ANTES de la negrita. Medido después: `[Keyword:***negrita y bastardilla***]`.

LOOKBEHIND Y LOOKAHEAD

Un patrón `/…/` se prueba sobre el texto desde la posición actual: un lookahead (`(?=\S)`) funciona, un lookbehind (`(?<=\S)`, `(?<![…])`) no ve lo anterior. Medido: con `to /(?<=\S)\*/` la bastardilla no cerraba. Las clases `\p{L}` y `\p{N}` sí reconocen letras con tilde y la ñ (`año_ñandú`).

LOS OTROS DOS CASOS DEL MISMO TIPO (corregidos en el mismo lote)

- Un `*` suelto abría bastardilla: `* ítem` (la lista, que va después en el archivo) y `5 * 3`. Ahora `italic.star` abre con `/\*(?=\S)/`. Medido: `* ítem` sale como lista (`Operator`) y `5 * 3` normal.
- Un guion bajo dentro de una palabra abría bastardilla (`palabra_con_guiones`, `snake_case`). Pandoc no la lee como énfasis (extensión `intraword_underscores`). Como el lookbehind no sirve, un estado anterior, `palabra.guion.bajo{Normal}`, consume la palabra entera: `match /[\p{L}\p{N}]+(_[\p{L}\p{N}]+)+/`. Medido: sin color; `_otra_` y `(_entre_)` siguen en bastardilla.

Las combinaciones anidadas (`**_x_**`, `*__y__*`, `_**z**_`) ya funcionaban: el tramo de afuera toma el color y el de adentro no se distingue.',
   'vigente', 'empirica',
   'gb.highlight 3.19 / gb.pcre / contenedor Ubuntu 24.04 (banco de GV-119); el síntoma, en gbpublisher con Gambas 3.22 / Linux Mint (Alberto, 21/10)',
   '2026-10', 'vinculo:GV-119,vinculo:GV-76,vinculo:SC-15',
   'Confirmar en Mint con 3.22: ***texto*** y ___texto___, * ítem, 5 * 3 y snake_case.',
   1200, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-120 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-120';

-- ------------------------------------------------------------
-- 3. GV-119: CONFIRMADA EN MINT
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = cuerpo || '

Confirmado en Mint con 3.22 (Alberto, 21/10): \sptext se colorea suelto y dentro de las marcas.',
       entorno = entorno || '; gbpublisher en Linux Mint con Gambas 3.22 (Alberto, 21/10)',
       pendiente = NULL,
       relaciones = relaciones || ',vinculo:GV-120',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'GV-119';
INSERT INTO verificacion SELECT 'GV-119 sin pendiente', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-119' AND pendiente IS NULL AND instr(cuerpo, 'Confirmado en Mint') > 0;

-- ------------------------------------------------------------
-- 4. SC-62: EL PANEL, PROBADO
-- ------------------------------------------------------------
UPDATE entradas
   SET pendiente = 'Falta en Mint: un caso que frene. El ODT, cuando se encare (decisión de Alberto, 21/10). Probados por Alberto (21/10): PDF, HTML y EPUB en libros y revistas, la inserción desde el panel y el resaltado.',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'SC-62 pendiente nuevo', instr(pendiente, 'Falta en Mint: un caso que frene.') = 1 FROM entradas WHERE codigo = 'SC-62';

COMMIT;

SELECT codigo, estado, pendiente FROM entradas WHERE codigo IN ('GV-119', 'GV-120', 'SC-62') ORDER BY numero;
