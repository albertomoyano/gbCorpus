-- ============================================================
-- gbCorpus — actualización 36: Verona en HTML y EPUB; refsection=chapter
-- Esquema: 1
-- Origen: el script de Verona se entregó como act-35, el mismo número que
--         el act-35 de SC-55 y SC-20 que ya está en gbCorpus (commit
--         ab6c2c6). Este script lo reemplaza: NO aplicar aquel archivo. Si ya
--         se aplicó, este reconoce SC-56 y RF-12 y solo hace lo nuevo.
--         Lo nuevo:
--         - la configuración de Verona pasa a .hidden/latex/cita-veronaM-
--           config.tex, sin la línea comentada de refsection=chapter
--           (decisión de Alberto; gbpublisher, commit a0a5365);
--         - GV-102: refsection=chapter, medido en el contenedor con
--           cita-veronaM-config.tex y prueba-biber.bib.
--         Corregido después del primer intento en Mint: GV-101 ya estaba
--         ocupada en la base (hyperxmp, alta del 15/10, sin script en
--         gbCorpus). Cotejado contra una copia de
--         ~/.gbcorpus/corpus.sqlite: la entrada nueva pasa a GV-102.
-- Fecha:  2026-10-17
-- Aplicar: sqlite3 -bail ~/.gbcorpus/corpus.sqlite < gbcorpus-act-36.sql
--          (DESPUÉS DE act-35 de gbCorpus: SC-55 y SC-20)
--
-- ALTAS:
--   SC-56   Bibliografía con Verona en HTML y EPUB (si no está)
--   RF-12   Fuente de biblatex-philosophy (si no está)
--   GV-102  refsection=chapter con bibliografía consolidada deja solo el
--           último capítulo, sin aviso
-- MODIFICA:
--   SC-56, RF-12  la configuración es cita-veronaM-config.tex
--   SC-56   la configuración corregida no redefine \bibnamedash
--   RF-12   remite a GV-102
--   SC-25   la línea «EPUB sin versalitas» remite a SC-56 (si no lo hace)
--   SC-14   relaciones: SC-56, RF-12
--   SC-31   relaciones: SC-56
--   SC-55   relaciones: GV-102
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
-- SC-56 Y RF-12: AUSENTES, O PRESENTES PORQUE SE APLICÓ EL ACT-35 DE VERONA
INSERT INTO verificacion SELECT 'SC-56 libre o la de Verona', COUNT(*) = 0 OR (COUNT(*) = 1 AND MAX(titulo) = 'Bibliografía con Verona en HTML y EPUB: nombre en cada entrada, versalitas por CSS, tipografía con smcp y c2sc') FROM entradas WHERE codigo = 'SC-56' OR (prefijo = 'SC' AND numero = 56);
INSERT INTO verificacion SELECT 'última SC: 55, o 56 la de Verona', MAX(numero) = 55 OR (MAX(numero) = 56 AND EXISTS (SELECT 1 FROM entradas WHERE codigo = 'SC-56' AND titulo = 'Bibliografía con Verona en HTML y EPUB: nombre en cada entrada, versalitas por CSS, tipografía con smcp y c2sc')) FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'RF-12 libre o la de Verona', COUNT(*) = 0 OR (COUNT(*) = 1 AND MAX(titulo) = 'Fuente de biblatex-philosophy (Verona)') FROM entradas WHERE codigo = 'RF-12' OR (prefijo = 'RF' AND numero = 12);
INSERT INTO verificacion SELECT 'última RF: 11 o 12', MAX(numero) IN (11, 12) FROM entradas WHERE prefijo = 'RF';
INSERT INTO verificacion SELECT 'GV-102 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-102' OR (prefijo = 'GV' AND numero = 102);
INSERT INTO verificacion SELECT 'GV-101 es la última GV (hyperxmp)', MAX(numero) = 101 AND EXISTS (SELECT 1 FROM entradas WHERE codigo = 'GV-101' AND instr(titulo, 'hyperxmp') > 0) FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-14 vigente', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-14' AND estado = 'vigente';
INSERT INTO verificacion SELECT 'SC-31 vigente', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-31' AND estado = 'vigente';
INSERT INTO verificacion SELECT 'SC-55 vigente', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-55' AND estado = 'vigente';
-- SC-25: LA LÍNEA ORIGINAL UNA SOLA VEZ, O YA CON LA EXCEPCIÓN
INSERT INTO verificacion SELECT 'SC-25 línea de versalitas, una vez',
  (length(cuerpo) - length(replace(cuerpo, '- EPUB sin versalitas: los nombres van en mayúsculas y minúsculas, como están en la base. Noto Serif las tiene, pero los lectores de EPUB no las respetan de forma pareja.', ''))) / length('- EPUB sin versalitas: los nombres van en mayúsculas y minúsculas, como están en la base. Noto Serif las tiene, pero los lectores de EPUB no las respetan de forma pareja.') = 1
  FROM entradas WHERE codigo = 'SC-25' AND estado = 'vigente';

-- ------------------------------------------------------------
-- 2. SC-56 (SI NO ESTÁ)
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'SC', 56, 'SC-56', 'Bibliografía con Verona en HTML y EPUB: nombre en cada entrada, versalitas por CSS, tipografía con smcp y c2sc',
   'DECISIÓN CERRADA (decisión de Alberto). Libros con el estilo Verona: philosophy-modern con `cita-veronaM-config.tex`. Vale para HTML y EPUB; el PDF no cambia.

Es una excepción a SC-31 y la explica esta entrada. SC-14 se sigue cumpliendo: el texto de cada referencia lo arma el estilo, y cambia solo cómo se dispone el bloque del nombre y el año.

1. EL NOMBRE EN CADA ENTRADA (EXCEPCIÓN 2 DE SC-31)

philosophy-modern escribe el nombre una sola vez y apila debajo los años de sus obras, en una columna de ancho fijo (`\bibhang`). Es un recurso para leer en papel. En pantalla el ancho cambia y el lector elige el cuerpo de letra: la columna le quita ancho al texto y no ayuda a leer.

En HTML y EPUB va la disposición classic del mismo estilo: `\printbibliography[restoreclassic]` con `dashed=false`. Cada entrada lleva su nombre y el año entre paréntesis:

    Abós, Álvaro (1984), Las organizaciones sindicales y el poder militar (1976-1983), Buenos Aires: Centro Editor de América Latina.
    Abós, Álvaro (1986), El posperonismo, Buenos Aires: Editorial Legasa.

MEDIDO con `ref-l-MOLINARO.bib` (222 entradas): en todas, lo que sigue a «Nombre (año), » es el mismo texto que el PDF. Las letras del año se conservan (1988a y 1988b, 2023a y 2023b).

`\bibnamedash` no interviene. En modern el autor repetido no lleva guion: la macro `author` de `philosophy-modern.bbx` no imprime nada en `bbx:dashcheck`. El guion es de classic y verbose, y con `dashed=false` tampoco aparece. La redefinición de `\bibnamedash` en `cita-veronaM-config.tex` no actúa con modern.

2. VERSALITAS POR CSS, SOBRE EL TEXTO CON SU CAJA

En el PDF, `scauthorsbib` y `lowscauthors` dan `\textsc{\MakeLowercase{...}}`: el texto queda en minúscula y la fuente lo pone en versalitas. Llevado tal cual a HTML, un lector que no respete las versalitas mostraría «abdala, omar».

En HTML y EPUB va `lowscauthors=false`: el texto conserva sus mayúsculas, «Abdala, Omar», y las versalitas las pone el CSS con `font-variant-caps: all-small-caps` (CSS Fonts Module Level 3). Se ve como en el PDF. Si el lector ignora el CSS, el nombre degrada a mayúsculas y minúsculas, como está en la base. Es la razón de SC-25 y por eso la bibliografía de Verona puede llevar versalitas.

3. TIPOGRAFÍA: smcp Y c2sc

`all-small-caps` usa dos rasgos OpenType: `c2sc` para las mayúsculas y `smcp` para las minúsculas. Si la fuente no los trae, el navegador fabrica versalitas falsas achicando mayúsculas.

REGLA: para usar Verona en HTML y EPUB, la tipografía tiene que traer `smcp` y `c2sc`. La que entrega la aplicación los trae. Verificado por Alberto en Mint con `otfinfo -f /usr/share/gbpublisher/fonts/NotoSerif-Regular.ttf`, que lista `c2sc` y `smcp`. Quien cambie la tipografía lo comprueba con el mismo comando (`otfinfo`, paquete lcdf-typetools).

FUERA DE ESTA DECISIÓN

- Cómo se genera el texto de la bibliografía para HTML y EPUB (pasada de tex4ht/make4ht con el mismo estilo): en diseño.
- Los otros estilos (APA, ISO 690, IEEE, Vancouver).',
   'vigente', 'empirica',
   'biblatex-philosophy v1.9.8g / biber 2.19 / TeX Live 2023 / make4ht v0.3m / contenedor Ubuntu 24.04; Noto Serif de gbpublisher en Mint',
   '2026-10',
   'vinculo:SC-14,vinculo:SC-25,vinculo:SC-31,vinculo:RF-12',
   'Medido en el contenedor sobre el HTML que da make4ht: la disposición classic con dashed=false, el texto de las 222 entradas contra el PDF y el marcado de las versalitas con lowscauthors=false. Sin probar: cómo responden los lectores de EPUB a all-small-caps, y si degradan a mayúsculas y minúsculas como se espera. Sin implementar en la aplicación: depende del diseño de la pasada de tex4ht.',
   560, datetime('now','localtime'), datetime('now','localtime')
 WHERE NOT EXISTS (SELECT 1 FROM entradas WHERE codigo = 'SC-56');
INSERT INTO verificacion SELECT 'SC-56 presente', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-56' AND estado = 'vigente';

-- ------------------------------------------------------------
-- 3. RF-12 (SI NO ESTÁ)
-- ------------------------------------------------------------
-- EL ORDEN SIGUE AL DE LA ÚLTIMA RF, SEA CUAL SEA SU VALOR
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'RF', 12, 'RF-12', 'Fuente de biblatex-philosophy (Verona)',
  'Paquete en CTAN: `macros/latex/contrib/biblatex-contrib/biblatex-philosophy`. Autor: Ivan Valbusa.

VERSIÓN ANCLADA

v1.9.8g (2022/09/16). Es la de CTAN y la de TeX Live 2023 (`texlive-bibtex-extra`), que es lo que trae la base de Mint 22. Biber 2.19 en la máquina de Alberto y en el contenedor.

ACCESO

`https://mirrors.ctan.org/macros/latex/contrib/biblatex-contrib/biblatex-philosophy.zip` descarga con `curl -L`. Algún espejo puede responder con un certificado vencido: se reintenta y la redirección lleva a otro. Con TeX Live instalado, los archivos ya están en `texmf-dist/tex/latex/biblatex-philosophy/`.

ORDEN DE CONSULTA

1. `philosophy-modern.bbx` — referencias de la disposición modern. Carga `philosophy-classic.bbx`.
2. `philosophy-classic.bbx` — la disposición classic, la de HTML y EPUB (SC-56). Carga `philosophy-standard.bbx`.
3. `philosophy-standard.bbx` — opciones del estilo, formatos de campo, relaciones (`related`), campos `orig*`.
4. `philosophy-modern.cbx` — citas.
5. `spanish-philosophy.lbx` — cadenas en español.
6. `biblatex-philosophy.dtx` — fuente documentado del que salen los anteriores. Informa la intención; si contradice al código instalado, gana el código.

La configuración de la aplicación: `.hidden/latex/cita-veronaM-config.tex`.

DATOS DEL FUENTE QUE USA EL PROYECTO

- `\printbibliography[restoreclassic]` (definida en `philosophy-modern.bbx`) vuelve a la disposición classic: `\bibhang` igual a `\parindent`, año entre paréntesis después del nombre, guion de autor repetido según `dashed`.
- En modern el autor repetido no lleva guion: `bbx:dashcheck` no imprime nada. `\bibnamedash` solo actúa en classic y verbose.
- `lowscauthors` hace que `\mkbibsc` sea `\textsc{\MakeLowercase{#1}}`.
- `scauthorsbib` está declarada por compatibilidad: la forma vigente es `scauthors=bib`.
- Los campos `orig*` y la opción `origfields` también son compatibilidad: el mecanismo vigente es `related`. La macro `transorigstring` que redefine la configuración pertenece al mecanismo viejo.

BANCO DE PRUEBAS

`ref-l-MOLINARO.bib` (222 entradas: 81 book, 73 article, 58 incollection, 8 thesis, 2 misc), más casos de choque: mismo autor y año, dos autores con el mismo apellido, listas que coinciden en el primer autor. Compilado con la configuración de la aplicación, es la salida esperada contra la que se verifican HTML y EPUB.',
  'vigente', 'empirica',
  'biblatex-philosophy v1.9.8g (2022/09/16) / biber 2.19 / TeX Live 2023 / contenedor Ubuntu 24.04',
  '2026-10',
  'vinculo:SC-14,vinculo:SC-56,vinculo:RC-BL-02,vinculo:GV-102',
  'Falta fijar dónde se guarda el banco de pruebas: el .bib de Molinaro y el de los casos de choque.',
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
FROM entradas WHERE prefijo = 'RF'
HAVING NOT EXISTS (SELECT 1 FROM entradas WHERE codigo = 'RF-12');
INSERT INTO verificacion SELECT 'RF-12 presente', COUNT(*) = 1 FROM entradas WHERE codigo = 'RF-12' AND estado = 'vigente';

-- ------------------------------------------------------------
-- 4. SC-56 Y RF-12: LA CONFIGURACIÓN ES cita-veronaM-config.tex
-- ------------------------------------------------------------
-- NO HACE NADA SI LAS ENTRADAS SE DIERON DE ALTA EN ESTE SCRIPT
UPDATE entradas
   SET cuerpo = replace(replace(cuerpo,
         '`.hidden/biblatex/biblatex-veronaM-config.tex`', '`.hidden/latex/cita-veronaM-config.tex`'),
         '`biblatex-veronaM-config.tex`', '`cita-veronaM-config.tex`'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo IN ('SC-56', 'RF-12') AND instr(cuerpo, 'biblatex-veronaM-config.tex') > 0;
-- LA CONFIGURACIÓN CORREGIDA YA NO REDEFINE \bibnamedash
UPDATE entradas
   SET cuerpo = replace(cuerpo,
         'La redefinición de `\bibnamedash` en `cita-veronaM-config.tex` no actúa con modern.',
         'Por eso `cita-veronaM-config.tex` no redefine `\bibnamedash`.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-56' AND instr(cuerpo, 'La redefinición de `\bibnamedash`') > 0;
INSERT INTO verificacion SELECT 'SC-56 sin la redefinición de bibnamedash', instr(cuerpo, 'La redefinición de `\bibnamedash`') = 0 AND instr(cuerpo, 'no redefine `\bibnamedash`') > 0 FROM entradas WHERE codigo = 'SC-56';
INSERT INTO verificacion SELECT 'sin la ruta vieja', COUNT(*) = 0 FROM entradas WHERE codigo IN ('SC-56', 'RF-12') AND instr(cuerpo, 'biblatex-veronaM-config.tex') > 0;
INSERT INTO verificacion SELECT 'RF-12 con la ruta nueva', instr(cuerpo, '`.hidden/latex/cita-veronaM-config.tex`') > 0 FROM entradas WHERE codigo = 'RF-12';

-- ------------------------------------------------------------
-- 5. SC-25: LA LÍNEA DE VERSALITAS REMITE A SC-56 (SI NO LO HACE)
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, '- EPUB sin versalitas: los nombres van en mayúsculas y minúsculas, como están en la base. Noto Serif las tiene, pero los lectores de EPUB no las respetan de forma pareja.',
         '- EPUB sin versalitas: los nombres van en mayúsculas y minúsculas, como están en la base. Noto Serif las tiene, pero los lectores de EPUB no las respetan de forma pareja. Excepción: la bibliografía con Verona lleva versalitas por CSS sobre el texto con su caja original, que degrada a mayúsculas y minúsculas si el lector no las respeta (SC-56).'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-25' AND instr(cuerpo, 'Excepción: la bibliografía con Verona') = 0;
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-56',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-25' AND instr(relaciones, 'SC-56') = 0;
INSERT INTO verificacion SELECT 'SC-25 actualizada', instr(cuerpo, 'Excepción: la bibliografía con Verona') > 0 AND instr(relaciones, 'SC-56') > 0 FROM entradas WHERE codigo = 'SC-25';

-- ------------------------------------------------------------
-- 6. SC-14 Y SC-31 REMITEN A SC-56 Y RF-12 (SI NO LO HACEN)
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-56,vinculo:RF-12',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-14' AND instr(relaciones, 'SC-56') = 0;
INSERT INTO verificacion SELECT 'SC-14 relaciones', instr(relaciones, 'SC-56') > 0 AND instr(relaciones, 'RF-12') > 0 FROM entradas WHERE codigo = 'SC-14';

UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-56',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-31' AND instr(relaciones, 'SC-56') = 0;
INSERT INTO verificacion SELECT 'SC-31 relaciones', instr(relaciones, 'SC-56') > 0 FROM entradas WHERE codigo = 'SC-31';

-- ------------------------------------------------------------
-- 7. GV-102
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 102, 'GV-102', 'biblatex: refsection=chapter con bibliografía consolidada deja solo el último capítulo, sin aviso',
   'La opción de carga `refsection=chapter` abre una sección bibliográfica nueva en cada `\chapter`. Un `\printbibliography` al final del libro imprime solo la sección en curso, que es la del último capítulo.

Medido con `cita-veronaM-config.tex` y dos capítulos, una cita en cada uno (Falco en el 1, Amelang en el 2):

    modo                                       sin la opción          con refsection=chapter
    por capítulo, como lo arma la aplicación   Falco / Amelang        igual
    consolidada, \printbibliography final      Amelang y Falco        solo Amelang

En la consolidada se pierden las referencias de todos los capítulos menos el último. No hay error y el log no trae ningún «biblatex Warning». Es la versión biblatex de GV-23: compila y da un libro equivocado.

En el modo por capítulo la opción no cambia nada, porque ya lo resuelve el generador. `docbook-to-latex.xsl` envuelve en `\begin{refsection}`…`\end{refsection}` cada pieza que trae `<bibliography>`. El canónico la trae solo cuando `libros_md.lugar_bibliografia` es `por_capitulo`.

CONSECUENCIA: la bibliografía por capítulo la arma el generador, nunca una opción del estilo. Las configuraciones de `.hidden/latex/` no llevan `refsection=chapter`, ni siquiera comentada: comentada, invita a activarla. Decisión de Alberto.

Para tex4ht (SC-56): el documento mínimo que genere `docbook-to-latex.xsl` tiene los mismos `refsection` que el PDF. Los id de tex4ht llevan el número de sección: `cite.0@clave`, `cite.1@clave`.',
   'vigente', 'empirica',
   'biblatex 3.19 (2023/03/05) / biber 2.19 / biblatex-philosophy v1.9.8g / LuaLaTeX, TeX Live 2023 / contenedor Ubuntu 24.04',
   '2026-10',
   'vinculo:SC-55,vinculo:RF-12,apoya:GV-23',
   NULL,
   1020, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-102 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-102' AND orden = 1020 AND estado = 'vigente';

-- ------------------------------------------------------------
-- 8. RF-12 Y SC-55 REMITEN A GV-102
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, '- Los campos `orig*` y la opción `origfields` también son compatibilidad: el mecanismo vigente es `related`. La macro `transorigstring` que redefine la configuración pertenece al mecanismo viejo.', '- Los campos `orig*` y la opción `origfields` también son compatibilidad: el mecanismo vigente es `related`. La macro `transorigstring` que redefine la configuración pertenece al mecanismo viejo.
- `refsection=chapter` no se usa: la bibliografía por capítulo la arma el generador, y con la consolidada la opción vacía la lista en silencio (GV-102). La configuración de la aplicación no la trae.'),
       relaciones = CASE WHEN instr(relaciones, 'GV-102') = 0 THEN relaciones || ',vinculo:GV-102' ELSE relaciones END,
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'RF-12' AND instr(cuerpo, 'GV-102') = 0;
INSERT INTO verificacion SELECT 'RF-12 remite a GV-102', instr(cuerpo, '(GV-102)') > 0 AND instr(relaciones, 'GV-102') > 0 FROM entradas WHERE codigo = 'RF-12';

UPDATE entradas
   SET relaciones = relaciones || ',vinculo:GV-102',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-55' AND instr(relaciones, 'GV-102') = 0;
INSERT INTO verificacion SELECT 'SC-55 relaciones', instr(relaciones, 'GV-102') > 0 FROM entradas WHERE codigo = 'SC-55';

COMMIT;

SELECT codigo, estado, evidencia, orden, titulo FROM entradas WHERE codigo IN ('SC-56', 'RF-12', 'GV-102', 'SC-25', 'SC-14', 'SC-31', 'SC-55') ORDER BY prefijo, numero;
