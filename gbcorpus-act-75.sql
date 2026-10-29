-- ============================================================
-- gbCorpus — actualización 75: entrega 1 del validador implementada
-- Esquema: 1
-- Origen: conversación del 29/10. Implementación y prueba en Linux Mint de
--         la entrega 1 de SC-75 (documento de trabajo
--         `claude/validador-docbook.md`). El freno se extendió al EPUB
--         (decisión de Alberto), y SC-53 y SC-54 pasan a describir el
--         código nuevo.
-- Fecha:  2026-10-29
-- Aplicar: después de act-74
--
-- MODIFICA:
--   SC-75      implementada: EPUB en el freno, recursos, en el código,
--              medido; evidencia, entorno y pendiente
--   SC-53      la pieza suelta la valida validar_canonicos.sh; usos;
--              pendiente; relación con SC-75
--   SC-54      gb-fuentes en la invocación y en el contrato; relación
--   SC-52      pendiente: la versión anclada de Saxon
--   GV-XML-03  entorno: también SaxonJ-HE 12.9 en Linux Mint
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: CADA TEXTO A REEMPLAZAR, UNA SOLA VEZ
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-75 texto 1: una vez', (length(cuerpo) - length(replace(cuerpo, '`claude/validador-docbook.md`). Todavía no implementada. Revistas', ''))) = length('`claude/validador-docbook.md`). Todavía no implementada. Revistas') FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 2: una vez', (length(cuerpo) - length(replace(cuerpo, '    [5] recursos      imagedata/@fileref resuelto desde jats/: existe y
                      está en media/. Sin comprobar direcciones de red', ''))) = length('    [5] recursos      imagedata/@fileref resuelto desde jats/: existe y
                      está en media/. Sin comprobar direcciones de red') FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 3: una vez', (length(cuerpo) - length(replace(cuerpo, '    estado           ensamblado     PDF            validador   apertura
    desactualizado   FRENO          FRENO          aviso       mensaje
    huérfano         (no lo ve)     (no lo ve)     aviso       mensaje
    sin huella       aviso          aviso          tenue       nada', ''))) = length('    estado           ensamblado     PDF            validador   apertura
    desactualizado   FRENO          FRENO          aviso       mensaje
    huérfano         (no lo ve)     (no lo ve)     aviso       mensaje
    sin huella       aviso          aviso          tenue       nada') FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 4: una vez', (length(cuerpo) - length(replace(cuerpo, '- FRENO, decisión de Alberto, en los DOS consumidores: `ensamblar_libro.sh` junta todos los capítulos desactualizados y no ensambla; `preparar_latex_libro.sh` hace fallar la pieza, como ya hace con un estilo que no coincide (SC-57). Frenar solo al ensamblar dejaría al PDF con la versión vieja.', ''))) = length('- FRENO, decisión de Alberto, en los DOS consumidores: `ensamblar_libro.sh` junta todos los capítulos desactualizados y no ensambla; `preparar_latex_libro.sh` hace fallar la pieza, como ya hace con un estilo que no coincide (SC-57). Frenar solo al ensamblar dejaría al PDF con la versión vieja.') FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 5: una vez', (length(cuerpo) - length(replace(cuerpo, '- Entra en `BloquearSalidas` (SC-53); al desbloquear vuelve a habilitarse solo si el proyecto es un libro.', ''))) = length('- Entra en `BloquearSalidas` (SC-53); al desbloquear vuelve a habilitarse solo si el proyecto es un libro.') FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-53 texto 6: una vez', (length(cuerpo) - length(replace(cuerpo, 'Un script que valida una parte del libro por separado —hoy, el canónico de cada capítulo— no cuenta como aviso', ''))) = length('Un script que valida una parte del libro por separado —hoy, el canónico de cada capítulo— no cuenta como aviso') FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 texto 7: una vez', (length(cuerpo) - length(replace(cuerpo, 'Un IDREF colgado de verdad lo marca la validación del libro en `ensamblar_libro.sh`, que lo cuenta como aviso.', ''))) = length('Un IDREF colgado de verdad lo marca la validación del libro en `ensamblar_libro.sh`, que lo cuenta como aviso.') FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 texto 8: una vez', (length(cuerpo) - length(replace(cuerpo, '`preparar_latex_libro.sh` y `compilar_pdf_libro.sh`. Este último fue el último en pasar', ''))) = length('`preparar_latex_libro.sh` y `compilar_pdf_libro.sh`. Este último fue el último en pasar') FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-54 texto 9: una vez', (length(cuerpo) - length(replace(cuerpo, '           --metadata gb-controles=tmp/controles-{base}.tsv
           --metadata gb-proyecto=RAIZ --output /dev/null', ''))) = length('           --metadata gb-controles=tmp/controles-{base}.tsv
           --metadata gb-proyecto=RAIZ --output /dev/null') FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 texto 10: una vez', (length(cuerpo) - length(replace(cuerpo, '- El filtro lo escribe siempre, vacío si no hay hallazgos. Si falta, el control no corrió y el capítulo falla: no se da por revisado lo que no se revisó.', ''))) = length('- El filtro lo escribe siempre, vacío si no hay hallazgos. Si falta, el control no corrió y el capítulo falla: no se da por revisado lo que no se revisó.') FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-53 sin SC-75', instr(relaciones, 'SC-75') = 0 FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-54 sin SC-75', instr(relaciones, 'SC-75') = 0 FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-52 pendiente original', pendiente LIKE 'Mini-test: si SaxonJ-HE 12.5 acepta%' FROM entradas WHERE codigo = 'SC-52';

-- ------------------------------------------------------------
-- 2. TEXTOS
-- ------------------------------------------------------------
UPDATE entradas SET cuerpo = replace(cuerpo, '`claude/validador-docbook.md`). Todavía no implementada. Revistas', '`claude/validador-docbook.md`). Entrega 1 implementada y probada en Linux Mint (29/10). Revistas'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 1: aplicado', instr(cuerpo, '`claude/validador-docbook.md`). Entrega 1 implementada y probada en Linux Mint (29/10). Revistas') > 0 FROM entradas WHERE codigo = 'SC-75';
UPDATE entradas SET cuerpo = replace(cuerpo, '    [5] recursos      imagedata/@fileref resuelto desde jats/: existe y
                      está en media/. Sin comprobar direcciones de red', '    [5] recursos      cada imagedata/@fileref, sin los ../ y ./ del
                      principio, es media/{nombre} y existe. Una subcarpeta
                      de media/ es aviso: LaTeX la encuentra, pero HTML y
                      EPUB se quedan con el nombre y lo buscan en media/.
                      Sin comprobar direcciones de red'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 2: aplicado', instr(cuerpo, '    [5] recursos      cada imagedata/@fileref, sin los ../ y ./ del
                      principio, es media/{nombre} y existe. Una subcarpeta
                      de media/ es aviso: LaTeX la encuentra, pero HTML y
                      EPUB se quedan con el nombre y lo buscan en media/.
                      Sin comprobar direcciones de red') > 0 FROM entradas WHERE codigo = 'SC-75';
UPDATE entradas SET cuerpo = replace(cuerpo, '    estado           ensamblado     PDF            validador   apertura
    desactualizado   FRENO          FRENO          aviso       mensaje
    huérfano         (no lo ve)     (no lo ve)     aviso       mensaje
    sin huella       aviso          aviso          tenue       nada', '    estado           ensamblado   PDF        EPUB       validador   apertura
    desactualizado   FRENO        FRENO      FRENO      aviso       mensaje
    huérfano         FRENO*       FRENO*     FRENO*     aviso       mensaje
    sin huella       aviso        aviso      aviso      tenue       nada

    * solo si la pieza está en la lista del consumidor: un huérfano suelto
      en jats/ no entra en ninguna, y solo lo ven el validador y la apertura'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 3: aplicado', instr(cuerpo, '    estado           ensamblado   PDF        EPUB       validador   apertura
    desactualizado   FRENO        FRENO      FRENO      aviso       mensaje
    huérfano         FRENO*       FRENO*     FRENO*     aviso       mensaje
    sin huella       aviso        aviso      aviso      tenue       nada

    * solo si la pieza está en la lista del consumidor: un huérfano suelto
      en jats/ no entra en ninguna, y solo lo ven el validador y la apertura') > 0 FROM entradas WHERE codigo = 'SC-75';
UPDATE entradas SET cuerpo = replace(cuerpo, '- FRENO, decisión de Alberto, en los DOS consumidores: `ensamblar_libro.sh` junta todos los capítulos desactualizados y no ensambla; `preparar_latex_libro.sh` hace fallar la pieza, como ya hace con un estilo que no coincide (SC-57). Frenar solo al ensamblar dejaría al PDF con la versión vieja.', '- FRENO, decisión de Alberto, en los TRES consumidores de los canónicos de capítulo: `ensamblar_libro.sh` junta todos los capítulos desactualizados y no ensambla, y con él frena el HTML, que lo llama anidado; `preparar_latex_libro.sh` hace fallar la pieza, como ya hace con un estilo que no coincide (SC-57); `generar_epub_libro.sh`, que no ensambla y transforma cada capítulo por separado, lo cuenta como problema y no genera el EPUB. Frenar solo al ensamblar dejaba al PDF y al EPUB con la versión vieja.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 4: aplicado', instr(cuerpo, '- FRENO, decisión de Alberto, en los TRES consumidores de los canónicos de capítulo: `ensamblar_libro.sh` junta todos los capítulos desactualizados y no ensambla, y con él frena el HTML, que lo llama anidado; `preparar_latex_libro.sh` hace fallar la pieza, como ya hace con un estilo que no coincide (SC-57); `generar_epub_libro.sh`, que no ensambla y transforma cada capítulo por separado, lo cuenta como problema y no genera el EPUB. Frenar solo al ensamblar dejaba al PDF y al EPUB con la versión vieja.') > 0 FROM entradas WHERE codigo = 'SC-75';
UPDATE entradas SET cuerpo = replace(cuerpo, '- Entra en `BloquearSalidas` (SC-53); al desbloquear vuelve a habilitarse solo si el proyecto es un libro.', '- Entra en `BloquearSalidas` (SC-53); al desbloquear vuelve a habilitarse solo si el proyecto es un libro.

EN EL CÓDIGO

- `engine/validar_canonicos.sh`; en `comun.sh`, `vigencia_canonico`, que reemplazó a `avisar_md_posterior` y deja el resultado en `VIGENCIA_ESTADO` y `VIGENCIA_DETALLE`.
- La huella: `controles_md.lua` (`gb-fuentes`, SC-54), `generar_canonicos_capitulos.sh` (`tmp/huellas-{base}.xml`), `ensamblar-capitulo-canonico.xsl` (parámetro `huellas`, obligatorio) y `ensamblar-libro-canonico.xsl` (copia las PI de cada capítulo).
- El Schematron compilado lo genera `generar-schematron-docbook.sh`, en la raíz del repositorio, con cuatro instancias de prueba que tienen que dar lo esperado antes de reemplazar la hoja.
- En Gambas, `m_GenerarSalidasLibro`: `HabilitarValidacion` (apartado 20 de `FMain.AbrirProyectoMD`), `ValidarCanonico` (`btnValidarXML_Click`), `RevisarVigenciaLibro` (apartado 23) e `InformarValidacion`, con textos propios: un validador no genera nada.

MEDIDO

- Las tres salidas del libro con y sin `<?gb-fuente?>` en el prólogo: LaTeX (8 piezas), HTML (9 archivos) y EPUB (8 páginas) idénticos byte a byte.
- Regenerar un canónico sin cambios en el .md reproduce el anterior salvo las PI. Un `touch` o una fecha vieja en el .md siguen dando «vigente»; cambiar el .md o un cuadro, o borrar un cuadro, da «desactualizado» en el capítulo y en el libro.
- En Linux Mint con Duek y Califa: el lote con las huellas, el ensamblado vigente y válido, el PDF, el freno del EPUB con seis capítulos modificados a propósito, el aviso al abrir y el botón.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-75 texto 5: aplicado', instr(cuerpo, '- Entra en `BloquearSalidas` (SC-53); al desbloquear vuelve a habilitarse solo si el proyecto es un libro.

EN EL CÓDIGO

- `engine/validar_canonicos.sh`; en `comun.sh`, `vigencia_canonico`, que reemplazó a `avisar_md_posterior` y deja el resultado en `VIGENCIA_ESTADO` y `VIGENCIA_DETALLE`.
- La huella: `controles_md.lua` (`gb-fuentes`, SC-54), `generar_canonicos_capitulos.sh` (`tmp/huellas-{base}.xml`), `ensamblar-capitulo-canonico.xsl` (parámetro `huellas`, obligatorio) y `ensamblar-libro-canonico.xsl` (copia las PI de cada capítulo).
- El Schematron compilado lo genera `generar-schematron-docbook.sh`, en la raíz del repositorio, con cuatro instancias de prueba que tienen que dar lo esperado antes de reemplazar la hoja.
- En Gambas, `m_GenerarSalidasLibro`: `HabilitarValidacion` (apartado 20 de `FMain.AbrirProyectoMD`), `ValidarCanonico` (`btnValidarXML_Click`), `RevisarVigenciaLibro` (apartado 23) e `InformarValidacion`, con textos propios: un validador no genera nada.

MEDIDO

- Las tres salidas del libro con y sin `<?gb-fuente?>` en el prólogo: LaTeX (8 piezas), HTML (9 archivos) y EPUB (8 páginas) idénticos byte a byte.
- Regenerar un canónico sin cambios en el .md reproduce el anterior salvo las PI. Un `touch` o una fecha vieja en el .md siguen dando «vigente»; cambiar el .md o un cuadro, o borrar un cuadro, da «desactualizado» en el capítulo y en el libro.
- En Linux Mint con Duek y Califa: el lote con las huellas, el ensamblado vigente y válido, el PDF, el freno del EPUB con seis capítulos modificados a propósito, el aviso al abrir y el botón.') > 0 FROM entradas WHERE codigo = 'SC-75';
UPDATE entradas SET cuerpo = replace(cuerpo, 'Un script que valida una parte del libro por separado —hoy, el canónico de cada capítulo— no cuenta como aviso', 'La validación de una parte del libro por separado —hoy, el canónico de cada capítulo— la hace `validar_canonicos.sh` (SC-75), que no cuenta como aviso'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 texto 6: aplicado', instr(cuerpo, 'La validación de una parte del libro por separado —hoy, el canónico de cada capítulo— la hace `validar_canonicos.sh` (SC-75), que no cuenta como aviso') > 0 FROM entradas WHERE codigo = 'SC-53';
UPDATE entradas SET cuerpo = replace(cuerpo, 'Un IDREF colgado de verdad lo marca la validación del libro en `ensamblar_libro.sh`, que lo cuenta como aviso.', 'Un IDREF colgado de verdad lo marca la validación del libro, que `ensamblar_libro.sh` le pide al mismo validador y que lo cuenta como aviso.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 texto 7: aplicado', instr(cuerpo, 'Un IDREF colgado de verdad lo marca la validación del libro, que `ensamblar_libro.sh` le pide al mismo validador y que lo cuenta como aviso.') > 0 FROM entradas WHERE codigo = 'SC-53';
UPDATE entradas SET cuerpo = replace(cuerpo, '`preparar_latex_libro.sh` y `compilar_pdf_libro.sh`. Este último fue el último en pasar', '`preparar_latex_libro.sh`, `compilar_pdf_libro.sh` y `validar_canonicos.sh` (SC-75). `compilar_pdf_libro.sh` fue el último en pasar'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 texto 8: aplicado', instr(cuerpo, '`preparar_latex_libro.sh`, `compilar_pdf_libro.sh` y `validar_canonicos.sh` (SC-75). `compilar_pdf_libro.sh` fue el último en pasar') > 0 FROM entradas WHERE codigo = 'SC-53';
UPDATE entradas SET cuerpo = replace(cuerpo, '           --metadata gb-controles=tmp/controles-{base}.tsv
           --metadata gb-proyecto=RAIZ --output /dev/null', '           --metadata gb-controles=tmp/controles-{base}.tsv
           --metadata gb-fuentes=tmp/fuentes-{base}.txt
           --metadata gb-proyecto=RAIZ --output /dev/null'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 texto 9: aplicado', instr(cuerpo, '           --metadata gb-controles=tmp/controles-{base}.tsv
           --metadata gb-fuentes=tmp/fuentes-{base}.txt
           --metadata gb-proyecto=RAIZ --output /dev/null') > 0 FROM entradas WHERE codigo = 'SC-54';
UPDATE entradas SET cuerpo = replace(cuerpo, '- El filtro lo escribe siempre, vacío si no hay hallazgos. Si falta, el control no corrió y el capítulo falla: no se da por revisado lo que no se revisó.', '- El filtro lo escribe siempre, vacío si no hay hallazgos. Si falta, el control no corrió y el capítulo falla: no se da por revisado lo que no se revisó.
- En `gb-fuentes` escribe los `cuadros/{id}.md` que nombra el .md, uno por línea, con la misma regla id → archivo que `cuadro-leer.lua`. Mismo contrato: siempre escrito, vacío si no hay cuadros; si falta, el capítulo falla. No es un control y no registra nada: con esa lista `generar_canonicos_capitulos.sh` anota las huellas del canónico (SC-75). Va acá y no en `cuadro-leer.lua` porque este filtro está en `engine/` y no se modifica (SC-11).'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 texto 10: aplicado', instr(cuerpo, '- El filtro lo escribe siempre, vacío si no hay hallazgos. Si falta, el control no corrió y el capítulo falla: no se da por revisado lo que no se revisó.
- En `gb-fuentes` escribe los `cuadros/{id}.md` que nombra el .md, uno por línea, con la misma regla id → archivo que `cuadro-leer.lua`. Mismo contrato: siempre escrito, vacío si no hay cuadros; si falta, el capítulo falla. No es un control y no registra nada: con esa lista `generar_canonicos_capitulos.sh` anota las huellas del canónico (SC-75). Va acá y no en `cuadro-leer.lua` porque este filtro está en `engine/` y no se modifica (SC-11).') > 0 FROM entradas WHERE codigo = 'SC-54';

-- ------------------------------------------------------------
-- 3. EVIDENCIA, ENTORNO, PENDIENTE Y RELACIONES
-- ------------------------------------------------------------
UPDATE entradas SET evidencia = 'empirica', entorno = 'gbpublisher / jing 20220510-3 / SaxonJ-HE 12.5 (contenedor) y 12.9 (Linux Mint) / Pandoc 3.1.3 / libxml 2.9.14 (contenedor) / gbc3 3.19 / contenedor Ubuntu 24.04 y Linux Mint con Duek y Califa', pendiente = '(1) Probar en Mint que el botón queda deshabilitado en una revista, y «Todos los canónicos» en Califa (bibliografía consolidada) para ver las remisiones en tenue. (2) Confirmar en Mint la versión de libxml (xmllint --version). (3) Entrega 2: discutir regla por regla el Schematron propio y los formatos de imagen por salida.', fecha_verificacion = '2026-10', fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-75';
UPDATE entradas SET pendiente = 'Probado en Mint con libros reales: «Canónico archivo en curso», «Todos los canónicos», «Ensamblar» y un lote en el que fallan cuatro capítulos (sus canónicos anteriores se borran). Falta ver «Ensamblar» negándose con un canónico borrado, y «Todos los canónicos» en un libro con bibliografía consolidada en Mint (remisiones en tenue, código 0; medido en contenedor con Califa). Hecho eso, quitar este pendiente.', relaciones = CASE WHEN relaciones = '' THEN 'vinculo:SC-75' ELSE relaciones || ',' || 'vinculo:SC-75' END, fecha_verificacion = '2026-10', fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-53';
UPDATE entradas SET relaciones = CASE WHEN relaciones = '' THEN 'vinculo:SC-75' ELSE relaciones || ',' || 'vinculo:SC-75' END, fecha_verificacion = '2026-10', fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-54';
UPDATE entradas
   SET pendiente = pendiente || ' (2) La versión anclada de Saxon: buena parte del corpus dice SaxonJ-HE 12.5 y en Linux Mint está la 12.9; nada en el código la fija (m_Constantes solo da la ruta). Decidir cuál es la del proyecto y dónde se verifica.',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-52';
INSERT INTO verificacion SELECT 'SC-52 pendiente agregado', instr(pendiente, 'La versión anclada de Saxon') > 0 FROM entradas WHERE codigo = 'SC-52';
UPDATE entradas
   SET entorno = entorno || '; en Linux Mint, SaxonJ-HE 12.9 con generar-schematron-docbook.sh (las cuatro instancias de prueba, como se esperaba)',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'GV-XML-03';
INSERT INTO verificacion SELECT 'GV-XML-03 entorno', instr(entorno, 'SaxonJ-HE 12.9') > 0 FROM entradas WHERE codigo = 'GV-XML-03';
INSERT INTO verificacion SELECT 'SC-75 empírica', evidencia = 'empirica' FROM entradas WHERE codigo = 'SC-75';
INSERT INTO verificacion SELECT 'SC-53 con SC-75', instr(relaciones, 'vinculo:SC-75') > 0 FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-54 con SC-75', instr(relaciones, 'vinculo:SC-75') > 0 FROM entradas WHERE codigo = 'SC-54';

COMMIT;

SELECT codigo, estado, evidencia, titulo FROM entradas
 WHERE codigo IN ('SC-52', 'SC-53', 'SC-54', 'SC-75', 'GV-XML-03')
 ORDER BY prefijo, numero;
