-- ============================================================
-- gbCorpus — actualización 43: RF-13 (fuente de biblatex-iso690); ISO 690
--            entra por tex4ht
-- Esquema: 1
-- Origen: relevamiento del repositorio de biblatex-iso690 (clon del
--         17/10, commit 7231d7a) y medición en el contenedor con el libro
--         de Duek, contra el PDF que Alberto compuso en Mint con ISO 690
--         (l-DUEK.pdf, 17/10). Numerado contra la base de Alberto
--         (~/.gbcorpus/corpus.sqlite, 17/10, con act-42 aplicado).
-- Fecha:  2026-10-17
-- Aplicar: después de act-42
--
-- ALTAS:
--   RF-13  Fuente de biblatex-iso690 (ISO 690)
-- MODIFICA:
--   SC-57  título y alcance: Verona, APA e ISO 690
--   SC-58  pendiente: las comillas de ISO 690 ya no se pierden
--   SC-14  relación con RF-13
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'RF-13 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'RF-13' OR (prefijo = 'RF' AND numero = 13);
INSERT INTO verificacion SELECT 'RF-12 es la última RF', MAX(numero) = 12 FROM entradas WHERE prefijo = 'RF';
INSERT INTO verificacion SELECT 'act-42 aplicado', instr(cuerpo, 'NIVELES DE \enquote') > 0 FROM entradas WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-57 título de act-39', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-57'
  AND titulo = 'Bibliografía de libro en HTML y EPUB: la arma biblatex con tex4ht, con el mismo estilo que el PDF (Verona, APA)';
INSERT INTO verificacion SELECT 'SC-57 ancla ALCANCE', instr(cuerpo, 'ALCANCE

Verona y APA. Los demás estilos siguen') > 0 FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'SC-58 ancla del pendiente', instr(pendiente, 'En las hojas de HTML y EPUB, las plantillas por estilo (las de los estilos que todavía no van por tex4ht: ISO 690, IEEE) leen el título con normalize-space y pierden las comillas de un <quote>: se resuelve cuando esos estilos pasen por tex4ht.') > 0 FROM entradas WHERE codigo = 'SC-58';

-- ------------------------------------------------------------
-- 2. RF-13
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('RF', 13, 'RF-13', 'Fuente de biblatex-iso690 (ISO 690)',
   'Repositorio: https://github.com/michal-h21/biblatex-iso690. Paquete en CTAN: `macros/latex/contrib/biblatex-contrib/biblatex-iso690`. Autor: Michal Hoftich.

VERSIÓN ANCLADA

v0.4.1 (2022/03/20). Es la de TeX Live 2023, la que compone en Mint 22 y en el contenedor. El repositorio (commit 7231d7a, 2025-09-28) trae los mismos archivos: `iso.bbx`, `iso-authoryear.bbx`, `iso-authoryear.cbx` y `spanish-iso.lbx` son idénticos byte a byte a los instalados (medido con diff). La aplicación usa la variante autor-año: `style=iso-authoryear`.

ACCESO

`git clone --depth 1 https://github.com/michal-h21/biblatex-iso690.git` funciona. Con TeX Live instalado, los archivos ya están en `texmf-dist/tex/latex/biblatex-iso690/`.

ORDEN DE CONSULTA

1. `iso.bbx` — opciones del estilo, formatos de campo, formato de los nombres. Fuente de verdad del comportamiento.
2. `iso-authoryear.bbx` — la variante autor-año de las referencias: orden `nyt`, `nameyeardelim`, fechas.
3. `iso-authoryear.cbx` — citas: `maxcitenames=1`, sobre `authoryear.cbx` de biblatex y `iso-fullcite.cbx`.
4. `spanish-iso.lbx` — cadenas en español; hereda las de `spanish.lbx` de biblatex.
5. `biblatex-iso690.tex` y su PDF — documentación. Informa la intención; si contradice al código, gana el código.

La configuración de la aplicación: `.hidden/latex/cita-iso690-config.tex`; la de pantalla, `cita-iso690-html.tex`.

BANCO DE PRUEBAS

`biblatex-iso690-examples.bib` (42 entradas) e `iso-example.tex`.

DATOS DEL FUENTE QUE USA EL PROYECTO

- `iso.bbx` fija `autolang=other`: cada entrada en el idioma de su `langid`. La aplicación lo cambia por `autolang=hyphen` (GV-105). El estilo trae también `currentlang` (las cadenas en el idioma del documento), que no se usa: con `autolang=other`, babel igual apaga los extras del español en una entrada en otro idioma.
- Los apellidos: `\familynameformat` va en mayúsculas (`\MakeUppercase`) o, con `familynamesc`, en `\textsc`. Se aplica con `\AtBeginBibliography`, solo en la bibliografía. La configuración de la aplicación lo reemplaza por versalitas parejas, `\textsc{\MakeLowercase{...}}`, en los cuatro componentes del nombre.
- `\mkbibacro` (DOI, ISBN, ISSN): `\textsc{\MakeLowercase{...}}` solo con `bibacrosc`, que el estilo trae desactivada.
- Títulos: `\DeclareFieldFormat*{title}{#1}`. ISO 690 no pone comillas a ningún título (SC-58).
- Citas: `\iffootnote` solo aparece en `\smartcite` (de `authoryear.cbx`), que la aplicación no emite. La detección de notas que tex4ht no responde no afecta a ISO 690 (SC-57).',
   'vigente', 'empirica',
   'biblatex-iso690 v0.4.1 (2022/03/20) / repositorio, commit 7231d7a / biblatex 3.19 / TeX Live 2023 / contenedor Ubuntu 24.04',
   '2026-10',
   'vinculo:SC-14,vinculo:SC-57,vinculo:SC-58,vinculo:GV-105',
   NULL,
   130, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'RF-13 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'RF-13' AND orden = 130;

-- ------------------------------------------------------------
-- 3. SC-57: ISO 690
-- ------------------------------------------------------------
UPDATE entradas
   SET titulo = 'Bibliografía de libro en HTML y EPUB: la arma biblatex con tex4ht, con el mismo estilo que el PDF (Verona, APA, ISO 690)',
       cuerpo = replace(cuerpo,
         'ALCANCE

Verona y APA. Los demás estilos siguen',
         'ISO 690

`cita-iso690-html.tex` cambia solo los nombres: en el PDF van `\textsc{\MakeLowercase{...}}`; en pantalla, `\textsc{...}` con la caja de la base, y las versalitas las pone el CSS. Es la decisión de Verona (SC-56). Las nuevas definiciones se agregan después de las del PDF (`\familynameformat` y un `\AtBeginBibliography`) y las pisan. Define `\gbImprimirBibliografia` como `\printbibliography[heading=none]`. RF-13.

MEDIDO con el libro de Duek, contra el PDF que Alberto compuso en Mint con ISO 690: las 132 citas y las 113 referencias de `citas.html` tienen el mismo texto que el PDF, sin distinguir caja, que es lo único que cambia a propósito (las dos diferencias de la comparación son cortes de página del PDF). HTML: vnu sin errores. EPUB: epubcheck 4.2.6 sin errores.

ALCANCE

Verona, APA e ISO 690. Los demás estilos siguen'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-57';
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:RF-13'
 WHERE codigo IN ('SC-57', 'SC-14') AND instr(relaciones, 'RF-13') = 0;
INSERT INTO verificacion SELECT 'SC-57 con ISO 690',
  instr(titulo, '(Verona, APA, ISO 690)') > 0 AND instr(cuerpo, 'cita-iso690-html.tex') > 0
  AND instr(cuerpo, 'Verona, APA e ISO 690. Los demás') > 0 AND instr(relaciones, 'RF-13') > 0
  FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'SC-14 con RF-13', instr(relaciones, 'RF-13') > 0 FROM entradas WHERE codigo = 'SC-14';

-- ------------------------------------------------------------
-- 4. SC-58: EL PENDIENTE DE ISO 690
-- ------------------------------------------------------------
UPDATE entradas
   SET pendiente = replace(pendiente,
         'En las hojas de HTML y EPUB, las plantillas por estilo (las de los estilos que todavía no van por tex4ht: ISO 690, IEEE) leen el título con normalize-space y pierden las comillas de un <quote>: se resuelve cuando esos estilos pasen por tex4ht.',
         'En las hojas de HTML y EPUB, las plantillas por estilo (hoy solo las de IEEE, que todavía no va por tex4ht) leen el título con normalize-space y pierden las comillas de un <quote>: se resuelve cuando IEEE pase por tex4ht.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-58 pendiente', instr(pendiente, 'hoy solo las de IEEE') > 0 FROM entradas WHERE codigo = 'SC-58';

COMMIT;

SELECT codigo, estado, orden, titulo FROM entradas WHERE codigo IN ('RF-13', 'SC-57') ORDER BY codigo;
