-- ============================================================
-- gbCorpus — actualización 69: el HTML y el PNG del gráfico los arma
--            engine/grafico.sh (SC-69, paso 2)
-- Esquema: 1
-- Origen: conversación del 25/10, paso 2 de la implementación de SC-69.
--         Alberto decide que el HTML y el PNG los arme un script de
--         engine/ (SC-13) y no m_Graficos. Con eso, Base64$ (GV-140) deja
--         de usarse. Al probar el script aparecieron dos comportamientos
--         de chromium: la ruta con # y el perfil propio.
-- Fecha:  2026-10-25
-- Aplicar: después de act-68
--
-- ALTAS:
--   GV-141  Chromium sin ventana: --dump-dom, la URL y el perfil
-- MODIFICA:
--   SC-69   el HTML por engine/grafico.sh; relaciones: SC-13, SC-53,
--           GV-141 en lugar de GV-140
--   GV-140  EN EL PROYECTO: ya no se usa; relaciones: vinculo:SC-69
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: LA BASE CON act-68; CADA TEXTO, UNA VEZ
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-140 última GV', MAX(numero) = 140 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'GV-141 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-141' OR (prefijo = 'GV' AND numero = 141);
INSERT INTO verificacion SELECT 'GV-140 apoya a SC-69', relaciones = 'apoya:SC-69' FROM entradas WHERE codigo = 'GV-140';
INSERT INTO verificacion SELECT 'SC-69 el HTML: una vez', (length(cuerpo) - length(replace(cuerpo, '- EL HTML. Una plantilla en `.hidden/chart/` con Chart.js 4.4.1 entero y un hueco para la configuración. `m_Graficos` arma la configuración con `JSON.Encode` y reemplaza `</` por `<\/` antes de embeberla (GV-137). Cada `fig-nombre.html` funciona solo: lleva Chart.js y la fuente.', ''))) = length('- EL HTML. Una plantilla en `.hidden/chart/` con Chart.js 4.4.1 entero y un hueco para la configuración. `m_Graficos` arma la configuración con `JSON.Encode` y reemplaza `</` por `<\/` antes de embeberla (GV-137). Cada `fig-nombre.html` funciona solo: lleva Chart.js y la fuente.') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 relaciones de act-68: una vez', (length(relaciones) - length(replace(relaciones, ',vinculo:SC-65,apoya:GV-140', ''))) = length(',vinculo:SC-65,apoya:GV-140') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'GV-140 en el proyecto: una vez', (length(cuerpo) - length(replace(cuerpo, 'EN EL PROYECTO: `m_Graficos` codifica las fuentes al armar el HTML del gráfico (SC-69); en `.hidden/chart/` quedan los woff2 y no una copia en base64.', ''))) = length('EN EL PROYECTO: `m_Graficos` codifica las fuentes al armar el HTML del gráfico (SC-69); en `.hidden/chart/` quedan los woff2 y no una copia en base64.') FROM entradas WHERE codigo = 'GV-140';

-- ------------------------------------------------------------
-- 2. SC-69
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, '- EL HTML. Una plantilla en `.hidden/chart/` con Chart.js 4.4.1 entero y un hueco para la configuración. `m_Graficos` arma la configuración con `JSON.Encode` y reemplaza `</` por `<\/` antes de embeberla (GV-137). Cada `fig-nombre.html` funciona solo: lleva Chart.js y la fuente.', '- EL HTML. `m_Graficos` lee y controla el archivo y escribe la descripción del gráfico con `JSON.Encode`, con `</` cambiado por `<\/` (GV-137), en `tmp/vista-grafico/fig-nombre.json`. `engine/grafico.sh` (SC-13, lanzado por `EjecutarScriptSalida`, SC-53) llena los huecos de la plantilla de `.hidden/chart/` —el idioma, las dos fuentes en base64, Chart.js 4.4.1 entero y la descripción— y controla con `chromium --dump-dom` que la plantilla haya dibujado (GV-141). La configuración de Chart.js la arma la plantilla: las funciones de las marcas y del tooltip no pueden ir en JSON. Cada `fig-nombre.html` funciona solo: lleva Chart.js y la fuente.'),
       relaciones = replace(relaciones, ',vinculo:SC-65,apoya:GV-140', ',vinculo:SC-65,vinculo:SC-13,vinculo:SC-53,apoya:GV-141'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 actualizada', instr(cuerpo, '- EL HTML. `m_Graficos` lee y controla el archivo y escribe la descripción del gráfico con `JSON.Encode`, con `</` cambiado por `<\/` (GV-137), en `tmp/vista-grafico/fig-nombre.json`. `engine/grafico.sh` (SC-13, lanzado por `EjecutarScriptSalida`, SC-53) llena los huecos de la plantilla de `.hidden/chart/` —el idioma, las dos fuentes en base64, Chart.js 4.4.1 entero y la descripción— y controla con `chromium --dump-dom` que la plantilla haya dibujado (GV-141). La configuración de Chart.js la arma la plantilla: las funciones de las marcas y del tooltip no pueden ir en JSON. Cada `fig-nombre.html` funciona solo: lleva Chart.js y la fuente.') > 0 AND instr(relaciones, ',vinculo:SC-65,vinculo:SC-13,vinculo:SC-53,apoya:GV-141') > 0 AND instr(relaciones, 'GV-140') = 0 FROM entradas WHERE codigo = 'SC-69';

-- ------------------------------------------------------------
-- 3. GV-140: YA NO SE USA
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'EN EL PROYECTO: `m_Graficos` codifica las fuentes al armar el HTML del gráfico (SC-69); en `.hidden/chart/` quedan los woff2 y no una copia en base64.', 'EN EL PROYECTO: no se usa. El HTML del gráfico lo arma `engine/grafico.sh` (SC-13, SC-69), que codifica las fuentes con `base64 -w0`; en `.hidden/chart/` quedan los woff2 y no una copia en base64.'),
       relaciones = 'vinculo:SC-69',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'GV-140';
INSERT INTO verificacion SELECT 'GV-140 actualizada', instr(cuerpo, 'EN EL PROYECTO: no se usa. El HTML del gráfico lo arma `engine/grafico.sh` (SC-13, SC-69), que codifica las fuentes con `base64 -w0`; en `.hidden/chart/` quedan los woff2 y no una copia en base64.') > 0 AND relaciones = 'vinculo:SC-69' FROM entradas WHERE codigo = 'GV-140';

-- ------------------------------------------------------------
-- 4. GV-141
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 141, 'GV-141', 'Chromium sin ventana: --dump-dom espera el dibujo; la página va como URL y sin perfil propio',
   'Medido con la plantilla de SC-69, en un proyecto con espacio, ñ y # en el nombre de la carpeta:

    --dump-dom <url>                   el DOM después de los scripts, incluido el dibujo que
                                       espera a document.fonts.load: <html data-listo="1">; si la
                                       plantilla falla, data-listo="error" y data-motivo
    la ruta tal cual, con # en ella    la página no se encuentra: chromium lee el # como el
                                       comienzo del fragmento
    file:// con %XX por cada byte      funciona con espacio, ñ y #
    --user-data-dir=<carpeta nueva>    --dump-dom no termina: vence el timeout
    sin --user-data-dir                un perfil temporal en /tmp/org.chromium.Chromium.*: no toca
                                       el de quien opera

EN EL PROYECTO: `engine/grafico.sh` controla así que el gráfico se haya dibujado, y arma la URL con perl, un %XX por cada byte que no es letra, cifra ni -._~ (SC-69).',
   'vigente', 'empirica',
   'Chromium 153 headless (Playwright) / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-69',
   'Confirmar con el chromium de Mint.',
   1410, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-141 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-141';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-140', 'GV-141', 'SC-69')
 ORDER BY prefijo, numero;
