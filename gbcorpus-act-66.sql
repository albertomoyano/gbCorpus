-- ============================================================
-- gbCorpus — actualización 66: el espacio fijo del .md (SC-68)
-- Esquema: 1
-- Origen: conversación del 24/10. Alberto quiere escribir un espacio
--         que no se corta tan simple como el ~ de LaTeX. ~ es el
--         subíndice de Pandoc; se elige ¬ (AltGr + la tecla a la
--         izquierda del 1), que Alberto probó en el editor en Mint, y
--         se suma la lista de abreviaturas del lector.
-- Fecha:  2026-10-24
-- Aplicar: después de act-65
--
-- ALTAS:
--   GV-130  Pandoc: ~ es el subíndice; dos ~ sin espacio lo arman sin aviso
--   GV-131  Pandoc: candidatos a marca en línea; | corta una celda, ¬ pasa
--   GV-132  TextEdit conserva U+00AC (¬) al guardar y al reabrir
--   GV-133  Pandoc: --abbreviations; pandoc.read no la toma sola
--   SC-68   Espacio fijo en el .md: ¬ y las abreviaturas
-- MODIFICA (UN PÁRRAFO AL FINAL Y LA RELACIÓN):
--   GV-47, SC-30, SC-40, SC-46
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-129 última GV', MAX(numero) = 129 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-67 última SC', MAX(numero) = 67 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-130 a GV-133 libres', COUNT(*) = 0 FROM entradas WHERE codigo IN ('GV-130', 'GV-131', 'GV-132', 'GV-133') OR (prefijo = 'GV' AND numero BETWEEN 130 AND 133);
INSERT INTO verificacion SELECT 'SC-68 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-68' OR (prefijo = 'SC' AND numero = 68);
INSERT INTO verificacion SELECT 'GV-47 sin el párrafo de SC-68', instr(cuerpo, 'SC-68') = 0 FROM entradas WHERE codigo = 'GV-47';
INSERT INTO verificacion SELECT 'SC-40 sin el párrafo de SC-68', instr(cuerpo, 'SC-68') = 0 FROM entradas WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-30 sin el párrafo de SC-68', instr(cuerpo, 'SC-68') = 0 FROM entradas WHERE codigo = 'SC-30';
INSERT INTO verificacion SELECT 'SC-46 sin el párrafo de SC-68', instr(cuerpo, 'SC-68') = 0 FROM entradas WHERE codigo = 'SC-46';

-- ------------------------------------------------------------
-- 2. GV-130
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 130, 'GV-130', 'Pandoc: ~ es el subíndice; dos ~ sin espacio entre ellos lo arman sin aviso',
   'Medido con pandoc 3.1.3 (`-f markdown -t native`). La extensión `subscript`, activa en `markdown`, toma como subíndice el texto entre dos `~` si no tiene espacios:

    siglo~XX y siglo~XIX.   Str "siglo~XX" … Str "siglo~XIX."   (un ~ suelto queda literal)
    art.~3,~inc.~b          Str "art.", Subscript ["3,"], Str "inc.~b"
    n.º~5,~vol.~2           Str "n.º", Subscript ["5,"], Str "vol.~2."
    H~2~O                   Str "H", Subscript ["2"], Str "O"

No hay aviso: «3,» sale en subíndice en todas las salidas. Un filtro no lo puede deshacer: no distingue `H~2~O` de `art.~3,~inc.`.

EN EL PROYECTO: `~` no puede ser el espacio fijo del .md mientras el subíndice sea `H~2~O` (SC-30). El espacio fijo es `¬` (SC-68).',
   'vigente', 'empirica',
   'pandoc 3.1.3 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-68,vinculo:SC-30',
   NULL,
   1300, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-130 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-130';

-- ------------------------------------------------------------
-- 3. GV-131
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 131, 'GV-131', 'Pandoc: candidatos a marca en línea; | corta una celda, ¬ pasa en todas las posiciones',
   'Medido con pandoc 3.1.3, cada candidato pegado entre dos palabras y en secuencia (`siglo|XX`, `art.|3,|inc.|b`):

    |      en un párrafo queda literal; en una celda de pipe table CORTA LA CELDA
           y el resto se pierde: «siglo|XX» da la celda «siglo»
    _      `siglo_XX` y `art._3,_inc._b` quedan literales (intraword_underscores),
           pero `_22_` da bastardilla: depende del contexto
    = +    quedan literales, pero aparecen en la prosa académica (n=30, C++, +5 %);
           una línea `===` debajo de un párrafo lo vuelve título
    ^      es el superíndice
    ¬      queda en el Str en todas las posiciones probadas

`¬` (U+00AC) pasó entre palabras, en secuencia (`art.¬3,¬inc.¬b`), en el sufijo y el prefijo de una cita (`[@a, pág.¬22]`), en una celda de tabla, pegado a una bastardilla (`*Felipe*¬II`), al principio y al final de una palabra, en el título de los metadatos, en una nota, en el pie de una imagen y en el texto de un enlace. En el código, la matemática y la URL de un enlace queda literal: no son Str.

`\ ` (barra y espacio) es el espacio duro que trae Pandoc (extensión `all_symbols_escapable`): `siglo\ XX` da `Str "siglo\160XX"`. Funciona, pero en el editor no se ve.

TECLADO (archivos xkb del contenedor): `¬` es AltGr + la tecla a la izquierda del 1 en `latam`, y AltGr+6 en `latam` y en `es`. Alberto usa la primera.',
   'vigente', 'empirica',
   'pandoc 3.1.3 / xkb (latam, es) / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-68,vinculo:GV-130',
   NULL,
   1310, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-131 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-131';

-- ------------------------------------------------------------
-- 4. GV-132
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 132, 'GV-132', 'TextEdit conserva U+00AC (¬) al guardar y al reabrir',
   'Prueba de Alberto en Mint (24/10): en `txtEditorProyecto`, que es un TextEdit, escribió `siglo¬XX`, guardó, cerró y volvió a abrir el archivo. El carácter se ve en el editor y en la terminal:

    grep -o $''\xc2\xac'' l-CALIFA.md | wc -l    ->  1

GV-47 no lo había probado: lo que `.Text` transforma al leer es U+00A0, no U+00AC.

Tampoco lo tocan, leído en el código:

- el escáner UTF-8 (`m_EscanerUTF8`): el 172 no está en ninguno de sus rangos;
- `limpiar_docx.lua`: no lo nombra;
- el corrector: `m_Hunspell` separa las palabras con `m_FuncionesGenericas.EsLetra`, que toma como letras el 192–255 de Latin-1. `¬` es el 172: `siglo¬XX` se revisa como «siglo» y «XX».',
   'vigente', 'empirica',
   'Gambas 3.22 / gb.qt5 / Linux Mint (prueba de Alberto); código de m_Hunspell, m_FuncionesGenericas y m_EscanerUTF8',
   '2026-10', 'apoya:SC-68,vinculo:GV-47',
   NULL,
   1320, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-132 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-132';

-- ------------------------------------------------------------
-- 5. GV-133
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 133, 'GV-133', 'Pandoc: --abbreviations pone un espacio duro detrás de cada abreviatura; pandoc.read no la toma sola',
   'Medido con pandoc 3.1.3. Con `smart` activo (lo está en `markdown`), el lector une una abreviatura de la lista con lo que sigue mediante U+00A0:

    la pág. 22, el n.º 5, Lic. Pérez, P. Bourdieu, EE. UU.
      ->  Str "pág.\160 22", "n.º\160 5", "Lic.\160 Pérez", "P.\160 Bourdieu", "EE.\160 UU."

- Coincidencia exacta: «Pág.» necesita su propia línea; «PÁG.» no está y no se une.
- Solo ante un espacio: una abreviatura al final de una línea del .md (SoftBreak) no se une con la siguiente.
- Pegada a otro inline: «pág. \num{1200}» da `Str "pág.\160"` y el RawInline; «cap. *tres*», `Str "cap.\160"` y la bastardilla.
- También en el sufijo de una cita: `[@a, pág. 40]` da `"pág.\160 40"`.
- El archivo REEMPLAZA la lista que trae Pandoc, no la amplía: con una lista sin «p.», «p. 4» deja de unirse. Sin la opción, Pandoc usa la suya (`pandoc --print-default-data-file=abbreviations`), que es inglesa pero trae p., pp., vol., fig., cf., ed. y n.: «p. 22» ya salía unido.
- Una abreviatura por línea, sin espacios.

pandoc.read EN UN FILTRO

`pandoc.read(texto, ''markdown'')` NO usa la lista de la línea de órdenes: usa la de Pandoc. Con `PANDOC_READER_OPTIONS` entero la usa, pero también toma `columns` (72 en lugar de 80) y cambia el ancho relativo de las columnas de una grid table (`ColWidth 0.111…` en lugar de `0.1`). Pasando solo esa opción, la salida es idéntica salvo las abreviaturas (medido con una grid table y una pipe table):

    pandoc.read(texto, ''markdown'', { abbreviations = PANDOC_READER_OPTIONS.abbreviations })

EL IDENTIFICADOR AUTOMÁTICO de un título quita el espacio duro, no lo vuelve guion: «# El siglo¬XX» da `el-sigloxx`.',
   'vigente', 'empirica',
   'pandoc 3.1.3 (Lua 5.4) / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-68,vinculo:SC-66',
   NULL,
   1330, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-133 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-133';

-- ------------------------------------------------------------
-- 6. SC-68
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 68, 'SC-68', 'Espacio fijo en el .md: ¬ como el ~ de LaTeX, y las abreviaturas por el lector',
   'DECISIÓN CERRADA (decisión de Alberto, 24/10). Escribir un espacio que no se corta tiene que ser tan simple como en LaTeX. Dos capas:

1. LA MARCA. `¬` (U+00AC) entre dos palabras, como el `~` de LaTeX:

    siglo¬XX    Felipe¬II    art.¬3,¬inc.¬b    20¬de¬mayo

En el teclado latinoamericano es AltGr + la tecla a la izquierda del 1 (GV-131).

2. LAS ABREVIATURAS, SIN MARCA. El lector de Pandoc pone el espacio duro detrás de cada abreviatura de `filters/abreviaturas-espacio-fijo.txt` (GV-133): «pág. 22», «cap. 3», «n.º 5», «Lic. Pérez», «EE. UU.» se escriben con un espacio común. Es lo que hace biblatex con `\cite[22]{clave}`.

POR QUÉ ¬ Y NO ~

`~` es el subíndice de Pandoc (SC-30), y arma uno sin aviso con dos `~` sin espacio entre ellos (GV-130). `\ ` no se ve en el editor; `|` corta una celda; `_`, `=` y `+` dependen del contexto o aparecen en la prosa (GV-131). `¬` no es sintaxis de Pandoc en ninguna posición, no aparece en la prosa y el editor lo conserva (GV-132). El carácter U+00A0 sigue sin escribirse en el .md (GV-47).

EXCEPCIÓN A SC-40: es la única marca del .md que no es ASCII. La convención ASCII de LaTeX, `~`, no está disponible.

LA CADENA

- `filters/espacio-fijo.lua` cambia `¬` por U+00A0 en los Str: también en el prefijo y el sufijo de una cita, las notas, las celdas, los pies, el texto de un enlace y los metadatos. En el código, la matemática y las URL queda literal.
- Va SEGUNDO: después de `cuadro-leer`, que inserta el texto del cuadro, y antes de todo filtro que serializa. Está en FILTROS_LIBRO y FILTROS_REVISTA (`engine/comun.sh`), en `m_XML.GenerarBodyXML` y en `m_GenerarODT`; solo, sin los demás filtros, en `m_GenerarEpub.ConvertirMdAXhtml` (el front y el back matter de la revista) y en `m_PrimerasLibro.ConvertirMarkdown`.
- `--abbreviations` en esos mismos lectores y en `vista_cuadro.sh`. La ruta está en `comun.sh` (`RUTA_ABREVIATURAS`) y en `m_Constantes` (`SUBRUTA_ABREVIATURAS`, con `SUBRUTA_FILTRO_ESPACIO_FIJO`). `generar_canonicos_capitulos.sh` y `vista_cuadro.sh` frenan si falta la lista.
- `cuadro-leer.lua` lee el archivo del cuadro con `pandoc.read`, pasándole solo la lista (GV-133).
- La lista viaja en `filters/`: se copia a `~/.gbpublisher/filters/` y se coteja con la instalada, como los filtros.

LAS SALIDAS

- Canónico JATS o DocBook, HTML, EPUB y ODT: el carácter U+00A0.
- PDF: `f:mapa-tex` (`tex-comun.xsl`) pasa U+00A0 a `~`, así el resultado no depende de cómo traten el carácter la fuente o LuaLaTeX. En una cita llega a la postnota: `\autocite[p.~22]{…}`.
- Primeras: Pandoc escribe `~` en LaTeX y el carácter en HTML.

EL LOCATOR IMPLÍCITO

`[@clave, 22]` da «p. 22» (`cite-to-biblioref-db.lua` y `cite-to-xref.lua`). El prefijo iba separado por un Space y la línea podía partirse entre «p.» y el número; ahora va en el mismo Str, con U+00A0. Un sufijo con letras («pág. 40») no pasa por ahí: lo une la lista.

CONTROLES Y ANÁLISIS

- `controles_md.lua`: control nuevo `espacio_fijo_suelto` (aviso), un `¬` que toca un espacio común o el borde de la línea («siglo ¬XX», «siglo¬ XX»). Pegado a otro inline está bien (`siglo¬*XX*`). `porcentaje_suelto` cubre también «20¬%».
- `analizar_proyecto.lua` parte cada Str en `¬` y en U+00A0: «siglo¬XX» son dos palabras y un espacio impreso, y perl recibe un espacio común. Por eso el análisis y los controles no llevan `--abbreviations`: cuentan igual con la lista o sin ella.

ALCANCE

El .md y las primeras, que pasan por Pandoc. El `.bib` sigue con el `~` de biblatex. Un campo de la base que no pasa por Markdown imprime `¬` tal cual. No hay escape para un `¬` literal en el texto: va en código, o en matemática como `\neg`. La lista es de la casa y se edita como dato: una abreviatura por línea, con sus formas con mayúscula.

MEDIDO en el contenedor (pandoc 3.1.3, SaxonJ-HE 12.5, gbc3 3.19 con gb.db en lugar de gb.db2, que 3.19 no trae): las cadenas de libro y de revista sobre un capítulo con `¬`, abreviaturas, el locator implícito, una nota y un cuadro: el canónico lleva U+00A0 donde corresponde y `H~2~O` sigue siendo subíndice. `f:latex` da `siglo~XX`, `pág.~22` y `p.~22`. Los escritores HTML y ODT dejan el carácter. Las primeras en LaTeX dan `siglo~XX` y `vol.~2`. El control y el análisis, sobre un .md de prueba. El proyecto compila.',
   'vigente', 'empirica',
   'gbpublisher / pandoc 3.1.3 / SaxonJ-HE 12.5 / gbc3 3.19 / contenedor Ubuntu 24.04; TextEdit en Mint con Gambas 3.22',
   '2026-10', 'vinculo:SC-40,vinculo:SC-30,vinculo:SC-31,vinculo:SC-54,vinculo:SC-46,vinculo:SC-66,vinculo:GV-47,vinculo:GV-88,apoya:GV-130,apoya:GV-131,apoya:GV-132,apoya:GV-133',
   'Probar en Mint con un libro y una revista reales: el PDF (una cita con «p.~22» en la postnota), el HTML, el EPUB, el ODT y las primeras; el aviso espacio_fijo_suelto al generar los canónicos.',
   680, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-68 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-68';

-- ------------------------------------------------------------
-- 7. GV-47, SC-30, SC-40 Y SC-46: EL PÁRRAFO Y LA RELACIÓN
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = cuerpo || char(10) || char(10) || 'DESDE SC-68 la marca de espacio fijo del .md es `¬` (U+00AC), que TextEdit conserva (GV-132). El .md sigue sin U+00A0: el espacio duro lo ponen el filtro y el lector de Pandoc, después de leer el archivo.',
       relaciones = relaciones || ',vinculo:SC-68,vinculo:GV-132',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'GV-47';
INSERT INTO verificacion SELECT 'GV-47 actualizada', instr(cuerpo, 'DESDE SC-68 la marca de espacio fijo del .md es `¬` (U+00AC), que TextEdit conserva (GV-132). El .md sigue sin U+00A0: el espacio duro lo ponen el filtro y el lector de Pandoc, después de leer el archivo.') > 0 AND instr(relaciones, ',vinculo:SC-68,vinculo:GV-132') > 0 FROM entradas WHERE codigo = 'GV-47';

UPDATE entradas
   SET cuerpo = cuerpo || char(10) || char(10) || 'EXCEPCIÓN: el espacio fijo se escribe `¬`, no `~`: en Pandoc `~` es el subíndice (SC-68, GV-130).',
       relaciones = relaciones || ',vinculo:SC-68',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-40';
INSERT INTO verificacion SELECT 'SC-40 actualizada', instr(cuerpo, 'EXCEPCIÓN: el espacio fijo se escribe `¬`, no `~`: en Pandoc `~` es el subíndice (SC-68, GV-130).') > 0 AND instr(relaciones, ',vinculo:SC-68') > 0 FROM entradas WHERE codigo = 'SC-40';

UPDATE entradas
   SET cuerpo = cuerpo || char(10) || char(10) || '`~` sigue siendo el subíndice (`H~2~O`). El espacio fijo del .md es `¬` (SC-68).',
       relaciones = relaciones || ',vinculo:SC-68',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-30';
INSERT INTO verificacion SELECT 'SC-30 actualizada', instr(cuerpo, '`~` sigue siendo el subíndice (`H~2~O`). El espacio fijo del .md es `¬` (SC-68).') > 0 AND instr(relaciones, ',vinculo:SC-68') > 0 FROM entradas WHERE codigo = 'SC-30';

UPDATE entradas
   SET cuerpo = cuerpo || char(10) || char(10) || 'ESPACIO FIJO: un Str se parte en `¬` y en U+00A0 antes de contar (SC-68): «siglo¬XX» son dos palabras y un espacio impreso.',
       relaciones = relaciones || ',vinculo:SC-68',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-46';
INSERT INTO verificacion SELECT 'SC-46 actualizada', instr(cuerpo, 'ESPACIO FIJO: un Str se parte en `¬` y en U+00A0 antes de contar (SC-68): «siglo¬XX» son dos palabras y un espacio impreso.') > 0 AND instr(relaciones, ',vinculo:SC-68') > 0 FROM entradas WHERE codigo = 'SC-46';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-47', 'GV-130', 'GV-131', 'GV-132', 'GV-133', 'SC-30', 'SC-40', 'SC-46', 'SC-68')
 ORDER BY prefijo, numero;
