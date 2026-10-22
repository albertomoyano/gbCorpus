-- ============================================================
-- gbCorpus — actualización 57: cifras y unidades con la norma
--            internacional (SC-64); plan de las tablas; lo medido de
--            babel-spanish y siunitx
-- Esquema: 1
-- Origen: conversación del 21 y 22/10 sobre el shortcode de tablas.
--         Decisiones de Alberto: la norma internacional para las
--         cifras (se aparta de su práctica de LaTeX en el porcentaje y
--         en las cifras de cuatro dígitos), el \sisetup final, \euro, el
--         orden de desarrollo en tres lotes y la vista previa de un
--         cuadro abierta con el visor del sistema. Medido en el
--         contenedor con LuaLaTeX de TeX Live 2023, babel-spanish 5.0q y
--         siunitx 3.3.10, la misma versión que trae Mint 22.
-- Fecha:  2026-10-22
-- Aplicar: después de act-56
--
-- ALTAS:
--   GV-122  babel-spanish: \% pone un espacio fino antes del signo
--   GV-123  siunitx 3.3.10 con babel-spanish: el punto decimal depende de
--           detect-all; agrupación, per-mode y unidades no definidas
--   SC-64   Cifras y unidades: la norma internacional, con siunitx
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-121 última GV', MAX(numero) = 121 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-63 última SC', MAX(numero) = 63 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-122 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-122' OR (prefijo = 'GV' AND numero = 122);
INSERT INTO verificacion SELECT 'GV-123 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-123' OR (prefijo = 'GV' AND numero = 123);
INSERT INTO verificacion SELECT 'SC-64 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-64' OR (prefijo = 'SC' AND numero = 64);

-- ------------------------------------------------------------
-- 2. GV-122
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 122, 'GV-122', 'babel-spanish: \% pone un espacio fino antes del signo',
   'Con el español activo, babel-spanish redefine `\%`. Leído en `spanish.ldf` (5.0q):

    \def\es@sppercent{% See tex.stack 435216 @egreg
      \leavevmode
      \ifnum\gluestretchorder\lastskip=\z@\unskip\fi
      \textormath{$\m@th\,$}{\,}}
    \def\spanishplainpercent{\let\es@sppercent\@empty}
    \addto\textspanish{%
      \let\percentsign\%%
      \es@sDRC\%{\es@sppercent\percentsign{}}}

Antes del signo pone `\,` y quita el espacio que hubiera. Sigue la recomendación de separar la cifra del signo (SI Brochure §5.4.7).

EN EL PROYECTO: un `88%` del .md llega al PDF como «88 %», aunque esté pegado, porque `tex-comun.xsl` escapa `%` como `\%` (en LaTeX, `%` abre un comentario) y ese `\%` es el que babel redefinió. El HTML y el EPUB muestran «88%»: las salidas difieren hoy.

MEDIDO (LuaLaTeX, posición de cada palabra con `pdftotext -bbox`):

    sin \spanishplainpercent    «88» «%»     separados
    con \spanishplainpercent    «88%»        pegados

`\SI{25}{\percent}` sale «25 %» en los dos casos: ese espacio lo pone siunitx, entre cifra y unidad.

`\spanishplainpercent` lo desactiva. Con la decisión de SC-64 (el porcentaje separado) no se usa.',
   'vigente', 'empirica',
   'LuaHBTeX 1.17.0 / TeX Live 2023 (Debian) / babel-spanish 5.0q / poppler pdftotext / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-64',
   NULL,
   1220, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-122 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-122';

-- ------------------------------------------------------------
-- 3. GV-123
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 123, 'GV-123', 'siunitx 3.3.10 con babel-spanish: el punto decimal depende de detect-all',
   'Medido con LuaLaTeX, babel-spanish 5.0q y siunitx 3.3.10 (TeX Live 2023, la de Mint 22), leyendo el PDF con `pdftotext`.

EL PUNTO DECIMAL DEPENDE DE detect-all

babel-spanish convierte en coma todo punto decimal en modo matemático (`es-nodecimaldot` lo desactiva). siunitx compone la cifra en modo matemático, salvo que se le pida seguir al texto:

    output-decimal-marker={.}, sin detect-all    \num{12.5} → «12,5»   \SI{2.5}{\hour} → «2,5 h»
    output-decimal-marker={.}, con detect-all    \num{12.5} → «12.5»   \SI{2.5}{\hour} → «2.5 h»

Con `detect-all`, una fórmula común (`$3.5$`) sigue saliendo «3,5»: lo hace babel, no siunitx. SACAR `detect-all` CAMBIA LOS DECIMALES A COMA SIN AVISO.

`detect-all` es una opción de siunitx 2. En la 3.3.10 está deprecada: deja un aviso informativo en el log y se traduce, leído en `siunitx.sty`, a `mode = match, propagate-math-font = true, reset-math-version = false, reset-text-family = false, reset-text-series = false, reset-text-shape = false, text-family-to-math = true, text-series-to-math = true`. Escribir esas opciones en su lugar da lo mismo.

LA ENTRADA

El punto es el separador decimal de la entrada: `\num{16.000}` es dieciséis (sale «16,000» o «16.000» según el marcador de salida). Una cifra con el formato del Word se lee mal; por eso la entrada en el .md es la de siunitx (SC-64).

AGRUPACIÓN

`group-minimum-digits` es la cantidad mínima de dígitos de un lado del separador decimal para que se agrupe. Con 5 (el valor por omisión): «1000», «12 345», «1234.5678», «0.123 45». Con 3: «1 000», «9 000.00».

UNIDADES

- `per-mode=fraction` compone «km/h» como fracción vertical y agranda la línea; `per-mode=symbol` da «48 km/h» en una línea; el valor por omisión da «48 km h⁻¹».
- `\euro`, `\perthousand` y `\pertenthousand` no existen: «Undefined control sequence». `\DeclareSIUnit\euro{€}` da «450 €/m²» y «1 250.5 €», sin aviso de carácter faltante.
- `\SIrange{50}{51}{\degree}` da «50° a 51°»: la palabra del rango la pone el idioma.
- `\SI`, `\SIrange` y `\num` funcionan en la 3.3.10; los nombres actuales son `\qty`, `\qtyrange` y `\num`.

COLUMNA S

`S[table-format=4.2]` alinea `9000.00`, `6.4` y `12.25` en el punto; una celda de texto va entre llaves (`{--}`).',
   'vigente', 'empirica',
   'LuaHBTeX 1.17.0 / TeX Live 2023 (Debian) / babel-spanish 5.0q / siunitx 3.3.10 / poppler pdftotext / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-64,vinculo:GV-122',
   NULL,
   1230, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-123 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-123';

-- ------------------------------------------------------------
-- 4. SC-64
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 64, 'SC-64', 'Cifras y unidades: la norma internacional, escrita con siunitx',
   'DECISIÓN CERRADA (decisión de Alberto, 22/10). Las cifras y las unidades siguen la norma internacional. En dos puntos se aparta de la práctica que Alberto usaba en LaTeX: el porcentaje va separado de la cifra, y las cifras de cuatro dígitos no se agrupan.

LA NORMA

    tema                     norma                                   fuente
    separador decimal        punto o coma, el habitual del contexto  CGPM 2003, Res. 10; SI Brochure §5.4.4
                             (el proyecto: punto)
    grupos de miles          de a tres, con un espacio; nunca con    SI Brochure §5.4.4; RAE (espacio fino)
                             punto ni coma
    cuatro dígitos           no se aísla un solo dígito: 1000        SI Brochure §5.4.4; DPD «2458 (no 2 458)»
    porcentaje               separado de la cifra: 25 %              SI Brochure §5.4.7
    unidad                   siempre separada de la cifra            SI Brochure §5.4.3
    grado de ángulo          pegado: 30° 22′ 8″                      SI Brochure §5.4.3
    grado Celsius            separado: 30.2 °C                       SI Brochure §5.4.3

EL MODELO DE ESCRITURA (decisión de Alberto)

La cifra se normaliza en el .md; el formato lo pone cada salida. Una cifra que es una cantidad se escribe con la entrada de siunitx: dígitos sin separador de miles, punto decimal, `e` para el exponente. En el texto: `\num{1000}`, `\SI{2.5}{\hour}`, `\SIrange{50}{51}{\degree}`; en una columna numérica de un cuadro, la cifra sola: `9000.00`. El Word no se respeta: el editor lo pasa a esta forma. El punto queda solo en los números que lo llevan por identidad, como texto común: «decreto 2.345/26», «ley 34.555».

LA CONFIGURACIÓN DE siunitx

    \sisetup{output-decimal-marker={.},
      group-separator={\hspace{0.15em}},
      group-minimum-digits=5,
      table-text-alignment=center,
      detect-all,
      per-mode=symbol}
    \DeclareSIUnit\euro{€}

- `detect-all` sostiene el punto decimal frente a babel-spanish: sin ella, los decimales salen con coma (GV-123).
- `group-minimum-digits=5`: «1000», «12 345» (la práctica anterior era 3).
- `per-mode=symbol`: «48 km/h» en una línea; la fracción vertical agrandaba la línea (decisión de Alberto).
- `\euro`: no hacía falta todavía, pero cuesta una línea (decisión de Alberto). La fuente tiene que tener el signo €.
- El porcentaje: se separa, así que no se usa `\spanishplainpercent` (GV-122). `\SI{25}{\percent}` es la forma de escribirlo.

EL DICCIONARIO CERRADO DEL TEXTO

Órdenes: `\num`, `\SI`, `\SIrange`, con los nombres que Alberto usa (siguen funcionando en siunitx 3). Unidades: `\hour`, `\metre`, `\gram`, `\tonne`, `\degree`, `\percent`, `\euro`, con el prefijo `\kilo` y los modificadores `\square`, `\cubic` y `\per`. Lo que no está en el diccionario frena la conversión con un mensaje.

EL HTML Y EL EPUB

El PDF compone con siunitx, que es la base del diseño (SC-31). El HTML y el EPUB usan un formateador chico que aplica las mismas reglas: punto decimal, grupos de a tres desde cinco dígitos, «× 10ⁿ» con superíndice, los símbolos del diccionario y la palabra del rango según el idioma. El espacio de los grupos y el de la unidad es U+202F (espacio fino que no corta la línea): una cifra no se parte entre dos renglones (decisión de Alberto). Un mini-test compara las dos salidas sobre la misma lista de casos.

LAS TABLAS: EL PLAN (decisión de Alberto)

Tres lotes, cada uno probado en Mint antes del siguiente:

1. Las cifras: el filtro de `\num`, `\SI` y `\SIrange`, el `\sisetup` en el contrato del libro y en el preámbulo de la revista, el formateador del HTML.
2. La cadena del cuadro: el archivo del cuadro en su carpeta, con las decisiones de composición en el encabezado, incluido desde el .md; el canónico (la rotación como atributo, la columna numérica alineada por carácter, los cortes como instrucción `gb-`); el PDF, con un flotante `[!ht]` por tramo, la cabecera repetida y los textos de continuación, y `sidewaystable` si rota; el HTML y el EPUB, con la tabla completa y derecha. El corte y la rotación los decide siempre el maquetador: nunca el compilador.
3. `FTabla` para el editor y no para el autor: la lista de los cuadros de la carpeta, la edición de las decisiones y una vista previa compilada con el mismo filtro, las mismas plantillas y el mismo preámbulo que el libro (sin la capa de hyperref), con `showframe` y el veredicto leído del log. La vista previa se abre con el visor de PDF del sistema: abrir, mirar y cerrar (decisión de Alberto).',
   'vigente', 'empirica',
   'LuaHBTeX 1.17.0 / TeX Live 2023 (Debian) / babel-spanish 5.0q / siunitx 3.3.10 / contenedor Ubuntu 24.04; SI Brochure 9.ª ed. (BIPM); Resolución 10 de la 22.ª CGPM',
   '2026-10', 'vinculo:SC-31,vinculo:SC-38,vinculo:SC-62,vinculo:GV-122,vinculo:GV-123',
   'Sin implementar: es la decisión y el plan. Lote 1 (cifras), lote 2 (cadena del cuadro) y lote 3 (FTabla y vista previa), cada uno con su SC y probado en Mint.',
   640, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-64 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-64';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-122', 'GV-123', 'SC-64')
 ORDER BY prefijo, numero;
