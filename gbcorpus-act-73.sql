-- ============================================================
-- gbCorpus — actualización 73: lo que jing no valida en DocBook 5.2,
--            y el Schematron del RNG compilado aparte
-- Esquema: 1
-- Origen: conversación del 29/10, diseño del validador del canónico
--         DocBook de libros (documento de trabajo
--         `claude/validador-docbook.md`). Mini-tests en contenedor
--         Ubuntu con jing 20220510-3, la misma versión del paquete que
--         en Linux Mint (`dpkg -l jing` en alberto-ryzen9), y
--         SaxonJ-HE 12.5. Corpus real: los canónicos de Duek y Califa.
-- Fecha:  2026-10-29
-- Aplicar: después de act-72
--
-- ALTAS:
--   GV-XML-02  jing no ejecuta el Schematron embebido ni mira las PI
--   GV-XML-03  el Schematron de DocBook 5.2, extraído del RNG, compila
--              y ejecuta con el esqueleto ISO
--
-- NO TOCA: GV-XML-01 queda reservado por el pendiente de SC-52.
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: LA FAMILIA EXISTE Y LOS CÓDIGOS ESTÁN LIBRES
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'familia GV-XML existe', COUNT(*) = 1 FROM familias WHERE prefijo = 'GV-XML';
INSERT INTO verificacion SELECT 'GV-XML-02 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-XML-02' OR (prefijo = 'GV-XML' AND numero = 2);
INSERT INTO verificacion SELECT 'GV-XML-03 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-XML-03' OR (prefijo = 'GV-XML' AND numero = 3);
INSERT INTO verificacion SELECT 'SC-52 existe', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-52';
INSERT INTO verificacion SELECT 'GV-26 existe', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-26';
INSERT INTO verificacion SELECT 'GV-28 existe', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-28';

-- ------------------------------------------------------------
-- 2. GV-XML-02
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV-XML', 2, 'GV-XML-02', 'jing no ejecuta el Schematron embebido en docbook.rng ni mira las instrucciones de procesamiento',
   'El RNG de DocBook 5.2 trae embebidas 247 reglas Schematron ISO (`s:pattern`, espacio de nombres `http://purl.oclc.org/dsdl/schematron`). jing las ignora: valida solo la gramática RELAX NG.

MEDIDO, contra `.hidden/schemas/docbook/docbook.rng-5.2`:

    instancia                                         jing
    <chapter> raíz sin @version                       válido
    <note> dentro de <note>                           válido
    footnoteref con @linkend a un <para>              válido
    <?gb-fuente sha256="…"?> en el prólogo            válido
    xref con @linkend a un id inexistente             IDREF "nada" without matching ID

Las tres primeras las prohíbe el Schematron del RNG. La cuarta muestra que una PI en el prólogo no molesta a la validación. La quinta, que la comprobación de ID e IDREF sí la hace jing (es la que SC-53 informa en tenue en una pieza suelta).

CONSECUENCIA: «válido para jing» no incluye ninguna regla Schematron de DocBook: ni las exclusiones (figura en figura, cuadro en nota, recuadro en recuadro), ni las comprobaciones de tipo de destino (`footnoteref`, `glossterm`, `indexterm/@startref`), ni la de `@version` en la raíz. Son una capa aparte (SC-52, criterio 4), y se ejecutan compiladas (GV-XML-03).

DE LAS 248 ASERCIONES: 131 son la de `@version` en la raíz; el resto, exclusiones entre elementos, tipos de destino de remisiones y reglas de XLink, segmentedlist, termdef y transclusión.',
   'vigente', 'empirica',
   'jing 20220510-3 (paquete Debian; la misma versión que en Linux Mint) / DocBook 5.2 RNG; contenedor Ubuntu',
   '2026-10', 'apoya:SC-52,vinculo:SC-53,vinculo:GV-XML-03',
   NULL,
   20, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-XML-02 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-XML-02';

-- ------------------------------------------------------------
-- 3. GV-XML-03
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV-XML', 3, 'GV-XML-03', 'El Schematron de DocBook 5.2, extraído del RNG, compila y ejecuta con el esqueleto ISO',
   'Las reglas que jing no ejecuta (GV-XML-02) se pueden correr aparte.

CÓMO

1. Extraer del RNG los `s:ns` (10, sin repetir prefijo) y los `s:pattern` (247) y envolverlos en `<s:schema queryBinding="xslt2">`. Una hoja XSLT 2.0 de diez líneas lo hace.
2. Compilar ese documento con `iso_svrl_for_xslt2.xsl` del repositorio (`.hidden/schematron/iso/`). No hay `include` que resolver.
3. Correr la hoja compilada (unos 400 KB) sobre el canónico. La salida es SVRL.

MEDIDO

- Compila sin errores ni advertencias. A diferencia de JATS4R (GV-26), ninguna regla aborta la transformación.
- Sobre las instancias de GV-XML-02 informa los tres incumplimientos: «If this element is the root element, it must have a version attribute.», «note must not occur among the children or descendants of note» y «@linkend on footnoteref must point to a footnote.».
- Sobre los 21 canónicos de dos libros reales (Duek, publicado; Califa, en corrección), capítulos y libro ensamblado: cero incumplimientos y ningún aborto. En el libro de Califa las reglas se dispararon 7113 veces.
- Toda salida contiene `schematron-output` (la comprobación de GV-28): es el informe, no la hoja.

COSTO

- Una llamada por archivo: unos 2,3 s, casi todo el arranque de la JVM y la carga de la hoja compilada.
- Una sola llamada sobre una carpeta (`-s:carpeta -o:carpeta/`): los 11 archivos de Califa en 3,6 s. El modo carpeta toma la carpeta entera, no una lista.

LÍMITE: el corpus real no tiene figuras ni cuadros. Las reglas de exclusión se probaron solo con instancias sintéticas.',
   'vigente', 'empirica',
   'SaxonJ-HE 12.5 / esqueleto ISO iso_svrl_for_xslt2.xsl del repositorio / DocBook 5.2 RNG / Java 21; contenedor Ubuntu; canónicos de Duek y Califa',
   '2026-10', 'apoya:SC-52,vinculo:GV-26,vinculo:GV-28,vinculo:GV-XML-02',
   NULL,
   30, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-XML-03 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-XML-03';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE prefijo = 'GV-XML'
 ORDER BY numero;
