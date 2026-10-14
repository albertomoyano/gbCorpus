-- ============================================================
-- gbCorpus — actualización 27: controles de corrección del .md
-- Esquema: 1
-- Origen: prueba de Alberto con un libro real: una llamada a nota sin
--         definición salió como «[^3]» en el PDF, sin aviso. Decisión de
--         Alberto: un lugar donde sumar controles, con los niveles que
--         propuso Claude (los tres casos de notas, error; los [WARNING] de
--         pandoc, aviso). Las comillas sin cerrar quedan para después.
--         Cotejado con docs/corpus.md de gbpublisher (GitHub, confirmado al
--         día), con la carpeta local de gbCorpus (último script: act-26) y
--         con una copia de la base local.
-- Fecha:  2026-10-14
--
-- ALTAS:
--   GV-99  Pandoc 3.1.3: las notas mal armadas pasan sin error y la
--          mayoría sin aviso
--   SC-54  Controles de corrección del .md: un filtro en engine/ con
--          niveles declarados
--
-- MODIFICA:
--   SC-53  vínculo a SC-54
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: CÓDIGOS LIBRES
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-99 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-99' OR (prefijo = 'GV' AND numero = 99);
INSERT INTO verificacion SELECT 'GV-98 es la última GV', MAX(numero) = 98 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-54 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-54' OR (prefijo = 'SC' AND numero = 54);
INSERT INTO verificacion SELECT 'SC-53 es la última SC', MAX(numero) = 53 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'SC-53 sin vínculo a SC-54', instr(relaciones, 'SC-54') = 0 FROM entradas WHERE codigo = 'SC-53';

-- ------------------------------------------------------------
-- 2. GV-99: LO MEDIDO
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 99, 'GV-99', 'Pandoc 3.1.3: las notas mal armadas pasan sin error y la mayoría sin aviso',
   'Medido con Pandoc 3.1.3, lector markdown, sin filtros:

    en el .md                              resultado                                ¿avisa?
    [^3] sin definición                    texto literal «[^3]»; no hay nota         no
    [^3]: sin contenido, al final          Note [] — una nota vacía                  no
    [^3]: vacía y debajo un párrafo        el párrafo pasa a ser el contenido de     no
                                           la nota y desaparece del texto
    [^2]: definida y nunca llamada         la nota se descarta                       sí, [WARNING]

El tercer caso es el grave: un párrafo se pierde sin ningún mensaje. En el AST ya no queda rastro (`Para "Antes."`, `Para "Después."` y nada entre los dos), así que solo se detecta sobre el texto fuente.

La llamada suelta llega como parte de un `Str` (`Str "Texto.[^3]"`): se puede buscar en el AST, y los bloques de código, que no tienen `Str`, quedan fuera solos.

El `[WARNING]` de la nota sin llamar lo emite el lector: sale igual en cualquier pasada sobre el mismo archivo, con o sin filtros.

Es el equivalente de `\footnote{}` en LaTeX, que compila sin error y deja la marca al pie vacía; según Alberto, no hay forma de hacer que el compilador falle con eso.',
   'vigente', 'empirica', 'Pandoc 3.1.3 / contenedor Ubuntu 24.04; el caso de la llamada suelta, en Linux Mint con un libro real', '2026-10',
   'apoya:SC-54,vinculo:SC-46', NULL,
   990, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-99 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-99' AND orden = 990;

-- ------------------------------------------------------------
-- 3. SC-54: LA DECISIÓN
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 54, 'SC-54', 'Controles de corrección del .md: un filtro en engine/ con niveles declarados',
   'DECISIÓN CERRADA (decisión de Alberto). Lo que el Markdown deja pasar sin error y llega mal al impreso —un error que se le puede pasar a la corrección— se controla al generar el canónico de cada capítulo, en un solo lugar donde los controles se van sumando a medida que el uso los muestra. El caso que lo originó: una llamada a nota sin su definición salió como «[^3]» literal en el PDF (GV-99).

DÓNDE

`engine/controles_md.lua`, en una pasada de pandoc propia que `generar_canonicos_capitulos.sh` corre antes de la conversión:

    pandoc ARCHIVO.md --from markdown --to plain
           --lua-filter engine/controles_md.lua
           --metadata gb-controles=tmp/controles-{base}.tsv --output /dev/null

- Pasada aparte y sin los filtros de producción, por el criterio de SC-46: `fenced-divs` serializa los divs a XML crudo y después ya no hay texto que revisar, y otros filtros frenan. Así el control ve el documento como lo escribió la corrección, también adentro de un recuadro.
- En `engine/` y no en `filters/`: un control que dice «este capítulo está bien» no se ajusta localmente (SC-11).

EL CONTRATO

- El informe va a un archivo, no a stderr, para no mezclarse con los mensajes de pandoc. Un hallazgo por línea: `nivel TAB control TAB mensaje`.
- El filtro lo escribe siempre, vacío si no hay hallazgos. Si falta, el control no corrió y el capítulo falla: no se da por revisado lo que no se revisó.
- `error`: el capítulo no se genera y su canónico anterior se borra (SC-53), así que «Ensamblar» se niega hasta corregirlo. `aviso`: se genera y el lote termina con código 3.
- El script no conoce ningún control por su nombre: lee el nivel. Un nivel que no conoce es un fallo.
- Los `[WARNING]` del lector de pandoc en esta pasada son también aviso. En la de conversión se omiten las líneas idénticas, para no informarlos dos veces.

CÓMO SE SUMA UN CONTROL

1. Una línea en la tabla `CONTROLES` del filtro, con su nombre y su nivel.
2. Una función que llama a `registrar(nombre, mensaje)`.
3. Su llamada en `Pandoc()`.

Cambiar el nivel de un control es cambiar esa tabla.

LOS CONTROLES

    llamada_sin_nota       error   [^3] en el texto sin su definición
    nota_vacia             error   una nota sin texto (\footnote{})
    definicion_sin_texto   error   [^3]: con la línea vacía, sobre el texto
                                   fuente; informa el número de línea
    [WARNING] de pandoc    aviso   entre ellos, nota definida y nunca llamada

`definicion_sin_texto` lee el archivo fuente (`PANDOC_STATE.input_files`) porque en el AST el caso ya no existe (GV-99), y saltea los bloques de código cercados con ``` o ~~~. Una definición de nota vacía al final del archivo la informan dos controles, `definicion_sin_texto` (con la línea) y `nota_vacia`: es el mismo error.',
   'vigente', 'empirica', 'Pandoc 3.1.3 / bash / contenedor Ubuntu 24.04: controles_md.lua solo y dentro de generar_canonicos_capitulos.sh, con un lote de un capítulo limpio, uno con aviso y uno con dos errores', '2026-10',
   'vinculo:SC-53,vinculo:SC-46,vinculo:SC-11,vinculo:SC-13,apoya:GV-99',
   '(1) Pasar a este mecanismo, como aviso, las comillas sin cerrar que hoy informa guillemets-to-quoted-db.lua por stderr, y sacar el mensaje del filtro de producción. (2) Revistas: usar el mismo filtro cuando su cadena se migre a engine/ (SC-13). (3) Probar en Mint con un libro real los tres errores y el aviso.',
   540, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-54 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-54' AND orden = 540;

-- ------------------------------------------------------------
-- 4. SC-53: VÍNCULO
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-54',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 vinculada', instr(relaciones, 'vinculo:SC-54') > 0 FROM entradas WHERE codigo = 'SC-53';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('GV-99', 'SC-53', 'SC-54') ORDER BY prefijo DESC, numero;
