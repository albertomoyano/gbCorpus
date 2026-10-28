-- ============================================================
-- gbCorpus — actualización 71: rediseño de revistas (entregas 25 a
--            28/10): decisiones, patrón de los editores, vocabulario
--            controlado y comportamientos medidos
-- Esquema: 1
-- Origen: conversación del 25 al 28/10 sobre el rediseño del ABM de
--         revistas (documento de trabajo claude/rediseno-revistas.md).
--         Las decisiones las tomó Alberto; las GV salen de las pruebas
--         de cada entrega (Gambas 3.19 y MySQL 8.0.46 en el contenedor).
-- Fecha:  2026-10-28
-- Aplicar: después de act-70
--
-- ALTAS:
--   SC-70  Un módulo por formulario o función principal
--   SC-71  Revistas: la pirámide N0-N3 y el esquema nuevo
--   SC-72  Revistas: las salidas
--   SC-73  Editores con tablas hijas: memoria, una transacción y reemplazo entero
--   SC-74  Vocabulario controlado
--   GV-145 TextBox.Change y la asignación por código
--   GV-146 ListBox simple: asignar Index no dispara Click
--   GV-147 If(…, Null, s) con s String da cadena vacía en Exec
--   GV-148 Los arreglos no tienen Exchange
--   GV-149 ROW_COUNT() en un Exec aparte dio 0
--   GV-150 LCase solo ASCII; String.LCase y el locale (UCase no se midió)
--   GV-151 FSysAdmin sin sesión
--   GV-152 MySQL 8: colaciones unicode_ci, 0900_as_ci, 0900_ai_ci
--   GV-153 MySQL 8: CHECK con REGEXP_LIKE y la opción 'c'
--   GV-154 ROR: dígito de control
-- MODIFICA:
--   SC-22  la cadena de esquema llega a 1.17.0
--   RC-GM-12 relación con GV-150
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: LA BASE CON act-70; CÓDIGOS LIBRES; TEXTO, UNA VEZ
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-69 última SC', MAX(numero) = 69 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-144 última GV', MAX(numero) = 144 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-70 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-70' OR (prefijo = 'SC' AND numero = 70);
INSERT INTO verificacion SELECT 'SC-71 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-71' OR (prefijo = 'SC' AND numero = 71);
INSERT INTO verificacion SELECT 'SC-72 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-72' OR (prefijo = 'SC' AND numero = 72);
INSERT INTO verificacion SELECT 'SC-73 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-73' OR (prefijo = 'SC' AND numero = 73);
INSERT INTO verificacion SELECT 'SC-74 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-74' OR (prefijo = 'SC' AND numero = 74);
INSERT INTO verificacion SELECT 'GV-145 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-145' OR (prefijo = 'GV' AND numero = 145);
INSERT INTO verificacion SELECT 'GV-146 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-146' OR (prefijo = 'GV' AND numero = 146);
INSERT INTO verificacion SELECT 'GV-147 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-147' OR (prefijo = 'GV' AND numero = 147);
INSERT INTO verificacion SELECT 'GV-148 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-148' OR (prefijo = 'GV' AND numero = 148);
INSERT INTO verificacion SELECT 'GV-149 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-149' OR (prefijo = 'GV' AND numero = 149);
INSERT INTO verificacion SELECT 'GV-150 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-150' OR (prefijo = 'GV' AND numero = 150);
INSERT INTO verificacion SELECT 'GV-151 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-151' OR (prefijo = 'GV' AND numero = 151);
INSERT INTO verificacion SELECT 'GV-152 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-152' OR (prefijo = 'GV' AND numero = 152);
INSERT INTO verificacion SELECT 'GV-153 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-153' OR (prefijo = 'GV' AND numero = 153);
INSERT INTO verificacion SELECT 'GV-154 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-154' OR (prefijo = 'GV' AND numero = 154);
INSERT INTO verificacion SELECT 'SC-22 cadena: una vez', (length(cuerpo) - length(replace(cuerpo, '1.12.0 (retiro de la tabla `postits`, SC-60). El refactor de bibtex tomará el número que le corresponda.', ''))) = length('1.12.0 (retiro de la tabla `postits`, SC-60). El refactor de bibtex tomará el número que le corresponda.') FROM entradas WHERE codigo = 'SC-22';
INSERT INTO verificacion SELECT 'RC-GM-12 sin GV-150', instr(relaciones, 'GV-150') = 0 FROM entradas WHERE codigo = 'RC-GM-12';

-- ------------------------------------------------------------
-- 2. SC-22: LA CADENA DE ESQUEMA
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo, '1.12.0 (retiro de la tabla `postits`, SC-60). El refactor de bibtex tomará el número que le corresponda.', '1.12.0 (retiro de la tabla `postits`, SC-60); 1.13.0 a 1.17.0 (rediseño de revistas, SC-71: las 23 tablas nuevas, NULL en lugar de '''', ROR de la afiliación, vocabulario controlado y dos términos CRediT). El refactor de bibtex tomará el número que le corresponda.'),
       relaciones = relaciones || ',vinculo:SC-71',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-22';
INSERT INTO verificacion SELECT 'SC-22 actualizada', instr(cuerpo, '1.12.0 (retiro de la tabla `postits`, SC-60); 1.13.0 a 1.17.0 (rediseño de revistas, SC-71: las 23 tablas nuevas, NULL en lugar de '''', ROR de la afiliación, vocabulario controlado y dos términos CRediT). El refactor de bibtex tomará el número que le corresponda.') > 0 AND instr(relaciones, 'vinculo:SC-71') > 0 FROM entradas WHERE codigo = 'SC-22';

-- ------------------------------------------------------------
-- 3. RC-GM-12: RELACIÓN CON GV-150
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = CASE WHEN relaciones = '' THEN 'vinculo:GV-150' ELSE relaciones || ',vinculo:GV-150' END,
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'RC-GM-12';
INSERT INTO verificacion SELECT 'RC-GM-12 actualizada', instr(relaciones, 'vinculo:GV-150') > 0 FROM entradas WHERE codigo = 'RC-GM-12';

-- ------------------------------------------------------------
-- 4. ALTAS SC
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 70, 'SC-70', 'Un módulo por formulario o función principal',
   'DECISIÓN CERRADA (Alberto, 25/10). Cada formulario, o cada función principal de la aplicación, tiene su propio módulo. El formulario tiene los controles y los manejadores; el módulo, las consultas, las validaciones y las grabaciones.

- Un formulario nuevo nace con su módulo: `FDossiers` + `m_Dossiers`, `FMetadatosNumero` + `m_Numero`, `FMetadatosArticulo` + `m_Articulo`, la pestaña «Revistas» de `FSysAdmin` + `m_Revistas`, `FVocabularios` + `m_Vocabularios`.
- Un catálogo que usan varios formularios tiene su módulo propio, aunque ningún formulario sea suyo (`m_Licencias`, `m_Idiomas`, `m_Vocabularios`).
- Los datos que viajan juntos entre el formulario y el módulo van en una clase chica (GV-24): `CContribuyente`, `CTextosArticulo`.

Ya estaba aplicado caso por caso: SC-20 (`m_Ventana`), SC-21 (`m_Snippets`), SC-66 y SC-67 (`m_Cuadros`), SC-69 (`m_Graficos`). Esta entrada lo hace regla general.',
   'vigente', 'empirica',
   'gbpublisher / Gambas 3.22.1 / Linux Mint',
   '2026-10', 'vinculo:SC-20,vinculo:SC-21,vinculo:SC-66,vinculo:SC-67,vinculo:SC-69,vinculo:GV-24',
   NULL,
   700, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-70 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-70';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 71, 'SC-71', 'Revistas: la pirámide N0-N3 y el esquema nuevo',
   'DECISIÓN CERRADA (Alberto, 25 a 28/10; documento de trabajo `claude/rediseno-revistas.md`).

PIRÁMIDE

- N0 Revista (permanente; pestaña «Revistas» de `FSysAdmin`, `m_Revistas`). N1 Número (uno por proyecto `r-*.md`; `FMetadatosNumero`, `m_Numero`). N2 Artículo (`FMetadatosArticulo`, `m_Articulo`). N3 bloques opcionales que activa cada revista (patrón de OJS: desactivar / habilitar / solicitar / exigir).
- Revistas no comparte tablas con libros. Las tablas hijas se nombran para que `capitulos` pueda adoptarlas después.

CRITERIOS DE ESQUEMA

- Un campo existe solo si lo consume una salida, una validación o una decisión del flujo.
- Estructura completa, columnas mínimas: todos los niveles y las tablas hijas desde el principio. Las declaraciones (COI, ética, ensayo, datos) son filas de una tabla por tipo, no columnas.
- Esquema nuevo, no transformación del viejo: la 1.13.0 creó 23 tablas sin tocar las viejas (`revistas_md`, `articulos`, `articulo_autor`), que se retiran en el 2.0.0.
- Los catálogos se guardan por valor (SC-23): `contribuyente_credit`, `articulo_declaracion`, `articulo_palabra_clave`.
- «Sin dato» es NULL con `CHECK (<> '''')` (GV-74, GV-147). Una clave única sobre columnas nulables se apoya en una columna generada (`numero.clave_identidad`, `articulo_palabra_clave.clave_vocabulario`).
- Las hijas del artículo caen en cascada con él; todo lo demás es RESTRICT.

REGLAS DEL FLUJO

- Herencia viva hasta publicar (decisión 14): mientras el artículo no está publicado, un campo vacío toma el valor de la revista (licencia, titular del copyright, tipo de acceso). Al publicar se congela el valor efectivo.
- Un artículo publicado es de solo lectura (decisión 17): el formulario lo bloquea y el módulo se niega a grabarlo. Reabrir exigirá un permiso desde `FSysAdmin` y quedará registrado en una tabla propia, con motivo obligatorio (entrega E, todavía no implementada).
- Secciones por revista (decisión 15), con título por idioma, orden, article-type por defecto y plantilla de resumen. El artículo guarda su propio article-type: `subj-group-type="heading"` y `@article-type` se separan.
- El dossier es una agrupación dentro del número, no una sección (`numero_dossier`), con título por idioma y personas a cargo (`numero_contribuyente` con `id_dossier`). Se borra solo sin artículos.
- El número se vincula al proyecto al abrirlo: vincular y confirmar siempre. Volumen y número quedan de solo lectura con artículos consignados; la revista se cambia solo sin artículos.
- La lista de artículos sale de los `a-*.md` de `articulos/` cruzados con la base por nombre de archivo: «sin metadatos» y «huérfana» se muestran.

CADENA DE ESQUEMA (SC-22): 1.13.0 (las 23 tablas), 1.14.0 (NULL en vez de '''', GV-74), 1.15.0 (ROR de la afiliación, GV-153, GV-154), 1.16.0 (vocabulario controlado, SC-74), 1.17.0 (dos términos CRediT a la forma de JATS4R).',
   'vigente', 'empirica',
   'gbpublisher / MySQL 8.0.46 / Gambas 3.22.1 / Linux Mint',
   '2026-10', 'vinculo:SC-22,vinculo:SC-23,vinculo:GV-74,vinculo:SC-72,vinculo:SC-73,vinculo:SC-74,vinculo:SC-70',
   NULL,
   710, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-71 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-71';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 72, 'SC-72', 'Revistas: las salidas',
   'DECISIÓN CERRADA (Alberto, 25/10; documento de trabajo `claude/rediseno-revistas.md`, decisiones 6 a 13). Todavía no implementada: rige el rediseño de las salidas de revistas.

- ORDEN: primero las salidas de lectura (PDF, HTML, EPUB, también del número completo); después los sabores XML, en el orden de necesidad real: JATS4R (que valida el canónico, no es un sabor), Crossref y DOAJ antes que PMC. Vancouver se resuelve en las salidas de lectura.
- CITAS: SC-57 llega a revistas. biblatex escribe las citas de HTML y EPUB por tex4ht; el estilo de cita es atributo de la revista y sale del catálogo `cita-*-config.tex`.
- REFERENCIAS: el texto formateado alimenta `mixed-citation` en los sabores (SciELO, PMC), no en el canónico, que queda como dato.
- IBID. Y OP. CIT. son presentación, no dato: el `.md` lleva siempre la clave. El PDF conserva la tradición y el HTML lleva citas autosuficientes (`cita-<estilo>-html.tex`).
- EL NÚMERO es un manifiesto interno que ordena los JATS de cada artículo. No se inventa un JATS de número.
- PAGINACIÓN: es un dato que nace en la composición. Se compone el número, se leen los rangos, vuelven a la base y recién ahí salen los PDF por artículo y los XML. Modelo de paginación como atributo de la revista: corrida por número, por volumen o continua (`elocation-id`); se implementan los dos primeros y la estructura admite el continuo.
- PROCESOS EXTERNOS: rigen SC-13 y SC-53. Gambas lee la base y la escribe como archivos (front del artículo, manifiesto del número, `.bib`); los scripts de `engine/` hacen el resto. Los generadores actuales de revistas en Gambas son deuda de migración: se reemplazan por scripts, no se adaptan.',
   'vigente', 'empirica',
   'gbpublisher / decisiones de diseño',
   '2026-10', 'vinculo:SC-57,vinculo:SC-13,vinculo:SC-53,vinculo:SC-71',
   'Pendiente de implementación. Mini-tests previos: philosophy-verbose bajo make4ht; Vancouver bajo tex4ht; PDF por artículo; rango de páginas; griego politónico; mixed-citation para PMC y SciELO.',
   720, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-72 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-72';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 73, 'SC-73', 'Editores con tablas hijas: memoria, una transacción y reemplazo entero',
   'DECISIÓN CERRADA (Alberto, 25 a 28/10). Patrón de los editores del rediseño de revistas (`FMetadatosNumero`, `FDossiers`, `FMetadatosArticulo`, `FPlantillasResumen`).

- Lo que tiene filas hijas (títulos por idioma, contribuyentes con afiliaciones y CRediT, resúmenes, palabras clave, secciones de una plantilla) se edita EN MEMORIA y se graba con el botón «Guardar», en la misma transacción que el registro principal: o se graba todo o nada.
- Las hijas se reemplazan enteras (DELETE + INSERT) dentro de esa transacción. Solo se borra lo que el editor muestra: un tipo de fila que el editor no edita no se toca (por ejemplo, los resúmenes al grabar los títulos traducidos).
- Si algo que se iba a reemplazar no se pudo leer, o la pestaña no puede mostrarlo entero, el guardado se bloquea y la línea de estado dice por qué. Grabar lo borraría.
- Un diálogo edita una COPIA del objeto (`CContribuyente.Copia()`) y el llamador conserva la referencia. Al aceptar (`Me.Close(1)`), la copia reemplaza al original; al cerrar, no queda nada. La instancia automática del diálogo se destruye al cerrarse.
- El módulo valida con las mismas reglas que el diálogo (una sola función de aviso, usada por los dos).
- Pestañas con nombre, una por bloque (decisión 19). Textos por idioma con un selector de idioma (decisión 20): lo escrito pasa a memoria al cambiar de idioma y antes de grabar.
- Un artículo publicado se abre para ver: los campos de texto quedan en solo lectura y no apagados, y el selector de idioma sigue vivo.',
   'vigente', 'empirica',
   'gbpublisher / Gambas 3.22.1 / MySQL 8.0.46 / Linux Mint',
   '2026-10', 'vinculo:SC-71,vinculo:SC-70,vinculo:GV-68,vinculo:GV-74,vinculo:GV-24',
   NULL,
   730, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-73 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-73';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 74, 'SC-74', 'Vocabulario controlado: catálogo global, búsqueda sin tildes, término e identificador por valor',
   'DECISIÓN CERRADA (Alberto, 28/10; entrega C3 del rediseño de revistas).

- CATÁLOGO GLOBAL: `vocabulario_termino` (vocabulario, idioma, término, identificador), común a todas las revistas. Un término por vocabulario, idioma y término; un identificador por vocabulario e idioma.
- COLACIÓN: la columna del término usa `utf8mb4_0900_as_ci` (no distingue mayúsculas; sí tildes y ñ) y la búsqueda, `COLLATE utf8mb4_0900_ai_ci` (GV-152). Los comodines del `LIKE` se escapan con `!` (SC-08).
- IDENTIFICADOR: el código del vocabulario (MeSH: D006801). La URI de JATS (`kwd/@vocab-term-identifier`; `kwd-group/@vocab` y `@vocab-identifier`, DTD 1.4) se arma al generar. MeSH: `http://id.nlm.nih.gov/mesh/` + código (MeSH RDF). DeCS: sin patrón de URI verificado.
- EN EL ARTÍCULO: sugerencias mientras se tipea (dos caracteres como mínimo); se agrega la sugerencia elegida o lo escrito. Si el catálogo ya tiene el término con otras mayúsculas, se usa su forma y su identificador. Un término nuevo entra al catálogo al guardar el artículo, en su transacción (`INSERT … ON DUPLICATE KEY UPDATE`, no `INSERT IGNORE`, que también callaría un CHECK).
- El artículo guarda término e identificador por valor (SC-23).
- CORRECCIÓN: solo desde `FVocabularios` (pestaña «Revistas» de `FSysAdmin`). Corregir un término corrige los artículos NO publicados que lo usan (herencia viva, SC-71); un publicado queda como salió. Se borra solo un término sin uso.
- Las palabras clave del autor siguen libres, una por línea.
- LICENCIAS: los datos de MeSH son de dominio público, con cita a NLM y versión declarada si se redistribuyen. Descargar DeCS exige un contrato de licencia gratuito con BIREME. Tipear términos no requiere nada.',
   'vigente', 'empirica',
   'gbpublisher / MySQL 8.0.46 / Gambas 3.22.1 / Linux Mint',
   '2026-10', 'vinculo:SC-23,vinculo:SC-08,vinculo:SC-71,vinculo:SC-73,vinculo:GV-152,vinculo:GV-145,vinculo:GV-146,vinculo:GV-150',
   NULL,
   740, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-74 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-74';

-- ------------------------------------------------------------
-- 5. ALTAS GV
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 145, 'GV-145', 'TextBox: Change se dispara al asignar Text por código, pero no si el texto no cambia',
   'Medido con un `TextBox` y un handler que cuenta:

    txt.Text = "hum"          Change: 1 (el handler corre aunque no tipeó nadie)
    txt.Text = ""             Change: 2
    txt.Text = "ano" dos veces  la segunda asignación no dispara Change

CONSECUENCIA: un handler de `Change` que depende de OTRO control (por ejemplo, sugerencias según el vocabulario elegido en un combo) no se vuelve a ejecutar si cambia ese otro control y el texto sigue igual. El otro control tiene que llamar al mismo procedimiento.

EN EL PROYECTO: `FMetadatosArticulo` (SC-74): `txtBuscarControlado_Change`, `cmbVocabulario_Click` y `cmbVocabulario_Change` llaman a `ActualizarCoincidencias`. Las asignaciones por código que no deben buscar van con la bandera `$bCargando`.',
   'vigente', 'empirica',
   'Gambas 3.19.0, gb.qt5 / xvfb / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-74,vinculo:GV-53',
   'Confirmar en Mint con Gambas 3.22.1.',
   1450, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-145 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-145';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 146, 'GV-146', 'ListBox de selección simple: asignar Index no dispara Click',
   'Medido con `ListBox` en su modo por omisión (una sola selección):

    lst.Index = 1     queda elegido el 1; Click NO corre; lst.Text devuelve el elemento

Es la contracara de GV-53: en un `ComboBox`, asignar `Index` dispara `Click` siempre. En una `ListBox` no hace falta la bandera de llenado para reponer la selección; si el código necesita lo que hace el handler, lo llama.

Lo que pasa en `Select.Multiple` está en GV-138.

EN EL PROYECTO: `FMetadatosArticulo` (SC-74): `RedibujarControladas` y `MostrarResumen` reponen el elemento elegido asignando `Index`.',
   'vigente', 'empirica',
   'Gambas 3.19.0, gb.qt5 / xvfb / contenedor Ubuntu 24.04',
   '2026-10', 'contracara:GV-53,vinculo:GV-138,apoya:SC-74',
   'Confirmar en Mint con Gambas 3.22.1.',
   1460, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-146 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-146';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 147, 'GV-147', 'If(s = "", Null, s) con s String no da Null: Exec escribe una cadena vacía',
   '`If()` toma el tipo de sus ramas. Con una rama `String`, el `Null` de la otra se convierte en `""`, y `Connection.Exec` recibe una cadena: escribe `''''`, no NULL.

Medido: `Exec("INSERT … VALUES (&1)", If(sId = "", Null, sId))` con `sId` vacío escribió `''''` y lo rechazó `CHECK (identificador <> '''')`.

PATRÓN: una función que devuelve `Variant`:

    Private Function NuloSiVacio(sTexto As String) As Variant
      If Trim(sTexto) = "" Then Return Null
      Return Trim(sTexto)
    End

CON Edit + Update ES INOFENSIVO: asignar `""` a un campo ya escribe NULL (GV-74), así que `!campo = If(…, Null, …)` da el resultado esperado por otro camino.

EN EL PROYECTO: `m_Vocabularios.NuloSiVacio`, `m_Articulo.NuloSiVacio`, `m_Revistas.NuloSiVacio`. Toda columna que la interfaz puede dejar vacía es NULL con `CHECK (<> '''')` (GV-74), y con `Exec` el valor tiene que llegar como `Variant` nulo.',
   'vigente', 'empirica',
   'Gambas 3.19.0, gb.db / MySQL 8.0.46 / contenedor Ubuntu 24.04',
   '2026-10', 'vinculo:GV-74,vinculo:GV-34,apoya:SC-71',
   NULL,
   1470, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-147 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-147';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 148, 'GV-148', 'Los arreglos no tienen Exchange: el intercambio se escribe a mano',
   'Medido: `aLista.Exchange(i, j)` sobre un `String[]` compila y falla al ejecutar con «Unknown symbol ''Exchange'' in class ''String[]''» (el miembro inexistente compila: GV-56).

PATRÓN: intercambio con una variable auxiliar del tipo del elemento. Con arreglos paralelos, el intercambio se hace en todos en el mismo paso.

EN EL PROYECTO: `CContribuyente.Intercambiar`, `CTextosArticulo.MoverControlado`, `FMetadatosArticulo.MoverContribuyente`, `FPlantillasResumen.MoverSeccion`.',
   'vigente', 'empirica',
   'Gambas 3.19.0 / contenedor Ubuntu 24.04',
   '2026-10', 'vinculo:GV-56',
   'Medido en 3.19.0. Confirmar en Gambas 3.22.1 (la instrucción Swap no se probó).',
   1480, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-148 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-148';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 149, 'GV-149', 'gb.db / MySQL: SELECT ROW_COUNT() en un Exec aparte dio 0 después de un UPDATE',
   'Medido dentro de una transacción: un `Exec` con `UPDATE … JOIN …` que corrigió una fila, seguido de `Exec("SELECT ROW_COUNT() AS n")` en la misma conexión, devolvió 0.

No se averiguó la causa. No contar las filas afectadas así.

PATRÓN: contar ANTES, con la misma condición y dentro de la misma transacción.

EN EL PROYECTO: `m_Vocabularios.GuardarTermino` cuenta las palabras clave que va a corregir antes del `UPDATE` (SC-74).',
   'vigente', 'empirica',
   'Gambas 3.19.0, gb.db / MySQL 8.0.46 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-74',
   'Una sola medición; causa sin averiguar.',
   1490, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-149 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-149';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 150, 'GV-150', 'LCase solo convierte ASCII; String.LCase convierte todo si el locale es UTF-8',
   'Medido:

    LCase("ÁRBOL Ñandú")           «Árbol Ñandú»: solo las letras ASCII
    String.LCase("ÁRBOL Ñandú")    con LANG=C.UTF-8: «árbol ñandú»
                                   con locale C (sin UTF-8): «Árbol Ñandú»

Es otro caso de RC-GM-12: las funciones sin prefijo son de bytes. Y `String.LCase` depende de que el locale sea UTF-8 (Mint lo es; un contenedor con locale C, no).

EN EL PROYECTO: el control de palabras clave repetidas (`m_Articulo.AvisoPalabras`) y el de términos repetidos al agregar uno controlado comparan con `String.LCase`, la misma regla que la clave única de la base (GV-152).',
   'vigente', 'empirica',
   'Gambas 3.19.0 / contenedor Ubuntu 24.04 (locale C y C.UTF-8)',
   '2026-10', 'vinculo:RC-GM-12,vinculo:GV-96,apoya:SC-74',
   'Confirmar en Mint con Gambas 3.22.1 y locale es_AR.UTF-8.',
   1500, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-150 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-150';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 151, 'GV-151', 'FSysAdmin funciona sin sesión: nada de lo que llama puede depender de m_ConexionBD.mConn',
   '`FSysAdmin` se abre también sin sesión de usuario, con su propia conexión (`hConnServidor`). En ese caso `m_ConexionBD.mConn` no existe, y cualquier función que la use falla con «Null object».

Medido: la pestaña «Revistas» llamaba a `m_Licencias.LlenarCombo`, que leía de `mConn`: «Null object» al abrir sin sesión.

PATRÓN: toda función que llama `FSysAdmin` recibe la conexión como parámetro. En los módulos compartidos, un parámetro `Optional hConn As Connection` que, si falta, toma `mConn`.

EN EL PROYECTO: `m_Revistas`, `m_Vocabularios`, `FPlantillasResumen` y `FVocabularios` (`hConn` del llamador); `m_Licencias.LlenarCombo`, `CompletarUrl` y `m_Idiomas.ListaValida` con `hConn` opcional.',
   'vigente', 'empirica',
   'gbpublisher / Gambas 3.22.1 / Linux Mint (informado por Alberto, 25/10)',
   '2026-10', 'apoya:SC-71',
   NULL,
   1510, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-151 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-151';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 152, 'GV-152', 'MySQL 8: utf8mb4_unicode_ci iguala ñ con n y las vocales con y sin tilde',
   'Medido con una clave única sobre una columna de texto:

    utf8mb4_unicode_ci    «Año» = «Ano», «Niño» = «Nino», «Métodos» = «Metodos»,
                          «humanos» = «Humanos»
    utf8mb4_0900_as_ci    distingue tildes y ñ; no distingue mayúsculas:
                          «Año» ≠ «Ano», «humanos» = «Humanos», «AÑO» = «Año»
    utf8mb4_0900_ai_ci    como unicode_ci: sirve para BUSCAR sin tildes

Para la clave única de un término en castellano, `unicode_ci` es un error: rechaza «Ano» si ya existe «Año». `0900_as_ci` va en la columna; `COLLATE utf8mb4_0900_ai_ci` va solo en la consulta de búsqueda. Pasar una columna a una colación más estricta (`MODIFY … COLLATE`) no crea repetidos y no choca con un CHECK de la columna.

Las colaciones 0900 son de MySQL 8: MariaDB no las tiene con ese nombre.

EN EL PROYECTO: actualización 1.16.0 (`vocabulario_termino.termino`, `articulo_palabra_clave.termino`; SC-74).',
   'vigente', 'empirica',
   'MySQL 8.0.46 / contenedor Ubuntu 24.04 (cliente con --default-character-set=utf8mb4)',
   '2026-10', 'apoya:SC-74,vinculo:SC-22',
   NULL,
   1520, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-152 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-152';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 153, 'GV-153', 'MySQL 8: un CHECK admite REGEXP_LIKE; con colación _ci hace falta la opción ''c''',
   'Medido: `CHECK (REGEXP_LIKE(ror, ''^https://ror[.]org/0[a-hj-km-np-tv-z0-9]{6}[0-9]{2}$'', ''c''))` se crea y controla. NULL pasa; `''''`, la forma sin prefijo, una letra excluida y LAS MAYÚSCULAS se rechazan. Sin `''c''`, la comparación sigue la colación de la columna (`_ci`) y acepta mayúsculas.

En un script bash con el SQL entre comillas dobles, el `$` del patrón va como `\$`.

EN EL PROYECTO: `contribuyente_afiliacion.ror`, actualización 1.15.0 (SC-71).',
   'vigente', 'empirica',
   'MySQL 8.0.46 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-71,vinculo:GV-111',
   NULL,
   1530, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-153 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-153';
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 154, 'GV-154', 'ROR: el dígito de control es ISO 7064 Mod 97-10 sobre los siete primeros caracteres en base 32 de Crockford',
   'Un ROR ID tiene nueve caracteres: un `0`, seis de base 32 de Crockford (minúsculas y cifras, sin i, l, o, u) y dos dígitos de control. La forma preferida es la URL completa: `https://ror.org/02mhbdp94` (ror.readme.io/docs/identifier; JATS e `institution-id` y Crossref `institution_id` muestran la URL).

La documentación remite al código generador para la cuenta. Verificada con los seis ROR de ejemplo de esa documentación (02mhbdp94, 03134gf68, 024mw5h28, 020hgte69, 05gq02987, 02twcfp32):

    n = valor en base 32 de los 7 primeros ("0123456789abcdefghjkmnpqrstvwxyz")
    control = 98 - (n * 100 mod 97)

En Gambas, `n` es `Long`: 32^7 no cabe en un `Integer`.

EN EL PROYECTO: `m_Articulo.NormalizarRor` (cualquier forma que acepte la API → URL completa en minúsculas) y `m_Articulo.RorValido`. La base controla la forma (GV-153).',
   'vigente', 'empirica',
   'ror.readme.io (identifier, jats, crossref) / Python 3 y Gambas 3.19.0',
   '2026-10', 'apoya:SC-71,vinculo:GV-153',
   NULL,
   1540, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-154 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-154';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('SC-22','RC-GM-12','SC-70','SC-71','SC-72','SC-73','SC-74','GV-145','GV-146','GV-147','GV-148','GV-149','GV-150','GV-151','GV-152','GV-153','GV-154')
 ORDER BY prefijo, numero;
