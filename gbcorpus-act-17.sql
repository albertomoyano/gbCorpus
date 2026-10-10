-- ============================================================
-- gbCorpus — actualización 17: SC-50, las aplicaciones satélite
-- Esquema: 1
-- Origen: revisión del corpus pedida por Alberto: la información sobre
--         gbCorpus, gbShortcodes y gbAyudas estaba repartida en SC-19,
--         RF-08, RF-11 y SC-24. Cotejada con los repositorios de
--         gbpublisher (996d020), gbCorpus (e782c54) y gbShortcodes
--         (ac3f916), y con las carpetas locales.
-- Fecha:  2026-10-10
--
-- ALTAS:
--   SC-50  Aplicaciones satélite de gbpublisher: un solo modelo
--
-- MODIFICA:
--   SC-19  pasa a deprecada, reemplazada por SC-50; el texto queda
--          como histórico
--   RF-08  se le quitan el alcance y la regla de trabajo, que pasan
--          a SC-50
--   RF-11  al día con el esquema 5 (grupo composicion); se le quita
--          lo que pasa a SC-50; la carga inicial con su nombre y su
--          lugar reales
--   SC-24  gbAyudas remite a SC-50
--   SC-34  se quita un título «RESALTADO» repetido y vacío
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: CÓDIGO LIBRE Y TEXTOS COMO SE LOS CITA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-50 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-50' OR (prefijo = 'SC' AND numero = 50);
INSERT INTO verificacion SELECT 'SC-19 vigente', estado = 'vigente' FROM entradas WHERE codigo = 'SC-19';
INSERT INTO verificacion SELECT 'RF-08 bloque a quitar', (length(cuerpo) - length(replace(cuerpo, 'ALCANCE DELIBERADO DE LA APLICACIÓN

gbCorpus NO da de alta ni elimina entradas ni familias. Solo lee, navega relaciones, edita texto y exporta. Las altas, bajas, cambios de estado y relaciones nuevas se acuerdan en conversación y se aplican por script SQL.

REGLA DE TRABAJO

Antes de pedir cambios sobre el corpus, exportar y compartir el `corpus.md` vigente, para que el trabajo se haga contra el estado real y no contra una copia vieja.', ''))) = length('ALCANCE DELIBERADO DE LA APLICACIÓN

gbCorpus NO da de alta ni elimina entradas ni familias. Solo lee, navega relaciones, edita texto y exporta. Las altas, bajas, cambios de estado y relaciones nuevas se acuerdan en conversación y se aplican por script SQL.

REGLA DE TRABAJO

Antes de pedir cambios sobre el corpus, exportar y compartir el `corpus.md` vigente, para que el trabajo se haga contra el estado real y no contra una copia vieja.') FROM entradas WHERE codigo = 'RF-08';
INSERT INTO verificacion SELECT 'RF-11 relación con SC-19', (length(relaciones) - length(replace(relaciones, 'vinculo:SC-19', ''))) = length('vinculo:SC-19') FROM entradas WHERE codigo = 'RF-11';
INSERT INTO verificacion SELECT 'RF-11 en versión 4', instr(cuerpo, 'ESTA ENTRADA DESCRIBE LA VERSIÓN 4 DEL ESQUEMA') > 0 FROM entradas WHERE codigo = 'RF-11';
INSERT INTO verificacion SELECT 'RF-11 cuerpo de partida', cuerpo = 'Programa aparte, con el modelo de gbCorpus (RF-08), que mantiene el catálogo de shortcodes de gbpublisher. Reemplaza a la tabla `shortcodes` de MySQL, retirada en la actualización 1.7.0 de la base de gbpublisher (SC-22, SC-34).

ESTA ENTRADA DESCRIBE LA VERSIÓN 4 DEL ESQUEMA Y DEL CONTRATO DE EXPORTACIÓN. La 2 agrega `clase`; la 3, el modo `dos-partes` y la regla de liberación; la 4, la tabla `modos`. El contrato de exportación no cambia desde la 2.

BASE

`~/.gbshortcodes/shortcodes.sqlite`, con `esquema_version`. La aplicación la crea en el primer arranque con el DDL de `m_Base.SentenciasDDL`, igual al de `shortcodes_esquema.sql` (verificado comparando `.schema`).

TABLA `shortcodes`

    nombre          TEXT NOT NULL UNIQUE   minúsculas, dígitos y guion: nombre de archivo
    clase           TEXT NOT NULL          la clase de Pandoc del .md: {.fig}, ::: epigraph, ]{.gloss}
    etiqueta        TEXT NOT NULL          lo que se ve en la lista de gbpublisher
    tipo            bloque | linea
    grupo           comun | estructura | disciplinar
    perfil          TEXT                   solo y siempre en disciplinar (CHECK)
    orden           INTEGER NOT NULL       dentro de grupo y perfil, de 10 en 10
    estado_libro    no_aplica | borrador | liberado
    estado_revista  no_aplica | borrador | liberado
    modo            el par (modo, tipo) es clave foránea a `modos`
    apertura        TEXT NOT NULL          puede tener saltos (el bloque de código)
    cierre          TEXT NOT NULL
    que_es          TEXT                   Markdown; NULL si no hay texto
    ejemplo         TEXT                   el ejemplo tal como se escribe en el .md
    como_sale       TEXT                   Markdown; NULL si no hay texto
    mapeo_docbook, mapeo_jats, notas, pendiente   internos: no se exportan
    fecha_alta, fecha_modificacion          datetime(''now'',''localtime'')

La clase es la clave con que gbpublisher valida un .md y empareja los cierres (SC-33). No es única: las variantes comparten clase (`figure` y `fig-fullwidth` son `fig`; las tres tablas, `table`). Para validar se usa el catálogo entero, en cualquier estado; para mostrar, solo lo liberado.

Restricciones: un shortcode no puede ser no_aplica en los dos; el par (modo, tipo) tiene que estar en `modos` (la figura, por ejemplo, solo existe como bloque); lo liberado tiene `que_es`, `ejemplo` y `como_sale`, y no tiene `pendiente`; un shortcode no puede estar liberado en un producto y en borrador en el otro (la regla de liberación de SC-34).

Los tres textos de la ayuda admiten NULL y no cadena vacía (`CHECK (x <> '''')`): Edit + Update escribe la cadena vacía como NULL (GV-74), y con NOT NULL guardar una sección vacía fallaba.

MODOS

Desde la versión 4 son filas de la tabla `modos` (modo, tipo, descripción), una por cada par permitido. Agregar un modo es un script de datos, no una migración; lo que hace cada modo al insertar lo decide gbpublisher (`m_Shortcodes.InsertarShortcode`). Las claves foráneas valen porque la aplicación y el importador abren la base con `PRAGMA foreign_keys = ON`; sin eso, SQLite no las controla (verificado).

- envolver: rodea la selección con apertura y cierre.
- plantilla: inserta apertura, marcador y cierre, sin selección (la sigla).
- figura: el camino de `FMain.InsertarFigura` (SC-32).
- dos-partes: envolver, con el control de la forma `{primera}{segunda}` antes de insertar (SC-35).
- separador: un bloque vacío, sin selección y con el cursor al principio de una línea vacía (SC-36). Se agrega con `datos-v4-001`.
- codigo: en bloque, pide el lenguaje (y en el listado, el nombre) y cerca la selección con `~~~ lenguaje`; en línea, la envuelve en comillas inversas (SC-42). Se agrega con `datos-v5-005`, para bloque y para línea.

QUÉ HACE LA APLICACIÓN

Lee, filtra, pule los textos (etiqueta, ayuda, mapeos, notas, pendiente) y exporta. NO da de alta ni elimina, y no cambia nombre, tipo, grupo, perfil, orden, estados, modo, apertura ni cierre: eso es comportamiento, se decide después de probarlo y se aplica por script SQL con Importar UPDATE SQL (`engine/importar_shortcodes.sh`, el contrato de SC-19 con `-- Esquema: 4`). El importador compara antes y después una huella del contenido, no solo la cantidad de filas, para no afirmar que la base quedó como estaba sin comprobarlo.

EXPORTACIÓN AL PAQUETE (CONTRATO CON gbpublisher)

A la carpeta `.hidden/shortcodes/` del proyecto gbpublisher. Van todos los shortcodes, en cualquier estado: gbpublisher filtra (instalado, solo lo liberado; desde el IDE, también los borradores).

- `_catalogo.tsv`: una cabecera fija, que hace de versión del contrato,

      nombre clase etiqueta tipo grupo perfil orden estado_libro estado_revista modo apertura cierre

  separada por tabuladores, y una línea por shortcode en el orden del catálogo: grupo (comun, estructura, disciplinar), perfil, orden, nombre. Escapes: `\\` por barra, `\t` por tabulador, `\n` por salto.
- `<nombre>.html`: fragmento, no documento. Tres secciones fijas, `<h3>Qué es</h3>`, `<h3>Cómo se escribe</h3>` y `<h3>Cómo sale</h3>`, y en la segunda la marca `<!--gb:ejemplo-->`, donde gbpublisher pone el ejemplo coloreado con su resaltador. El estilo lo pone quien lo muestra. Una sección vacía de un borrador sale «Sin completar.».
- `<nombre>.md`: el ejemplo tal cual, con salto final.

Las secciones se convierten con `pandoc -f markdown -t html --wrap=none` (Exec sobre un array, SC-05). La exportación se detiene, sin escribir nada, si una sección trae títulos, imágenes o tablas: el TextEdit de la ayuda solo tiene probados párrafos, listas, énfasis y código (GV-64). Antes de escribir exige una carpeta vacía o con `_catalogo.tsv`, y después ofrece borrar los .html y .md que no son del catálogo: todo lo que hay en la carpeta entra al .deb.

Salida determinista: dos exportaciones del mismo contenido dan archivos idénticos (verificado con diff).

OTRAS SALIDAS

- Documento de prueba, de libros o de revistas: un `.md` con un título y el ejemplo de cada shortcode que aplica, liberado o en borrador. Es lo que se compone en PDF, EPUB y HTML antes de liberar.
- Volcado SQL restaurable (verificado: restaura las 77 filas sobre una base vacía).

CARGA INICIAL

`shortcodes-carga-inicial.sql`: las 77 filas de `gbpublisher-baseline-1.0.0.sql`. Liberada solo la figura, sin pendiente desde la versión 3; los ejemplos que Pandoc no lee como se espera llevan pendiente. Los scripts que cambian shortcodes después de la carga se numeran: `gbshortcodes-act-001.sql`, `-002`… (el primero libera el epígrafe, SC-35). Los ejemplos de bloque llevan el cierre nombrado (SC-33).

MIGRACIONES DE ESQUEMA

La aplicación no abre una base de una versión anterior: dice qué script aplicar. La migración la corre el importador desde una terminal, y se reconoce por una línea de su cabecera:

    -- Migración: 1 a 2

El importador la acepta solo si la base está en la versión de partida y la de llegada es la que él maneja, y al terminar comprueba que la base quedó en la de llegada. `gbshortcodes-migrar-1-a-2.sql` rehace la tabla con la columna `clase` en su lugar (las columnas y restricciones quedan iguales a las de una base creada en v2, verificado) y pone el cierre nombrado en los ejemplos que siguen iguales a los de la carga inicial; uno editado se conserva y se lista.

`gbshortcodes-migrar-2-a-3.sql` rehace la tabla con las restricciones nuevas (SQLite no cambia un CHECK en su lugar) y copia las filas sin cambiarlas, salvo la figura: si sigue como en la carga, le quita el pendiente que pedía referencia cruzada en revistas, que no existe (SC-32). Antes de copiar comprueba la regla de liberación y frena si una fila la viola. Verificado: la base migrada tiene el mismo esquema que una creada en v3, y el DDL de la aplicación es igual al de `shortcodes_esquema.sql`.

Para correr un script de una versión, el importador tiene que ser el de esa versión: `importar_shortcodes.sh` de la 3 rechaza un script declarado `-- Esquema: 2` (medido). Por eso un cambio de datos que la migración necesita va dentro de la migración, y los scripts de datos de una versión se aplican antes de migrar a la siguiente.

NOMBRES Y LUGARES (DESDE LA VERSIÓN 4)

- `esquema-vN-a-vM.sql`: las migraciones, en `.hidden/esquema/`, que viaja en el paquete.
- `carga-inicial.sql`: también en `.hidden/esquema/`. Es el catálogo completo en la versión del programa: al pasar a la 4 se regeneró desde la carga original más `datos-v3-001` y `datos-v3-002`, porque una base nueva no puede aplicar scripts de una versión anterior. Se regenera en cada versión de esquema. Verificado: una base nueva con esta carga tiene las mismas filas que la base migrada.
- `datos-vN-NNN.sql`: los cambios de datos, en `datos/` del repositorio, numerados dentro de su versión. El nombre dice a qué versión van y en qué orden; `gbshortcodes-act-001` y `-002` pasaron a `datos-v3-001` y `datos-v3-002`. `datos/` no viaja en el paquete y la aplicación no lo lee: un script de datos se importa a mano, con «Importar script SQL». Lo que la aplicación lee está en `.hidden/esquema/`: la migración desde la versión anterior y la carga inicial.

LA APLICACIÓN MIGRA Y CARGA SOLA

Al abrir una base una versión atrás, la aplicación ofrece «Migrar» y corre su propio importador con su propio script de migración, en la pestaña Terminal (que pide la confirmación `s`). Al abrir una base sin shortcodes, ofrece la carga inicial. Los dos archivos salen de `RutaRecurso`: desde el IDE, de `.hidden/` del proyecto; instalada, de `/usr/share/gbshortcodes`. Así siempre son los de la versión que está corriendo, sin terminal externa ni ruta que elegir. Una migración que no se aplica deja la ventana abierta y bloqueada para leer el terminal. El título muestra la versión de esquema. Verificado con la aplicación bajo xvfb: una base v3 queda en v4 con sus 77 filas, y una base nueva se carga.

`esquema-v3-a-v4.sql` crea `modos` con sus filas, comprueba que todos los shortcodes usen un par existente y rehace la tabla con la clave foránea. Verificado: la base migrada tiene el mismo esquema que una creada en v4, y el DDL de la aplicación es igual al de `shortcodes_esquema.sql`.

`User.Home` no sigue la variable `HOME`: una prueba con otra `HOME` abre igual la base del usuario real (medido en 3.19).' FROM entradas WHERE codigo = 'RF-11';
INSERT INTO verificacion SELECT 'SC-24 párrafo de gbAyudas', (length(cuerpo) - length(replace(cuerpo, 'Las ayudas se escriben en gbAyudas, un programa aparte con base SQLite, al estilo de gbCorpus. A diferencia de gbCorpus, da de alta y de baja: es el editor de las ayudas.', ''))) = length('Las ayudas se escriben en gbAyudas, un programa aparte con base SQLite, al estilo de gbCorpus. A diferencia de gbCorpus, da de alta y de baja: es el editor de las ayudas.') FROM entradas WHERE codigo = 'SC-24';
INSERT INTO verificacion SELECT 'SC-34 título repetido', (length(cuerpo) - length(replace(cuerpo, '(SC-33).

RESALTADO

REGLA DE LIBERACIÓN', ''))) = length('(SC-33).

RESALTADO

REGLA DE LIBERACIÓN') FROM entradas WHERE codigo = 'SC-34';

-- ------------------------------------------------------------
-- 2. ALTA DE SC-50
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 50, 'SC-50', 'Aplicaciones satélite de gbpublisher: un solo modelo', 'DECISIÓN CERRADA (decisión de Alberto). gbCorpus, gbShortcodes y gbAyudas son aplicaciones satélite de gbpublisher y siguen un solo modelo, descrito acá. Lo propio de cada una —su base y su contrato de exportación— está en su entrada de referencia: RF-08, RF-11 y SC-24.

QUÉ SON

Programas aparte, en Gambas 3 y SQLite, que mantienen fuera de la base MySQL datos que gbpublisher consume o que gobiernan su desarrollo. Cada uno tiene su repositorio en GitHub (`albertomoyano/gbCorpus`, `albertomoyano/gbShortcodes`), su paquete `.deb` y licencia GPL v3.

    aplicación     base                                 exporta a gbpublisher
    gbCorpus       ~/.gbcorpus/corpus.sqlite            docs/corpus.md (perfil documental)
    gbShortcodes   ~/.gbshortcodes/shortcodes.sqlite    .hidden/shortcodes/
    gbAyudas       a definir (SC-24)                    .hidden/ayudas/

gbAyudas todavía no existe: cuando se construya, sigue esta entrada.

LA BASE

- Un archivo SQLite en una carpeta oculta del usuario: la aplicación puede instalarse en `/usr/bin` y la base sigue en un lugar escribible. Para moverla entre máquinas se copia la carpeta; una sola copia válida por vez.
- La tabla `esquema_version`. La aplicación la compara con su `m_Base.VERSION_ESQUEMA` y no abre una base de otra versión.
- En el primer arranque la aplicación crea la base: gbCorpus con las familias sembradas; gbShortcodes vacía, y ofrece la carga inicial.
- `PRAGMA foreign_keys = ON` en cada apertura, en la aplicación y en el importador (GV-30): sin eso las claves foráneas no se controlan.

ALCANCE: LA APLICACIÓN LEE, PULE Y EXPORTA

La aplicación consulta, navega, pule los textos y exporta. No da de alta ni elimina, y no cambia el comportamiento de lo que guarda. Las altas, las bajas, los cambios de estado y de comportamiento se acuerdan en la conversación y se aplican por script SQL. Una herramienta que crea reglas con un botón termina llena de reglas que nadie decidió.

La excepción está decidida en SC-24: gbAyudas da de alta y de baja, porque es el editor de las ayudas.

EL IMPORTADOR

`engine/importar_<aplicación>.sh` (`importar_corpus.sh`, `importar_shortcodes.sh`). Se lanza con «Importar UPDATE SQL» y corre en la pestaña Terminal (SC-13); también funciona en una terminal cualquiera. Correr el `.sql` a mano con `sqlite3` saltea el respaldo y todas las verificaciones: no se hace.

Lo que el importador ya garantiza, y el script no repite:

- Antes de escribir: `sqlite3` presente, base legible e íntegra (`integrity_check`) y `esquema_version` igual a la que maneja el importador.
- Respaldo con `VACUUM INTO` en la carpeta `respaldos` junto a la base, con rotación de 20.
- Antepone `PRAGMA foreign_keys = ON`, `.bail on` y `.changes on`: el primer error detiene todo y SQLite deshace la transacción abierta.
- Después: integridad y `foreign_key_check`. gbCorpus revisa además los vínculos de `relaciones` a códigos inexistentes y lista las entradas escritas en la corrida; gbShortcodes compara una huella del contenido antes y después, no solo la cantidad de filas.
- Código de salida: 0 aplicado, 1 no aplicado. Tras un fallo comprueba si la base quedó como estaba; no lo afirma sin mirar (SC-13).

EL SCRIPT

Lo que debe traer:

- Una cabecera de comentarios que diga qué hace, qué da de alta y qué modifica. El importador la muestra antes de pedir confirmación. Sin instrucciones para correrlo por línea de comando.
- La línea `-- Esquema: N`, con la versión de la base para la que se escribió (hoy, 1 en gbCorpus y 5 en gbShortcodes). Si falta, el importador avisa; si no coincide con la base, aborta.
- Su propia transacción, `BEGIN TRANSACTION;` … `COMMIT;`, para que las verificaciones propias queden dentro.
- Verificaciones de lo que el importador no puede saber: que un código o un nombre nuevo esté libre, que un texto a reemplazar exista exactamente una vez, que un `UPDATE` se haya aplicado. Patrón: tabla temporal con `CHECK (ok = 1)`; un `INSERT` que da 0 hace fallar la sentencia, `.bail` la detiene y la transacción se deshace.
- `fecha_alta` y `fecha_modificacion` con `datetime(''now'',''localtime'')`. El importador aísla lo escrito en la corrida comparando contra un sello de ese mismo reloj; con `date(''now'')` no puede.
- Las convenciones de la base de destino: en gbCorpus, las de RF-08 (`orden = numero * 10`; `cuerpo` y `relaciones` nunca NULL; relaciones como pares `tipo:CODIGO`); en gbShortcodes, las restricciones de RF-11.
- Literales con las comillas simples duplicadas, generados con un programa y no a mano: un apóstrofe sin duplicar corta la sentencia.

Se admite un `SELECT` final de resumen: su salida aparece en el informe.

Lo que no debe traer: `PRAGMA foreign_keys`, que el importador ya emite y que dentro de una transacción no tiene efecto, ni una comprobación de `esquema_version`, que el importador hace contra la cabecera.

MIGRACIONES DE ESQUEMA

Una migración lleva en la cabecera, además de `-- Esquema: N` (la versión de partida),

    -- Migración: N a M

El importador la acepta solo si la base está en N y él maneja M, y al terminar comprueba que la base quedó en M. Un importador maneja una sola versión: rechaza un script declarado para otra. Por eso los scripts de datos de una versión se aplican antes de migrar a la siguiente, y un cambio de datos que la migración necesita va dentro de la migración.

La aplicación no abre una base de una versión anterior. Si está una versión atrás, ofrece «Migrar» y corre su propio importador con su propio script de migración en la pestaña Terminal. Al abrir una base vacía, ofrece la carga inicial.

Hoy solo gbShortcodes cambió de esquema (va por la 5; el detalle de cada migración está en RF-11). gbCorpus sigue en la 1 y su importador no tiene migraciones: si sube de versión, adopta este mismo mecanismo.

NOMBRES Y LUGARES DE LOS SCRIPTS

    gbCorpus       gbcorpus-act-NN.sql                    raíz del repositorio
    gbShortcodes   datos/datos-vN-NNN.sql                 cambios de datos
                   .hidden/esquema/esquema-vN-a-vM.sql    migraciones
                   .hidden/esquema/carga-inicial.sql      catálogo completo para una base nueva

- En gbCorpus el número es un contador simple, independiente de los códigos de las entradas.
- En gbShortcodes el número va dentro de su versión de esquema: el nombre dice a qué versión va y en qué orden. La diferencia con gbCorpus es deliberada: gbShortcodes cambia de esquema y su importador rechaza los scripts de otra versión.
- `datos/` no viaja en el paquete y la aplicación no lo lee: un script de datos se importa a mano. `.hidden/esquema/` sí viaja: la aplicación lee de ahí la migración y la carga inicial.
- La carga inicial se regenera en cada versión de esquema: una base nueva no puede aplicar scripts de una versión anterior.
- Los scripts aplicados quedan en el repositorio. El número más alto es el último aplicado, y de ahí sale el siguiente.
- Los nombres anteriores (`corpus-alta-*.sql`, `gbshortcodes-act-*.sql`, `gbshortcodes-migrar-*.sql`) son históricos y no se usan más.

RECURSOS QUE VIAJAN CON EL PROGRAMA

El importador, las migraciones y la carga inicial se buscan primero en `.hidden/` del proyecto y después en `/usr/share/<aplicación>/`. Desde el IDE, `Application.Path` es la carpeta del proyecto y se usa el recurso del proyecto; instalada, es `/usr/bin`, la búsqueda en el proyecto falla y se usa el del sistema. Así siempre corren los de la versión en ejecución: con el orden inverso, el IDE usaría el del paquete instalado, que puede ser de otra versión. Si no está en ninguno de los dos lugares, el mensaje muestra las dos rutas. Es el criterio de SC-11, y estos recursos no se copian a la carpeta del usuario.

Todo lo que la aplicación instalada busca en `/usr/share/<aplicación>/` tiene que estar en los archivos extra del paquete (`ExtraFiles` del `.project`), una carpeta de `.hidden/` por línea, con el formato de gbpublisher:

    ExtraFiles=*:"engine\t/usr/share/gbshortcodes\nesquema\t/usr/share/gbshortcodes"

EXPORTACIÓN

Determinista: orden fijo y sin fecha de generación. Dos exportaciones del mismo contenido dan archivos idénticos, y el diff de git muestra solo lo que cambió. Cada aplicación exporta además un volcado SQL restaurable, en texto, como respaldo que se puede comparar en git.

La carpeta de destino dentro de gbpublisher entra entera al `.deb`. Por eso la exportación la deja igual a la base: gbShortcodes ofrece borrar lo que no es del catálogo, y gbAyudas hace lo mismo (SC-24).

COTEJO ANTES DE ESCRIBIR UN SCRIPT

El estado vigente se lee de los repositorios de GitHub.

- Corpus: `docs/corpus.md` del repositorio de gbpublisher, clonado con `git clone --depth 1`, se coteja con el `corpus.md` adjunto al proyecto de trabajo con Claude: mismas entradas, mismos estados y pasajes testigo idénticos. Si el del repositorio es el más reciente, se adopta sin consultar y se dice en una línea. Si el más reciente es el adjunto —caso raro, porque el repositorio recibe cada exportación—, o si cada uno tiene algo que el otro no tiene, se avisa y se espera la respuesta antes de hacer nada.
- Catálogo de shortcodes: el `_catalogo.tsv` exportado a `.hidden/shortcodes/` de gbpublisher, y los scripts de `datos/` del repositorio de gbShortcodes.
- El número del script nuevo sale del último que está en el repositorio de cada aplicación.

Es lo que garantiza que un código nuevo esté libre y que un texto a reemplazar exista tal como se lo cita.

FLUJO DE TRABAJO

Claude entrega los archivos completos. Alberto los incorpora en el IDE y publica en GitHub, que es la copia que se consulta.

CADA APLICACIÓN

- gbCorpus: la base en RF-08. Tres exportaciones: el corpus completo, con todos los estados (va a `docs/corpus.md` de gbpublisher); las reglas vigentes de las familias marcadas como operativas; el volcado SQL.
- gbShortcodes: la base, el contrato de exportación y cada migración en RF-11. gbpublisher lee el catálogo según SC-34.
- gbAyudas: el diseño de las ayudas, la conversión, los estados, la exportación y el visor en SC-24. La entrada de referencia de su base se escribe cuando se construya.', 'vigente', 'empirica',
   'gbCorpus 0.0.8 / gbShortcodes 0.0.5 (esquema 5) / Gambas 3.22.1 / Linux Mint; código de los dos repositorios', '2026-10',
   'vinculo:SC-19,vinculo:RF-08,vinculo:RF-11,vinculo:SC-24,vinculo:SC-34,vinculo:SC-13,vinculo:SC-11,vinculo:GV-30', 'Dos correcciones de código derivadas de esta entrada, entregadas con gbcorpus-act-17: (1) gbCorpus busca el importador primero en el sistema y después en «engine/» del proyecto (FMain.RutaImportador), al revés de lo que fija «Recursos que viajan con el programa»; (2) el .project de gbShortcodes declara en ExtraFiles solo «engine», y la aplicación instalada busca en /usr/share/gbshortcodes también esquema/carga-inicial.sql y las migraciones. Verificar las dos en Mint y quitar este pendiente.', 500, datetime('now','localtime'), datetime('now','localtime'));

INSERT INTO verificacion SELECT 'SC-50 escrita', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-50';

-- ------------------------------------------------------------
-- 3. SC-19 DEPRECADA
-- ------------------------------------------------------------
UPDATE entradas
   SET estado = 'deprecada',
       cuerpo = 'DEPRECADA. Reemplazada por SC-50, que extiende el contrato a todas las aplicaciones satélite (gbCorpus, gbShortcodes y gbAyudas) y reúne lo que estaba repartido en esta entrada, RF-08, RF-11 y SC-24.

Texto histórico:

' || cuerpo,
       relaciones = 'reemplazada_por:SC-50,' || relaciones,
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-19';

INSERT INTO verificacion SELECT 'SC-19 deprecada', estado = 'deprecada' AND instr(relaciones, 'reemplazada_por:SC-50') = 1 AND instr(cuerpo, 'DEPRECADA. Reemplazada por SC-50') = 1 FROM entradas WHERE codigo = 'SC-19';

-- ------------------------------------------------------------
-- 4. RF-08: EL FUNCIONAMIENTO PASA A SC-50
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'ALCANCE DELIBERADO DE LA APLICACIÓN

gbCorpus NO da de alta ni elimina entradas ni familias. Solo lee, navega relaciones, edita texto y exporta. Las altas, bajas, cambios de estado y relaciones nuevas se acuerdan en conversación y se aplican por script SQL.

REGLA DE TRABAJO

Antes de pedir cambios sobre el corpus, exportar y compartir el `corpus.md` vigente, para que el trabajo se haga contra el estado real y no contra una copia vieja.', 'CÓMO FUNCIONA LA APLICACIÓN

El alcance, el importador, los scripts y la exportación son los de todas las aplicaciones satélite: SC-50.'),
       relaciones = relaciones || ',vinculo:SC-50',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'RF-08';

INSERT INTO verificacion SELECT 'RF-08 actualizada', instr(cuerpo, 'ALCANCE DELIBERADO') = 0 AND instr(cuerpo, 'CÓMO FUNCIONA LA APLICACIÓN') > 0 FROM entradas WHERE codigo = 'RF-08';

-- ------------------------------------------------------------
-- 5. RF-11: ESQUEMA 5, SIN LO QUE PASA A SC-50
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = 'Programa aparte, con el modelo de gbCorpus (RF-08), que mantiene el catálogo de shortcodes de gbpublisher. Reemplaza a la tabla `shortcodes` de MySQL, retirada en la actualización 1.7.0 de la base de gbpublisher (SC-22, SC-34).

ESTA ENTRADA DESCRIBE LA VERSIÓN 5 DEL ESQUEMA Y DEL CONTRATO DE EXPORTACIÓN. La 2 agrega `clase`; la 3, el modo `dos-partes` y la regla de liberación; la 4, la tabla `modos`; la 5, el grupo `composicion`. El contrato de exportación no cambia desde la 2.

Cómo funciona la aplicación —alcance, importador, migraciones, nombres de los scripts, recursos y exportación— está en SC-50, común a todas las aplicaciones satélite.

BASE

`~/.gbshortcodes/shortcodes.sqlite`, con `esquema_version`. La aplicación la crea en el primer arranque con el DDL de `m_Base.SentenciasDDL`, igual al de `shortcodes_esquema.sql` (verificado comparando `.schema`).

TABLA `shortcodes`

    nombre          TEXT NOT NULL UNIQUE   minúsculas, dígitos y guion: nombre de archivo
    clase           TEXT NOT NULL          la clase de Pandoc del .md: {.fig}, ::: epigraph, ]{.gloss}
    etiqueta        TEXT NOT NULL          lo que se ve en la lista de gbpublisher
    tipo            bloque | linea
    grupo           comun | estructura | disciplinar | composicion
    perfil          TEXT                   solo y siempre en disciplinar (CHECK)
    orden           INTEGER NOT NULL       dentro de grupo y perfil, de 10 en 10
    estado_libro    no_aplica | borrador | liberado
    estado_revista  no_aplica | borrador | liberado
    modo            el par (modo, tipo) es clave foránea a `modos`
    apertura        TEXT NOT NULL          puede tener saltos (el bloque de código)
    cierre          TEXT NOT NULL
    que_es          TEXT                   Markdown; NULL si no hay texto
    ejemplo         TEXT                   el ejemplo tal como se escribe en el .md
    como_sale       TEXT                   Markdown; NULL si no hay texto
    mapeo_docbook, mapeo_jats, notas, pendiente   internos: no se exportan
    fecha_alta, fecha_modificacion          datetime(''now'',''localtime'')

La clase es la clave con que gbpublisher valida un .md y empareja los cierres (SC-33). No es única: las variantes comparten clase (`figure` y `fig-fullwidth` son `fig`; las tres tablas, `table`). Para validar se usa el catálogo entero, en cualquier estado; para mostrar, solo lo liberado.

Restricciones: un shortcode no puede ser no_aplica en los dos; el par (modo, tipo) tiene que estar en `modos` (la figura, por ejemplo, solo existe como bloque); lo liberado tiene `que_es`, `ejemplo` y `como_sale`, y no tiene `pendiente`; un shortcode no puede estar liberado en un producto y en borrador en el otro (la regla de liberación de SC-34).

Los tres textos de la ayuda admiten NULL y no cadena vacía (`CHECK (x <> '''')`): Edit + Update escribe la cadena vacía como NULL (GV-74), y con NOT NULL guardar una sección vacía fallaba.

MODOS

Desde la versión 4 son filas de la tabla `modos` (modo, tipo, descripción), una por cada par permitido. Agregar un modo es un script de datos, no una migración; lo que hace cada modo al insertar lo decide gbpublisher (`m_Shortcodes.InsertarShortcode`). Las claves foráneas valen porque la aplicación y el importador abren la base con `PRAGMA foreign_keys = ON`; sin eso, SQLite no las controla (verificado).

- envolver: rodea la selección con apertura y cierre.
- plantilla: inserta apertura, marcador y cierre, sin selección (la sigla).
- figura: el camino de `FMain.InsertarFigura` (SC-32).
- dos-partes: envolver, con el control de la forma `{primera}{segunda}` antes de insertar (SC-35).
- separador: un bloque vacío, sin selección y con el cursor al principio de una línea vacía (SC-36). Se agrega con `datos-v4-001`.
- codigo: en bloque, pide el lenguaje (y en el listado, el nombre) y cerca la selección con `~~~ lenguaje`; en línea, la envuelve en comillas inversas (SC-42). Se agrega con `datos-v5-005`, para bloque y para línea.

COMPORTAMIENTO

En gbShortcodes, el comportamiento de un shortcode es su nombre, tipo, grupo, perfil, orden, estados, modo, apertura y cierre. La aplicación no lo cambia: se aplica por script (SC-50), después de probarlo. Sí pule la etiqueta, la ayuda, los mapeos, las notas y el pendiente.

EXPORTACIÓN AL PAQUETE (CONTRATO CON gbpublisher)

A la carpeta `.hidden/shortcodes/` del proyecto gbpublisher. Van todos los shortcodes, en cualquier estado: gbpublisher filtra (instalado, solo lo liberado; desde el IDE, también los borradores).

- `_catalogo.tsv`: una cabecera fija, que hace de versión del contrato,

      nombre clase etiqueta tipo grupo perfil orden estado_libro estado_revista modo apertura cierre

  separada por tabuladores, y una línea por shortcode en el orden del catálogo: grupo (comun, estructura, disciplinar, composicion), perfil, orden, nombre. Escapes: `\\` por barra, `\t` por tabulador, `\n` por salto.
- `<nombre>.html`: fragmento, no documento. Tres secciones fijas, `<h3>Qué es</h3>`, `<h3>Cómo se escribe</h3>` y `<h3>Cómo sale</h3>`, y en la segunda la marca `<!--gb:ejemplo-->`, donde gbpublisher pone el ejemplo coloreado con su resaltador. El estilo lo pone quien lo muestra. Una sección vacía de un borrador sale «Sin completar.».
- `<nombre>.md`: el ejemplo tal cual, con salto final.

Las secciones se convierten con `pandoc -f markdown -t html --wrap=none` (Exec sobre un array, SC-05). La exportación se detiene, sin escribir nada, si una sección trae títulos, imágenes o tablas: el TextEdit de la ayuda solo tiene probados párrafos, listas, énfasis y código (GV-64). Antes de escribir exige una carpeta vacía o con `_catalogo.tsv`, y después ofrece borrar los .html y .md que no son del catálogo: todo lo que hay en la carpeta entra al .deb.

Salida determinista: dos exportaciones del mismo contenido dan archivos idénticos (verificado con diff).

OTRAS SALIDAS

- Documento de prueba, de libros o de revistas: un `.md` con un título y el ejemplo de cada shortcode que aplica, liberado o en borrador. Es lo que se compone en PDF, EPUB y HTML antes de liberar.
- Volcado SQL restaurable (verificado: restaura las 77 filas sobre una base vacía).

CARGA INICIAL

`.hidden/esquema/carga-inicial.sql`: el catálogo completo al empezar la versión de esquema en curso, para una base nueva y vacía. La de la versión 5 es la carga original de los 77 shortcodes de MySQL más `datos-v3-001` (el epígrafe), `datos-v3-002` (la figura de ancho completo) y `datos-v4-001` (el modo separador y el froufrou): 79 filas, con epigraph, figure, fig-fullwidth y froufrou liberados. Los `datos-v5-*` se aplican después. Los ejemplos de bloque llevan el cierre nombrado (SC-33).

MIGRACIONES DE ESQUEMA

El mecanismo es el de SC-50. Lo propio de cada una:

`gbshortcodes-migrar-1-a-2.sql` rehace la tabla con la columna `clase` en su lugar (las columnas y restricciones quedan iguales a las de una base creada en v2, verificado) y pone el cierre nombrado en los ejemplos que siguen iguales a los de la carga inicial; uno editado se conserva y se lista.

`gbshortcodes-migrar-2-a-3.sql` rehace la tabla con las restricciones nuevas (SQLite no cambia un CHECK en su lugar) y copia las filas sin cambiarlas, salvo la figura: si sigue como en la carga, le quita el pendiente que pedía referencia cruzada en revistas, que no existe (SC-32). Antes de copiar comprueba la regla de liberación y frena si una fila la viola. Verificado: la base migrada tiene el mismo esquema que una creada en v3, y el DDL de la aplicación es igual al de `shortcodes_esquema.sql`.

`esquema-v3-a-v4.sql` crea `modos` con sus filas, comprueba que todos los shortcodes usen un par existente y rehace la tabla con la clave foránea. Verificado: la base migrada tiene el mismo esquema que una creada en v4, y el DDL de la aplicación es igual al de `shortcodes_esquema.sql`. Con la aplicación bajo xvfb, una base v3 queda en v4 con sus 77 filas, y una base nueva se carga.

`esquema-v4-a-v5.sql` rehace la tabla con el grupo `composicion` en su CHECK, para las instrucciones de composición que solo afectan al PDF (SC-38, SC-39); va al final del catálogo. Los datos no cambian. La corre la aplicación al abrir una base v4.

`User.Home` no sigue la variable `HOME`: una prueba con otra `HOME` abre igual la base del usuario real (medido en 3.19).',
       relaciones = replace(relaciones, 'vinculo:SC-19', 'vinculo:SC-50') || ',vinculo:SC-38,vinculo:SC-39',
       pendiente = 'Versiones 2 y 3 verificadas en Mint con 3.22.1. La 4 se probó en el contenedor (Gambas 3.19, gb.db, aplicación bajo xvfb). La 5 está en uso en Mint: los datos-v5-* se aplicaron y probaron ahí (datos-v5-011).',
       fecha_verificacion = '2026-10',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'RF-11';

INSERT INTO verificacion SELECT 'RF-11 actualizada', instr(cuerpo, 'VERSIÓN 5 DEL ESQUEMA') > 0 AND instr(cuerpo, 'esquema-v4-a-v5.sql') > 0 AND instr(cuerpo, 'NOMBRES Y LUGARES') = 0 FROM entradas WHERE codigo = 'RF-11';

-- ------------------------------------------------------------
-- 6. SC-24 Y SC-34
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, 'Las ayudas se escriben en gbAyudas, un programa aparte con base SQLite, al estilo de gbCorpus. A diferencia de gbCorpus, da de alta y de baja: es el editor de las ayudas.', 'Las ayudas se escriben en gbAyudas, una aplicación satélite que sigue el modelo de SC-50. Es la excepción a su alcance: da de alta y de baja, porque es el editor de las ayudas.'),
       relaciones = relaciones || ',vinculo:SC-50',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-24';

UPDATE entradas
   SET cuerpo = replace(cuerpo, '(SC-33).

RESALTADO

REGLA DE LIBERACIÓN', '(SC-33).

REGLA DE LIBERACIÓN'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-34';

INSERT INTO verificacion SELECT 'SC-24 actualizada', instr(cuerpo, 'sigue el modelo de SC-50') > 0 FROM entradas WHERE codigo = 'SC-24';
INSERT INTO verificacion SELECT 'SC-34 un solo RESALTADO', (length(cuerpo) - length(replace(cuerpo, 'RESALTADO', ''))) = length('RESALTADO') FROM entradas WHERE codigo = 'SC-34';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-19', 'SC-24', 'SC-34', 'SC-50', 'RF-08', 'RF-11') ORDER BY prefijo, numero;
