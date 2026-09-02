-- ============================================
-- corpus.sqlite — REGISTRO NORMATIVO DE GBPUBLISHER
-- Esquema versión 1
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

-- --- 4. SEMILLA ---
INSERT INTO familias (prefijo, nombre, descripcion, orden, ancho_numero, en_operativo) VALUES
  ('RC-GM', 'Reglas críticas Gambas',       'Comportamientos del lenguaje que obligan a un patrón determinado', 10, 2, 1),
  ('RC-XJ', 'Reglas críticas XSLT + JATS',  'Transformación y validación de XML de revistas',                   20, 2, 1),
  ('RC-DB', 'Reglas críticas DocBook',      'Modelo de contenido y serialización de libros',                    30, 2, 1),
  ('RC-PL', 'Reglas críticas Perl',         'Motor de expresiones regulares externo',                           40, 2, 1),
  ('SC',    'Soluciones canónicas',         'Decisiones cerradas: aplicar, no rediscutir',                       50, 2, 1),
  ('GV',    'Comportamientos verificados',  'Evidencia empírica de gambas-verificado.md',                        60, 2, 0);

INSERT INTO esquema_version (version, fecha) VALUES (1, date('now'));
