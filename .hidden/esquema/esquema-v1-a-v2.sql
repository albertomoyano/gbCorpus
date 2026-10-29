-- ============================================================
-- esquema-v1-a-v2: migración del esquema de gbCorpus de la 1 a la 2
-- ------------------------------------------------------------
-- Agrega la tabla importaciones: el registro de cada script que el
-- importador aplicó, con su número en la serie gbcorpus-act-NN, la
-- huella sha256 del archivo y el momento. Hasta acá la base no sabía qué
-- scripts había recibido: el 29/10 act-75 y act-76 figuraban como
-- aplicadas y no lo estaban, y nada lo mostraba (RF-08, SC-50).
-- Siembra: act-78, la última aplicada en v1, como registro retroactivo,
-- con la hora de sus entradas y la huella de su archivo. Es el punto de
-- partida de la serie: el importador espera act-79 a continuación.
-- Los datos de familias y entradas no cambian.
-- La corre la propia aplicación al abrir una base v1 (también se puede
-- correr con el importador de la 2 desde una terminal).
-- Migración: 1 a 2
-- Esquema: 1
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE _verif (paso TEXT, ok INTEGER CHECK (ok = 1));

-- --- 1. ESTADO DE PARTIDA: act-78 APLICADA, TABLA LIBRE ---
INSERT INTO _verif SELECT 'act-78 aplicada', COUNT(*) = 2 FROM entradas
  WHERE codigo IN ('GV-XML-04', 'GV-155');
INSERT INTO _verif SELECT 'tabla importaciones libre', COUNT(*) = 0 FROM sqlite_master
  WHERE name = 'importaciones';

-- --- 2. LA TABLA ---
-- numero ES NULL PARA UN SCRIPT FUERA DE LA SERIE (UNA MIGRACIÓN, UN
-- VOLCADO). UNIQUE ADMITE VARIOS NULL EN SQLITE: LOS NULL SON DISTINTOS
-- ENTRE SÍ PARA UNA RESTRICCIÓN UNIQUE (sqlite.org/lang_createtable.html)
CREATE TABLE importaciones (
  id_importacion INTEGER PRIMARY KEY,
  archivo        TEXT    NOT NULL CHECK (archivo <> ''),
  numero         INTEGER UNIQUE CHECK (numero > 0),
  sha256         TEXT    CHECK (length(sha256) = 64 AND sha256 NOT GLOB '*[^0-9a-f]*'),
  fecha          TEXT    NOT NULL,
  origen         TEXT    NOT NULL DEFAULT 'importador'
                 CHECK (origen IN ('importador', 'retroactivo'))
);

-- --- 3. SIEMBRA: act-78, CON LA HORA EN QUE DIO DE ALTA SUS ENTRADAS ---
-- fecha_alta Y NO fecha_modificacion: UNA EDICIÓN POSTERIOR DESDE LA
-- APLICACIÓN MUEVE LA SEGUNDA Y NUNCA LA PRIMERA. LA HUELLA ES LA DEL
-- ARCHIVO gbcorpus-act-78.sql DE LA CARPETA DE gbCorpus, CALCULADA CON
-- sha256sum AL REDACTAR ESTA MIGRACIÓN
INSERT INTO importaciones (archivo, numero, sha256, fecha, origen)
  SELECT 'gbcorpus-act-78.sql', 78,
         '409168e51e4e5867cea89f8c64e7d9fd196dcd3ba11ccbe57826938fe94c63b0',
         MIN(fecha_alta), 'retroactivo'
    FROM entradas WHERE codigo IN ('GV-XML-04', 'GV-155');

INSERT INTO _verif SELECT 'siembra con fecha', COUNT(*) = 1 FROM importaciones
  WHERE numero = 78 AND fecha IS NOT NULL;

-- --- 4. SELLO DE VERSIÓN ---
INSERT INTO esquema_version (version, fecha) VALUES (2, date('now'));

DROP TABLE _verif;

COMMIT;
