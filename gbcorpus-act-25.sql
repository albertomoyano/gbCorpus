-- ============================================================
-- gbCorpus — actualización 25: scripts de engine/ como dirección del código y
--            contrato de la lanzadora
-- Esquema: 1
-- Origen: conversación con Alberto sobre unificar los canónicos DocBook en
--         menuDocBook (mDocBook). Cotejado con docs/corpus.md de gbpublisher
--         (GitHub, confirmado al día por Alberto), con la carpeta local de
--         gbCorpus (último script: act-24) y con una copia de la base local.
-- Fecha:  2026-10-14
--
-- ALTAS:
--   SC-53  Lanzadora de scripts de engine/: un solo camino, código de salida
--          por archivo de estado
--
-- MODIFICA:
--   SC-13  sección nueva antes de INTÉRPRETES ADMITIDOS: pasar a engine/ es
--          la dirección del código, no solo un criterio caso por caso
--          (decisión de Alberto); pendiente con el inventario de migración;
--          vínculo a SC-53
--   SC-32  la marca de fallo de pandoc en libros ya no la escribe
--          GenerarBodyCapituloXML, que se retiró
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: CÓDIGO LIBRE Y TEXTOS COMO SE LOS CITA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-53 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-53' OR (prefijo = 'SC' AND numero = 53);
INSERT INTO verificacion SELECT 'SC-52 es la última SC', MAX(numero) = 52 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'SC-13 ancla una vez', (length(cuerpo) - length(replace(cuerpo, 'INTÉRPRETES ADMITIDOS', ''))) / length('INTÉRPRETES ADMITIDOS') = 1 FROM entradas WHERE codigo = 'SC-13';
INSERT INTO verificacion SELECT 'SC-13 sin pendiente', pendiente IS NULL OR pendiente = '' FROM entradas WHERE codigo = 'SC-13';
INSERT INTO verificacion SELECT 'SC-32 texto una vez', (length(cuerpo) - length(replace(cuerpo, 'Un filtro que detiene la conversión ya no deja un capítulo vacío: `GenerarBodyCapituloXML` escribe una marca de fallo en lugar del fragmento y lo informa (GV-23).', ''))) / length('Un filtro que detiene la conversión ya no deja un capítulo vacío: `GenerarBodyCapituloXML` escribe una marca de fallo en lugar del fragmento y lo informa (GV-23).') = 1 FROM entradas WHERE codigo = 'SC-32';

-- ------------------------------------------------------------
-- 2. SC-13: LA DIRECCIÓN DEL CÓDIGO
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'INTÉRPRETES ADMITIDOS', 'ES LA DIRECCIÓN DEL CÓDIGO, NO SOLO UN CRITERIO PARA CADA CASO

Decisión de Alberto (2026-10). Lo que pueda ir a `engine/` va a `engine/`, preferentemente en bash; en Gambas queda solo lo que la relación entre costo, complejidad y seguridad justifique. Una función nueva no se escribe en Gambas si podría ser un script.

Queda en Gambas:

- Lo que lee o escribe la base. Los scripts no la tocan: antes del lanzamiento, Gambas escribe como archivo todo lo que el script necesita de ella (el info y la bibliografía de cada capítulo, el manifiesto del libro, la lista de un lote).
- Lo que toca la interfaz: el editor, las grillas, los diálogos y el guard de cambios sin guardar (SC-06).
- Lo que como script costaría más de lo que ahorra, o sería menos seguro. El encabezado de la función dice por qué se quedó.

Una función de Gambas que tipea en la terminal con `Input()` fuera de la lanzadora (SC-53) es deuda de migración: si la terminal está ocupada el comando se encola y corre fuera de contexto, Gambas no recibe código de salida, y la espera por la aparición de un archivo da por terminado lo que recién empezó a escribirse.

El primer caso migrado con este criterio: los canónicos de capítulo. `engine/generar_canonicos_capitulos.sh` reemplazó a `FMain.btnGenerarDocBookcanonico_Click` y a `m_XML.GenerarBodyCapituloXML`.

INTÉRPRETES ADMITIDOS'),
       pendiente = 'Inventario de las funciones que todavía tipean en la terminal con Input() fuera de la lanzadora, para ordenar la migración. Por grep, al 2026-10: FMain, las salidas de revista (m_GenerarEpub, m_GenerarSCIELO, m_GenerarDOAJ, m_GenerarHTML, m_GenerarODT, m_GenerarCROSSREF, m_GenerarPDF), m_XML, m_GitHub, m_OrdenTaller, m_FuncionesGenericas, m_InicioCierre y GenerarPDFLibro en m_GenerarSalidasLibro.',
       relaciones = relaciones || ',vinculo:SC-53',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-13';
INSERT INTO verificacion SELECT 'SC-13 actualizada', instr(cuerpo, 'ES LA DIRECCIÓN DEL CÓDIGO') > 0 AND instr(cuerpo, 'ES LA DIRECCIÓN DEL CÓDIGO') < instr(cuerpo, 'INTÉRPRETES ADMITIDOS') AND instr(relaciones, 'vinculo:SC-53') > 0 AND instr(pendiente, 'Inventario') = 1 FROM entradas WHERE codigo = 'SC-13';

-- ------------------------------------------------------------
-- 3. SC-53: LA LANZADORA
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 53, 'SC-53', 'Lanzadora de scripts de engine/: un solo camino, código de salida por archivo de estado',
   'DECISIÓN CERRADA. Todo script de `engine/` que Gambas lanza en la terminal del proyecto pasa por `m_GenerarSalidasLibro.EjecutarScriptSalida`. Es el contrato del criterio 1 de SC-13: Gambas recibe una decisión, el código de salida, y no parsea nada.

POR QUÉ NO Exec

`TerminalView.Exec()` responde «Terminal already in use»: el control ya tiene un bash interactivo corriendo (GV-42). Así que se sigue tipeando con `Input()`, pero cambia lo que Gambas espera.

QUÉ TIPEA

Una sola línea: el script con sus argumentos y, a continuación, la escritura de su código de salida en un archivo de estado.

    bash <script> <args…> ; echo $? > tmp/.estado-…tmp && mv -f tmp/.estado-…tmp tmp/.estado-…

- `;` y no `&&` después del script: el estado se escribe aunque el script falle, que es cuando más hace falta.
- `mv` dentro de la misma carpeta es atómico: el archivo de estado aparece completo y solo cuando el script terminó. Gambas espera ESE archivo, no el producto, que aparece con el primer byte.
- El nombre es único por lanzamiento. Si una línea anterior sigue encolada, cada una espera su propio estado y ninguna lee el código de la otra.
- Los argumentos van con `Shell$()`, no con `Quote()`: dentro de las comillas dobles de `Quote()` el shell sigue expandiendo `$(…)` y los backticks (GV-06). Ninguno va vacío: el que no aplica se pasa como «-», porque un argumento vacío que se pierde corre de posición a los siguientes.

MIENTRAS ESPERA

Gambas no tipea nada en la terminal. Los controles que podrían hacerlo se deshabilitan (`BloquearSalidas`), y nunca un contenedor ancestro del TerminalView, que lo apagaría con ellos (GV-42). `HayScriptEnCurso()` sirve a los guards que no pasan por esos controles: abrir otro proyecto, cerrar la aplicación. Si vence el plazo, se pregunta si seguir esperando; nunca se escribe un echo. Bloqueo, espera y desbloqueo están en la lanzadora y en ningún otro lado, con un solo camino de salida (RC-GM-20).

CÓDIGOS

Los fija `engine/comun.sh` y los replica `m_GenerarSalidasLibro`:

    0  SALIDA_OK       el producto se generó y lo verificado dio bien
    3  SALIDA_AVISOS   se generó, pero algo merece revisión
    1  SALIDA_FALLO    no se generó

Los resultados propios de la lanzadora son negativos, para no confundirse con ningún código de proceso: en curso, no lanzado, abandonado, ilegible. `InformarResultado` los traduce a un mensaje que solo afirma lo que el script verificó.

LO QUE TODO SCRIPT TRAE

- `source comun.sh`: los colores, `paso`, `ok`, `aviso`, `tenue`, `morir`. `aviso()` cuenta, y `terminar()` es la única salida normal: elige 0 o 3 según haya habido avisos, así ningún script puede olvidarse de informarlos.
- No toca la base. Lo que necesita de ella llega como archivo (SC-13).
- Escribe cada producto en un temporal de la misma carpeta, verifica que esté bien formado y recién entonces lo renombra con `mv -f`. En disco hay siempre una versión completa, nunca una a medio escribir. Es `mv` de bash y no la sentencia `Move` de Gambas, que no pisa el destino (GV-39).
- Un script que llama a otro exporta `GBP_ANIDADO=1`, y el llamado se presenta como un paso más del llamador.

LOTES

Varias unidades del mismo trabajo van en UN lanzamiento con una lista, no en un bucle de lanzamientos desde Gambas: un solo bloqueo, una sola espera, un solo código. El script sigue con las unidades que quedan cuando una falla y al final lista todas las que fallaron, porque el editor necesita ver todo lo que hay que corregir, no solo lo primero que falló. Caso: `generar_canonicos_capitulos.sh`, que recibe `tmp/lote-canonicos.tsv`.

LOS USOS

`ensamblar_libro.sh`, `generar_html_libro.sh` y `generar_canonicos_capitulos.sh`.',
   'vigente', 'empirica', 'gbpublisher / Gambas 3.22 / gb.form.terminal / bash / Linux Mint; generar_canonicos_capitulos.sh probado en contenedor Ubuntu 24.04 con Pandoc 3.1.3, SaxonJ-HE 12.5 y jing, y el proyecto compilado con gbc3 3.19', '2026-10',
   'vinculo:SC-13,vinculo:SC-06,vinculo:SC-11,vinculo:GV-06,vinculo:GV-39,vinculo:GV-42,vinculo:RC-GM-20,apoya:GV-23',
   'Probar en Mint, con un libro real, los tres ítems de menuDocBook: «Canónico archivo en curso», «Todos los canónicos» y un lote en el que un capítulo falla (su canónico anterior se borra y «Ensamblar» se niega hasta regenerarlo). Hecho eso, quitar este pendiente.',
   530, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-53 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-53' AND orden = 530 AND estado = 'vigente';

-- ------------------------------------------------------------
-- 4. SC-32: QUIÉN ESCRIBE LA MARCA DE FALLO
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'Un filtro que detiene la conversión ya no deja un capítulo vacío: `GenerarBodyCapituloXML` escribe una marca de fallo en lugar del fragmento y lo informa (GV-23).', 'Un filtro que detiene la conversión ya no deja un capítulo vacío (GV-23). En libros, `engine/generar_canonicos_capitulos.sh` no arma el fragmento, muestra el motivo del filtro y borra el canónico anterior del capítulo, para que el ensamblado no tome uno que ya no corresponde al .md. En revistas, `m_XML.GenerarBodyXML` escribe una marca de fallo en lugar del fragmento y lo informa.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-32';
INSERT INTO verificacion SELECT 'SC-32 actualizada', instr(cuerpo, 'GenerarBodyCapituloXML') = 0 AND instr(cuerpo, 'generar_canonicos_capitulos.sh') > 0 FROM entradas WHERE codigo = 'SC-32';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-13', 'SC-32', 'SC-53') ORDER BY numero;
