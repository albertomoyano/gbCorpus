-- ============================================================
-- gbCorpus — actualización 63: los cuadros, entrega 2 (SC-66)
-- Esquema: 1
-- Origen: conversación del 22/10. Decisiones de Alberto: el filete
--         doble con bloques: («una división lógica dentro del cuadro»);
--         la entrega 1 probada en Mint. La clave ancho: total de la
--         revista, la propuesta (no hubo objeción).
-- Fecha:  2026-10-22
-- Aplicar: después de act-62
--
-- MODIFICA:
--   SC-66   la entrega 2; la entrega 1, probada; el pendiente
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

INSERT INTO verificacion SELECT 'SC-66 con el pendiente de act-62', pendiente = 'Entrega 2: celdas unidas (grid table → \multicolumn, \cmidrule), encabezado de dos niveles, agrupar (\cmidrule{2-n} entre las filas de un grupo), cortes (un flotante por tramo, encabezado repetido, «Continúa en la página siguiente» / «Viene de la página anterior», el pie en el último), rotar (sidewaystable) y el ancho total de la revista. Los controles de avisos (SC-54) sobre el archivo del cuadro. Las filas viejas table-wrap, table-fullwidth y table-landscape de gbShortcodes, con el lote 3.' FROM entradas WHERE codigo = 'SC-66';
INSERT INTO verificacion SELECT 'SC-66 ancla de la entrega 1 (una vez)', (length(cuerpo) - length(replace(cuerpo, 'Frenan con un mensaje hasta la entrega 2: las celdas unidas, el encabezado de dos niveles, `agrupar`, `cortes`, `rotar` y el ancho total de la revista.', ''))) = length('Frenan con un mensaje hasta la entrega 2: las celdas unidas, el encabezado de dos niveles, `agrupar`, `cortes`, `rotar` y el ancho total de la revista.') FROM entradas WHERE codigo = 'SC-66';
INSERT INTO verificacion SELECT 'SC-66 sin la entrega 2', instr(cuerpo, 'ENTREGA 2 (IMPLEMENTADA)') = 0 FROM entradas WHERE codigo = 'SC-66';

UPDATE entradas
   SET cuerpo = replace(cuerpo, 'Frenan con un mensaje hasta la entrega 2: las celdas unidas, el encabezado de dos niveles, `agrupar`, `cortes`, `rotar` y el ancho total de la revista.', 'Probada en Mint por Alberto (22/10): el PDF, «perfecto».') || '

ENTREGA 2 (IMPLEMENTADA)

Dos claves más en el encabezado: `bloques: [11, 22]`, las filas del cuerpo tras las que va el filete doble (decisión de Alberto: «una división lógica dentro del cuadro», un caso raro); y, solo en revistas, `ancho: columna | total` (en el libro, `total` frena: hay un solo ancho).

- CELDAS UNIDAS. Con grid table. `cuadro-leer.lua` ubica cada celda en su columna (atributo `gb-col`, porque con celdas unidas la posición en la fila no la dice); `cuadro-armar.lua` escribe `namest`/`nameend`/`morerows` en CALS (y `colname` en la celda simple, para que las salidas digitales sepan su columna) y `colspan`/`rowspan` en JATS. En el PDF: la celda que une columnas es `\multicolumn{n}{c|}{…}` (sin filete si llega a la última); la que une filas lleva el texto en la primera fila en el cuerpo y en la última en el encabezado, y las filas que ocupa quedan vacías, como en los cuadros de la casa. El filete entre dos filas es `\midrule` si ninguna celda sigue unida; si no, un `\cmidrule` por cada tramo de columnas libres (el `\cmidrule{2-n}` de la casa). En el HTML y el EPUB, `colspan` y `rowspan`; la celda que une columnas, centrada.
- ENCABEZADO DE VARIAS FILAS. Con grid table (`===` debajo del encabezado). Se repite en cada tramo.
- `agrupar: sí`. La celda vacía de la primera columna continúa el grupo: la primera celda del grupo pasa a unir esas filas. La primera columna no puede traer ya celdas unidas.
- `cortes`. Un flotante por tramo, todos `[!ht]` (o `sidewaystable`): el encabezado repetido; al final de cada tramo menos el último, «Continúa en la página siguiente» a la derecha; al principio de cada tramo menos el primero, «Viene de la página anterior» a la izquierda, los dos en bastardilla; el pie y la etiqueta solo en el último, así el número es uno. Los textos son macros del contrato 17 y del preámbulo de la revista: `\gbCuadroContinua`, `\gbCuadroViene`. El HTML y el EPUB muestran la tabla completa.
- `bloques`. `\midrule` doble entre esas filas. El HTML conserva su estilo y no lo marca.
- `rotar: sí`. `sidewaystable`, uno por tramo (contrato 17: el paquete `rotating`). En el canónico, `orient="land"` / `orientation="landscape"`.
- `ancho: total` (revistas). El entorno `gbcuadrototal` del preámbulo de la revista, el mismo `adjustwidth` que la figura de ancho completo. Con `rotar` frena: el cuadro apaisado ya ocupa la página.
- La composición del cuadro es una plantilla con nombre en `tex-comun.xsl`, `gb-cuadro-latex`, común a libros y revistas; la plantilla de cada hoja solo junta las filas, el pie y la rotación (GV-117). Funciones: `f:cuadro-span`, `f:cuadro-grilla`, `f:cuadro-abajo`, `f:cuadro-filete`, `f:cuadro-cantidad`.

FRENAN, ADEMÁS: un corte o un bloque que no es un número de fila, que deja la última sin filas después, repetido o fuera de orden, o que parte una celda unida o un grupo; la misma fila en cortes y en bloques; una fila con más celdas que columnas o con un hueco.

MEDIDO: el cuadro de los tesistas (cuadro4-3 de la casa) con `agrupar` y un corte entre grupos; uno de dos niveles de encabezado con subtotales unidos, `bloques` y `rotar` (como el cuadroX2); el mismo con `ancho: total` en una revista. Libro: canónico válido (RNG), PDF compilado: los dos tramos con sus textos, el pie solo en el último, `\cmidrule{2-4}` entre las filas de un grupo, `\cmidrule{2-5}` bajo la fila de grupos del encabezado, «Período» en la fila de abajo, el filete doble. Revista: JATS válido (DTD), PDF compilado con `gbcuadrototal`, HTML, EPUB, SciELO y Redalyc. ODT con celdas unidas. Los casos que frenan, uno por uno.',
       pendiente = 'Probar en Mint la entrega 2. Los controles de avisos (SC-54) sobre el archivo del cuadro. Las filas viejas table-wrap, table-fullwidth y table-landscape de gbShortcodes, con el lote 3.',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-66';
INSERT INTO verificacion SELECT 'SC-66 actualizada', instr(cuerpo, 'ENTREGA 2 (IMPLEMENTADA)') > 0 AND instr(cuerpo, 'Probada en Mint por Alberto (22/10): el PDF, «perfecto».') > 0 AND pendiente = 'Probar en Mint la entrega 2. Los controles de avisos (SC-54) sobre el archivo del cuadro. Las filas viejas table-wrap, table-fullwidth y table-landscape de gbShortcodes, con el lote 3.' FROM entradas WHERE codigo = 'SC-66';

COMMIT;

SELECT codigo, estado, pendiente FROM entradas WHERE codigo = 'SC-66';
