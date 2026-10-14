-- ============================================================
-- gbCorpus — actualización 28: controles de comillas e imágenes
-- Esquema: 1
-- Origen: pedido de Alberto: pasar las comillas sin cerrar a los
--         controles del .md (SC-54) y controlar que las imágenes que usa
--         cada .md estén en media/, sin controlar las que sobran.
--         Cotejado con la carpeta local de gbCorpus (último script: act-27)
--         y con una copia de la base local, que ya tiene act-27 (el
--         docs/corpus.md de GitHub todavía no la refleja).
-- Fecha:  2026-10-14
--
-- MODIFICA:
--   SC-54  tabla de controles con los tres nuevos; secciones IMÁGENES y
--          COMILLAS; invocación con gb-proyecto; pendiente y entorno
--   SC-30  vínculo a SC-54 (el criterio de comillas es el de su filtro)
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-54 tabla de partida', (length(cuerpo) - length(replace(cuerpo, 'LOS CONTROLES

    llamada_sin_nota       error   [^3] en el texto sin su definición
    nota_vacia             error   una nota sin texto (\footnote{})
    definicion_sin_texto   error   [^3]: con la línea vacía, sobre el texto
                                   fuente; informa el número de línea
    [WARNING] de pandoc    aviso   entre ellos, nota definida y nunca llamada

`definicion_sin_texto` lee el archivo fuente (`PANDOC_STATE.input_files`) porque en el AST el caso ya no existe (GV-99), y saltea los bloques de código cercados con ``` o ~~~. Una definición de nota vacía al final del archivo la informan dos controles, `definicion_sin_texto` (con la línea) y `nota_vacia`: es el mismo error.', ''))) / length('LOS CONTROLES

    llamada_sin_nota       error   [^3] en el texto sin su definición
    nota_vacia             error   una nota sin texto (\footnote{})
    definicion_sin_texto   error   [^3]: con la línea vacía, sobre el texto
                                   fuente; informa el número de línea
    [WARNING] de pandoc    aviso   entre ellos, nota definida y nunca llamada

`definicion_sin_texto` lee el archivo fuente (`PANDOC_STATE.input_files`) porque en el AST el caso ya no existe (GV-99), y saltea los bloques de código cercados con ``` o ~~~. Una definición de nota vacía al final del archivo la informan dos controles, `definicion_sin_texto` (con la línea) y `nota_vacia`: es el mismo error.') = 1 FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 invocación de partida', (length(cuerpo) - length(replace(cuerpo, 'pandoc ARCHIVO.md --from markdown --to plain
           --lua-filter engine/controles_md.lua
           --metadata gb-controles=tmp/controles-{base}.tsv --output /dev/null', ''))) / length('pandoc ARCHIVO.md --from markdown --to plain
           --lua-filter engine/controles_md.lua
           --metadata gb-controles=tmp/controles-{base}.tsv --output /dev/null') = 1 FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 pendiente de partida', pendiente = '(1) Pasar a este mecanismo, como aviso, las comillas sin cerrar que hoy informa guillemets-to-quoted-db.lua por stderr, y sacar el mensaje del filtro de producción. (2) Revistas: usar el mismo filtro cuando su cadena se migre a engine/ (SC-13). (3) Probar en Mint con un libro real los tres errores y el aviso.' FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-30 sin vínculo a SC-54', instr(relaciones, 'SC-54') = 0 FROM entradas WHERE codigo = 'SC-30';

-- ------------------------------------------------------------
-- 2. SC-54
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(replace(cuerpo, 'LOS CONTROLES

    llamada_sin_nota       error   [^3] en el texto sin su definición
    nota_vacia             error   una nota sin texto (\footnote{})
    definicion_sin_texto   error   [^3]: con la línea vacía, sobre el texto
                                   fuente; informa el número de línea
    [WARNING] de pandoc    aviso   entre ellos, nota definida y nunca llamada

`definicion_sin_texto` lee el archivo fuente (`PANDOC_STATE.input_files`) porque en el AST el caso ya no existe (GV-99), y saltea los bloques de código cercados con ``` o ~~~. Una definición de nota vacía al final del archivo la informan dos controles, `definicion_sin_texto` (con la línea) y `nota_vacia`: es el mismo error.', 'LOS CONTROLES

    llamada_sin_nota          error   [^3] en el texto sin su definición
    nota_vacia                error   una nota sin texto (\footnote{})
    definicion_sin_texto      error   [^3]: con la línea vacía, sobre el texto
                                      fuente; informa el número de línea
    imagen_inexistente        error   una imagen del .md que no está en media/:
                                      borrada o renombrada
    imagen_fuera_de_media     error   una imagen que apunta fuera de media/
    comillas_desbalanceadas   aviso   « » que no cierran en su lista de inlines
    [WARNING] de pandoc       aviso   entre ellos, nota definida y nunca llamada

`definicion_sin_texto` lee el archivo fuente (`PANDOC_STATE.input_files`) porque en el AST el caso ya no existe (GV-99), y saltea los bloques de código cercados con ``` o ~~~. Una definición de nota vacía al final del archivo la informan dos controles, `definicion_sin_texto` (con la línea) y `nota_vacia`: es el mismo error.

IMÁGENES

Se controla cada nodo `Image` del .md, suelto o dentro de un `::: fig`, contra la raíz del proyecto que recibe el filtro (`gb-proyecto`): las rutas se escriben relativas a ella (`media/fig-mapa.png`, SC-32). El nombre se compara exacto, con mayúsculas. Una dirección con esquema (`http:`, `https:`, `data:`) no es un archivo del proyecto y se saltea. Fuera de `media/` es error aunque el archivo exista, porque el EPUB y el HTML solo copian `media/`. NO se controla lo inverso: que `media/` tenga imágenes que ningún .md usa es normal (la tapa, los logos, figuras que se sacaron del texto). Decisión de Alberto.

COMILLAS

`comillas_desbalanceadas` aplica el mismo criterio que `guillemets-to-quoted-db.lua`, que es el que decide si arma la cita o deja los caracteres literales: cada lista de inlines se mira sola, solo cuentan los « » de sus `Str` directos, y está mal si un » cierra sin nada abierto o si al final queda un « abierto. Así el aviso coincide con lo que el filtro de producción no pudo resolver, incluida su limitación (`«un *texto» citado*` no cierra en ninguna de las dos listas). Si cambia el criterio del filtro, cambia el control. Verificado: sobre el mismo .md, los dos marcan las mismas cuatro listas.

El filtro de producción sigue escribiendo su mensaje por stderr porque revistas, que todavía no pasa por los controles, depende de él. En libros, `generar_canonicos_capitulos.sh` lo omite en la conversión: ya lo informó el control.'), 'pandoc ARCHIVO.md --from markdown --to plain
           --lua-filter engine/controles_md.lua
           --metadata gb-controles=tmp/controles-{base}.tsv --output /dev/null', 'pandoc ARCHIVO.md --from markdown --to plain
           --lua-filter engine/controles_md.lua
           --metadata gb-controles=tmp/controles-{base}.tsv
           --metadata gb-proyecto=RAIZ --output /dev/null'),
       pendiente = '(1) Revistas: usar el mismo filtro cuando su cadena se migre a engine/ (SC-13); entonces sacar el mensaje de comillas de guillemets-to-quoted-db.lua, que hoy queda solo por revistas. (2) Probar en Mint con un libro real los controles de notas, imágenes y comillas.',
       entorno = 'Pandoc 3.1.3 / bash / contenedor Ubuntu 24.04: controles_md.lua solo y dentro de generar_canonicos_capitulos.sh; los controles de notas, en Linux Mint con un libro real',
       relaciones = relaciones || ',vinculo:SC-30,vinculo:SC-32',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 actualizada', instr(cuerpo, 'imagen_inexistente') > 0 AND instr(cuerpo, 'gb-proyecto=RAIZ') > 0 AND instr(cuerpo, 'COMILLAS') > 0 AND instr(pendiente, '(1) Revistas') = 1 FROM entradas WHERE codigo = 'SC-54';

-- ------------------------------------------------------------
-- 3. SC-30: VÍNCULO
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-54',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-30';
INSERT INTO verificacion SELECT 'SC-30 vinculada', instr(relaciones, 'vinculo:SC-54') > 0 FROM entradas WHERE codigo = 'SC-30';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-30', 'SC-54') ORDER BY numero;
