-- ============================================================
-- gbCorpus — actualización 78: entrega 2 del validador
-- Esquema: 1
-- Origen: conversación del 29/10. Las reglas propias de gbpublisher
--         (gbpublisher.sch) y el formato de imagen, implementados y probados
--         en Linux Mint por Alberto.
-- Fecha:  2026-10-29
-- Aplicar: después de act-75 y act-76 (y de act-77, que es independiente)
--
-- MODIFICA:
--   SC-75      capas [5] y [6], las reglas propias, los recursos del
--              sistema, el código; pendiente y entorno
-- ALTAS:
--   GV-XML-04  una regla Schematron con contexto en una PI solo se dispara
--              para las del prólogo
--   GV-155     LuaLaTeX: los formatos de imagen de graphicx
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: act-75 Y act-76 APLICADAS; CÓDIGOS LIBRES
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'act-75 aplicada', evidencia = 'empirica' FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'act-76 aplicada', pendiente LIKE 'Entrega 2:%' FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'GV-XML-04 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-XML-04' OR (prefijo = 'GV-XML' AND numero = 4);
INSERT INTO verificacion SELECT 'GV-155 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-155' OR (prefijo = 'GV' AND numero = 155);
INSERT INTO verificacion SELECT 'SC-75 texto 1: una vez', (length(cuerpo) - length(replace(cuerpo, '                      EPUB se quedan con el nombre y lo buscan en media/.
                      Sin comprobar direcciones de red', ''))) = length('                      EPUB se quedan con el nombre y lo buscan en media/.
                      Sin comprobar direcciones de red') FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 2: una vez', (length(cuerpo) - length(replace(cuerpo, 'Entrega 1: estas cuatro capas, las huellas, la función de vigencia, el botón y la apertura. Entrega 2: el Schematron propio de gbpublisher —remisiones que jing no ve [4] y reglas del proyecto [6]: bibliomisc de ubicación, PI gb-* conocidas, alt de figuras, xml:lang— y los formatos de imagen admitidos por salida; cada regla se decide por separado.', ''))) = length('Entrega 1: estas cuatro capas, las huellas, la función de vigencia, el botón y la apertura. Entrega 2: el Schematron propio de gbpublisher —remisiones que jing no ve [4] y reglas del proyecto [6]: bibliomisc de ubicación, PI gb-* conocidas, alt de figuras, xml:lang— y los formatos de imagen admitidos por salida; cada regla se decide por separado.') FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 3: una vez', (length(cuerpo) - length(replace(cuerpo, 'El Schematron compilado (`schemas/docbook/docbook-sch.xsl`) lo genera fuera de la aplicación un script del repositorio, con la extracción y la compilación de GV-XML-03, y anota en su cabecera la huella del RNG del que salió.', ''))) = length('El Schematron compilado (`schemas/docbook/docbook-sch.xsl`) lo genera fuera de la aplicación un script del repositorio, con la extracción y la compilación de GV-XML-03, y anota en su cabecera la huella del RNG del que salió.') FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 4: una vez', (length(cuerpo) - length(replace(cuerpo, '- El Schematron compilado lo genera `generar-schematron-docbook.sh`, en la raíz del repositorio, con cuatro instancias de prueba que tienen que dar lo esperado antes de reemplazar la hoja.', ''))) = length('- El Schematron compilado lo genera `generar-schematron-docbook.sh`, en la raíz del repositorio, con cuatro instancias de prueba que tienen que dar lo esperado antes de reemplazar la hoja.') FROM entradas WHERE codigo = 'SC-75';

-- ------------------------------------------------------------
-- 2. SC-75
-- ------------------------------------------------------------
UPDATE entradas SET cuerpo = replace(cuerpo, '                      EPUB se quedan con el nombre y lo buscan en media/.
                      Sin comprobar direcciones de red', '                      EPUB se quedan con el nombre y lo buscan en media/.
                      Y tiene que ser png o jpg, lo único que sale en las
                      tres salidas: LuaLaTeX no admite svg, gif ni webp
                      (GV-155) y el EPUB y el HTML no muestran un pdf. Otro
                      formato es aviso y dice en qué salida se pierde.
                      Sin comprobar direcciones de red
    [6] proyecto      las reglas propias de gbpublisher
                      (schemas/gbpublisher/gbpublisher.sch), en la misma
                      hoja y la misma pasada que las de DocBook. Se separan
                      por el prefijo gbp- de su @id; cada una declara su
                      nivel en @role (tenue informa; cualquier otro valor
                      cuenta como aviso)'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 1: aplicado', instr(cuerpo, '                      EPUB se quedan con el nombre y lo buscan en media/.
                      Y tiene que ser png o jpg, lo único que sale en las
                      tres salidas: LuaLaTeX no admite svg, gif ni webp
                      (GV-155) y el EPUB y el HTML no muestran un pdf. Otro
                      formato es aviso y dice en qué salida se pierde.
                      Sin comprobar direcciones de red
    [6] proyecto      las reglas propias de gbpublisher
                      (schemas/gbpublisher/gbpublisher.sch), en la misma
                      hoja y la misma pasada que las de DocBook. Se separan
                      por el prefijo gbp- de su @id; cada una declara su
                      nivel en @role (tenue informa; cualquier otro valor
                      cuenta como aviso)') > 0 FROM entradas WHERE codigo = 'SC-75';
UPDATE entradas SET cuerpo = replace(cuerpo, 'Entrega 1: estas cuatro capas, las huellas, la función de vigencia, el botón y la apertura. Entrega 2: el Schematron propio de gbpublisher —remisiones que jing no ve [4] y reglas del proyecto [6]: bibliomisc de ubicación, PI gb-* conocidas, alt de figuras, xml:lang— y los formatos de imagen admitidos por salida; cada regla se decide por separado.', 'Entrega 1: las capas [1], [2], [3] y [5], las huellas, la función de vigencia, el botón y la apertura. Entrega 2: las reglas propias [6] y el formato de imagen en [5]. Las dos, implementadas y probadas en Linux Mint (29/10). La capa [4] —remisiones que jing no ve— quedó repartida en las reglas propias de citas y de figuras sin remitir; lo que falta de ella está en el pendiente.

LAS REGLAS PROPIAS

Decididas una por una (Alberto, 29/10). El @id del patrón y de cada aserción empieza con gbp-.

    patrón          alcance        nivel   qué controla
    gbp-ubicacion   pieza, y cada  aviso   seccion-libro: uno, fm, a o bm;
                    pieza del               orden-seccion: uno, dos cifras;
                    libro                   tipo-capitulo: a lo sumo uno, no
                                            vacío. Un duplicado frena las
                                            hojas de salida
    gbp-estilo      pieza y libro  aviso   estilo-cita: uno en la pieza; uno
                                            en el <info> del libro y ninguno
                                            en sus capítulos.
                                            lugar-bibliografia: uno en el
                                            libro, por_capitulo o consolidada
    gbp-pi          todos          aviso   PI gb-* conocidas (gb-alinear,
                                            gb-corte, gb-cuadro, gb-espacio,
                                            gb-fuente); gb-fuente solo en el
                                            prólogo
    gbp-cita        todos          aviso   un biblioref cuyo destino está en
                                            el documento apunta a una entrada
                                            de bibliografía. Destino ausente:
                                            nada (en pieza, remisión externa;
                                            en libro, lo dice jing)
    gbp-bib         libro          tenue   entrada que nadie cita
    gbp-remision    libro          tenue   figura o cuadro con id que nadie
                                            remite
    gbp-alt         todos          aviso   imagen sin texto alternativo (las
                                            de <info>, como la tapa, no)
    gbp-idioma      raíz y piezas  aviso   xml:lang con forma de etiqueta de
                    del libro               idioma (BCP 47)

- tipo-capitulo se controla solo en cantidad y xml:lang solo en la forma: los dos catálogos están en la base (tipos de pieza, m_Idiomas), y el validador no la toca (SC-13). Una lista copiada en el Schematron se desactualizaría sin aviso: la de la hoja de capítulo ya no tiene indice_concepto ni indice_autores.
- Una figura o una cita que remite a otra pieza no se juzga en la pieza: los fig-*, tbl-* y bib-* son globales (SC-32, SC-66), y esas reglas corren en el libro.
- Las reglas sobre instrucciones de procesamiento se escriben sobre la raíz del documento: con el esqueleto ISO, una regla con contexto en una PI solo se dispara para las del prólogo (GV-XML-04).
- Las raíces de pieza que las reglas nombran no incluyen bibliography: la bibliografía consolidada es hija del libro y no es una pieza.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 2: aplicado', instr(cuerpo, 'Entrega 1: las capas [1], [2], [3] y [5], las huellas, la función de vigencia, el botón y la apertura. Entrega 2: las reglas propias [6] y el formato de imagen en [5]. Las dos, implementadas y probadas en Linux Mint (29/10). La capa [4] —remisiones que jing no ve— quedó repartida en las reglas propias de citas y de figuras sin remitir; lo que falta de ella está en el pendiente.

LAS REGLAS PROPIAS

Decididas una por una (Alberto, 29/10). El @id del patrón y de cada aserción empieza con gbp-.

    patrón          alcance        nivel   qué controla
    gbp-ubicacion   pieza, y cada  aviso   seccion-libro: uno, fm, a o bm;
                    pieza del               orden-seccion: uno, dos cifras;
                    libro                   tipo-capitulo: a lo sumo uno, no
                                            vacío. Un duplicado frena las
                                            hojas de salida
    gbp-estilo      pieza y libro  aviso   estilo-cita: uno en la pieza; uno
                                            en el <info> del libro y ninguno
                                            en sus capítulos.
                                            lugar-bibliografia: uno en el
                                            libro, por_capitulo o consolidada
    gbp-pi          todos          aviso   PI gb-* conocidas (gb-alinear,
                                            gb-corte, gb-cuadro, gb-espacio,
                                            gb-fuente); gb-fuente solo en el
                                            prólogo
    gbp-cita        todos          aviso   un biblioref cuyo destino está en
                                            el documento apunta a una entrada
                                            de bibliografía. Destino ausente:
                                            nada (en pieza, remisión externa;
                                            en libro, lo dice jing)
    gbp-bib         libro          tenue   entrada que nadie cita
    gbp-remision    libro          tenue   figura o cuadro con id que nadie
                                            remite
    gbp-alt         todos          aviso   imagen sin texto alternativo (las
                                            de <info>, como la tapa, no)
    gbp-idioma      raíz y piezas  aviso   xml:lang con forma de etiqueta de
                    del libro               idioma (BCP 47)

- tipo-capitulo se controla solo en cantidad y xml:lang solo en la forma: los dos catálogos están en la base (tipos de pieza, m_Idiomas), y el validador no la toca (SC-13). Una lista copiada en el Schematron se desactualizaría sin aviso: la de la hoja de capítulo ya no tiene indice_concepto ni indice_autores.
- Una figura o una cita que remite a otra pieza no se juzga en la pieza: los fig-*, tbl-* y bib-* son globales (SC-32, SC-66), y esas reglas corren en el libro.
- Las reglas sobre instrucciones de procesamiento se escriben sobre la raíz del documento: con el esqueleto ISO, una regla con contexto en una PI solo se dispara para las del prólogo (GV-XML-04).
- Las raíces de pieza que las reglas nombran no incluyen bibliography: la bibliografía consolidada es hija del libro y no es una pieza.') > 0 FROM entradas WHERE codigo = 'SC-75';
UPDATE entradas SET cuerpo = replace(cuerpo, 'El Schematron compilado (`schemas/docbook/docbook-sch.xsl`) lo genera fuera de la aplicación un script del repositorio, con la extracción y la compilación de GV-XML-03, y anota en su cabecera la huella del RNG del que salió.', 'El Schematron compilado (`schemas/schematron-canonico.xsl`) junta las reglas del RNG y las propias. Lo genera fuera de la aplicación `generar-schematron-canonico.sh`, en la raíz del repositorio, con la extracción y la compilación de GV-XML-03, y anota en su cabecera las huellas del RNG, de `gbpublisher.sch` y del esqueleto. Reemplazó a `generar-schematron-docbook.sh` y a `schemas/docbook/docbook-sch.xsl`, que solo tenían las de DocBook.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 3: aplicado', instr(cuerpo, 'El Schematron compilado (`schemas/schematron-canonico.xsl`) junta las reglas del RNG y las propias. Lo genera fuera de la aplicación `generar-schematron-canonico.sh`, en la raíz del repositorio, con la extracción y la compilación de GV-XML-03, y anota en su cabecera las huellas del RNG, de `gbpublisher.sch` y del esqueleto. Reemplazó a `generar-schematron-docbook.sh` y a `schemas/docbook/docbook-sch.xsl`, que solo tenían las de DocBook.') > 0 FROM entradas WHERE codigo = 'SC-75';
UPDATE entradas SET cuerpo = replace(cuerpo, '- El Schematron compilado lo genera `generar-schematron-docbook.sh`, en la raíz del repositorio, con cuatro instancias de prueba que tienen que dar lo esperado antes de reemplazar la hoja.', '- El Schematron compilado lo genera `generar-schematron-canonico.sh`, con instancias de prueba que tienen que dar lo esperado antes de reemplazar la hoja: cuatro para DocBook (cantidad y mensaje exactos) y tres para las reglas propias, una limpia, una pieza y un libro, que comparan el conjunto exacto de @id que fallan.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 4: aplicado', instr(cuerpo, '- El Schematron compilado lo genera `generar-schematron-canonico.sh`, con instancias de prueba que tienen que dar lo esperado antes de reemplazar la hoja: cuatro para DocBook (cantidad y mensaje exactos) y tres para las reglas propias, una limpia, una pieza y un libro, que comparan el conjunto exacto de @id que fallan.') > 0 FROM entradas WHERE codigo = 'SC-75';
UPDATE entradas
   SET pendiente = '(1) La remisión a un destino que la salida no sabe numerar (un xref a un elemento sin número): leer antes qué tipos numeran las tres hojas. (2) Posible regla: una figura con pocos píxeles para el ancho de la caja sale pixelada en el PDF, que la compone siempre a \linewidth; HTML y EPUB la muestran a su tamaño natural. Se retoma con el shortcode de figuras.',
       entorno = entorno || '; LuaHBTeX 1.17.0 (TeX Live 2023)',
       relaciones = relaciones || ',vinculo:GV-XML-04,vinculo:GV-155',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 pendiente y relaciones', pendiente LIKE '(1) La remisión%' AND instr(relaciones, 'vinculo:GV-155') > 0 FROM entradas WHERE codigo = 'SC-75';

-- ------------------------------------------------------------
-- 3. ALTAS
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV-XML', 4, 'GV-XML-04', 'Schematron con el esqueleto ISO: una regla con contexto en una PI solo se dispara para las del prólogo',
   'Con el esqueleto ISO (`iso_svrl_for_xslt2.xsl`), una regla cuyo contexto es una instrucción de procesamiento solo se dispara para las PI que están fuera del elemento raíz.

MEDIDO, sobre un capítulo con `<?gb-fuente …?>` en el prólogo y `<?gb-raro …?>` dentro de un `<para>`:

    contexto de la regla                              resultado
    processing-instruction()[starts-with(name(),      se dispara una vez, para la
      ''gb-'')]                                         del prólogo; gb-raro no se
                                                      revisa
    /  con  //processing-instruction()[…]  en un      encuentra gb-raro
      s:let y la aserción sobre él

La hoja compilada recorre los elementos de cada patrón con `apply-templates select="*"`: las PI dentro de los elementos no entran en el recorrido.

REGLA: una regla sobre instrucciones de procesamiento se escribe sobre la raíz del documento (`context="/"`), con las PI juntadas en un `s:let`. Así lo hace el patrón gbp-pi de `gbpublisher.sch` (SC-75).

También medido: el `@id` y el `@role` de cada aserción llegan al SVRL como atributos de `svrl:failed-assert`. Es lo que usa el validador para separar las reglas propias y leer su nivel.',
   'vigente', 'empirica',
   'SaxonJ-HE 12.5 / esqueleto ISO iso_svrl_for_xslt2.xsl del repositorio / contenedor Ubuntu; gbpublisher.sch compilado y probado también en Linux Mint con SaxonJ-HE 12.9',
   '2026-10', 'apoya:SC-75,vinculo:GV-XML-03',
   NULL, 40, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-XML-04 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-XML-04';

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 155, 'GV-155', 'LuaLaTeX: graphicx admite pdf, png y jpg, no svg, gif ni webp',
   'El controlador de graphicx para LuaTeX (`luatex.def`) admite estas extensiones:

    .pdf,.png,.jpg,.mps,.jpeg,.jbig2,.jb2  (y las mismas en mayúsculas)

MEDIDO: un `\includegraphics[width=\linewidth]` con un png compila; con un svg o un gif, LuaLaTeX frena con «LaTeX Error: Unknown graphics extension: .svg.» (o .gif).

CONSECUENCIA: de los formatos que admite el EPUB 3.3 (jpg, png, gif, svg, webp; GV-66), solo jpg y png salen también en el PDF, y el HTML los muestra todos. Una figura que tiene que salir en las tres salidas va en png o jpg; un pdf sale solo en el PDF. Es la regla de formato de la capa de recursos del validador (SC-75) y la que SC-25 ya fijaba para los logos.',
   'vigente', 'empirica',
   'LuaHBTeX 1.17.0 / TeX Live 2023 (Debian) / graphics-def luatex.def / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-75,vinculo:GV-66,vinculo:SC-25',
   NULL, 1550, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-155 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-155';

COMMIT;

SELECT codigo, estado, evidencia, titulo FROM entradas
 WHERE codigo IN ('SC-75', 'GV-XML-04', 'GV-155')
 ORDER BY prefijo, numero;
