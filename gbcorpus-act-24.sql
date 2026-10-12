-- ============================================================
-- gbCorpus — actualización 24: familia GV-XML y verificación en XML
-- Esquema: 1
-- Origen: conversación con Alberto sobre cómo reducir el error de
--         Claude en XML, JATS y DocBook. Cotejado con docs/corpus.md
--         de gbpublisher (GitHub, igual al local) y con la carpeta
--         local de gbCorpus (último script: act-23).
-- Fecha:  2026-10-12
--
-- ALTAS:
--   Familia GV-XML  Comportamientos verificados XML (fuera del
--                   bloque operativo, como GV)
--   SC-52           Verificación en XML, JATS y DocBook: lo que no
--                   pasa el validador no está verificado
--
-- MODIFICA:
--   SC-50  el cotejo previo: gbpublisher se lee de GitHub, previa
--          pregunta de si está al día; gbCorpus y gbShortcodes, de la
--          carpeta local, y de ahí sale el número del script nuevo.
--          El corpus.md adjunto al proyecto no se coteja
--   GV     descripción de la familia: ya no es solo gambas-verificado.md
--          y remite a GV-XML
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: NOMBRES LIBRES Y TEXTOS COMO SE LOS CITA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-XML libre', COUNT(*) = 0 FROM familias WHERE prefijo = 'GV-XML';
INSERT INTO verificacion SELECT 'GV es la última familia', orden = (SELECT MAX(orden) FROM familias) FROM familias WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'GV descripción de partida', descripcion = 'Evidencia empírica de gambas-verificado.md' FROM familias WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-52 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-52' OR (prefijo = 'SC' AND numero = 52);
INSERT INTO verificacion SELECT 'SC-51 es la última SC', MAX(numero) = 51 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'SC-50 cotejo de partida', (length(cuerpo) - length(replace(cuerpo, 'El estado vigente se lee de los repositorios de GitHub.

- Corpus: `docs/corpus.md` del repositorio de gbpublisher, clonado con `git clone --depth 1`, se coteja con el `corpus.md` adjunto al proyecto de trabajo con Claude: mismas entradas, mismos estados y pasajes testigo idénticos. Si el del repositorio es el más reciente, se adopta sin consultar y se dice en una línea. Si el más reciente es el adjunto —caso raro, porque el repositorio recibe cada exportación—, o si cada uno tiene algo que el otro no tiene, se avisa y se espera la respuesta antes de hacer nada.
- Catálogo de shortcodes: el `_catalogo.tsv` exportado a `.hidden/shortcodes/` de gbpublisher, y los scripts de `datos/` del repositorio de gbShortcodes.
- El número del script nuevo sale del último que está en el repositorio de cada aplicación.', ''))) = length('El estado vigente se lee de los repositorios de GitHub.

- Corpus: `docs/corpus.md` del repositorio de gbpublisher, clonado con `git clone --depth 1`, se coteja con el `corpus.md` adjunto al proyecto de trabajo con Claude: mismas entradas, mismos estados y pasajes testigo idénticos. Si el del repositorio es el más reciente, se adopta sin consultar y se dice en una línea. Si el más reciente es el adjunto —caso raro, porque el repositorio recibe cada exportación—, o si cada uno tiene algo que el otro no tiene, se avisa y se espera la respuesta antes de hacer nada.
- Catálogo de shortcodes: el `_catalogo.tsv` exportado a `.hidden/shortcodes/` de gbpublisher, y los scripts de `datos/` del repositorio de gbShortcodes.
- El número del script nuevo sale del último que está en el repositorio de cada aplicación.') FROM entradas WHERE codigo = 'SC-50';

-- ------------------------------------------------------------
-- 2. FAMILIA GV-XML: DESPUÉS DE GV, FUERA DEL BLOQUE OPERATIVO
-- ------------------------------------------------------------
INSERT INTO familias (prefijo, nombre, descripcion, orden, ancho_numero, en_operativo)
SELECT 'GV-XML',
       'Comportamientos verificados XML',
       'Evidencia empírica sobre XML, XPath, XSLT, Saxon, los validadores y los esquemas JATS y DocBook',
       MAX(orden) + 10,
       2,
       0
  FROM familias;

UPDATE familias SET descripcion = 'Evidencia empírica de Gambas, Pandoc y el resto del pipeline. Desde la actualización 24, lo de XML, XSLT y sus validadores va a GV-XML; las entradas anteriores quedan acá con su código' WHERE prefijo = 'GV';

INSERT INTO verificacion SELECT 'GV-XML alta', COUNT(*) = 1 FROM familias WHERE prefijo = 'GV-XML' AND orden > (SELECT orden FROM familias WHERE prefijo = 'GV') AND en_operativo = 0;
INSERT INTO verificacion SELECT 'GV descripción nueva', instr(descripcion, 'GV-XML') > 0 FROM familias WHERE prefijo = 'GV';

-- ------------------------------------------------------------
-- 3. SC-52: VERIFICACIÓN EN XML, JATS Y DOCBOOK
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 52, 'SC-52', 'Verificación en XML, JATS y DocBook: lo que no pasa el validador no está verificado',
   'DECISIÓN CERRADA (decisión de Alberto). Cómo se trabaja cuando Claude propone XML, XPath o XSLT para JATS o DocBook.

POR QUÉ

El riesgo no es la ignorancia sino el error verosímil: un atributo, un valor o un orden de hijos que suena correcto y que el esquema no admite, dicho con la misma seguridad que lo verificado. La estructura general suele estar bien; el error está en el detalle de qué va dentro de qué y en qué orden.

1. LO QUE NO PASA EL VALIDADOR NO ESTÁ VERIFICADO

Todo fragmento JATS o DocBook propuesto viene con una instancia mínima de prueba y el comando que la valida contra el esquema del repositorio. Una estructura se da por buena cuando el validador la acepta, no cuando parece correcta.

2. EL ESQUEMA ESTÁ EN EL REPOSITORIO, NO EN LA MEMORIA

Ante una duda de modelo de contenido —qué hijos admite un elemento, en qué orden, qué valores toma un atributo— la respuesta sale del esquema:

    JATS 1.4 Archiving   .hidden/dtd/JATS-archivearticle1-4.dtd y sus módulos
    DocBook 5.2          .hidden/schemas/docbook/docbook.rng

Si en la sesión no hay acceso al esquema, se dice y se pide el fragmento.

3. ORIGEN DECLARADO DE CADA AFIRMACIÓN

Las afirmaciones técnicas que no son triviales llevan su origen:

    [esquema]   verificado contra la DTD, el RNG o el Schematron
    [doc]       documentación oficial: Tag Library, especificación W3C, manual de Saxon
    [memoria]   conocimiento sin verificar; se verifica antes de usarlo

4. CAPAS DE VALIDEZ SEPARADAS

Válido para el esquema JATS no quiere decir que pase SciELO PS (packtools), PMC o el esquema de depósito de Crossref. Válido para el RNG de DocBook no quiere decir que lo procese bien una hoja del proyecto. Cada regla dice a qué capa pertenece.

5. LO QUE DEPENDE DE LA VERSIÓN SE PRUEBA CON EL PROCESADOR ANCLADO

El comportamiento de XSLT, XPath y los validadores se prueba con la versión anclada del proyecto, no se deduce. Caso abierto en el pendiente de esta entrada.

6. LO VERIFICADO SE ACUMULA EN GV-XML

Todo comportamiento comprobado de XML, XPath, XSLT, Saxon, xmllint, jing, Schematron, packtools y los esquemas JATS y DocBook entra como GV-XML-NN, con entorno y fecha. Las entradas anteriores sobre esos temas (GV-21, GV-22, GV-25, GV-26, GV-28, GV-71, GV-81, GV-82) quedan en GV con su código: están citadas en el código y en otras entradas, y renumerarlas rompería esas citas.',
   'vigente', 'inferida', 'JATS Archiving 1.4 / DocBook 5.2 / SaxonJ-HE 12.5', NULL,
   'vinculo:GV-21,vinculo:GV-22,vinculo:GV-25,vinculo:GV-26,vinculo:GV-28,vinculo:GV-71,vinculo:GV-81,vinculo:GV-82,vinculo:SC-50',
   'Mini-test: si SaxonJ-HE 12.5 acepta construcciones de XSLT 3.0 en una hoja declarada version="2.0". El resultado entra como GV-XML-01 y se quita este pendiente.',
   520, datetime('now','localtime'), datetime('now','localtime'));

INSERT INTO verificacion SELECT 'SC-52 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-52' AND orden = 520;

-- ------------------------------------------------------------
-- 4. SC-50: EL COTEJO PASA A SER UNA PREGUNTA
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'El estado vigente se lee de los repositorios de GitHub.

- Corpus: `docs/corpus.md` del repositorio de gbpublisher, clonado con `git clone --depth 1`, se coteja con el `corpus.md` adjunto al proyecto de trabajo con Claude: mismas entradas, mismos estados y pasajes testigo idénticos. Si el del repositorio es el más reciente, se adopta sin consultar y se dice en una línea. Si el más reciente es el adjunto —caso raro, porque el repositorio recibe cada exportación—, o si cada uno tiene algo que el otro no tiene, se avisa y se espera la respuesta antes de hacer nada.
- Catálogo de shortcodes: el `_catalogo.tsv` exportado a `.hidden/shortcodes/` de gbpublisher, y los scripts de `datos/` del repositorio de gbShortcodes.
- El número del script nuevo sale del último que está en el repositorio de cada aplicación.', 'El estado vigente se lee de dos lugares, según la aplicación:

- gbpublisher: el repositorio de GitHub, clonado con `git clone --depth 1`. Antes de leerlo, Claude pregunta si está al día; un sí lo habilita como copia de trabajo, sin más cotejo, y un no obliga a esperar el push. De ahí salen el corpus (`docs/corpus.md`) y el catálogo de shortcodes (`_catalogo.tsv` en `.hidden/shortcodes/`). El `corpus.md` adjunto al proyecto de trabajo con Claude no se coteja ni se usa.
- gbCorpus y gbShortcodes: la carpeta local de cada una en la máquina de Alberto, a la que Claude tiene acceso. No se consulta GitHub: los scripts se aplican en local y pueden no estar subidos. De ahí salen los scripts aplicados (`gbcorpus-act-NN.sql` en la raíz de gbCorpus, `datos/` de gbShortcodes).
- El número del script nuevo sale del más alto en la carpeta local de la aplicación.'),
       relaciones = relaciones || ',vinculo:SC-52',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-50';

INSERT INTO verificacion SELECT 'SC-50 actualizada', instr(cuerpo, 'Claude pregunta si está al día') > 0 AND instr(cuerpo, 'más alto en la carpeta local') > 0 AND instr(cuerpo, 'se coteja con el `corpus.md` adjunto') = 0 AND instr(relaciones, 'vinculo:SC-52') > 0 FROM entradas WHERE codigo = 'SC-50';

COMMIT;

SELECT prefijo, nombre, orden, en_operativo FROM familias WHERE prefijo IN ('GV', 'GV-XML') ORDER BY orden;
SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-50', 'SC-52') ORDER BY numero;
