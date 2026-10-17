-- ============================================================
-- gbCorpus — actualización 37: SC-57, la bibliografía de HTML y EPUB la
--            arma biblatex con tex4ht (Verona)
-- Esquema: 1
-- Origen: diseño acordado con Alberto. Pruebas en el contenedor (Ubuntu
--         24.04, TeX Live 2023, biber 2.19, make4ht v0.3m) con
--         cita-veronaM-config.tex corregida, ref-l-MOLINARO.bib y
--         prueba-biber.bib. Numerado contra gbpublisher/docs/corpus.md
--         (17/10, 08:29) más act-36 (GV-102).
-- Fecha:  2026-10-17
-- Aplicar: después de act-36
--
-- ALTAS:
--   SC-57  Bibliografía de libro en HTML y EPUB: la arma biblatex con
--          tex4ht, con el mismo estilo que el PDF (Verona)
-- MODIFICA:
--   SC-56  el mecanismo ya no está «en diseño»: remite a SC-57
--   SC-14, SC-42, RF-12, GV-102  relaciones: SC-57
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-57 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-57' OR (prefijo = 'SC' AND numero = 57);
INSERT INTO verificacion SELECT 'SC-56 es la última SC', MAX(numero) = 56 FROM entradas WHERE prefijo = 'SC';
-- ACT-36 APLICADO: GV-102 ES LA DE refsection=chapter
INSERT INTO verificacion SELECT 'act-36 aplicado (GV-102)', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-102' AND instr(titulo, 'refsection=chapter') > 0;
INSERT INTO verificacion SELECT 'SC-14 vigente', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-14' AND estado = 'vigente';
INSERT INTO verificacion SELECT 'SC-42 vigente', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-42' AND estado = 'vigente';
INSERT INTO verificacion SELECT 'RF-12 vigente', COUNT(*) = 1 FROM entradas WHERE codigo = 'RF-12' AND estado = 'vigente';
INSERT INTO verificacion SELECT 'SC-56 ancla FUERA, una vez',
  (length(cuerpo) - length(replace(cuerpo, '- Cómo se genera el texto de la bibliografía para HTML y EPUB (pasada de tex4ht/make4ht con el mismo estilo): en diseño.', '')))
  / length('- Cómo se genera el texto de la bibliografía para HTML y EPUB (pasada de tex4ht/make4ht con el mismo estilo): en diseño.') = 1
  FROM entradas WHERE codigo = 'SC-56';
INSERT INTO verificacion SELECT 'SC-56 ancla pendiente, una vez', instr(pendiente, 'Sin implementar en la aplicación: depende del diseño de la pasada de tex4ht.') > 0 FROM entradas WHERE codigo = 'SC-56';

-- ------------------------------------------------------------
-- 2. SC-57
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 57, 'SC-57', 'Bibliografía de libro en HTML y EPUB: la arma biblatex con tex4ht, con el mismo estilo que el PDF (Verona)',
   'DECISIÓN CERRADA (decisión de Alberto). Libros con Verona. El texto de las citas y de las referencias que van a HTML y EPUB no lo escribe una hoja XSLT: lo escribe biblatex, con el mismo estilo y la misma configuración que el PDF, a través de tex4ht (make4ht). Es la forma más directa de cumplir SC-14: el estilo no se replica, se usa.

POR QUÉ

Lo difícil de un estilo autor-año no es la puntuación, es lo que calcula biber: el orden, la letra del año (2020a, 2020b), la unicidad de nombres y de listas (`uniquelist=minyear`). Las hojas actuales no lo hacen en ningún estilo: el «iso690» de `docbook-to-html.xsl` ni siquiera sigue a `iso-authoryear`. La CSL nunca formó una referencia: es la etiqueta del selector.

Se descartó bblxml de biber: trae el cálculo pero no el formato, y está declarado obsoleto desde biber 2.15 («será quitado en la versión 4»; sigue en 2.23).

MEDIDO con `ref-l-MOLINARO.bib` (222 entradas): las 222 referencias del HTML tienen el mismo texto que el PDF, y las citas del cuerpo y de las notas también; cada referencia tiene una cita que enlaza a ella; el HTML es XML bien formado.

LAS PIEZAS

1. `docbook-to-latex.xsl`, MODO NUEVO. Escribe un documento mínimo con el mismo preámbulo de estilo, los mismos `refsection` que el PDF y cada `biblioref` como `\gbcita{n}{\parencite...}`, con n su posición en el libro. Así las citas son las del PDF por construcción, sin una segunda lógica.
2. UN SCRIPT EN `engine/`. Corre make4ht sobre ese documento. Entrada: el mismo `.bib` del PDF, `referencias/ref-<proyecto>.bib`. Salida: `tmp/bib/html-libro-<nombre>` y `tmp/bib/epub-libro-<nombre>`, el mismo patrón que el código (SC-42). `referencias/` queda para los datos canónicos: make4ht deja además una docena de archivos auxiliares por corrida, y lo que se regenera en cada salida no se mezcla con la fuente.
3. `docbook-to-html.xsl` Y `docbook-to-epub.xsl`. Reciben el parámetro `bib_dir`. Cuentan los `biblioref` igual que el modo del punto 1 y toman cada cita por `gbcita-n` y cada referencia por sección y clave. Si falta un fragmento, cortan con un mensaje: no vuelven al XSLT viejo (GV-23).
4. EL CSS de las cuatro hojas: sangría francesa y `font-variant-caps: all-small-caps` para las versalitas (SC-56).
5. EL SELECTOR DE ESTILOS lista estilos biblatex, no archivos `.csl`.
6. LA CONFIGURACIÓN DE tex4ht viaja en `.hidden/latex/`, con las de estilo.

LA PASADA HTML USA LA MISMA CONFIGURACIÓN

Se carga `cita-veronaM-config.tex` y después un archivo propio del estilo, `cita-veronaM-html.tex`, con lo que cambia en pantalla:

    \ExecuteBibliographyOptions{backref=false,lowscauthors=false,dashed=false}
    \newcommand*{\gbImprimirBibliografia}{\printbibliography[heading=none,restoreclassic]}

Las tres opciones se aplican después de cargar biblatex (medido). `restoreclassic` no se puede fijar con `\DeclarePrintbibliographyDefaults` («keyval Error: restoreclassic undefined», medido). Por eso va en una macro que define cada estilo, y el modo nuevo emite siempre `\gbImprimirBibliografia`. Lo que es del estilo queda en el archivo del estilo, no en la hoja.

LA CONFIGURACIÓN DE tex4ht (medido)

- La cursiva de biblatex (`\emph`) sale como `<em>`; `\textsc`, como `<span class="versalitas-todas">`; el ordinal de babel-spanish (`n.º`), como punto y `<sup>`. `\bibfont` se vacía: sin eso, cada tamaño de letra da un `<span>` con el nombre de la fuente (`ec-lmr-9`).
- `\gbcita{n}{...}` sale como `<span id="gbcita-n">`. En el PDF no se usa.
- En babel-spanish `<` y `>` son activos: el marcado que inserta la configuración va con `\string<` y `\string>`. Sin eso: «Argument of \language@active@arg has an extra }».
- Las notas, en la misma página (`fn-in`): si no, cada nota sale en un archivo aparte.

LOS ID

tex4ht numera los `refsection` desde 1: `cite.1@clave`, `cite.2@clave`. Una obra citada en dos capítulos tiene dos destinos, uno por sección, como en el PDF. Con la consolidada hay una sola sección. La unión cita-referencia es por sección y clave, nunca solo por clave.

LÍMITE CONOCIDO

Con tex4ht, biblatex no detecta las notas al pie («Patching footnotes failed»). En Verona no importa: philosophy solo lo usa en `scauthors=citefn` y `bibcitefn`, y la configuración usa `scauthors=bib`. La cita dentro de una nota salió igual que en el PDF. Un estilo que se comporte distinto en las notas, como los verbose, no entra por este camino sin medirlo antes.

ALCANCE

Verona. Los demás estilos siguen con sus hojas hasta que se releven (SC-14: un estilo sin RF no se implementa), y cuando entren lo hacen por este mismo camino, con su archivo `-html.tex`.',
   'vigente', 'empirica',
   'biblatex 3.19 / biber 2.19 / biblatex-philosophy v1.9.8g / make4ht v0.3m / TeX Live 2023 / contenedor Ubuntu 24.04',
   '2026-10',
   'vinculo:SC-14,vinculo:SC-56,vinculo:SC-31,vinculo:SC-42,vinculo:RF-12,vinculo:GV-102,apoya:GV-23',
   'Sin implementar. Medido en el contenedor por partes: el texto contra el PDF, las opciones después de cargar, \gbImprimirBibliografia, \gbcita en el cuerpo y en una nota, los id por sección. Falta: el modo de docbook-to-latex.xsl, el script de engine/, las hojas de HTML y EPUB, el CSS, el selector; epubcheck 4.2.6 sobre un EPUB real; la prueba en Mint con un libro real.',
   570, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-57 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-57' AND orden = 570 AND estado = 'vigente';

-- ------------------------------------------------------------
-- 3. SC-56 REMITE A SC-57
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo,
         '- Cómo se genera el texto de la bibliografía para HTML y EPUB (pasada de tex4ht/make4ht con el mismo estilo): en diseño.',
         '- Cómo se genera el texto de la bibliografía para HTML y EPUB: lo arma biblatex con tex4ht (SC-57).'),
       pendiente = replace(pendiente,
         'Sin implementar en la aplicación: depende del diseño de la pasada de tex4ht.',
         'Sin implementar en la aplicación: va con SC-57.'),
       relaciones = relaciones || ',vinculo:SC-57',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-56';
INSERT INTO verificacion SELECT 'SC-56 actualizada', instr(cuerpo, 'con tex4ht (SC-57)') > 0 AND instr(cuerpo, 'en diseño.') = 0 AND instr(pendiente, 'va con SC-57') > 0 AND instr(relaciones, 'SC-57') > 0 FROM entradas WHERE codigo = 'SC-56';

-- ------------------------------------------------------------
-- 4. RELACIONES
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-57',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo IN ('SC-14', 'SC-42', 'RF-12', 'GV-102') AND instr(relaciones, 'SC-57') = 0;
INSERT INTO verificacion SELECT 'relaciones a SC-57', COUNT(*) = 4 FROM entradas WHERE codigo IN ('SC-14', 'SC-42', 'RF-12', 'GV-102') AND instr(relaciones, 'SC-57') > 0;

COMMIT;

SELECT codigo, estado, evidencia, orden, titulo FROM entradas WHERE codigo IN ('SC-57', 'SC-56') ORDER BY numero;
