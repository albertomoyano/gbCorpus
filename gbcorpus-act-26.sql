-- ============================================================
-- gbCorpus — actualización 26: validación de una pieza suelta
-- Esquema: 1
-- Origen: prueba de Alberto con un libro real (bibliografía consolidada):
--         «Todos los canónicos» daba avisos por IDREF de citas cuya
--         bibliografía entra recién al ensamblar. Decisión de Alberto:
--         opción A, todos los IDREF sin ID se informan en tenue.
--         Cotejado con docs/corpus.md de gbpublisher (GitHub, confirmado al
--         día), con la carpeta local de gbCorpus (último script: act-25) y
--         con una copia de la base local.
-- Fecha:  2026-10-14
--
-- MODIFICA:
--   SC-53  sección nueva antes de LOS USOS: los IDREF sin ID de una pieza
--          suelta no son aviso; pendiente actualizado con lo ya probado
--   SC-32  remite a SC-53 en la frase sobre el canónico suelto
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-53 ancla una vez', (length(cuerpo) - length(replace(cuerpo, 'LOS USOS', ''))) / length('LOS USOS') = 1 FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 sin la sección', instr(cuerpo, 'VALIDACIÓN DE UNA PIEZA SUELTA') = 0 FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 pendiente de partida', pendiente = 'Probar en Mint, con un libro real, los tres ítems de menuDocBook: «Canónico archivo en curso», «Todos los canónicos» y un lote en el que un capítulo falla (su canónico anterior se borra y «Ensamblar» se niega hasta regenerarlo). Hecho eso, quitar este pendiente.' FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-32 frase una vez', (length(cuerpo) - length(replace(cuerpo, 'El canónico de una pieza que remite a otra no valida suelto (IDREF); el del libro, sí.', ''))) / length('El canónico de una pieza que remite a otra no valida suelto (IDREF); el del libro, sí.') = 1 FROM entradas WHERE codigo = 'SC-32';

-- ------------------------------------------------------------
-- 2. SC-53: VALIDACIÓN DE UNA PIEZA SUELTA
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'LOS USOS', 'VALIDACIÓN DE UNA PIEZA SUELTA

Un script que valida una parte del libro por separado —hoy, el canónico de cada capítulo— no cuenta como aviso los errores `IDREF "…" without matching ID` de jing. Son remisiones a algo que está fuera de la pieza: las citas a la bibliografía consolidada, cuyos `bib-*` entran recién al ensamblar, y las remisiones a figuras o secciones de otra pieza (SC-32). Contadas como aviso, daban código 3 en todo libro con bibliografía consolidada, y un aviso que sale siempre tapa a los que importan.

Se informan en tenue, con su cantidad, como remisiones que se verifican al ensamblar. Cualquier otro error de jing sigue siendo aviso. Si solo hubo remisiones, el informe no dice «válido»: dice que no hay errores de esquema propios de la pieza. Un IDREF colgado de verdad lo marca la validación del libro en `ensamblar_libro.sh`, que lo cuenta como aviso. Es la separación de capas de SC-52: válido como pieza no es válido como libro.

El patrón sale de la salida real de jing en Linux Mint: `69:1130: error: IDREF "bib-4308-TOCHO2020" without matching ID`.

LOS USOS'),
       pendiente = 'Probado en Mint con un libro real: «Canónico archivo en curso», «Todos los canónicos» y «Ensamblar». Falta un lote en el que un capítulo falla (su canónico anterior se borra y «Ensamblar» se niega hasta regenerarlo), y volver a correr «Todos los canónicos» en un libro con bibliografía consolidada para ver las remisiones en tenue y el código 0. Hecho eso, quitar este pendiente.',
       relaciones = relaciones || ',vinculo:SC-32,vinculo:SC-52',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 actualizada', instr(cuerpo, 'VALIDACIÓN DE UNA PIEZA SUELTA') > 0 AND instr(cuerpo, 'VALIDACIÓN DE UNA PIEZA SUELTA') < instr(cuerpo, 'LOS USOS') AND instr(pendiente, 'Probado en Mint') = 1 AND instr(relaciones, 'vinculo:SC-52') > 0 FROM entradas WHERE codigo = 'SC-53';

-- ------------------------------------------------------------
-- 3. SC-32: REMISIÓN A SC-53
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'El canónico de una pieza que remite a otra no valida suelto (IDREF); el del libro, sí.', 'El canónico de una pieza que remite a otra no valida suelto (IDREF); el del libro, sí. Por eso `generar_canonicos_capitulos.sh` no cuenta esos errores como aviso (SC-53).'),
       relaciones = relaciones || ',vinculo:SC-53',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-32';
INSERT INTO verificacion SELECT 'SC-32 actualizada', instr(cuerpo, 'no cuenta esos errores como aviso (SC-53)') > 0 AND instr(relaciones, 'vinculo:SC-53') > 0 FROM entradas WHERE codigo = 'SC-32';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-32', 'SC-53') ORDER BY numero;
