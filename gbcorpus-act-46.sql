-- ============================================================
-- gbCorpus — actualización 46: IEEE entra por tex4ht (RF-14); las cadenas
--            en castellano comunes a todos los estilos (SC-59, GV-106)
-- Esquema: 1
-- Origen: medición en el contenedor con el libro de Duek, contra el PDF que
--         Alberto compuso en Mint con IEEE (l-DUEK.pdf, 17/10); relevamiento
--         de biblatex-ieee (instalado v1.3f y repositorio, commit ea2ebc7);
--         banco de cadenas con los cuatro estilos. Decisiones de Alberto
--         (17/10): sangría por la etiqueta más ancha (opción b), «presentado
--         en», archivo común de cadenas (camino 1), «Tesis de Doctorado» en
--         Verona y las erratas. Numerado contra la base de Alberto
--         (~/.gbcorpus/corpus.sqlite, 17/10, con act-45 aplicado).
-- Fecha:  2026-10-17
-- Aplicar: después de act-45
--
-- ALTAS:
--   RF-14   Fuente de biblatex-ieee (IEEE)
--   SC-59   Cadenas en castellano comunes a todos los estilos de biblatex
--   GV-106  Una cadena sin traducción sale en negrita; un editortype sin
--           cadena, tal cual
-- MODIFICA:
--   SC-57   título, la regla de las etiquetas, la sección IEEE y el alcance
--   SC-58   pendiente: las comillas de IEEE ya no se pierden
--   SC-14   relación con RF-14
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'act-45 aplicado', instr(cuerpo, 'EL ESTILO EN EL CANÓNICO DE CADA PIEZA') > 0 FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'RF-14 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'RF-14' OR (prefijo = 'RF' AND numero = 14);
INSERT INTO verificacion SELECT 'SC-59 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-59' OR (prefijo = 'SC' AND numero = 59);
INSERT INTO verificacion SELECT 'GV-106 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-106' OR (prefijo = 'GV' AND numero = 106);
INSERT INTO verificacion SELECT 'RF-13 última RF', MAX(numero) = 13 FROM entradas WHERE prefijo = 'RF';
INSERT INTO verificacion SELECT 'SC-58 última SC', MAX(numero) = 58 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-105 última GV', MAX(numero) = 105 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-57 título', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-57'
  AND titulo = 'Bibliografía de libro en HTML y EPUB: la arma biblatex con tex4ht, con el mismo estilo que el PDF (Verona, APA, ISO 690)';
INSERT INTO verificacion SELECT 'SC-57 ancla etiquetas', instr(cuerpo, ' y una bibliografía con etiquetas en el `<dt>` (estilo numérico o alfabético, no medido por este camino).') > 0 FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'SC-57 ancla ALCANCE', instr(cuerpo, 'ALCANCE

Verona, APA e ISO 690. Los demás estilos siguen') > 0 FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'SC-58 ancla del pendiente', instr(pendiente, 'En las hojas de HTML y EPUB, las plantillas por estilo (hoy solo las de IEEE, que todavía no va por tex4ht) leen el título con normalize-space y pierden las comillas de un <quote>: se resuelve cuando IEEE pase por tex4ht.') > 0 FROM entradas WHERE codigo = 'SC-58';

-- ------------------------------------------------------------
-- 2. RF-14
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('RF', 14, 'RF-14', 'Fuente de biblatex-ieee (IEEE)',
   'Repositorio: https://github.com/josephwright/biblatex-ieee. Paquete en CTAN: `macros/latex/contrib/biblatex-contrib/biblatex-ieee`. Autor: Joseph Wright.

VERSIÓN ANCLADA

v1.3f (2021/12/06). Es la de TeX Live 2023, la que compone en Mint 22 y en el contenedor. La aplicación usa `style=ieee`.

EL REPOSITORIO YA ES OTRO

El repositorio (commit ea2ebc7, 2026-01-21) trae v1.4f (2025-08-01), y cambia lo que se ve:

- `ieee.cbx` pasa de `numeric-comp` a `numeric-verb`; la compresión queda en un archivo nuevo, `ieee-comp.cbx`.
- `ieee.cbx` pasa de `maxcitenames=3, minnames=3` a `maxcitenames=2, minnames=1`, y agrega `sortcites`. En v1.3f el `minnames=3` del cbx pisa el `minnames=1` del bbx, porque se ejecuta después: por eso el PDF de Duek pone tres nombres antes de «et al.» («G. Krichesky, P. Pogré, K. Benchimol et al.»). Con v1.4f sería uno.
- `ieee.bbx`: 115 líneas de diferencia.

Una actualización de TeX Live cambia las citas y las referencias de un libro ya compuesto: hay que medir antes de actualizar.

ACCESO

`git clone --depth 1 https://github.com/josephwright/biblatex-ieee.git` funciona. Con TeX Live instalado, los archivos ya están en `texmf-dist/tex/latex/biblatex-ieee/`.

ORDEN DE CONSULTA

1. `ieee.bbx` — formatos de campo, cadenas propias, opciones. Requiere `numeric-comp`. Fuente de verdad del comportamiento.
2. `ieee.cbx` — citas. En v1.3f, sobre `numeric-comp.cbx` de biblatex, con `sorting=none`: las referencias se numeran en el orden de cita.
3. `biblatex-ieee.tex` y su PDF — documentación. Informa la intención; si contradice al código, gana el código.

La configuración de la aplicación: `.hidden/latex/cita-ieee-config.tex`; la de pantalla, `cita-ieee-html.tex`.

BANCO DE PRUEBAS

`biblatex-ieee.bib`, en el repositorio.

DATOS DEL FUENTE QUE USA EL PROYECTO

- Cadenas propias: `ieee.bbx` declara `presentedat` y `patentjp` y las define solo en inglés. En castellano salen en negrita (GV-106); `cita-ieee-config.tex` las define (SC-59).
- La numeración vuelve a 1 en cada `refsection`: en un libro, en cada pieza con bibliografía, como en el PDF.
- Citas: `\iffootnote` solo aparece en `\smartcite` (de `numeric-comp.cbx`), que la aplicación no emite. La detección de notas que tex4ht no responde no afecta a IEEE (SC-57).
- Una cita con varias claves sale con un corchete por clave («[1], [2]») y un rango con tres o más seguidas («[22]-[24]»).',
   'vigente', 'empirica',
   'biblatex-ieee v1.3f (2021/12/06) / repositorio, commit ea2ebc7 (v1.4f) / biblatex 3.19 / TeX Live 2023 / contenedor Ubuntu 24.04; PDF de Duek en Mint',
   '2026-10',
   'vinculo:SC-14,vinculo:SC-57,vinculo:SC-59,vinculo:GV-106',
   NULL,
   140, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'RF-14 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'RF-14' AND orden = 140;

-- ------------------------------------------------------------
-- 3. GV-106
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 106, 'GV-106', 'biblatex: una cadena sin traducción sale en negrita; un editortype, un type o un pubstate sin cadena, tal cual',
   'Dos comportamientos distintos de biblatex ante una cadena que falta en el idioma del libro:

1. Una cadena DECLARADA (`\NewBibliographyString`) y sin definir en ese idioma: biblatex imprime la clave en negrita y avisa en el `.log` («Package biblatex Warning: Bibliography string ''presentedat'' untranslated»). MEDIDO en el PDF de Duek con IEEE: «presentedatX Congreso…». Bajo tex4ht la negrita llega como `<span class="ec-lmbx-10">`, que no está en la lista cerrada de `cita-fragmentos.xsl`: la hoja corta (SC-57, GV-23).

2. El valor de `editortype`, `type` o `pubstate` que no es una cadena DECLARADA: biblatex imprime el código tal cual y no avisa. MEDIDO con IEEE: «J. Marcus, coordinator», «C. Kaplan, direction», «Tesis…» como «gradothesis»; con ISO 690, los catorce tipos de tesis del catálogo que su configuración no tenía; con Verona e IEEE, «self-published».

El segundo es el peligroso: no hay aviso, y el PDF sale. Por eso los códigos del catálogo de la aplicación tienen su cadena en un archivo común a todos los estilos (SC-59).

`\NewBibliographyString` con una cadena que ya existe no hace nada; una clave con guion (`self-published`) es válida (medido).',
   'vigente', 'empirica',
   'biblatex 3.19 / biblatex-ieee v1.3f / biblatex-iso690 v0.4.1 / biblatex-philosophy / LuaLaTeX / contenedor Ubuntu 24.04; PDF de Duek en Mint',
   '2026-10',
   'vinculo:SC-59,vinculo:SC-57,vinculo:RF-14,apoya:GV-23',
   NULL,
   1060, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-106 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-106' AND orden = 1060;

-- ------------------------------------------------------------
-- 4. SC-59
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 59, 'SC-59', 'Cadenas en castellano comunes a todos los estilos de biblatex: cita-cadenas-es.tex',
   'Las cadenas de biblatex se reparten en dos clases (decisión de Alberto, 17/10):

A. LAS QUE NI biblatex (`spanish.lbx`) NI EL ESTILO TRAEN. Son la traducción de los códigos del catálogo de la aplicación (tabla `cmb_biblatex`: `editor_type`, `thesis_type`, `pubstate`) y los agregados de la editorial (cine, `\sq`, `\sqq`, `documentjob`, `origpubbare`). Van en `.hidden/latex/cita-cadenas-es.tex`, uno solo para todos los estilos. Una cadena así solo aparece si una entrada la usa: en un estilo que no la necesita no cambia nada.

B. LAS QUE `spanish.lbx` YA TRAE Y UN ESTILO REDEFINE (meses, `url`, `urlseen`, `phdthesis`, `compiler`, `nodate`…). Son decisiones de cada estilo y quedan en su `cita-<estilo>-config.tex`. MEDIDO: las de Verona aplicadas a IEEE cambian «comp.» por «compilador», «dirección:» por «recuperado de:» y «oct.» por «octubre».

Las cadenas propias de un estilo (`presentedat` y `patentjp` de IEEE, RF-14) van en su config.

QUIÉN LO CARGA

El que carga el estilo, inmediatamente después de `cita-<estilo>-config.tex` (`\NewBibliographyString` exige biblatex cargado): `preambulo-contrato.tex` (PDF de libros) y el documento mínimo de `preparar_citas_libro.sh` (pasada de tex4ht), por nombre; `m_XML.ObtenerPreambuloEmbebido` (revistas), con ruta absoluta. No lo carga el config: `\input` resuelve contra la carpeta de la compilación, no contra la del archivo que lo pide, y en revistas el config se carga por ruta absoluta desde otra carpeta. Sin biblatex (vancouver, que va por bibtex) el archivo termina sin definir nada.

Llega al proyecto con `CopiarRecursosLatex`, que copia todos los `.tex` de `~/.gbpublisher/latex/`; `preparar_citas_libro.sh` lo copia a la carpeta de la pasada y corta si falta.

LOS CÓDIGOS DEL CATÁLOGO SON EL CONTRATO

Antes de este lote cada config tenía su lista, y se habían separado: ISO 690 usaba claves propias (`licenciaturathesis`, `tifthesis`, `organizator`…) que el catálogo no ofrece, y no tenía catorce de las que sí ofrece. El código `self-published` del catálogo no tenía cadena en ningún estilo (la configuración traía `edauthor`). Las claves heredadas de ISO 690 quedan como alias, para un `.bib` escrito a mano.

ERRATAS CORREGIDAS EN EL MISMO LOTE

- Verona: `phdthesis` dice «Tesis de Doctorado», como ISO 690 (decisión de Alberto).
- ISO 690: «con introdución de» → «con introducción de»; `prepublished` estaba dos veces; `bytranslatorfo` va en su propio bloque con `\makeatletter`, como en Verona: dentro del bloque general `\lbx@lfromlang` se leía `\lbx` seguido de texto.

MEDIDO en el contenedor con el `.bib` de Duek y un banco de 50 entradas (todos los códigos del catálogo, una traducción con prólogo e introducción, un congreso, una obra sin fecha, `\sq` y `\sqq`), antes y después, en los cuatro estilos de libro:
- Verona: un solo cambio, «Tesis Doctoral» → «Tesis de Doctorado».
- ISO 690: los catorce tipos de tesis que salían como código salen traducidos.
- APA: los tipos de tesis salen traducidos; `\sq` y `\sqq`, que no estaban definidos, funcionan.
- IEEE: «coord.», «coords.», «dir.», «dirs.», los tipos de tesis, «mimeo», «fotocopia», «impresión digital», «presentado en», `\sq` y `\sqq`.
- Ningún error ni cadena sin traducir en el `.log` de los cuatro.

Con `\sq` la postnota deja de ser un número y biblatex no le antepone «p.» ni «pág.» («25 y sig.»): es el comportamiento de biblatex, el mismo que ya tenía Verona.',
   'vigente', 'empirica',
   'biblatex 3.19 / biblatex-philosophy / biblatex-apa / biblatex-iso690 v0.4.1 / biblatex-ieee v1.3f / LuaLaTeX / contenedor Ubuntu 24.04',
   '2026-10',
   'vinculo:SC-14,vinculo:SC-57,vinculo:RF-09,vinculo:RF-12,vinculo:RF-13,vinculo:RF-14,vinculo:GV-106',
   'Falta la prueba en Mint: el PDF de un libro con cada estilo y una revista. La diferencia de `nodate` entre Verona («s/f») e ISO 690 («sin fecha») queda como decisión de cada estilo, sin revisar.',
   590, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-59 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-59' AND orden = 590;

-- ------------------------------------------------------------
-- 5. SC-57: IEEE
-- ------------------------------------------------------------
UPDATE entradas
   SET titulo = 'Bibliografía de libro en HTML y EPUB: la arma biblatex con tex4ht, con el mismo estilo que el PDF (Verona, APA, ISO 690, IEEE)',
       cuerpo = replace(replace(cuerpo,
         ' y una bibliografía con etiquetas en el `<dt>` (estilo numérico o alfabético, no medido por este camino).',
         ' y una bibliografía cuyas etiquetas no son las del estilo: `[n]` en cada `<dt>` en un estilo numérico (`gbct:estilo-numerico`, hoy solo IEEE), ninguna en un autor-año.'),
         'ALCANCE

Verona, APA e ISO 690. Los demás estilos siguen',
         'IEEE

`cita-ieee-html.tex` no cambia nada: solo define `\gbImprimirBibliografia` como `\printbibliography[heading=none]`. RF-14.

La etiqueta `[n]` de cada entrada llega en el `<dt>` de `citas.html` y sale como `span.ref-numero`, la marca del camino por plantillas. Sangría (decisión de Alberto, opción b): la etiqueta ocupa una columna del ancho de la más ancha de su lista (`ref-etiqueta-1`, `-2` o `-3`, por las cifras) y todas las líneas del texto arrancan después, como en `thebibliography` del PDF. Columnas de 1,8, 2,4 y 3 em: anchos medidos en Chromium, con IBM Plex Sans Bold en el panel del HTML y Noto Serif Bold en el EPUB. La hoja descarta el salto de línea con que tex4ht abre cada `<dd>`: detrás de la etiqueta se veía como un espacio y corría la primera línea.

MEDIDO con el libro de Duek, contra el PDF que Alberto compuso en Mint con IEEE: las 132 citas de `citas.html` tienen el texto del PDF; de las 113 referencias, 102 son iguales, diez difieren solo por la extracción del PDF (guiones de URL al cortar la línea, una URL partida por el cambio de página) y una por la cadena `presentedat` sin traducir del PDF (GV-106, SC-59). Alineación medida en Chromium: en todas las entradas de varias líneas, la segunda arranca donde arranca el texto de la primera. HTML: vnu sin errores. EPUB: epubcheck 4.2.6 sin errores. ISO 690 por el mismo camino: la salida no cambia salvo espacios en blanco.

El camino viejo por plantillas numeraba IEEE de corrido en todo el libro («[20, p. 47]» donde el PDF dice «[1, p. 47]»): por tex4ht la numeración vuelve a 1 en cada pieza, como en el PDF.

ALCANCE

Verona, APA, ISO 690 e IEEE. Los demás estilos siguen'),
       relaciones = relaciones || ',vinculo:RF-14,vinculo:SC-59',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-57';
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:RF-14'
 WHERE codigo = 'SC-14' AND instr(relaciones, 'RF-14') = 0;
INSERT INTO verificacion SELECT 'SC-57 con IEEE',
  instr(titulo, '(Verona, APA, ISO 690, IEEE)') > 0 AND instr(cuerpo, 'cita-ieee-html.tex') > 0
  AND instr(cuerpo, 'no medido por este camino') = 0 AND instr(cuerpo, 'Verona, APA, ISO 690 e IEEE. Los demás') > 0
  AND instr(relaciones, 'RF-14') > 0 AND instr(relaciones, 'SC-59') > 0
  FROM entradas WHERE codigo = 'SC-57';
INSERT INTO verificacion SELECT 'SC-14 con RF-14', instr(relaciones, 'RF-14') > 0 FROM entradas WHERE codigo = 'SC-14';

-- ------------------------------------------------------------
-- 6. SC-58: EL PENDIENTE DE IEEE
-- ------------------------------------------------------------
UPDATE entradas
   SET pendiente = replace(pendiente,
         'En las hojas de HTML y EPUB, las plantillas por estilo (hoy solo las de IEEE, que todavía no va por tex4ht) leen el título con normalize-space y pierden las comillas de un <quote>: se resuelve cuando IEEE pase por tex4ht.',
         'Resuelto en act-46: IEEE va por tex4ht y las comillas salen de biblatex. Las plantillas por estilo de las hojas (las que leen el título con normalize-space y pierden las comillas de un <quote>) solo quedan para un libro sin la pasada de citas.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-58 pendiente', instr(pendiente, 'Resuelto en act-46') > 0 FROM entradas WHERE codigo = 'SC-58';

COMMIT;

SELECT codigo, estado, orden, titulo FROM entradas WHERE codigo IN ('RF-14', 'SC-57', 'SC-59', 'GV-106') ORDER BY codigo;
