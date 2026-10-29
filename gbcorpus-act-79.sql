-- ============================================================
-- gbCorpus — actualización 79: el registro de importaciones
-- Esquema: 2
-- Origen: conversación del 29/10. act-75 y act-76 estaban en la carpeta y
--         no en la base, y nada lo mostraba. Alberto decide «lo prolijo»:
--         el esquema 2 de gbCorpus, con la tabla importaciones, la serie
--         vigilada por el importador y el semáforo lblInformar.
-- Fecha:  2026-10-29
-- Aplicar: después de la migración esquema-v1-a-v2 (que siembra act-78).
--          Es la primera act que el importador nuevo registra.
--
-- MODIFICA:
--   RF-08  cuatro tablas; la tabla importaciones; el semáforo; entorno
--   SC-50  gbCorpus en el esquema 2; lo que el importador garantiza; los
--          lugares de las migraciones; el número más alto ya no prueba
--          que un script se haya aplicado; el cotejo; entorno
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: LA MIGRACIÓN APLICADA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'act-78 sembrada', COUNT(*) = 1 FROM importaciones WHERE numero = 78 AND origen = 'retroactivo';


-- ------------------------------------------------------------
-- 2. CADA TEXTO A REEMPLAZAR EXISTE EXACTAMENTE UNA VEZ
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'RF-08 texto 1: una vez', (length(cuerpo) - length(replace(cuerpo, 'Tres tablas, sin vistas.', ''))) = length('Tres tablas, sin vistas.') FROM entradas WHERE codigo = 'RF-08';
INSERT INTO verificacion SELECT 'RF-08 texto 2: una vez', (length(cuerpo) - length(replace(cuerpo, 'ESTA ENTRADA DESCRIBE LA VERSIÓN 1 DEL ESQUEMA. Si `esquema_version` no dice 1, hay migraciones posteriores y esta descripción quedó vieja.', ''))) = length('ESTA ENTRADA DESCRIBE LA VERSIÓN 1 DEL ESQUEMA. Si `esquema_version` no dice 1, hay migraciones posteriores y esta descripción quedó vieja.') FROM entradas WHERE codigo = 'RF-08';
INSERT INTO verificacion SELECT 'RF-08 texto 3: una vez', (length(cuerpo) - length(replace(cuerpo, 'TABLA `esquema_version`

    version  INTEGER NOT NULL
    fecha    TEXT NOT NULL
', ''))) = length('TABLA `esquema_version`

    version  INTEGER NOT NULL
    fecha    TEXT NOT NULL
') FROM entradas WHERE codigo = 'RF-08';
INSERT INTO verificacion SELECT 'RF-08 texto 4: una vez', (length(cuerpo) - length(replace(cuerpo, 'El alcance, el importador, los scripts y la exportación son los de todas las aplicaciones satélite: SC-50.', ''))) = length('El alcance, el importador, los scripts y la exportación son los de todas las aplicaciones satélite: SC-50.') FROM entradas WHERE codigo = 'RF-08';
INSERT INTO verificacion SELECT 'SC-50 texto 1: una vez', (length(cuerpo) - length(replace(cuerpo, '(hoy, 1 en gbCorpus y 5 en gbShortcodes)', ''))) = length('(hoy, 1 en gbCorpus y 5 en gbShortcodes)') FROM entradas WHERE codigo = 'SC-50';
INSERT INTO verificacion SELECT 'SC-50 texto 2: una vez', (length(cuerpo) - length(replace(cuerpo, '- Código de salida: 0 aplicado, 1 no aplicado. Tras un fallo comprueba si la base quedó como estaba; no lo afirma sin mirar (SC-13).
', ''))) = length('- Código de salida: 0 aplicado, 1 no aplicado. Tras un fallo comprueba si la base quedó como estaba; no lo afirma sin mirar (SC-13).
') FROM entradas WHERE codigo = 'SC-50';
INSERT INTO verificacion SELECT 'SC-50 texto 3: una vez', (length(cuerpo) - length(replace(cuerpo, 'Hoy solo gbShortcodes cambió de esquema (va por la 5; el detalle de cada migración está en RF-11). gbCorpus sigue en la 1 y su importador no tiene migraciones: si sube de versión, adopta este mismo mecanismo.', ''))) = length('Hoy solo gbShortcodes cambió de esquema (va por la 5; el detalle de cada migración está en RF-11). gbCorpus sigue en la 1 y su importador no tiene migraciones: si sube de versión, adopta este mismo mecanismo.') FROM entradas WHERE codigo = 'SC-50';
INSERT INTO verificacion SELECT 'SC-50 texto 4: una vez', (length(cuerpo) - length(replace(cuerpo, '    gbCorpus       gbcorpus-act-NN.sql                    raíz del repositorio
', ''))) = length('    gbCorpus       gbcorpus-act-NN.sql                    raíz del repositorio
') FROM entradas WHERE codigo = 'SC-50';
INSERT INTO verificacion SELECT 'SC-50 texto 5: una vez', (length(cuerpo) - length(replace(cuerpo, '- Los scripts aplicados quedan en el repositorio. El número más alto es el último aplicado, y de ahí sale el siguiente.', ''))) = length('- Los scripts aplicados quedan en el repositorio. El número más alto es el último aplicado, y de ahí sale el siguiente.') FROM entradas WHERE codigo = 'SC-50';
INSERT INTO verificacion SELECT 'SC-50 texto 6: una vez', (length(cuerpo) - length(replace(cuerpo, 'De ahí salen los scripts aplicados (`gbcorpus-act-NN.sql` en la raíz de gbCorpus, `datos/` de gbShortcodes).', ''))) = length('De ahí salen los scripts aplicados (`gbcorpus-act-NN.sql` en la raíz de gbCorpus, `datos/` de gbShortcodes).') FROM entradas WHERE codigo = 'SC-50';
INSERT INTO verificacion SELECT 'SC-50 entorno: una vez', (length(entorno) - length(replace(entorno, 'gbCorpus 0.0.8 / gbShortcodes', ''))) = length('gbCorpus 0.0.8 / gbShortcodes') FROM entradas WHERE codigo = 'SC-50';

-- ------------------------------------------------------------
-- 3. REEMPLAZOS
-- ------------------------------------------------------------
UPDATE entradas SET cuerpo = replace(cuerpo, 'Tres tablas, sin vistas.', 'Cuatro tablas, sin vistas.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'RF-08';
UPDATE entradas SET cuerpo = replace(cuerpo, 'ESTA ENTRADA DESCRIBE LA VERSIÓN 1 DEL ESQUEMA. Si `esquema_version` no dice 1, hay migraciones posteriores y esta descripción quedó vieja.', 'ESTA ENTRADA DESCRIBE LA VERSIÓN 2 DEL ESQUEMA. Si `esquema_version` no dice 2, hay migraciones posteriores y esta descripción quedó vieja. La 2 agregó la tabla `importaciones` (`.hidden/esquema/esquema-v1-a-v2.sql`, 29/10/2026); las otras tres no cambiaron desde la 1.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'RF-08';
UPDATE entradas SET cuerpo = replace(cuerpo, 'TABLA `esquema_version`

    version  INTEGER NOT NULL
    fecha    TEXT NOT NULL
', 'TABLA `esquema_version`

    version  INTEGER NOT NULL
    fecha    TEXT NOT NULL

TABLA `importaciones` (DESDE EL ESQUEMA 2)

    id_importacion  INTEGER PRIMARY KEY
    archivo         TEXT NOT NULL CHECK (archivo <> '''')
    numero          INTEGER UNIQUE CHECK (numero > 0)
    sha256          TEXT CHECK (64 dígitos hexadecimales en minúscula)
    fecha           TEXT NOT NULL
    origen          TEXT NOT NULL DEFAULT ''importador''
                    CHECK (origen IN (''importador'', ''retroactivo''))

Una fila por script aplicado, en orden de llegada. La escribe solo el importador, en la misma sesión de `sqlite3` que aplica el script y después de él: si el script falla, no hay fila. La aplicación la lee y no la toca.

- `archivo`: el nombre del `.sql`, sin carpeta.
- `numero`: el NN de `gbcorpus-act-NN.sql`. NULL para un script fuera de la serie, como una migración; UNIQUE admite varios NULL en SQLite.
- `sha256`: la huella del archivo tal como se aplicó. Detecta el mismo archivo aplicado dos veces, aunque haya cambiado de nombre.
- `fecha`: `datetime(''now'',''localtime'')` del momento de la aplicación.
- `origen`: `retroactivo` solo para la siembra de la migración, act-78, que se aplicó antes de que existiera el registro; su fecha es la `fecha_alta` de las entradas que dio de alta. Todo lo demás es `importador`.

Lo que se aplicó antes del esquema 2 no está registrado, salvo act-78. La serie empieza ahí.
'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'RF-08';
UPDATE entradas SET cuerpo = replace(cuerpo, 'El alcance, el importador, los scripts y la exportación son los de todas las aplicaciones satélite: SC-50.', 'El alcance, el importador, los scripts y la exportación son los de todas las aplicaciones satélite: SC-50. La cabecera muestra, en `lblInformar`, el último registro de `importaciones` (`m_Base.UltimaImportacion`): «última importación: act-NN · fecha». Si el último script no es de la serie, agrega en qué act va la serie. Antes de pedir un cambio al corpus, ese número tiene que ser el más alto de la carpeta de gbCorpus. El volcado SQL incluye el registro.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'RF-08';
UPDATE entradas SET cuerpo = replace(cuerpo, '(hoy, 1 en gbCorpus y 5 en gbShortcodes)', '(hoy, 2 en gbCorpus y 5 en gbShortcodes)'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-50';
UPDATE entradas SET cuerpo = replace(cuerpo, '- Código de salida: 0 aplicado, 1 no aplicado. Tras un fallo comprueba si la base quedó como estaba; no lo afirma sin mirar (SC-13).
', '- Código de salida: 0 aplicado, 1 no aplicado. Tras un fallo comprueba si la base quedó como estaba; no lo afirma sin mirar (SC-13).
- gbCorpus, desde el esquema 2, registra cada script aplicado en la tabla `importaciones`, con su número de la serie, la huella sha256 del archivo y el momento (RF-08). Antes de escribir vigila la serie `gbcorpus-act-NN`. Rechaza un archivo ya aplicado, por su huella, y un número ya registrado. Si el número no es el último más uno, dice cuáles faltan y se detiene; en una terminal interactiva sigue solo si se escribe «saltar», y sin terminal se detiene siempre. Un script fuera de la serie, como una migración, se registra sin número. Después comprueba que la fila haya entrado.
'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-50';
UPDATE entradas SET cuerpo = replace(cuerpo, 'Hoy solo gbShortcodes cambió de esquema (va por la 5; el detalle de cada migración está en RF-11). gbCorpus sigue en la 1 y su importador no tiene migraciones: si sube de versión, adopta este mismo mecanismo.', 'Las dos aplicaciones cambiaron de esquema con este mismo mecanismo: gbShortcodes va por la 5 (el detalle de cada migración está en RF-11) y gbCorpus por la 2, que agregó el registro de importaciones (RF-08).'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-50';
UPDATE entradas SET cuerpo = replace(cuerpo, '    gbCorpus       gbcorpus-act-NN.sql                    raíz del repositorio
', '    gbCorpus       gbcorpus-act-NN.sql                    raíz del repositorio
                   .hidden/esquema/esquema-vN-a-vM.sql    migraciones
'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-50';
UPDATE entradas SET cuerpo = replace(cuerpo, '- Los scripts aplicados quedan en el repositorio. El número más alto es el último aplicado, y de ahí sale el siguiente.', '- Los scripts aplicados quedan en el repositorio, y el número del siguiente sale del más alto de la carpeta. Que un script esté en la carpeta no prueba que se haya aplicado: el 29/10/2026 act-75 y act-76 estaban en la carpeta de gbCorpus y no en la base. En gbCorpus lo dice el registro de importaciones (RF-08); gbShortcodes no tiene registro.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-50';
UPDATE entradas SET cuerpo = replace(cuerpo, 'De ahí salen los scripts aplicados (`gbcorpus-act-NN.sql` en la raíz de gbCorpus, `datos/` de gbShortcodes).', 'De ahí salen los scripts escritos (`gbcorpus-act-NN.sql` en la raíz de gbCorpus, `datos/` de gbShortcodes). Cuáles se aplicaron en gbCorpus lo dice la tabla `importaciones` de `~/.gbcorpus/corpus.sqlite`, y se coteja antes de escribir: si la última registrada no es la más alta de la carpeta, falta aplicar algo y se avisa antes de redactar.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-50';
UPDATE entradas SET entorno = replace(entorno, 'gbCorpus 0.0.8 / gbShortcodes', 'gbCorpus 0.0.10 (esquema 2) / gbShortcodes'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-50';
UPDATE entradas SET entorno = 'gbCorpus 0.0.10 / SQLite / esquema versión 2', fecha_verificacion = '2026-10', fecha_modificacion = datetime('now','localtime') WHERE codigo = 'RF-08' AND entorno = 'gbCorpus / SQLite / esquema versión 1';
INSERT INTO verificacion SELECT 'RF-08 entorno', changes() = 1;

-- ------------------------------------------------------------
-- 4. RESULTADO
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'RF-08 describe v2', instr(cuerpo, 'VERSIÓN 2 DEL ESQUEMA') > 0 AND instr(cuerpo, 'TABLA `importaciones`') > 0 FROM entradas WHERE codigo = 'RF-08';
INSERT INTO verificacion SELECT 'SC-50 sin «sigue en la 1»', instr(cuerpo, 'sigue en la 1') = 0 FROM entradas WHERE codigo = 'SC-50';

COMMIT;

SELECT codigo, estado, entorno, titulo FROM entradas
 WHERE codigo IN ('RF-08', 'SC-50')
 ORDER BY prefijo, numero;
