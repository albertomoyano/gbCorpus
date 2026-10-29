-- ============================================
-- corpus.sqlite — REGISTRO NORMATIVO DE GBPUBLISHER
-- Esquema versión 2
-- Creación manual:  sqlite3 corpus.sqlite < corpus_esquema.sql
-- ============================================

PRAGMA foreign_keys = ON;

-- --- 1. FAMILIAS: ALTA POR ABM, NO POR CÓDIGO ---
CREATE TABLE familias (
  prefijo       TEXT PRIMARY KEY,
  nombre        TEXT    NOT NULL,
  descripcion   TEXT,
  orden         INTEGER NOT NULL,
  ancho_numero  INTEGER NOT NULL DEFAULT 2,
  en_operativo  INTEGER NOT NULL DEFAULT 1
);

-- --- 2. ENTRADAS: REGLAS Y APARTADOS DE EVIDENCIA EN UNA SOLA TABLA ---
CREATE TABLE entradas (
  id_entrada         INTEGER PRIMARY KEY,
  prefijo            TEXT    NOT NULL REFERENCES familias(prefijo),
  numero             INTEGER NOT NULL,
  codigo             TEXT    NOT NULL UNIQUE,
  titulo             TEXT    NOT NULL,
  cuerpo             TEXT    NOT NULL DEFAULT '',
  estado             TEXT    NOT NULL DEFAULT 'vigente'
                     CHECK (estado IN ('vigente','corregida','deprecada','hipotesis')),
  evidencia          TEXT    CHECK (evidencia IN ('empirica','doc_oficial','inferida')),
  entorno            TEXT,
  fecha_verificacion TEXT,
  relaciones         TEXT    NOT NULL DEFAULT '',
  pendiente          TEXT,
  orden              INTEGER NOT NULL,
  fecha_alta         TEXT    NOT NULL,
  fecha_modificacion TEXT    NOT NULL,
  UNIQUE (prefijo, numero)
);

CREATE INDEX ix_entradas_familia ON entradas (prefijo, orden);
CREATE INDEX ix_entradas_estado  ON entradas (estado);

-- --- 3. VERSIÓN DE ESQUEMA ---
CREATE TABLE esquema_version (
  version INTEGER NOT NULL,
  fecha   TEXT    NOT NULL
);

-- --- 4. REGISTRO DE IMPORTACIONES (DESDE EL ESQUEMA 2) ---
-- LO ESCRIBE SOLO EL IMPORTADOR: UNA FILA POR SCRIPT APLICADO. numero ES
-- EL NN DE gbcorpus-act-NN.sql, O NULL PARA UN SCRIPT FUERA DE LA SERIE
-- (UNIQUE ADMITE VARIOS NULL EN SQLITE)
CREATE TABLE importaciones (
  id_importacion INTEGER PRIMARY KEY,
  archivo        TEXT    NOT NULL CHECK (archivo <> ''),
  numero         INTEGER UNIQUE CHECK (numero > 0),
  sha256         TEXT    CHECK (length(sha256) = 64 AND sha256 NOT GLOB '*[^0-9a-f]*'),
  fecha          TEXT    NOT NULL,
  origen         TEXT    NOT NULL DEFAULT 'importador'
                 CHECK (origen IN ('importador', 'retroactivo'))
);

-- --- 5. SEMILLA ---
INSERT INTO familias (prefijo, nombre, descripcion, orden, ancho_numero, en_operativo) VALUES
  ('RC-GM', 'Reglas críticas Gambas',       'Comportamientos del lenguaje que obligan a un patrón determinado', 10, 2, 1),
  ('RC-XJ', 'Reglas críticas XSLT + JATS',  'Transformación y validación de XML de revistas',                   20, 2, 1),
  ('RC-DB', 'Reglas críticas DocBook',      'Modelo de contenido y serialización de libros',                    30, 2, 1),
  ('RC-PL', 'Reglas críticas Perl',         'Motor de expresiones regulares externo',                           40, 2, 1),
  ('SC',    'Soluciones canónicas',         'Decisiones cerradas: aplicar, no rediscutir',                       50, 2, 1),
  ('GV',    'Comportamientos verificados',  'Evidencia empírica de gambas-verificado.md',                        60, 2, 0);

INSERT INTO esquema_version (version, fecha) VALUES (2, date('now'));
