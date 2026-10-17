-- ============================================================
-- gbCorpus — actualización 39: APA entra por tex4ht; las referencias del
--            HTML van en Noto Serif
-- Esquema: 1
-- Origen: decisión de Alberto (17/10): las referencias del HTML en la
--         tipografía del texto. Medición de APA en el contenedor (biblatex-apa
--         v9.17, TeX Live 2023, make4ht v0.3m) con el libro de Duek, contra
--         el PDF que Alberto compuso en Mint con APA (l-DUEK.pdf, 17/10).
--         Numerado contra la base de Alberto (~/.gbcorpus/corpus.sqlite,
--         17/10, con act-38 aplicado).
-- Fecha:  2026-10-17
-- Aplicar: después de act-38
--
-- MODIFICA:
--   SC-57  título y alcance: Verona y APA; la pieza del CSS
--   GV-104 la decisión sobre el panel de referencias
--   RF-09  pendiente: la versión instalada no es la anclada
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'act-38 aplicado (GV-104)', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-104' AND estado = 'vigente';
INSERT INTO verificacion SELECT 'SC-57 título de act-37', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-57'
  AND titulo = 'Bibliografía de libro en HTML y EPUB: la arma biblatex con tex4ht, con el mismo estilo que el PDF (Verona)';
INSERT INTO verificacion SELECT 'SC-57 ancla ALCANCE', instr(cuerpo, 'ALCANCE

Verona. Los demás estilos siguen con sus hojas hasta que se releven') > 0 FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'SC-57 ancla CSS', instr(cuerpo, 'en el HTML va en `.ref-item.ref-biblatex`, solo para estas entradas, porque la hoja es común con revistas.') > 0 FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'GV-104 ancla', instr(cuerpo, 'Queda para decidir, como un lote aparte: embeber en el HTML una fuente con `smcp` y `c2sc`, o componer el panel de referencias con ella.') > 0 FROM entradas WHERE codigo = 'GV-104';
INSERT INTO verificacion SELECT 'RF-09 vigente', COUNT(*) = 1 FROM entradas WHERE codigo = 'RF-09' AND estado = 'vigente';

-- ------------------------------------------------------------
-- 2. SC-57: APA
-- ------------------------------------------------------------
UPDATE entradas
   SET titulo = 'Bibliografía de libro en HTML y EPUB: la arma biblatex con tex4ht, con el mismo estilo que el PDF (Verona, APA)',
       cuerpo = replace(replace(cuerpo,
         'ALCANCE

Verona. Los demás estilos siguen con sus hojas hasta que se releven',
         'APA

`cita-apa-html.tex` no cambia ninguna opción: `cita-apa-config.tex` ya carga `backref=false`, y biblatex-apa repite el nombre en cada entrada y no usa versalitas. Solo define `\gbImprimirBibliografia` como `\printbibliography[heading=none]`.

MEDIDO con el libro de Duek, contra el PDF que Alberto compuso en Mint con APA: las 132 citas y las 113 referencias de `citas.html` tienen el mismo texto que el PDF (las únicas diferencias de la comparación son cortes de página del PDF). HTML: vnu sin errores. EPUB: epubcheck 4.2.6 sin errores.

En las notas no hay límite: `\iffootnote`, que tex4ht no puede responder, en `apa.cbx` solo lo usa `\smartcite`, y la aplicación no lo emite.

Lo que reemplaza: las plantillas de APA de las hojas ordenaban las referencias como el canónico y no como el estilo, repetían el título de la obra en las partes de libro («La juventud es más que una palabra. La juventud es más que una palabra, 13-30») y unían dos autores con «y» donde biblatex-apa pone «&».

ALCANCE

Verona y APA. Los demás estilos siguen con sus hojas hasta que se releven'),
         'en el HTML va en `.ref-item.ref-biblatex`, solo para estas entradas, porque la hoja es común con revistas.',
         'en el HTML va en `.ref-item.ref-biblatex`, solo para estas entradas, porque la hoja es común con revistas. Esas entradas van además en `--font-serif` (Noto Serif), la tipografía del texto, que trae `smcp` y `c2sc` (GV-104; decisión de Alberto).'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'SC-57 con APA',
  instr(titulo, '(Verona, APA)') > 0 AND instr(cuerpo, 'Verona y APA. Los demás estilos') > 0
  AND instr(cuerpo, 'cita-apa-html.tex') > 0 AND instr(cuerpo, 'van además en `--font-serif`') > 0
  FROM entradas WHERE codigo = 'SC-57';

-- ------------------------------------------------------------
-- 3. GV-104: LA DECISIÓN
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo,
         'Queda para decidir, como un lote aparte: embeber en el HTML una fuente con `smcp` y `c2sc`, o componer el panel de referencias con ella.',
         'DECISIÓN DE ALBERTO: las referencias del HTML van en Noto Serif, la tipografía del texto (`.ref-item.ref-biblatex` con `--font-serif`). Vale lo mismo que para el texto: la fuente no se embebe y la toma del sistema del lector.'),
       pendiente = NULL,
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'GV-104';
INSERT INTO verificacion SELECT 'GV-104 decidida', instr(cuerpo, 'DECISIÓN DE ALBERTO') > 0 AND pendiente IS NULL FROM entradas WHERE codigo = 'GV-104';

-- ------------------------------------------------------------
-- 4. RF-09: LA VERSIÓN INSTALADA
-- ------------------------------------------------------------
-- RF-09 ESTÁ ANCLADA A 9.20 (EL REPOSITORIO); TeX Live 2023 TRAE 9.17,
-- QUE ES CON LA QUE COMPONE LA APLICACIÓN. SE ANOTA, NO SE RESUELVE
UPDATE entradas
   SET pendiente = ifnull(pendiente || ' ', '') || 'La versión anclada es la del repositorio (9.20); la que compone en Mint y en el contenedor es la de TeX Live 2023, biblatex-apa v9.17 (2023/03/20). Una afirmación tomada del fuente de 9.20 se verifica contra 9.17 antes de aplicarla.',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'RF-09' AND instr(ifnull(pendiente, ''), 'v9.17') = 0;
INSERT INTO verificacion SELECT 'RF-09 anotada', instr(pendiente, 'v9.17') > 0 FROM entradas WHERE codigo = 'RF-09';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-57', 'GV-104', 'RF-09') ORDER BY codigo;
