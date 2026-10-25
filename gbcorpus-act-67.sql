-- ============================================================
-- gbCorpus — actualización 67: los gráficos (SC-69) y lo medido
--            para decidirlos (GV-134 a GV-139)
-- Esquema: 1
-- Origen: conversación del 25/10. Alberto acepta rehacer FFiguras con
--         la lógica de FTabla: el archivo graficos/fig-nombre.md, las
--         salidas en media/, la figura común de SC-32, la decisión por
--         unparsed-text-available, el HTML con JSON.Encode; el formato
--         del encabezado con la clave series; los nombres FGraficos,
--         m_Graficos, CGrafico; Noto Serif embebida en el HTML.
-- Fecha:  2026-10-25
-- Aplicar: después de la actualización que dio de alta SC-68 y GV-133
--
-- ALTAS:
--   GV-134  Chart.js 4.4.1: lo que dibuja con cada forma de los datos
--   GV-135  Canvas: la fuente embebida, cargada antes de dibujar
--   GV-136  Saxon-HE 12.5: unparsed-text-available con ruta absoluta
--   GV-137  JSON.Encode (gb.util.web): qué escapa y qué no
--   GV-138  ListBox en Select.Multiple: la selección por código
--   GV-139  Chromium headless: --force-device-scale-factor
--   SC-69   Gráficos: el archivo, el formulario y las salidas
-- MODIFICA:
--   SC-32   relaciones: vinculo:SC-69
--   SC-67   relaciones: vinculo:SC-69
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-133 última GV', MAX(numero) = 133 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-68 última SC', MAX(numero) = 68 FROM entradas WHERE prefijo = 'SC';
INSERT INTO verificacion SELECT 'GV-134 a GV-139 libres', COUNT(*) = 0 FROM entradas WHERE codigo IN ('GV-134', 'GV-135', 'GV-136', 'GV-137', 'GV-138', 'GV-139') OR (prefijo = 'GV' AND numero BETWEEN 134 AND 139);
INSERT INTO verificacion SELECT 'SC-69 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-69' OR (prefijo = 'SC' AND numero = 69);
INSERT INTO verificacion SELECT 'SC-32 sin vínculo a SC-69', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-32' AND relaciones <> '' AND instr(relaciones, 'SC-69') = 0;
INSERT INTO verificacion SELECT 'SC-67 sin vínculo a SC-69', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-67' AND relaciones <> '' AND instr(relaciones, 'SC-69') = 0;

-- ------------------------------------------------------------
-- 2. GV-134
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 134, 'GV-134', 'Chart.js 4.4.1: lo que dibuja con cada forma de los datos',
   'Medido con el `chart.min.js` del proyecto en Chromium headless, ventana de 844×560, con la configuración que armaba `FFiguras.btnDibujar`:

    torta o dona, backgroundColor como cadena   todas las porciones del mismo color: hace falta un
                                                arreglo, un color por porción
    responsive: true, sin aspectRatio           el canvas toma el ancho del contenedor y la proporción
                                                por omisión del tipo: 820×500 en barras, 820×820 en
                                                torta; la torta sale cortada en 844×560
    scatter con valores sueltos y labels        la x de cada punto es null: no dibuja ningún punto;
                                                hacen falta pares {x, y}
    un valor que no es número en data («s/d»)   el script se corta (ReferenceError): no hay gráfico
    doughnut con dos datasets                   dos anillos concéntricos, el primero afuera; la
                                                leyenda nombra las porciones, no los anillos
    options.locale: ''es-AR''                     marcas «1.000», «1.200»; tooltip «S: 1.234,5»

EN EL PROYECTO: los cuatro primeros eran errores de FFiguras. En SC-69 la configuración la arma `m_Graficos` desde el archivo: un color por porción, la proporción del archivo, pares {x, y} en dispersión, `null` en la celda vacía, y las celdas se controlan antes de generar.',
   'vigente', 'empirica',
   'Chart.js 4.4.1 (.hidden/chart/chart.min.js) / Chromium 153 headless (Playwright) / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-69',
   NULL,
   1340, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-134 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-134';

-- ------------------------------------------------------------
-- 3. GV-135
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 135, 'GV-135', 'Canvas: la fuente embebida tiene que estar cargada antes de dibujar',
   'Medido en Chromium headless con Chart.js 4.4.1 y Noto Serif en un `@font-face` con data URI (woff2), bajo un nombre de familia propio para no confundirla con una instalada:

    dibujar sin esperar                 la imagen es idéntica a la de la letra de respaldo,
                                        aunque después document.fonts.check dé true
    esperar document.fonts.load(…)      sale en Noto Serif, con tildes y ñ
    y dibujar en el then

El canvas no se vuelve a pintar cuando la fuente llega: lo dibujado queda. `@font-face` carga la fuente recién cuando algo la pide, y un data URI no cambia eso.

EL SUBCONJUNTO. Noto Serif 2.015 (`.hidden/fonts`) es OFL 1.1 y su aviso no declara Reserved Font Name: se puede reducir y distribuir con el mismo nombre. Con `pyftsubset` (fonttools):

    pyftsubset NotoSerif-Regular.ttf \
      --unicodes="U+0020-007E,U+00A0-00FF,U+0152-0153,U+2010-2015,U+2018-201E,U+2022,U+2026,U+2030,U+2032-2033,U+2039-203A,U+20AC,U+2212" \
      --layout-features=''kern,liga,tnum,lnum,pnum'' --flavor=woff2 --output-file=…

Regular, 11,6 KB; Bold, 12,4 KB. Las TTF enteras pesan unos 500 KB cada una.

EN EL PROYECTO: el HTML del gráfico embebe los dos subconjuntos y dibuja después de `document.fonts.load` (SC-69).',
   'vigente', 'empirica',
   'Chromium 153 headless (Playwright) / Chart.js 4.4.1 / fonttools 4.66.1 / Noto Serif 2.015 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-69',
   NULL,
   1350, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-135 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-135';

-- ------------------------------------------------------------
-- 4. GV-136
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 136, 'GV-136', 'Saxon-HE 12.5: unparsed-text-available con una ruta absoluta pasada por parámetro',
   'Medido con la ruta de la carpeta `media` como parámetro de la línea de órdenes y el nombre del archivo armado en la hoja:

    iri-to-uri, ruta con espacio y ñ            true si el archivo existe, false si no
    iri-to-uri, ruta con # o ?                  false aunque exista: iri-to-uri no escapa # ni ?
    encode-for-uri por segmento                 true y false correctos con espacio, ñ, # y ?
    el HTML de un gráfico (200 KB, Chart.js)    true: el contenido se lee como texto UTF-8 válido
    locale POSIX (LANG vacío)                   la ñ del parámetro llega rota (a%EF%BF%BD%EF%BF%BDo)
                                                y la función da false; -Dfile.encoding y
                                                -Dsun.jnu.encoding no lo corrigen
    locale UTF-8                                la ñ llega bien

La forma que funciona:

    concat(''file://'', string-join(
      for $s in tokenize($ruta, ''/'') return encode-for-uri($s), ''/''))

EN EL PROYECTO: Mint usa es_AR.UTF-8. La hoja del HTML decide así si una figura tiene versión interactiva (SC-69).',
   'vigente', 'empirica',
   'Saxon-HE 12.5 / OpenJDK / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-69',
   NULL,
   1360, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-136 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-136';

-- ------------------------------------------------------------
-- 5. GV-137
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 137, 'GV-137', 'JSON.Encode (gb.util.web): qué escapa y qué no',
   'Medido con una `Collection` y un `Variant[]`:

    comilla doble, barra invertida      \" y \\
    salto de línea, tabulador           \n y \t
    Null en un Variant[]                null
    Float                               con punto, también con es_AR.UTF-8
    </script> dentro de una cadena      sale igual: NO se escapa
    orden de las claves                 el de inserción en la Collection

Embebido en un `<script>`, un texto con `</script>` cierra el bloque: antes de embeber hay que reemplazar `</` por `<\/`, que sigue siendo JSON válido.

LEER LOS NÚMEROS. Con es_AR.UTF-8, `Val("1234.5")` da Null y `CFloat("1234.5")` da 1234.5 (GV-96): los números del archivo se leen con `CFloat` dentro de `Try`.

EN EL PROYECTO: la configuración del gráfico se escribe con `JSON.Encode` (SC-69).',
   'vigente', 'empirica',
   'Gambas 3.19.0, gb.util.web / contenedor Ubuntu 24.04, C.UTF-8 y es_AR.UTF-8',
   '2026-10', 'apoya:SC-69,vinculo:GV-96,vinculo:GV-98',
   'Confirmar en Mint con Gambas 3.22.1.',
   1370, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-137 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-137';

-- ------------------------------------------------------------
-- 6. GV-138
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 138, 'GV-138', 'ListBox en Select.Multiple: la selección por código no emite eventos',
   'Medido con `Mode = Select.Multiple` y cuatro elementos:

    lst[1].Selected = True, lst[3].Selected = True   quedan elegidos 1 y 3; ningún evento
                                                     (Select ni Click)
    leer lst[i].Selected                            devuelve la selección
    lst.Index, lst.Text                             -1 y vacío: elegir por código no mueve
                                                    el elemento actual
    UnselectAll()                                   no queda ninguno; ningún evento

A diferencia de `Index` (GV-53), reponer la selección de una lista múltiple no dispara los handlers: no hace falta la bandera de llenado para esto.

EN EL PROYECTO: la lista de series de FGraficos (SC-69).',
   'vigente', 'empirica',
   'Gambas 3.19.0, gb.qt5 / xvfb / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-69,vinculo:GV-53',
   'Confirmar en Mint con Gambas 3.22.1.',
   1380, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-138 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-138';

-- ------------------------------------------------------------
-- 7. GV-139
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 139, 'GV-139', 'Chromium headless: --force-device-scale-factor multiplica el PNG y Chart.js dibuja a esa escala',
   'Medido:

    --screenshot --window-size=844,560                         PNG de 844×560
    lo mismo con --force-device-scale-factor=3                 PNG de 2532×1680
    devicePixelRatio 3, canvas de 800 px de ancho en CSS       canvas.width = 2400

Chart.js toma `window.devicePixelRatio` y dibuja el canvas a esa escala: el PNG no es una ampliación. 844 px a 1× dan unos 7 cm a 300 ppp; a 3×, unos 21 cm.

EN EL PROYECTO: el PNG del gráfico se saca a escala 3 (SC-69).',
   'vigente', 'empirica',
   'Chromium 153 headless (Playwright) / Chart.js 4.4.1 / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-69',
   'Confirmar con el chromium de Mint (el paquete que pide la aplicación).',
   1390, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-139 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-139';

-- ------------------------------------------------------------
-- 8. SC-69
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 69, 'SC-69', 'Gráficos: el archivo, el formulario y las salidas',
   'DECISIÓN CERRADA (Alberto acepta las recomendaciones, 25/10). El formulario de los gráficos pasa a trabajar como el de los cuadros (SC-67): del proyecto y no del artículo, con el archivo como fuente y las decisiones guardadas en él. Reemplaza a FFiguras y FFigurasEditar.

POR QUÉ

FFiguras dependía del artículo abierto en el combo de revistas (no servía para libros), no guardaba ninguna decisión (tipo, paleta, leyenda), numeraba contando archivos —y «Generar» escribía el PNG con un número distinto del CSV cargado— y armaba el JavaScript pegando texto: una comilla en una etiqueta o un «s/d» en una celda cortaban el gráfico. La torta salía de un solo color y cortada, y la dispersión vacía (GV-134). En `jats-to-html.xsl`, el criterio `starts-with($nombre, ''fi'')` tomaba también `fig-*`, el prefijo de toda figura (SC-32): en modo interactivo, cada figura común era un iframe a un archivo inexistente.

EL ARCHIVO DEL GRÁFICO

Cada gráfico vive en `graficos/fig-nombre.md`, en la raíz del proyecto como `cuadros/`, en libros y revistas. El nombre lleva `fig-` y letras sin tilde, cifras o guiones. Las salidas van a `media/`, porque el EPUB y el HTML solo copian `media/` (SC-32): `media/fig-nombre.png` y `media/fig-nombre.html`.

    ---
    tipo: barras        # barras | barras-h | lineas | area | dispersion | torta | dona
    paleta: Set2        # ColorBrewer; la clase (cualitativa, secuencial, divergente) sale del nombre
    leyenda: sí
    series: [1, 3]      (solo si se eligen)
    eje-x: ''Década''     (solo si hay)
    eje-y: ''Tesistas''   (solo si hay)
    unidad: ''%''         (solo si hay)
    apilado: sí         (solo si sí; barras, barras-h y area)
    cero: no            (solo si no; por omisión el eje arranca en cero)
    proporcion: 16:10   # 16:9 | 16:10 | 4:3 | 1:1
    ---

    | Década | Capital | Interior |
    |---|---|---|
    | 1890 | 42 | 13 |

- Los textos van entre comillas simples, con la comilla duplicada, como en el cuadro (SC-67). La pipe table, sin alinear con espacios. Lee y escribe `m_Graficos`, con el lector y el escritor de filas de `m_Cuadros`.
- La primera columna son las categorías; en `dispersion`, la x, numérica. Cada columna siguiente es una serie y su encabezado, el nombre.
- `series`: las columnas de datos que se dibujan, contadas desde la primera serie. Sin la clave, todas. `torta`: exactamente una; con más de una serie en la tabla y sin `series`, frena. `dona`: una o más, en anillos concéntricos (GV-134); la leyenda no nombra los anillos, así que el pie de la figura lo tiene que decir.
- Los números, con punto y sin separador de miles (SC-64). Se leen con `CFloat` (GV-96, GV-137). Una celda vacía es un dato que falta: `null`, y la línea se corta ahí.
- Sin título ni texto alternativo: el pie y el `alt` son de la figura en el .md (SC-32). El título dentro de la imagen repetía el pie.

LAS SALIDAS

- EL HTML. Una plantilla en `.hidden/chart/` con Chart.js 4.4.1 entero y un hueco para la configuración. `m_Graficos` arma la configuración con `JSON.Encode` y reemplaza `</` por `<\/` antes de embeberla (GV-137). Cada `fig-nombre.html` funciona solo: lleva Chart.js y la fuente.
- LA FUENTE. Noto Serif, la del HTML (decisión de Alberto). Un subconjunto latino en woff2, Regular y Bold, embebido como data URI (unos 32 KB): el iframe es otro documento y no hereda la fuente de la página, y el PNG se saca sin red. La plantilla dibuja después de `document.fonts.load` (GV-135). Los subconjuntos se generan una vez con el comando de GV-135 y viven en `.hidden/chart/`.
- LO QUE LLEVA EL GRÁFICO. `locale` del idioma de la pieza (coma decimal y punto de miles en marcas y tooltips); títulos de ejes; apilado; `beginAtZero` salvo `cero: no`; la unidad en las marcas y en el tooltip; tooltip de todas las series a la vez; `pointStyle` y `borderDash` distintos por serie, para que se distingan impresas en gris; en `torta` y `dona`, un color por porción. En las paletas secuenciales se omiten los dos tonos más claros: sobre blanco no se ven.
- ACCESIBILIDAD. El canvas lleva `role="img"`, un `aria-label` y, adentro, la tabla de datos como contenido de respaldo.
- EL PNG. Chromium headless sobre el mismo HTML, 844 px de ancho por el alto de la proporción, a escala 3 (GV-139). Es el que va al PDF, al EPUB y al HTML en borrador. Se genera en `tmp/vista-grafico/` del proyecto y se copia a `media/`.

EN EL .md

El gráfico entra como una figura común, por el camino de `FMain.InsertarFigura` sin el diálogo de imagen (SC-32): `media/fig-nombre.png`, con el id `fig-nombre`. Las cadenas no cambian.

EN EL HTML

- `jats-to-html.xsl` y `docbook-to-html.xsl` deciden si una figura es interactiva por la existencia de `fig-nombre.html` junto al PNG: `unparsed-text-available()` sobre la ruta absoluta de `media`, que reciben como parámetro, armada con `encode-for-uri` por segmento (GV-136). Se retira `starts-with($nombre, ''fi'')`.
- En borrador, siempre el PNG; en final, el iframe si existe el HTML. La pregunta PNG o Chart.js de `m_GenerarHTML` se retira: cada figura sabe si tiene versión interactiva.
- El iframe ocupa el ancho del contenedor con el `aspect-ratio` de la proporción, en lugar de 844×520 fijos. Adentro, el PNG como respaldo.
- El EPUB sigue con el PNG.

EL FORMULARIO (FGraficos)

Con la disposición y la lógica de FTabla (SC-67). A la izquierda, los gráficos de `graficos/`, con Nuevo (una plantilla), Borrar y Duplicar. Tres pestañas:

- Datos: la grilla editable, con los menús de fila y de columna. Importar CSV llena la grilla desde un archivo: el CSV ya no es la fuente.
- Diseño: las claves del encabezado; `series`, en una lista de selección múltiple con los encabezados (GV-138).
- Vista: el gráfico en un WebView.

Guardar, Generar, Insertar y Cerrar; se cierra solo por los botones (SC-20). Cambiar de gráfico, Insertar y Cerrar con cambios sin guardar preguntan: guardar, descartar o quedarse (SC-06). Insertar devuelve el id a FMain por `m_Graficos` (RC-GM-13). Borrar quita el archivo y sus dos salidas, y avisa si alguna pieza nombra la figura. El retocador de imágenes (`m_GestionImagenes`) no lista los `fig-*` que tienen fuente en `graficos/`: se regeneran, no se retocan.

QUÉ FRENA AL GENERAR

Una clave desconocida o repetida; un valor fuera de la lista; `series` con una columna que no existe, repetida o fuera de orden; `torta` con más de una serie elegida; `apilado` en un tipo que no lo admite; una celda de datos que no es un número con punto ni está vacía, nombrando la fila y la columna; en `dispersion`, una x que no es número; una tabla sin series.

SE RETIRAN FFiguras.form/.class, FFigurasEditar.form/.class, la convención `fd/fi/fh` y la edición del CSV en LibreOffice.',
   'vigente', 'empirica',
   'Chart.js 4.4.1 / Chromium 153 headless / Saxon-HE 12.5 / gbc3 3.19 / contenedor Ubuntu 24.04',
   '2026-10', 'vinculo:SC-32,vinculo:SC-66,vinculo:SC-67,vinculo:SC-64,vinculo:SC-06,vinculo:SC-20,vinculo:RC-GM-13,vinculo:GV-53,vinculo:GV-96,vinculo:GV-129,apoya:GV-134,apoya:GV-135,apoya:GV-136,apoya:GV-137,apoya:GV-138,apoya:GV-139',
   'Implementar. Confirmar en Mint: chromium con --force-device-scale-factor (GV-139), JSON.Encode y ListBox múltiple en 3.22.1 (GV-137, GV-138).',
   690, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'SC-69 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-69';

-- ------------------------------------------------------------
-- 9. SC-32 Y SC-67: EL VÍNCULO A SC-69
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-69',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo IN ('SC-32', 'SC-67');
INSERT INTO verificacion SELECT 'SC-32 y SC-67 actualizadas', COUNT(*) = 2 FROM entradas WHERE codigo IN ('SC-32', 'SC-67') AND instr(relaciones, ',vinculo:SC-69') > 0;

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-134', 'GV-135', 'GV-136', 'GV-137', 'GV-138', 'GV-139', 'SC-32', 'SC-67', 'SC-69')
 ORDER BY prefijo, numero;
