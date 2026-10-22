-- ============================================================
-- gbCorpus — actualización 59: las cifras probadas en Mint (SC-65)
-- Esquema: 1
-- Origen: prueba de Alberto en Mint del 22/10 sobre el lote de cifras.
-- Fecha:  2026-10-22
-- Aplicar: después de act-58
--
-- MODIFICA:
--   SC-65   lo probado en Mint; el motivo oculto por la pila de Lua
--           (mostrar_cola); pendiente reducido
--   SC-64   pendiente: el lote 1, probado
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-65 con su pendiente de act-58', pendiente = 'Probar en Mint con un libro y una revista reales: PDF (párrafo, título y su marcador, nota, celda), HTML, EPUB, ODT, un capítulo en inglés con \SIrange, la inserción desde el panel, el resaltado, los avisos y un caso que frene. El cambio de idioma por capítulo en el PDF del libro, que no existe (ver LO QUE NO CUBRE), cuando se encare.' FROM entradas WHERE codigo = 'SC-65';
INSERT INTO verificacion SELECT 'SC-64 con su pendiente de act-58', pendiente = 'Lote 1 (cifras) implementado en SC-65: falta probarlo en Mint. Lote 2 (cadena del cuadro) y lote 3 (FTabla y vista previa), cada uno con su SC y probado en Mint.' FROM entradas WHERE codigo = 'SC-64';
INSERT INTO verificacion SELECT 'SC-65 sin la prueba en Mint', instr(cuerpo, 'PROBADO EN MINT') = 0 FROM entradas WHERE codigo = 'SC-65';

-- ------------------------------------------------------------
-- 2. SC-65
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = cuerpo || '

PROBADO EN MINT (Alberto, 22/10)

Un libro real (preliminares de «El Atlántico de los exilios»): cifras en un título, un párrafo, una nota y una celda, en el PDF, el HTML y el EPUB; el marcador del PDF; la inserción desde el panel; el resaltado; el aviso de un «88%» suelto, con el capítulo generado igual; y un caso que frena, `\SI{88}{\per}`. Las filas `num`, `si` y `si-rango` se liberan con `datos-v5-017`.

EL MOTIVO QUE NO SE VEÍA

En esa prueba la terminal mostró el final del mensaje de `cifras.lua` y no su primera línea, la que dice qué falla: Pandoc agrega al mensaje de un filtro que frena una o dos «stack traceback:» (medido con pandoc 3.1.3: veinte líneas, el motivo en la tercera), y `mostrar_cola` de `engine/comun.sh` mostraba las últimas quince. Ahora `mostrar_cola` corta la salida desde la primera «stack traceback:»: vale para todos los filtros y todos los scripts de `engine/`.',
       pendiente = 'El cambio de idioma por capítulo en el PDF del libro, que no existe (ver LO QUE NO CUBRE), cuando se encare; con él, probar un capítulo en inglés con \SIrange. El ODT y la revista en Mint, con la fase de salidas que les corresponde.',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-65';
INSERT INTO verificacion SELECT 'SC-65 actualizada', instr(cuerpo, 'PROBADO EN MINT (Alberto, 22/10)') > 0 AND instr(cuerpo, 'EL MOTIVO QUE NO SE VEÍA') > 0 AND pendiente = 'El cambio de idioma por capítulo en el PDF del libro, que no existe (ver LO QUE NO CUBRE), cuando se encare; con él, probar un capítulo en inglés con \SIrange. El ODT y la revista en Mint, con la fase de salidas que les corresponde.' FROM entradas WHERE codigo = 'SC-65';

-- ------------------------------------------------------------
-- 3. SC-64
-- ------------------------------------------------------------
UPDATE entradas
   SET pendiente = 'Lote 1 (cifras) implementado y probado en Mint (SC-65). Lote 2 (cadena del cuadro) y lote 3 (FTabla y vista previa), cada uno con su SC y probado en Mint.',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-64';
INSERT INTO verificacion SELECT 'SC-64 actualizada', pendiente = 'Lote 1 (cifras) implementado y probado en Mint (SC-65). Lote 2 (cadena del cuadro) y lote 3 (FTabla y vista previa), cada uno con su SC y probado en Mint.' FROM entradas WHERE codigo = 'SC-64';

COMMIT;

SELECT codigo, estado, pendiente FROM entradas
 WHERE codigo IN ('SC-64', 'SC-65') ORDER BY numero;
