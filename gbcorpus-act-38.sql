-- ============================================================
-- gbCorpus — actualización 38: SC-57 implementada (citas y referencias de
--            libro en HTML y EPUB desde biblatex), nombres de archivo de
--            Verona, dos comportamientos verificados
-- Esquema: 1
-- Origen: lote del selector de estilos y de la pieza 3 de SC-57. Pruebas en
--         el contenedor (Ubuntu 24.04, TeX Live 2023, biber 2.19, make4ht
--         v0.3m, Saxon-HE 12.9, Gambas 3.19, epubcheck 4.2.6, vnu 20.6.30)
--         con el libro de Duek. Numerado contra la base de Alberto
--         (~/.gbcorpus/corpus.sqlite, 17/10) y gbpublisher/docs/corpus.md.
-- Fecha:  2026-10-17
-- Aplicar: después de act-37
--
-- ALTAS:
--   GV-103  Gambas Like: la clase negada es [^…]; [!…] no niega
--   GV-104  IBM Plex Sans no trae smcp ni c2sc; Noto Serif sí
-- MODIFICA:
--   SC-56, RF-12, GV-102, SC-57  cita-veronaM-*.tex → cita-verona-modern-*.tex
--   SC-57  cuerpo reescrito con lo implementado; pendiente; relaciones
--   SC-56  relación con GV-104
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-103 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-103' OR (prefijo = 'GV' AND numero = 103);
INSERT INTO verificacion SELECT 'GV-104 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-104' OR (prefijo = 'GV' AND numero = 104);
INSERT INTO verificacion SELECT 'GV-102 es la última GV', MAX(numero) = 102 FROM entradas WHERE prefijo = 'GV';
-- ACT-37 APLICADO
INSERT INTO verificacion SELECT 'SC-57 vigente (act-37)', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-57' AND estado = 'vigente';
INSERT INTO verificacion SELECT 'SC-56 vigente', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-56' AND estado = 'vigente';
-- LOS NOMBRES VIEJOS: ESTÁN EN ESTAS CUATRO ENTRADAS Y EN NINGUNA OTRA
INSERT INTO verificacion SELECT 'veronaM solo en SC-56, RF-12, GV-102, SC-57',
  COUNT(*) = 4 AND SUM(codigo IN ('SC-56', 'RF-12', 'GV-102', 'SC-57')) = 4
  FROM entradas WHERE instr(cuerpo || titulo || ifnull(pendiente, '') || ifnull(entorno, ''), 'veronaM') > 0;
INSERT INTO verificacion SELECT 'SC-57 ancla del cuerpo', instr(cuerpo, 'LAS PIEZAS') > 0 AND instr(cuerpo, '1. `docbook-to-latex.xsl`, MODO NUEVO.') > 0 FROM entradas WHERE codigo = 'SC-57';

-- ------------------------------------------------------------
-- 2. NOMBRES DE ARCHIVO DE VERONA
-- ------------------------------------------------------------
-- DECISIÓN DE ALBERTO: cita-verona-modern-config.tex, PARA QUE EL NOMBRE
-- DIGA EL ESTILO (philosophy-modern). EL IDENTIFICADOR DEL ESTILO EN LA
-- BASE ES verona-modern
UPDATE entradas
   SET cuerpo = replace(replace(cuerpo,
                  'cita-veronaM-config.tex', 'cita-verona-modern-config.tex'),
                  'cita-veronaM-html.tex', 'cita-verona-modern-html.tex'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo IN ('SC-56', 'RF-12', 'GV-102');
INSERT INTO verificacion SELECT 'nombres corregidos en SC-56, RF-12, GV-102',
  COUNT(*) = 3 FROM entradas WHERE codigo IN ('SC-56', 'RF-12', 'GV-102')
  AND instr(cuerpo, 'veronaM') = 0 AND instr(cuerpo, 'cita-verona-modern-config.tex') > 0;

-- ------------------------------------------------------------
-- 3. GV-103
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 103, 'GV-103', 'Gambas Like: la clase negada es [^…]; [!…] no niega',
   'En un patrón de `Like`, la clase de caracteres negada se escribe con circunflejo: `[^a-z]`. La forma con signo de exclamación, `[!a-z]`, que es la del glob de bash y la de Visual Basic, NO niega: Gambas la lee como una clase que contiene el propio `!` y el rango.

MEDIDO con `gbs3`:

    "abc"  Like "*[!a-z]*"    True     (cualquier letra entra en la clase)
    "abc"  Like "*[^a-z]*"    False
    "a/b"  Like "*[^a-z]*"    True

El error no da aviso: el patrón compila y responde, con el resultado contrario al esperado. Un control de forma escrito con `[!…]` deja pasar todo. Así pasaba en el primer borrador de `m_GenerarSalidasLibro.EstiloLibroExiste`, que tiene que rechazar un identificador con `/` o `..` antes de armar una ruta: con `[!a-z0-9-]` aceptaba `a/b` y `../x`.

REGLA: en `Like`, la negación va con `[^…]`. Si la línea existe por esta entrada, citarla.

Es otra de las diferencias con Visual Basic que rompen código (CONTEXTO, punto 4).',
   'vigente', 'empirica',
   'Gambas 3.19.0 (gbs3) / contenedor Ubuntu 24.04',
   '2026-10',
   'vinculo:SC-57,apoya:GV-23',
   'Medido en Gambas 3.19. Repetir en Mint con la versión instalada, con este script de gbs3: Print "abc" Like "*[!a-z]*", "abc" Like "*[^a-z]*" — tiene que dar True y False.',
   1030, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-103 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-103' AND orden = 1030;

-- ------------------------------------------------------------
-- 4. GV-104
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 104, 'GV-104', 'IBM Plex Sans no trae smcp ni c2sc; Noto Serif sí',
   'Las versalitas de la bibliografía de Verona en HTML y EPUB las pone el CSS con `font-variant-caps: all-small-caps`, que usa los rasgos OpenType `smcp` y `c2sc` (SC-56). Sin ellos el navegador fabrica versalitas falsas achicando mayúsculas.

MEDIDO con fontTools sobre las fuentes de `.hidden/fonts/` (tabla GSUB):

    IBMPlexSans-Regular.otf    sin smcp, sin c2sc
    NotoSerif-Regular.ttf      smcp y c2sc

CONSECUENCIA PARA EL EPUB: el libro embebe Noto Serif (`@font-face` de `gbpublisher-epub-libro.css`). Cumple la regla de SC-56.

CONSECUENCIA PARA EL HTML: el panel de referencias (`.ref-item`) se compone con `--font-sans`, que es IBM Plex Sans, y `gbpublisher.css` no embebe fuentes: usa las que tenga instaladas el lector. Con Plex, las versalitas del panel son falsas. Con la serif tampoco hay garantía, porque Noto Serif no se embebe y el respaldo es Georgia.

Queda para decidir, como un lote aparte: embeber en el HTML una fuente con `smcp` y `c2sc`, o componer el panel de referencias con ella.',
   'vigente', 'empirica',
   'fontTools 4.65 / fuentes de gbpublisher (.hidden/fonts) / contenedor Ubuntu 24.04',
   '2026-10',
   'vinculo:SC-56,vinculo:SC-57',
   'Sin decidir qué fuente usa el panel de referencias del HTML (decisión de Alberto).',
   1040, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-104 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-104' AND orden = 1040;

UPDATE entradas
   SET relaciones = relaciones || ',vinculo:GV-104',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-56' AND instr(relaciones, 'GV-104') = 0;
INSERT INTO verificacion SELECT 'SC-56 relación con GV-104', instr(relaciones, 'GV-104') > 0 FROM entradas WHERE codigo = 'SC-56';

-- ------------------------------------------------------------
-- 5. SC-57: LO IMPLEMENTADO
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = 'DECISIÓN CERRADA (decisión de Alberto). Libros con Verona. El texto de las citas y de las referencias que van a HTML y EPUB no lo escribe una hoja XSLT: lo escribe biblatex, con el mismo estilo y la misma configuración que el PDF, a través de tex4ht (make4ht). Es la forma más directa de cumplir SC-14: el estilo no se replica, se usa.

POR QUÉ

Lo difícil de un estilo autor-año no es la puntuación, es lo que calcula biber: el orden, la letra del año (2020a, 2020b), la unicidad de nombres y de listas (`uniquelist=minyear`). Las hojas actuales no lo hacen en ningún estilo: el «iso690» de `docbook-to-html.xsl` ni siquiera sigue a `iso-authoryear`. La CSL nunca formó una referencia: era la etiqueta del selector.

Se descartó bblxml de biber: trae el cálculo pero no el formato, y está declarado obsoleto desde biber 2.15 («será quitado en la versión 4»; sigue en 2.23).

MEDIDO con `ref-l-MOLINARO.bib` (222 entradas): las 222 referencias del HTML tienen el mismo texto que el PDF, y las citas del cuerpo y de las notas también.

QUIÉN DECIDE EL CAMINO

Gambas, en un solo lugar: `m_GenerarSalidasLibro.PrepararCitasPantalla`. Si el estilo tiene archivo de pantalla, `~/.gbpublisher/latex/cita-<estilo>-html.tex`, el modo es `tex4ht`: escribe los insumos de la pasada (`m_GenerarPDFLibro.EscribirInsumosCitas`: la lista de piezas, `tmp/citas-proyecto.tex` y el `.bib`, con las mismas funciones que el PDF) y pasa el modo a `generar_html_libro.sh` y a `generar_epub_libro.sh`. Si no lo tiene, el modo es `xslt` y siguen las plantillas por estilo de las hojas. Los scripts reciben el modo y no lo vuelven a decidir.

Un estilo sin archivo de pantalla y sin plantillas en la hoja (hoy, cualquiera fuera de apa, iso690, ieee y vancouver) corta el HTML y el EPUB. Antes caía en un autor-año genérico que no es el del PDF.

LAS PIEZAS

1. `docbook-to-latex-citas.xsl`. Importa la hoja del PDF y sobrescribe solo la plantilla de pieza: escribe los mismos `refsection` que el PDF y cada grupo de citas como `\gbcita{id}{comando}`, con el comando que arma la plantilla de `biblioref` del PDF. Así las citas son las del PDF por construcción. Una cita de una nota va dentro de `\footnote`. Antes de `\gbImprimirBibliografia`, la marca `\gbbibliografia{sección-orden}`.
2. `cita-comun.xsl`. La regla del agrupamiento de citas (`gbct:grupo-desde`, `gbct:es-continuacion` y sus auxiliares), `gbct:comando-cita` (era `f:comando-cita` de `tex-comun.xsl`) y el id de cada grupo (`gbct:id-cita`). La incluyen el PDF, la pasada de citas y las hojas de HTML y EPUB: una sola regla. El estilo llega como parámetro explícito y no como variable global. Medido: los `.tex` del PDF de Duek salen idénticos byte a byte después de la mudanza.
3. `engine/preparar_citas_libro.sh`. Corre la hoja de citas por pieza, arma el documento mínimo `citas.tex` y lo compila con make4ht. Verifica el producto: XML bien formado, sin errores de biber, una marca `gbcita-` por cada `\gbcita` y una `gbbib-` por cada bibliografía. Salida: `tmp/bib/html-libro-<nombre>` y `tmp/bib/epub-libro` (carpeta fija: el proyecto tiene un solo EPUB, y el nombre de su archivo puede llevar espacios). `referencias/` queda para los datos canónicos.
4. `cita-fragmentos.xsl`. La lectura de `citas.html` para las hojas de HTML y EPUB: declara el parámetro `bib_dir`, busca cada grupo por su id y cada bibliografía por su marca, y copia el marcado a la salida en el espacio de nombres de XHTML. Cada hoja define la plantilla `gbct:enlace-cita`, porque el enlace de una cita no es igual en HTML (panel) y en EPUB (href).
5. `docbook-to-html.xsl` Y `docbook-to-epub.xsl`. Con `bib_dir`, el primer `biblioref` de cada grupo dibuja el texto de biblatex y los demás no emiten nada; el separador entre dos citas se suprime solo si la segunda quedó en el grupo de la primera (la regla del PDF). Las referencias son las que imprimió biblatex, en su orden, y cada una se une con su `biblioentry` por la clave: el `xml:id` es el destino de los enlaces. Sin `bib_dir`, la salida es la misma que antes (medido: idéntica byte a byte en las dos hojas).
6. EL CSS. `font-variant-caps: all-small-caps` para `.versalitas-todas` en `gbpublisher.css` y `gbpublisher-epub-libro.css` (SC-56). Sangría francesa: el EPUB ya la tenía en `.ref-item`; en el HTML va en `.ref-item.ref-biblatex`, solo para estas entradas, porque la hoja es común con revistas.
7. EL SELECTOR DE ESTILOS lista los `cita-*-config.tex` de `~/.gbpublisher/latex/`, con la etiqueta de su primera línea (`% ESTILO: …`). `libros_md.estilo_cita` guarda el identificador (`apa`, `verona-modern`); la conversión de los `.csl` viejos la hace `actualizar-esquema-1.9.0.sh`.
8. LA CONFIGURACIÓN DE tex4ht, `cita-tex4ht.cfg`, viaja en `.hidden/latex/`, con las de estilo.

EL id DE CADA CITA

`gbcita-{sección}-{orden}-{n}`: sección y orden salen del `<info>` de la pieza; n es la posición, dentro de la pieza, del primer `biblioref` del grupo, contando los de las notas. Se cuenta dentro de la pieza y no en el libro: así es el mismo en el canónico de la pieza (PDF, pasada de citas, EPUB) y en el del libro ensamblado (HTML). Medido en Duek.

LA BIBLIOGRAFÍA DE CADA PIEZA

tex4ht numera las `refsection` (`cite.1@clave`, `cite.2@clave`). Para no repetir ese conteo, cada bibliografía lleva antes su marca: `<span id="gbbib-a-01">`, y `gbbib-libro` la consolidada. La lista de una pieza es la primera que sigue a su marca, si no hay otra marca en medio: una `refsection` sin citas no imprime lista. La unión cita-referencia es por pieza y clave, nunca solo por clave.

LA PASADA HTML USA LA MISMA CONFIGURACIÓN

Se carga `cita-verona-modern-config.tex` y después un archivo propio del estilo, `cita-verona-modern-html.tex`, con lo que cambia en pantalla:

    \ExecuteBibliographyOptions{backref=false,lowscauthors=false,dashed=false}
    \newcommand*{\gbImprimirBibliografia}{\printbibliography[heading=none,restoreclassic]}

Las tres opciones se aplican después de cargar biblatex (medido). `restoreclassic` no se puede fijar con `\DeclarePrintbibliographyDefaults` («keyval Error: restoreclassic undefined», medido). Por eso va en una macro que define cada estilo, y la hoja de citas emite siempre `\gbImprimirBibliografia`. Lo que es del estilo queda en el archivo del estilo, no en la hoja.

LA CONFIGURACIÓN DE tex4ht (medido)

- La cursiva de biblatex (`\emph`) sale como `<em>`; `\textsc`, como `<span class="versalitas-todas">`; el ordinal de babel-spanish (`n.º`), como punto y `<sup>`. `\bibfont` y `\footnotesize` se vacían: sin eso, cada tamaño de letra da un `<span>` con el nombre de la fuente (`ec-lmr-9`).
- `\gbcita{id}{...}` sale como `<span id="gbcita-id">` y `\gbbibliografia{x}` como `<span id="gbbib-x">`. En una compilación común no escriben nada.
- En babel-spanish `<` y `>` son activos: el marcado que inserta la configuración va con `\string<` y `\string>`. Sin eso: «Argument of \language@active@arg has an extra }».
- Las notas, en la misma página (`fn-in`): si no, cada nota sale en un archivo aparte.
- Un ancho de 500 cm: sin cortes de renglón no aparecen espacios espurios antes de una URL.

QUÉ PASA DE citas.html A LA SALIDA

Una lista cerrada: `em`, `strong`, `sup`, `del`, `u`, `span.versalitas-todas`, los enlaces externos y los enlaces de cita, que se vuelven el enlace de la hoja. Las anclas de tex4ht se descartan. Cualquier otro elemento corta la hoja con su nombre (GV-23): es un cambio de tex4ht o del estilo que hay que mirar. También cortan: `citas.html` ausente, un id de cita o una marca de bibliografía que no está, una referencia sin `biblioentry` en el canónico y una bibliografía con etiquetas en el `<dt>` (estilo numérico o alfabético, no medido por este camino).

LÍMITE CONOCIDO

Con tex4ht, biblatex no detecta las notas al pie («Patching footnotes failed»). En Verona no importa: philosophy solo lo usa en `scauthors=citefn` y `bibcitefn`, y la configuración usa `scauthors=bib`. La cita dentro de una nota salió igual que en el PDF. Un estilo que se comporte distinto en las notas, como los verbose, no entra por este camino sin medirlo antes.

El agrupamiento depende del estilo solo en un caso: `suppress` con afijos en un estilo numérico. Hoy el PDF y la pasada de citas toman el estilo del canónico de pieza, que no trae `csl-style`, y las hojas de HTML y EPUB el de la base. Para los autor-año da lo mismo; para IEEE no, y se resuelve en el lote del estilo en el canónico.

ALCANCE

Verona. Los demás estilos siguen con sus hojas hasta que se releven (SC-14: un estilo sin RF no se implementa), y cuando entren lo hacen por este mismo camino, con su archivo `-html.tex`.',
       pendiente = 'Implementado y medido en el contenedor con el libro de Duek (132 citas, 113 referencias): el texto de cada cita del HTML y del EPUB es el de citas.html, y las referencias de cada pieza son las mismas y en el mismo orden; los enlaces de cita del EPUB no tienen destinos rotos; vnu sin errores en el HTML; epubcheck 4.2.6 sin errores en el EPUB; bibliografía consolidada simulada (103 referencias) en HTML y EPUB; los cortes de la hoja con un citas.html incompleto. Falta: la prueba en Mint con un libro real; cómo responden los lectores de EPUB a all-small-caps; la fuente del panel de referencias del HTML (GV-104).',
       entorno = 'biblatex 3.19 / biber 2.19 / biblatex-philosophy v1.9.8g / make4ht v0.3m / TeX Live 2023 / Saxon-HE 12.9 / epubcheck 4.2.6 / contenedor Ubuntu 24.04',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-57';
-- LAS RELACIONES APARTE, CON GUARDA: UNA SEGUNDA CORRIDA NO LAS DUPLICA
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:GV-103,vinculo:GV-104'
 WHERE codigo = 'SC-57' AND instr(relaciones, 'GV-103') = 0;
INSERT INTO verificacion SELECT 'SC-57 reescrita',
  instr(cuerpo, 'PrepararCitasPantalla') > 0 AND instr(cuerpo, 'veronaM') = 0
  AND instr(cuerpo, 'MODO NUEVO') = 0 AND instr(pendiente, 'epubcheck 4.2.6 sin errores') > 0
  AND instr(relaciones, 'GV-103') > 0 AND instr(relaciones, 'GV-104') > 0
  FROM entradas WHERE codigo = 'SC-57';

-- NINGUNA ENTRADA CON EL NOMBRE VIEJO
INSERT INTO verificacion SELECT 'sin veronaM', COUNT(*) = 0 FROM entradas
  WHERE instr(cuerpo || titulo || ifnull(pendiente, '') || ifnull(entorno, ''), 'veronaM') > 0;

COMMIT;

SELECT codigo, estado, evidencia, orden, titulo FROM entradas WHERE codigo IN ('SC-56', 'SC-57', 'GV-103', 'GV-104') ORDER BY prefijo DESC, numero;
