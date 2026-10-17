-- ============================================================
-- gbCorpus — actualización 45: SC-57, el estilo de cita en el canónico de
--            cada pieza
-- Esquema: 1
-- Origen: diseño acordado con Alberto (17/10, cuatro puntos). Pruebas en el
--         contenedor con el libro de Duek (Saxon-HE 12.9, xmllint, Gambas
--         3.19). Numerado contra la base de Alberto (~/.gbcorpus/corpus.sqlite,
--         17/10, con act-44 aplicado).
-- Fecha:  2026-10-17
-- Aplicar: después de act-44
--
-- MODIFICA:
--   SC-57     el límite conocido del agrupamiento: resuelto
--   RC-XJ-02  relación con SC-57
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'act-44 aplicado', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-58' AND instr(titulo, 'el signo \&') > 0;
INSERT INTO verificacion SELECT 'SC-57 ancla', instr(cuerpo, 'El agrupamiento depende del estilo solo en un caso: `suppress` con afijos en un estilo numérico. Hoy el PDF y la pasada de citas toman el estilo del canónico de pieza, que no trae `csl-style`, y las hojas de HTML y EPUB el de la base. Para los autor-año da lo mismo; para IEEE no, y se resuelve en el lote del estilo en el canónico.') > 0 FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'RC-XJ-02 vigente', COUNT(*) = 1 FROM entradas WHERE codigo = 'RC-XJ-02' AND estado = 'vigente';

-- ------------------------------------------------------------
-- 2. SC-57: EL ESTILO EN EL CANÓNICO DE PIEZA
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo,
         'El agrupamiento depende del estilo solo en un caso: `suppress` con afijos en un estilo numérico. Hoy el PDF y la pasada de citas toman el estilo del canónico de pieza, que no trae `csl-style`, y las hojas de HTML y EPUB el de la base. Para los autor-año da lo mismo; para IEEE no, y se resuelve en el lote del estilo en el canónico.',
         'EL ESTILO EN EL CANÓNICO DE CADA PIEZA

El agrupamiento depende del estilo en un caso: `suppress` con afijos en un estilo numérico. El PDF y la pasada de citas transforman el canónico de cada pieza, que no traía `csl-style`: `docbook-to-latex.xsl` agrupaba siempre como `apa`. Desde este lote (decisión de Alberto, cuatro puntos):

1. `m_XML.GenerarInfoCapituloXML`, BLOQUE 2c, escribe `<bibliomisc role="csl-style">` en el `<info>` de cada pieza, con el `estilo_cita` de su libro: el mismo valor que el bloque 15 del canónico del libro (RC-XJ-02: el dato de la base va en el canónico, no por parámetro).
2. `ensamblar-libro-canonico.xsl` lo descarta al copiar la pieza, como los tres marcadores de ubicación: el libro lo trae una vez en su propio `<info>` (medido: uno solo en el canónico ensamblado).
3. `preparar_latex_libro.sh` y `preparar_citas_libro.sh` cotejan el `csl-style` de cada canónico con el `\estandar` del preámbulo o de las definiciones (`estilo_canonico`, en `comun.sh`). Si falta o no coincide, la pieza falla con «el canónico declara el estilo «…» y el libro usa «…»: regenerá el canónico». Así un cambio de estilo sin regenerar no compone con un estilo y agrupa con otro. HTML y EPUB por las plantillas de la hoja agrupan con el estilo que pasa Gambas, que es el de la base; por tex4ht, la pasada de citas ya cotejó.
4. Los canónicos anteriores a este lote no traen el dato: la primera generación de cada libro corta hasta regenerarlos (GV-23: mejor cortar que tomar `apa` en silencio).

MEDIDO con Duek: con los canónicos viejos, las nueve piezas fallan con el mensaje; con el dato, los `.tex` del PDF salen idénticos byte a byte a los anteriores (para un autor-año el agrupamiento no cambia); con el estilo del libro distinto del canónico, la pasada de citas corta.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-57';
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-57'
 WHERE codigo = 'RC-XJ-02' AND instr(relaciones, 'SC-57') = 0;
INSERT INTO verificacion SELECT 'SC-57 actualizada', instr(cuerpo, 'EL ESTILO EN EL CANÓNICO DE CADA PIEZA') > 0 AND instr(cuerpo, 'se resuelve en el lote del estilo en el canónico') = 0 FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'RC-XJ-02 relacionada', instr(relaciones, 'SC-57') > 0 FROM entradas WHERE codigo = 'RC-XJ-02';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-57', 'RC-XJ-02');
