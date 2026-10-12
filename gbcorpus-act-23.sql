-- ============================================================
-- gbCorpus — actualización 23: la llamada de nota va después del signo
-- Esquema: 1
-- Origen: Alberto: detrás de una llamada de nota solo puede haber un
--         espacio o un fin de línea; los signos de cierre van antes.
--         Patrón nota-despues-del-signo, probado con el motor.
-- Fecha:  2026-10-11
--
-- MODIFICA:
--   SC-40  sección nueva: llamada de nota después del signo de cierre
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: act-22 APLICADA Y SIN LA SECCIÓN NUEVA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-40 con la sección de rangos', instr(cuerpo, 'RANGOS NUMÉRICOS: GUION SIMPLE') > 0 FROM entradas WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-40 título de elisión una vez', (length(cuerpo) - length(replace(cuerpo, 'ELISIÓN: (...), NUNCA [...]', ''))) = length('ELISIÓN: (...), NUNCA [...]') FROM entradas WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-40 sin la sección nueva', instr(cuerpo, 'LLAMADA DE NOTA') = 0 FROM entradas WHERE codigo = 'SC-40';

-- ------------------------------------------------------------
-- 2. SC-40
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'ELISIÓN: (...), NUNCA [...]', 'LLAMADA DE NOTA: DESPUÉS DEL SIGNO DE CIERRE

Norma de la editorial (decisión de Alberto), que se aparta de la RAE: la llamada de nota va después de cualquier signo de cierre, `texto.[^a]`, `«cita».[^b]`. Detrás de una llamada solo puede haber un espacio o un fin de línea.

Lo corrige el patrón `nota-despues-del-signo` de la búsqueda con expresiones regulares (SC-51), con el flag `m`:

    (?<!^)((?:\[\^[^\]\s]+\])+)((?:[.,;:!?»)\]’”*_]|-{2,3})+)   ->  $2$1

- Mueve juntos todos los signos de cierre que siguen (`[^a]».` → `».[^a]`) y todas las llamadas seguidas (`[^a][^b].` → `.[^a][^b]`). Una segunda pasada no encuentra nada.
- Signos de cierre: `. , ; : ! ? » ) ] ’ ”`, los cierres de énfasis `*` y `_`, y la raya de cierre `--` o `---`.
- No toca la definición (`[^a]:` al comienzo de línea) ni una llamada pegada a una letra o a un signo de apertura (`[^a]palabra`, `[^a](véase)`): ahí falta un espacio, y mover el carácter rompería la palabra.
- No cubre las notas en línea de Pandoc, `^[texto]`.

ELISIÓN: (...), NUNCA [...]'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-40';

INSERT INTO verificacion SELECT 'SC-40 actualizada', instr(cuerpo, 'LLAMADA DE NOTA: DESPUÉS DEL SIGNO DE CIERRE') > 0 FROM entradas WHERE codigo = 'SC-40';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo = 'SC-40';
