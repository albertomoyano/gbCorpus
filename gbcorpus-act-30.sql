-- ============================================================
-- gbCorpus — actualización 30: la preparación de los archivos LaTeX sale
--            de Gambas
-- Esquema: 1
-- Origen: el vacío sin señal de vida antes de «Componiendo el PDF»: eran
--         los Exec síncronos de GenerarMainTeX. Decisión de Alberto: opción
--         B, preparar_latex_libro.sh; una pieza que falla no corta el resto;
--         el preámbulo y el .bib siguen en Gambas. Cotejado con la carpeta
--         local de gbCorpus (último script: act-29) y con una copia de la
--         base local.
-- Fecha:  2026-10-14
--
-- MODIFICA:
--   SC-53  LOS USOS: preparar_latex_libro.sh, el corte y el main.tex último
--   SC-13  segundo caso migrado; el inventario ya no tiene el PDF de libros
--   SC-44  GenerarMainTeX pasa a llamarse ArmarInsumosLaTeX
--   SC-45  ídem
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-53 usos', (length(cuerpo) - length(replace(cuerpo, '`ensamblar_libro.sh`, `generar_html_libro.sh`, `generar_epub_libro.sh`, `generar_canonicos_capitulos.sh` y `compilar_pdf_libro.sh`. Este último', ''))) / length('`ensamblar_libro.sh`, `generar_html_libro.sh`, `generar_epub_libro.sh`, `generar_canonicos_capitulos.sh` y `compilar_pdf_libro.sh`. Este último') = 1 FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 ancla usos', (length(cuerpo) - length(replace(cuerpo, 'llegan como código 3.', ''))) / length('llegan como código 3.') = 1 FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-13 inventario', (length(pendiente) - length(replace(pendiente, 'm_InicioCierre y los echo de GenerarPDFLibro antes de lanzar el compilador (el compilador ya pasa por la lanzadora).', ''))) / length('m_InicioCierre y los echo de GenerarPDFLibro antes de lanzar el compilador (el compilador ya pasa por la lanzadora).') = 1 FROM entradas WHERE codigo = 'SC-13';
INSERT INTO verificacion SELECT 'SC-13 primer caso', (length(cuerpo) - length(replace(cuerpo, '`engine/generar_canonicos_capitulos.sh` reemplazó a `FMain.btnGenerarDocBookcanonico_Click` y a `m_XML.GenerarBodyCapituloXML`.', ''))) / length('`engine/generar_canonicos_capitulos.sh` reemplazó a `FMain.btnGenerarDocBookcanonico_Click` y a `m_XML.GenerarBodyCapituloXML`.') = 1 FROM entradas WHERE codigo = 'SC-13';
INSERT INTO verificacion SELECT 'SC-44 GenerarMainTeX', (length(cuerpo) - length(replace(cuerpo, 'Lo usan `m_GenerarPDFLibro.GenerarMainTeX`,', ''))) / length('Lo usan `m_GenerarPDFLibro.GenerarMainTeX`,') = 1 FROM entradas WHERE codigo = 'SC-44';
INSERT INTO verificacion SELECT 'SC-45 GenerarMainTeX', (length(cuerpo) - length(replace(cuerpo, '`m_GenerarPDFLibro.GenerarMainTeX` (7.1b)', ''))) / length('`m_GenerarPDFLibro.GenerarMainTeX` (7.1b)') = 1 FROM entradas WHERE codigo = 'SC-45';

-- ------------------------------------------------------------
-- 2. SC-53
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(replace(cuerpo, '`ensamblar_libro.sh`, `generar_html_libro.sh`, `generar_epub_libro.sh`, `generar_canonicos_capitulos.sh` y `compilar_pdf_libro.sh`. Este último', '`ensamblar_libro.sh`, `generar_html_libro.sh`, `generar_epub_libro.sh`, `generar_canonicos_capitulos.sh`, `preparar_latex_libro.sh` y `compilar_pdf_libro.sh`. Este último'), 'llegan como código 3.', 'llegan como código 3.

`preparar_latex_libro.sh` hace lo que antes hacía `m_GenerarPDFLibro.GenerarMainTeX` con `Exec` síncronos: colorear y transformar cada pieza (`colorear_codigo.sh` y `docbook-to-latex.xsl`), borrar los `c-*.tex` huérfanos y poner el `main.tex` en su lugar. Mientras eso corría en Gambas, la interfaz no se repintaba (GV-17) y no había señal de vida antes de que empezara la compilación. Gambas conserva lo que sale de la base, en `m_GenerarPDFLibro.ArmarInsumosLaTeX`: preámbulo derivado, `.bib`, la lista de piezas con cuerpo (`tmp/latex-piezas.txt`) y el `main.tex` propuesto (`latex/.main.tex.tmp`). «Solo generar» lanza `preparar_latex_libro.sh`; «Generar y compilar» lanza `compilar_pdf_libro.sh`, que lo llama anidado primero y no compila si falla.

El `main.tex` sigue yendo último (criterio de SC-07): el script lo pone con `mv` solo si todas las piezas salieron bien, y si alguna falla el anterior queda intacto. Como `mv` conserva la fecha del temporal, anterior a las piezas, un `touch` lo deja como el archivo más nuevo. Una pieza que falla no corta el resto: se listan todas y no se pone el `main.tex`. El preámbulo derivado y el `.bib` los sigue escribiendo Gambas antes del script: si una pieza falla quedan nuevos junto al `main.tex` anterior, lo que se aceptó porque no son declarativos y la próxima corrida los reescribe. Decisión de Alberto.'),
       relaciones = relaciones || ',vinculo:SC-07',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 actualizada', instr(cuerpo, 'ArmarInsumosLaTeX') > 0 AND instr(cuerpo, '`preparar_latex_libro.sh` y `compilar_pdf_libro.sh`') > 0 FROM entradas WHERE codigo = 'SC-53';

-- ------------------------------------------------------------
-- 3. SC-13, SC-44 Y SC-45
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, '`engine/generar_canonicos_capitulos.sh` reemplazó a `FMain.btnGenerarDocBookcanonico_Click` y a `m_XML.GenerarBodyCapituloXML`.', '`engine/generar_canonicos_capitulos.sh` reemplazó a `FMain.btnGenerarDocBookcanonico_Click` y a `m_XML.GenerarBodyCapituloXML`. El segundo, la salida PDF de libros: `compilar_pdf_libro.sh` pasó a la lanzadora y la preparación de los archivos LaTeX salió de Gambas a `preparar_latex_libro.sh` (SC-53).'),
       pendiente = replace(pendiente, 'm_InicioCierre y los echo de GenerarPDFLibro antes de lanzar el compilador (el compilador ya pasa por la lanzadora).', 'm_InicioCierre. La salida PDF de libros ya no tiene nada fuera de la lanzadora.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-13';
UPDATE entradas SET cuerpo = replace(cuerpo, 'Lo usan `m_GenerarPDFLibro.GenerarMainTeX`,', 'Lo usan `m_GenerarPDFLibro.ArmarInsumosLaTeX`,'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-44';
UPDATE entradas SET cuerpo = replace(cuerpo, '`m_GenerarPDFLibro.GenerarMainTeX` (7.1b)', '`m_GenerarPDFLibro.ArmarInsumosLaTeX` (7.1b)'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-45';
INSERT INTO verificacion SELECT 'SC-13 actualizada', instr(cuerpo, 'El segundo, la salida PDF') > 0 AND instr(pendiente, 'ya no tiene nada fuera') > 0 FROM entradas WHERE codigo = 'SC-13';
INSERT INTO verificacion SELECT 'sin GenerarMainTeX vigente', COUNT(*) = 0 FROM entradas WHERE codigo IN ('SC-44', 'SC-45') AND instr(cuerpo, 'GenerarMainTeX') > 0;

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-13', 'SC-44', 'SC-45', 'SC-53') ORDER BY numero;
