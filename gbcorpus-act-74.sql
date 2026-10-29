-- ============================================================
-- gbCorpus — actualización 74: validación del canónico DocBook de libros
-- Esquema: 1
-- Origen: conversación del 29/10 (documento de trabajo
--         `claude/validador-docbook.md`). Decisiones de Alberto sobre el
--         validador, la huella de vigencia y el freno del canónico
--         desactualizado. Todavía no implementada.
-- Fecha:  2026-10-29
-- Aplicar: después de act-73
--
-- ALTAS:
--   SC-75  Validación del canónico DocBook de libros: un validador en
--          engine/, huella de las fuentes y freno del desactualizado
--
-- NO TOCA: SC-53 y SC-54 describen lo que hoy hace el código. Se
--          actualizan cuando se implemente la entrega 1 (pendiente de
--          SC-75).
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: act-73 APLICADA; SC-75 LIBRE
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-XML-02 existe', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-XML-02';
INSERT INTO verificacion SELECT 'GV-XML-03 existe', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-XML-03';
INSERT INTO verificacion SELECT 'SC-75 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-75' OR (prefijo = 'SC' AND numero = 75);
INSERT INTO verificacion SELECT 'relaciones existen', COUNT(*) = 8 FROM entradas WHERE codigo IN ('SC-11', 'SC-13', 'SC-32', 'SC-52', 'SC-53', 'SC-54', 'SC-57', 'SC-66');

-- ------------------------------------------------------------
-- 2. SC-75
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 75, 'SC-75', 'Validación del canónico DocBook de libros: un validador en engine/, huella de las fuentes y freno del desactualizado',
   'DECISIÓN CERRADA (Alberto, 29/10; documento de trabajo `claude/validador-docbook.md`). Todavía no implementada. Revistas y JATS4R quedan para la fase de artículos.

UN SOLO VALIDADOR

`engine/validar_canonicos.sh <ruta_proyecto> <modo> <lista_rel|->`. Lo usan el botón «Validar» del visor XML, la apertura del proyecto, `generar_canonicos_capitulos.sh` y `ensamblar_libro.sh`; estos dos dejan de validar por su cuenta y lo llaman anidado (`GBP_ANIDADO=1`, SC-53).

- Modo `completo`: todas las capas. Modo `vigencia`: solo la vigencia, sin JVM.
- La lista es un archivo de `tmp/` con una ruta de canónico por línea, relativa al proyecto. «-» es todos los `jats/c-*.xml`.
- Un lote es UNA llamada (SC-53): jing recibe todos los archivos juntos; el Schematron corre una vez sobre `tmp/validar/`, una carpeta de enlaces a la lista (GV-XML-03).
- El alcance lo da la raíz de cada archivo: `book` es libro; las raíces de pieza (`chapter`, `preface`, `appendix`, `dedication`, `acknowledgements`…) son pieza; `article` y cualquier otra, fallo.

LAS CAPAS

    [1] vigencia      las PI gb-fuente contra el disco
    [2] bien formado  xmllint; si falla, el resto «no ejecutado», nunca ✓
    [3] DocBook 5.2   jing más el Schematron del RNG compilado aparte
                      (GV-XML-02, GV-XML-03). En pieza, los IDREF sin ID
                      van en tenue (SC-53); en libro, son aviso
    [5] recursos      imagedata/@fileref resuelto desde jats/: existe y
                      está en media/. Sin comprobar direcciones de red

Entrega 1: estas cuatro capas, las huellas, la función de vigencia, el botón y la apertura. Entrega 2: el Schematron propio de gbpublisher —remisiones que jing no ve [4] y reglas del proyecto [6]: bibliomisc de ubicación, PI gb-* conocidas, alt de figuras, xml:lang— y los formatos de imagen admitidos por salida; cada regla se decide por separado.

CÓDIGOS

    0  corrieron todas las capas y no hubo hallazgos
    3  hubo hallazgos, o una capa no pudo correr (jing ausente, por ejemplo)
    1  no se pudo validar: mal formado, archivo ausente, raíz desconocida

Es la lectura de los códigos de SC-53 para un script que no genera nada. Los mensajes de Gambas no dicen «se generó»: dicen «válido», «con hallazgos» o «no se pudo validar».

EL INFORME

`tmp/validacion.tsv`, reescrito siempre, también vacío: `archivo TAB capa TAB nivel TAB mensaje`, con nivel `ok`, `aviso`, `tenue`, `fallo` o `no_ejecutado`. Lo leen los scripts que llaman al validador, para atribuir los avisos a cada capítulo. Gambas no lo lee (SC-53).

LA HUELLA DE LAS FUENTES

La vigencia es respecto de lo que se copia DENTRO del canónico: el .md y los `cuadros/{id}.md` que nombra (SC-66). Lo que solo se referencia —las imágenes— no deja viejo al canónico y lo cubre la capa de recursos. Lo que llega de la base (`tmp/info-*`, `tmp/biblio-*`) no lo cubre ninguna huella: el informe dice «vigente respecto de sus archivos fuente», no «vigente».

- sha256 y no fecha de modificación: una copia (el .md que vuelve de otra máquina) cambia la fecha sin cambiar el texto, o conserva una fecha vieja con texto nuevo.
- `controles_md.lua` lista los cuadros que nombra el .md en `tmp/fuentes-{base}.txt` (`-M gb-fuentes`), siempre escrito, vacío si no hay; si falta, el capítulo falla (el contrato de SC-54). Va en `controles_md.lua` y no en `cuadro-leer.lua` porque está en `engine/` y no se modifica (SC-11); repite la regla id → archivo de `cuadro-leer.lua`, con referencia cruzada en los dos.
- `generar_canonicos_capitulos.sh` calcula las huellas antes de pandoc, las escribe en `tmp/huellas-{base}.xml` y se las pasa a la hoja de capítulo, que escribe una `<?gb-fuente archivo="…" sha256="…"?>` por fuente antes de la raíz, con la ruta relativa al proyecto. Una ruta con comillas dobles se rechaza: el contenido de una PI no se escapa.
- La hoja del libro copia las PI de cada capítulo a su propio prólogo. Las PI del prólogo no las ve jing ni las toman las hojas de salida (GV-XML-02).

LOS ESTADOS

`vigencia_canonico` en `comun.sh` reemplaza a `avisar_md_posterior` y devuelve un estado, sin avisar por su cuenta:

    vigente         todas las fuentes coinciden
    desactualizado  alguna fuente falta o tiene otra huella
    huérfano        no existe el .md de la pieza (no aplica al libro)
    sin huella      el canónico no tiene PI gb-fuente

    estado           ensamblado     PDF            validador   apertura
    desactualizado   FRENO          FRENO          aviso       mensaje
    huérfano         (no lo ve)     (no lo ve)     aviso       mensaje
    sin huella       aviso          aviso          tenue       nada

- FRENO, decisión de Alberto, en los DOS consumidores: `ensamblar_libro.sh` junta todos los capítulos desactualizados y no ensambla; `preparar_latex_libro.sh` hace fallar la pieza, como ya hace con un estilo que no coincide (SC-57). Frenar solo al ensamblar dejaría al PDF con la versión vieja.
- «Sin huella» es aviso y no freno mientras dure la transición: todos los canónicos anteriores a esta regla la tienen, y se resuelve regenerándolos.
- Un huérfano no se borra: un canónico se reconstruye desde su .md, y un huérfano no lo tiene. Lo borra el editor.

LA APERTURA

Al abrir un libro, `RevisarVigenciaLibro` lanza el validador en modo `vigencia` con «-», por `EjecutarScriptSalida` (SC-53): toda la lógica queda en `engine/` y no hay JVM. Con código 0 no muestra nada; con 3 —que en este modo solo pueden dar desactualizados y huérfanos— avisa que el ensamblado y el PDF van a frenar y que el detalle está en la terminal. «Sin huella» no se informa al abrir: avisaría en cada apertura.

LOS RECURSOS DEL SISTEMA

El RNG y el Schematron compilado salen de los recursos del sistema, no de `~/.gbpublisher/` (SC-11): un informe que dice «válido» solo se sostiene con el esquema del paquete. En bash, `$DIR_ENGINE/..`; en Gambas, `m_InicioCierre.RutaRecursos()`, que es `.hidden/` desde el IDE y `/usr/share/gbpublisher/` instalado. No una ruta fija: haría correr al IDE con los recursos de otra versión.

El Schematron compilado (`schemas/docbook/docbook-sch.xsl`) lo genera fuera de la aplicación un script del repositorio, con la extracción y la compilación de GV-XML-03, y anota en su cabecera la huella del RNG del que salió.

LA INTERFAZ

- `btnValidarXML`, en el visor XML (`TabPanelVisor`, índice 1), valida el archivo elegido en `cmbArchivosXML`.
- En un proyecto de revista está deshabilitado: se decide en la apertura con el tipo ya resuelto (`iTipoSeleccionado`), no mirando otra vez el prefijo.
- Entra en `BloquearSalidas` (SC-53); al desbloquear vuelve a habilitarse solo si el proyecto es un libro.',
   'vigente', 'inferida',
   'gbpublisher / decisiones de diseño; mini-tests en contenedor Ubuntu con jing 20220510-3, SaxonJ-HE 12.5 y libxml 2.9.14',
   '2026-10', 'vinculo:SC-52,vinculo:SC-53,vinculo:SC-54,vinculo:SC-11,vinculo:SC-13,vinculo:SC-66,vinculo:SC-32,vinculo:SC-57,vinculo:GV-XML-02,vinculo:GV-XML-03',
   '(1) Implementar la entrega 1 y, con ella, actualizar SC-53 (quién valida y la validación de la pieza suelta) y SC-54 (gb-fuentes). (2) Mini-test: las tres salidas del libro con y sin <?gb-fuente?> en el prólogo deben salir idénticas. (3) Confirmar en Mint la versión de libxml (xmllint --version). (4) Entrega 2: discutir regla por regla el Schematron propio y los formatos de imagen por salida.',
   750, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-75 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-75';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo = 'SC-75';
