-- ============================================================
-- gbCorpus — actualización 68: correcciones a SC-69 al hacer la
--            plantilla del gráfico
-- Esquema: 1
-- Origen: conversación del 25/10, paso 1 de la implementación de SC-69.
--         Al escribir la plantilla aparecieron dos contradicciones de
--         SC-69: el locale contradice SC-64 (las cifras con punto y
--         U+202F) y role="img" oculta la tabla de respaldo. El rango del
--         subconjunto de GV-135 dejaba afuera U+202F y los volados.
-- Fecha:  2026-10-25
-- Aplicar: después de act-67
--
-- ALTAS:
--   GV-140  Base64$ con un archivo binario
-- MODIFICA:
--   SC-69   las cifras y la unidad (SC-64), la accesibilidad, la nota
--           de la corrección; relaciones: SC-65, GV-140
--   GV-135  el rango del subconjunto y los pesos
--   GV-139  --screenshot espera el dibujo asíncrono
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: CADA TEXTO A REEMPLAZAR, UNA SOLA VEZ
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-139 última GV', MAX(numero) = 139 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'GV-140 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-140' OR (prefijo = 'GV' AND numero = 140);
INSERT INTO verificacion SELECT 'SC-69 cifras: una vez', (length(cuerpo) - length(replace(cuerpo, '`locale` del idioma de la pieza (coma decimal y punto de miles en marcas y tooltips); títulos de ejes;', ''))) = length('`locale` del idioma de la pieza (coma decimal y punto de miles en marcas y tooltips); títulos de ejes;') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 unidad: una vez', (length(cuerpo) - length(replace(cuerpo, 'la unidad en las marcas y en el tooltip;', ''))) = length('la unidad en las marcas y en el tooltip;') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 accesibilidad: una vez', (length(cuerpo) - length(replace(cuerpo, '- ACCESIBILIDAD. El canvas lleva `role="img"`, un `aria-label` y, adentro, la tabla de datos como contenido de respaldo.', ''))) = length('- ACCESIBILIDAD. El canvas lleva `role="img"`, un `aria-label` y, adentro, la tabla de datos como contenido de respaldo.') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 nota: una vez', (length(cuerpo) - length(replace(cuerpo, 'SE RETIRAN FFiguras.form/.class', ''))) = length('SE RETIRAN FFiguras.form/.class') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'GV-135 rango: una vez', (length(cuerpo) - length(replace(cuerpo, '--unicodes="U+0020-007E,U+00A0-00FF,U+0152-0153,U+2010-2015,U+2018-201E,U+2022,U+2026,U+2030,U+2032-2033,U+2039-203A,U+20AC,U+2212"', ''))) = length('--unicodes="U+0020-007E,U+00A0-00FF,U+0152-0153,U+2010-2015,U+2018-201E,U+2022,U+2026,U+2030,U+2032-2033,U+2039-203A,U+20AC,U+2212"') FROM entradas WHERE codigo = 'GV-135';
INSERT INTO verificacion SELECT 'GV-135 pesos: una vez', (length(cuerpo) - length(replace(cuerpo, 'Regular, 11,6 KB; Bold, 12,4 KB. Las TTF enteras pesan unos 500 KB cada una.', ''))) = length('Regular, 11,6 KB; Bold, 12,4 KB. Las TTF enteras pesan unos 500 KB cada una.') FROM entradas WHERE codigo = 'GV-135';
INSERT INTO verificacion SELECT 'GV-139 cli: una vez', (length(cuerpo) - length(replace(cuerpo, 'Chart.js toma `window.devicePixelRatio`', ''))) = length('Chart.js toma `window.devicePixelRatio`') FROM entradas WHERE codigo = 'GV-139';

-- ------------------------------------------------------------
-- 2. LOS REEMPLAZOS
-- ------------------------------------------------------------
UPDATE entradas SET cuerpo = replace(cuerpo, '`locale` del idioma de la pieza (coma decimal y punto de miles en marcas y tooltips); títulos de ejes;', 'Las cifras de las marcas, del tooltip y de la tabla de datos con las reglas de SC-64, como el formateador de `cifras.lua` (SC-65): punto decimal, grupos de a tres con U+202F desde cinco dígitos, menos U+2212, «× 10ⁿ» con volado; títulos de ejes;'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 cifras: aplicado', instr(cuerpo, 'Las cifras de las marcas, del tooltip y de la tabla de datos con las reglas de SC-64, como el formateador de `cifras.lua` (SC-65): punto decimal, grupos de a tres con U+202F desde cinco dígitos, menos U+2212, «× 10ⁿ» con volado; títulos de ejes;') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, 'la unidad en las marcas y en el tooltip;', 'la unidad en las marcas, el tooltip y la tabla, separada de la cifra con U+202F salvo el grado de ángulo (SC-64);'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 unidad: aplicado', instr(cuerpo, 'la unidad en las marcas, el tooltip y la tabla, separada de la cifra con U+202F salvo el grado de ángulo (SC-64);') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, '- ACCESIBILIDAD. El canvas lleva `role="img"`, un `aria-label` y, adentro, la tabla de datos como contenido de respaldo.', '- ACCESIBILIDAD. El canvas va con `aria-hidden` y, al lado, la tabla de datos, fuera de la vista y legible por un lector de pantalla. No se usa `role="img"` en el canvas: en WAI-ARIA 1.2 el rol img vuelve presentacional lo que tiene adentro, y la tabla de respaldo se perdería.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 accesibilidad: aplicado', instr(cuerpo, '- ACCESIBILIDAD. El canvas va con `aria-hidden` y, al lado, la tabla de datos, fuera de la vista y legible por un lector de pantalla. No se usa `role="img"` en el canvas: en WAI-ARIA 1.2 el rol img vuelve presentacional lo que tiene adentro, y la tabla de respaldo se perdería.') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, 'SE RETIRAN FFiguras.form/.class', 'CORREGIDO EL 25/10 (act-68), al hacer la plantilla: la primera versión pedía `locale` con el idioma de la pieza, que da coma decimal y punto de miles y contradice SC-64; y pedía `role="img"` con la tabla adentro del canvas, que la oculta. Las dos cosas quedaron como se lee arriba.

SE RETIRAN FFiguras.form/.class'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 nota: aplicado', instr(cuerpo, 'CORREGIDO EL 25/10 (act-68), al hacer la plantilla: la primera versión pedía `locale` con el idioma de la pieza, que da coma decimal y punto de miles y contradice SC-64; y pedía `role="img"` con la tabla adentro del canvas, que la oculta. Las dos cosas quedaron como se lee arriba.

SE RETIRAN FFiguras.form/.class') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, '--unicodes="U+0020-007E,U+00A0-00FF,U+0152-0153,U+2010-2015,U+2018-201E,U+2022,U+2026,U+2030,U+2032-2033,U+2039-203A,U+20AC,U+2212"', '--unicodes="U+0020-007E,U+00A0-00FF,U+0152-0153,U+2010-2015,U+2018-201E,U+2022,U+2026,U+202F,U+2030,U+2032-2033,U+2039-203A,U+2070,U+2074-2079,U+207B,U+20AC,U+2212"'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'GV-135';
INSERT INTO verificacion SELECT 'GV-135 rango: aplicado', instr(cuerpo, '--unicodes="U+0020-007E,U+00A0-00FF,U+0152-0153,U+2010-2015,U+2018-201E,U+2022,U+2026,U+202F,U+2030,U+2032-2033,U+2039-203A,U+2070,U+2074-2079,U+207B,U+20AC,U+2212"') > 0 FROM entradas WHERE codigo = 'GV-135';
UPDATE entradas SET cuerpo = replace(cuerpo, 'Regular, 11,6 KB; Bold, 12,4 KB. Las TTF enteras pesan unos 500 KB cada una.', 'Regular, 12,0 KB; Bold, 12,8 KB. Las TTF enteras pesan unos 500 KB cada una. El espacio fino U+202F y los volados (⁰ ⁴–⁹ ⁻) los piden las cifras de SC-64: la primera versión del rango los dejaba afuera, y la TTF entera los tiene.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'GV-135';
INSERT INTO verificacion SELECT 'GV-135 pesos: aplicado', instr(cuerpo, 'Regular, 12,0 KB; Bold, 12,8 KB. Las TTF enteras pesan unos 500 KB cada una. El espacio fino U+202F y los volados (⁰ ⁴–⁹ ⁻) los piden las cifras de SC-64: la primera versión del rango los dejaba afuera, y la TTF entera los tiene.') > 0 FROM entradas WHERE codigo = 'GV-135';
UPDATE entradas SET cuerpo = replace(cuerpo, 'Chart.js toma `window.devicePixelRatio`', '`--screenshot` espera el dibujo que se hace después de `document.fonts.load` (GV-135): con la plantilla de SC-69, los siete tipos salieron dibujados y en Noto Serif, a 1× y a 3×, sin `--virtual-time-budget`. Con `--hide-scrollbars`, la tabla oculta de la plantilla no agrega barra.

Chart.js toma `window.devicePixelRatio`'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'GV-139';
INSERT INTO verificacion SELECT 'GV-139 cli: aplicado', instr(cuerpo, '`--screenshot` espera el dibujo que se hace después de `document.fonts.load` (GV-135): con la plantilla de SC-69, los siete tipos salieron dibujados y en Noto Serif, a 1× y a 3×, sin `--virtual-time-budget`. Con `--hide-scrollbars`, la tabla oculta de la plantilla no agrega barra.

Chart.js toma `window.devicePixelRatio`') > 0 FROM entradas WHERE codigo = 'GV-139';
UPDATE entradas SET relaciones = relaciones || ',vinculo:SC-65,apoya:GV-140', fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 relaciones', instr(relaciones, ',vinculo:SC-65,apoya:GV-140') > 0 FROM entradas WHERE codigo = 'SC-69';

-- ------------------------------------------------------------
-- 3. GV-140
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 140, 'GV-140', 'Base64$ con un archivo binario',
   'Medido con `File.Load` de un woff2 (12 796 bytes) y `Base64$`:

    Len(File.Load(…))         12 796: la cadena tiene los bytes del archivo
    Base64$(…)                17 064 caracteres, en una sola línea, sin saltos
    comparado con base64 -w0  idéntico (la misma suma md5)

`Base64$` es una función del intérprete: no pide componente.

EN EL PROYECTO: `m_Graficos` codifica las fuentes al armar el HTML del gráfico (SC-69); en `.hidden/chart/` quedan los woff2 y no una copia en base64.',
   'vigente', 'empirica',
   'Gambas 3.19.0 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-69',
   'Confirmar en Mint con Gambas 3.22.1.',
   1400, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-140 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-140';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-135', 'GV-139', 'GV-140', 'SC-69')
 ORDER BY prefijo, numero;
