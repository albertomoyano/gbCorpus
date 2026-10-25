-- ============================================================
-- gbCorpus — actualización 70: los gráficos implementados (SC-69,
--            pasos 3 a 5) y lo medido al hacerlos
-- Esquema: 1
-- Origen: conversación del 25/10. Pasos 3 (FGraficos y FMain), 4 (las
--         hojas de HTML, m_GenerarHTML, m_GestionImagenes) y 5 (el
--         retiro de FFiguras). Alberto aplicó y subió los pasos 1 a 4.
-- Fecha:  2026-10-25
-- Aplicar: después de act-69
--
-- ALTAS:
--   GV-142  WebView: asignar la misma URL vuelve a leer la página
--   GV-143  XSLT: el JavaScript escrito en una hoja se lee como XML
--   GV-144  CSS: una tabla no se achica a 1 px
-- MODIFICA:
--   SC-69   lo implementado: la descripción, la accesibilidad, las hojas
--           de HTML, el formulario, el retiro; pendiente: probar en Mint;
--           relaciones: GV-68, GV-142, GV-143, GV-144
--   GV-138  reemplazar List no borra la selección
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: CADA TEXTO A REEMPLAZAR, UNA SOLA VEZ
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-141 última GV', MAX(numero) = 141 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'GV-142 a GV-144 libres', COUNT(*) = 0 FROM entradas WHERE codigo IN ('GV-142', 'GV-143', 'GV-144') OR (prefijo = 'GV' AND numero BETWEEN 142 AND 144);
INSERT INTO verificacion SELECT 'SC-69 con el pendiente de act-67', pendiente = 'Implementar. Confirmar en Mint: chromium con --force-device-scale-factor (GV-139), JSON.Encode y ListBox múltiple en 3.22.1 (GV-137, GV-138).' FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 sin GV-142', instr(relaciones, 'GV-142') = 0 FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 descripción: una vez', (length(cuerpo) - length(replace(cuerpo, 'en `tmp/vista-grafico/fig-nombre.json`. `engine/grafico.sh`', ''))) = length('en `tmp/vista-grafico/fig-nombre.json`. `engine/grafico.sh`') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 accesibilidad: una vez', (length(cuerpo) - length(replace(cuerpo, '- ACCESIBILIDAD. El canvas va con `aria-hidden` y, al lado, la tabla de datos, fuera de la vista y legible por un lector de pantalla.', ''))) = length('- ACCESIBILIDAD. El canvas va con `aria-hidden` y, al lado, la tabla de datos, fuera de la vista y legible por un lector de pantalla.') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 modos: una vez', (length(cuerpo) - length(replace(cuerpo, '- En borrador, siempre el PNG; en final, el iframe si existe el HTML. La pregunta PNG o Chart.js de `m_GenerarHTML` se retira: cada figura sabe si tiene versión interactiva.', ''))) = length('- En borrador, siempre el PNG; en final, el iframe si existe el HTML. La pregunta PNG o Chart.js de `m_GenerarHTML` se retira: cada figura sabe si tiene versión interactiva.') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 iframe: una vez', (length(cuerpo) - length(replace(cuerpo, '- El iframe ocupa el ancho del contenedor con el `aspect-ratio` de la proporción, en lugar de 844×520 fijos. Adentro, el PNG como respaldo.', ''))) = length('- El iframe ocupa el ancho del contenedor con el `aspect-ratio` de la proporción, en lugar de 844×520 fijos. Adentro, el PNG como respaldo.') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 datos: una vez', (length(cuerpo) - length(replace(cuerpo, '- Datos: la grilla editable, con los menús de fila y de columna. Importar CSV llena la grilla desde un archivo: el CSV ya no es la fuente.', ''))) = length('- Datos: la grilla editable, con los menús de fila y de columna. Importar CSV llena la grilla desde un archivo: el CSV ya no es la fuente.') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 vista: una vez', (length(cuerpo) - length(replace(cuerpo, '- Vista: el gráfico en un WebView.', ''))) = length('- Vista: el gráfico en un WebView.') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 botones: una vez', (length(cuerpo) - length(replace(cuerpo, 'Guardar, Generar, Insertar y Cerrar;', ''))) = length('Guardar, Generar, Insertar y Cerrar;') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 insertar: una vez', (length(cuerpo) - length(replace(cuerpo, 'Insertar devuelve el id a FMain por `m_Graficos` (RC-GM-13).', ''))) = length('Insertar devuelve el id a FMain por `m_Graficos` (RC-GM-13).') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 retiro: una vez', (length(cuerpo) - length(replace(cuerpo, 'SE RETIRAN FFiguras.form/.class, FFigurasEditar.form/.class, la convención `fd/fi/fh` y la edición del CSV en LibreOffice.', ''))) = length('SE RETIRAN FFiguras.form/.class, FFigurasEditar.form/.class, la convención `fd/fi/fh` y la edición del CSV en LibreOffice.') FROM entradas WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'GV-138 list: una vez', (length(cuerpo) - length(replace(cuerpo, '    UnselectAll()                                   no queda ninguno; ningún evento
', ''))) = length('    UnselectAll()                                   no queda ninguno; ningún evento
') FROM entradas WHERE codigo = 'GV-138';
INSERT INTO verificacion SELECT 'GV-138 proyecto: una vez', (length(cuerpo) - length(replace(cuerpo, 'EN EL PROYECTO: la lista de series de FGraficos (SC-69).', ''))) = length('EN EL PROYECTO: la lista de series de FGraficos (SC-69).') FROM entradas WHERE codigo = 'GV-138';

-- ------------------------------------------------------------
-- 2. LOS REEMPLAZOS
-- ------------------------------------------------------------
UPDATE entradas SET cuerpo = replace(cuerpo, 'en `tmp/vista-grafico/fig-nombre.json`. `engine/grafico.sh`', 'en `tmp/vista-grafico/fig-nombre.json`. Un texto vacío no queda en la `Collection` (GV-68): la clave no se escribe, y la plantilla toma como vacío lo que falta. `engine/grafico.sh`'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 descripción: aplicado', instr(cuerpo, 'en `tmp/vista-grafico/fig-nombre.json`. Un texto vacío no queda en la `Collection` (GV-68): la clave no se escribe, y la plantilla toma como vacío lo que falta. `engine/grafico.sh`') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, '- ACCESIBILIDAD. El canvas va con `aria-hidden` y, al lado, la tabla de datos, fuera de la vista y legible por un lector de pantalla.', '- ACCESIBILIDAD. El canvas va con `aria-hidden` y, al lado, la tabla de datos, en un `div` fuera de la vista y legible por un lector de pantalla. La clase que la oculta va en el `div` y no en la tabla: una tabla no se achica y agrandaba el alto de la página (GV-144).'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 accesibilidad: aplicado', instr(cuerpo, '- ACCESIBILIDAD. El canvas va con `aria-hidden` y, al lado, la tabla de datos, en un `div` fuera de la vista y legible por un lector de pantalla. La clase que la oculta va en el `div` y no en la tabla: una tabla no se achica y agrandaba el alto de la página (GV-144).') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, '- En borrador, siempre el PNG; en final, el iframe si existe el HTML. La pregunta PNG o Chart.js de `m_GenerarHTML` se retira: cada figura sabe si tiene versión interactiva.', '- En borrador, siempre el PNG; en final, el iframe si existe el HTML. La pregunta PNG o Chart.js de `m_GenerarHTML` se retira: cada figura sabe si tiene versión interactiva. En libros no hay modo de control: el HTML del libro es de publicación, y cada gráfico con su HTML va en iframe.
- Las reglas viven en `grafico-comun.xsl` (`gbg:interactivo`, `gbg:proporcion`, `gbg:iframe`), que incluyen las dos hojas. En `docbook-to-html.xsl` el iframe sale en el espacio de nombres de XHTML (`xsl:element`), como el resto de esa hoja: un elemento literal de la hoja común saldría sin espacio de nombres.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 modos: aplicado', instr(cuerpo, '- En borrador, siempre el PNG; en final, el iframe si existe el HTML. La pregunta PNG o Chart.js de `m_GenerarHTML` se retira: cada figura sabe si tiene versión interactiva. En libros no hay modo de control: el HTML del libro es de publicación, y cada gráfico con su HTML va en iframe.
- Las reglas viven en `grafico-comun.xsl` (`gbg:interactivo`, `gbg:proporcion`, `gbg:iframe`), que incluyen las dos hojas. En `docbook-to-html.xsl` el iframe sale en el espacio de nombres de XHTML (`xsl:element`), como el resto de esa hoja: un elemento literal de la hoja común saldría sin espacio de nombres.') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, '- El iframe ocupa el ancho del contenedor con el `aspect-ratio` de la proporción, en lugar de 844×520 fijos. Adentro, el PNG como respaldo.', '- El iframe ocupa el ancho del contenedor con el `aspect-ratio` de la proporción, en lugar de 844×520 fijos; la hoja lee la proporción de la descripción que lleva el HTML («"proporcion":1.6»). Medido en Chromium a 1280, 800 y 390 px: el iframe mide lo que el gráfico. Sin respaldo adentro: HTML5 no muestra el contenido de un iframe. El panel de figuras toma la miniatura del atributo `data-png` del contenedor, porque con un iframe no hay imagen de donde tomarla.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 iframe: aplicado', instr(cuerpo, '- El iframe ocupa el ancho del contenedor con el `aspect-ratio` de la proporción, en lugar de 844×520 fijos; la hoja lee la proporción de la descripción que lleva el HTML («"proporcion":1.6»). Medido en Chromium a 1280, 800 y 390 px: el iframe mide lo que el gráfico. Sin respaldo adentro: HTML5 no muestra el contenido de un iframe. El panel de figuras toma la miniatura del atributo `data-png` del contenedor, porque con un iframe no hay imagen de donde tomarla.') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, '- Datos: la grilla editable, con los menús de fila y de columna. Importar CSV llena la grilla desde un archivo: el CSV ya no es la fuente.', '- Datos: la grilla editable, con los menús de fila y de columna; la primera columna, la de las categorías, no se quita. Importar CSV llena la grilla desde un archivo: el CSV ya no es la fuente. El separador es el que más aparece en la primera línea (coma, punto y coma o tabulador); las celdas van tal cual: una cifra con coma decimal se señala al generar, no se adivina.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 datos: aplicado', instr(cuerpo, '- Datos: la grilla editable, con los menús de fila y de columna; la primera columna, la de las categorías, no se quita. Importar CSV llena la grilla desde un archivo: el CSV ya no es la fuente. El separador es el que más aparece en la primera línea (coma, punto y coma o tabulador); las celdas van tal cual: una cifra con coma decimal se señala al generar, no se adivina.') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, '- Vista: el gráfico en un WebView.', '- Vista: el gráfico en un WebView, con la URL codificada como en GV-141 (`m_Graficos.UrlDeArchivo`). Al abrir un gráfico muestra el último generado (GV-142).'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 vista: aplicado', instr(cuerpo, '- Vista: el gráfico en un WebView, con la URL codificada como en GV-141 (`m_Graficos.UrlDeArchivo`). Al abrir un gráfico muestra el último generado (GV-142).') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, 'Guardar, Generar, Insertar y Cerrar;', 'Guardar, Vista previa, Generar, Insertar y Cerrar;'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 botones: aplicado', instr(cuerpo, 'Guardar, Vista previa, Generar, Insertar y Cerrar;') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, 'Insertar devuelve el id a FMain por `m_Graficos` (RC-GM-13).', 'Insertar devuelve el id a FMain por `m_Graficos` (RC-GM-13), y FMain escribe el bloque de la figura con `BloqueFigura`, la misma función que `InsertarFigura`. Lo que se inserta es el PNG: si falta o es anterior al archivo, Insertar ofrece generarlo antes.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 insertar: aplicado', instr(cuerpo, 'Insertar devuelve el id a FMain por `m_Graficos` (RC-GM-13), y FMain escribe el bloque de la figura con `BloqueFigura`, la misma función que `InsertarFigura`. Lo que se inserta es el PNG: si falta o es anterior al archivo, Insertar ofrece generarlo antes.') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, 'SE RETIRAN FFiguras.form/.class, FFigurasEditar.form/.class, la convención `fd/fi/fh` y la edición del CSV en LibreOffice.', 'SE RETIRARON (25/10) FFiguras.form/.class, FFigurasEditar.form/.class, la convención `fd/fi/fh` y la edición del CSV en LibreOffice.

IMPLEMENTADO (25/10), en cinco pasos: la plantilla y la fuente; `m_Graficos`, `CGrafico` y `engine/grafico.sh`; FGraficos y `FMain`; las dos hojas de HTML, `m_GenerarHTML` y `m_GestionImagenes`; el retiro de FFiguras. MEDIDO en el contenedor: el módulo con un banco de prueba (ida y vuelta, lo que no encaja, lo que frena, las cifras, el CSV, vista y generación en una carpeta con espacio, ñ y #); el formulario bajo xvfb; las dos hojas con Saxon; el HTML de revista en Chromium.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 retiro: aplicado', instr(cuerpo, 'SE RETIRARON (25/10) FFiguras.form/.class, FFigurasEditar.form/.class, la convención `fd/fi/fh` y la edición del CSV en LibreOffice.

IMPLEMENTADO (25/10), en cinco pasos: la plantilla y la fuente; `m_Graficos`, `CGrafico` y `engine/grafico.sh`; FGraficos y `FMain`; las dos hojas de HTML, `m_GenerarHTML` y `m_GestionImagenes`; el retiro de FFiguras. MEDIDO en el contenedor: el módulo con un banco de prueba (ida y vuelta, lo que no encaja, lo que frena, las cifras, el CSV, vista y generación en una carpeta con espacio, ñ y #); el formulario bajo xvfb; las dos hojas con Saxon; el HTML de revista en Chromium.') > 0 FROM entradas WHERE codigo = 'SC-69';
UPDATE entradas SET cuerpo = replace(cuerpo, '    UnselectAll()                                   no queda ninguno; ningún evento
', '    UnselectAll()                                   no queda ninguno; ningún evento
    List = <otra lista>                             los índices que siguen existiendo quedan
                                                    elegidos: la selección no se borra
'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'GV-138';
INSERT INTO verificacion SELECT 'GV-138 list: aplicado', instr(cuerpo, '    UnselectAll()                                   no queda ninguno; ningún evento
    List = <otra lista>                             los índices que siguen existiendo quedan
                                                    elegidos: la selección no se borra
') > 0 FROM entradas WHERE codigo = 'GV-138';
UPDATE entradas SET cuerpo = replace(cuerpo, 'EN EL PROYECTO: la lista de series de FGraficos (SC-69).', 'EN EL PROYECTO: la lista de series de FGraficos (SC-69). `RefrescarSeries` reemplaza la lista, llama a `UnselectAll` y recién después elige: sin eso, al insertar una columna la serie elegida quedaba elegida dos veces, en su lugar viejo y en el nuevo.'), fecha_modificacion = datetime('now','localtime') WHERE codigo = 'GV-138';
INSERT INTO verificacion SELECT 'GV-138 proyecto: aplicado', instr(cuerpo, 'EN EL PROYECTO: la lista de series de FGraficos (SC-69). `RefrescarSeries` reemplaza la lista, llama a `UnselectAll` y recién después elige: sin eso, al insertar una columna la serie elegida quedaba elegida dos veces, en su lugar viejo y en el nuevo.') > 0 FROM entradas WHERE codigo = 'GV-138';
UPDATE entradas
   SET pendiente = 'Probar en Mint: el formulario, la vista previa y la generación en un libro y en una revista, y el HTML final con un gráfico en los dos. Confirmar en Mint: chromium con --force-device-scale-factor (GV-139), JSON.Encode, ListBox múltiple y WebView en 3.22.1 (GV-137, GV-138, GV-142).',
       relaciones = relaciones || ',vinculo:GV-68,apoya:GV-142,apoya:GV-143,apoya:GV-144',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-69';
INSERT INTO verificacion SELECT 'SC-69 pendiente y relaciones', pendiente = 'Probar en Mint: el formulario, la vista previa y la generación en un libro y en una revista, y el HTML final con un gráfico en los dos. Confirmar en Mint: chromium con --force-device-scale-factor (GV-139), JSON.Encode, ListBox múltiple y WebView en 3.22.1 (GV-137, GV-138, GV-142).' AND instr(relaciones, ',vinculo:GV-68,apoya:GV-142,apoya:GV-143,apoya:GV-144') > 0 FROM entradas WHERE codigo = 'SC-69';

-- ------------------------------------------------------------
-- 3. LAS ALTAS
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 142, 'GV-142', 'WebView (gb.qt5.webview): asignar la misma URL vuelve a leer la página',
   'Medido con un archivo en una carpeta con espacio y # en el nombre, cambiando su contenido entre una asignación y otra:

    URL = <url>, después el archivo cambia, URL = <la misma>   muestra el contenido nuevo
    Reload()                                                  muestra el contenido nuevo
    leer URL                                                  la URL decodificada: espacio y ñ
                                                              legibles, el # sigue como %23

No hace falta `Reload()` ni pasar por about:blank para ver un archivo regenerado. Y la URL que se lee no es la que se asignó: compararlas para decidir si recargar no sirve.

EN EL PROYECTO: FGraficos muestra la vista previa y lo generado asignando la URL (`MostrarEnVista`, SC-69).',
   'vigente', 'empirica',
   'Gambas 3.19.0, gb.qt5.webview / xvfb / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-69',
   'Confirmar en Mint con Gambas 3.22.1.',
   1420, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-142 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-142';

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 143, 'GV-143', 'XSLT: el JavaScript escrito en una hoja se lee como XML',
   'El JavaScript de las hojas de HTML va como texto de la hoja, sin CDATA. El parser de XML lo lee antes que nadie:

    // … <img> … en un comentario de JS   la hoja no compila: «The element type "img" must be
                                           terminated by the matching end-tag»
    ''<img src="'' + x + ''" alt=""/>''        compila: el parser lo toma como un elemento img
                                           literal, con atributos que contienen JS, y el método
                                           html lo vuelve a escribir como <img src="'' + x + ''"
                                           alt="">, que sigue siendo JS válido

La segunda forma funciona de casualidad: depende de que el texto parezca un elemento bien formado. Un comentario o una cadena con una etiqueta suelta rompe la hoja entera.

EN EL PROYECTO: el panel de figuras de `jats-to-html.xsl` (SC-69). Al tocar el JS de una hoja: nada que parezca una etiqueta en los comentarios, y probar que la hoja compile.',
   'vigente', 'empirica',
   'Saxon-HE 12.5 / jats-to-html.xsl / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-69',
   NULL,
   1430, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-143 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-143';

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 144, 'GV-144', 'CSS: una tabla no se achica a 1 px; agranda la página aunque esté recortada',
   'Medido con la plantilla del gráfico (SC-69), en un iframe de 570 px de alto con el canvas de 570:

    la clase «fuera de la vista» (position:absolute;   el documento mide 637 px: la tabla
    width:1px; height:1px; overflow:hidden; clip)      crece con sus filas e ignora el height
    en la <table>
    la misma clase en un <div> que envuelve la tabla   el documento mide 570 px

`clip` oculta lo que se ve pero no quita la tabla del alto de la página. Con `scrolling="no"` en el iframe no se notaba; en una página que se desplaza, sí.

EN EL PROYECTO: la tabla de datos de la plantilla del gráfico va dentro de un div con la clase (SC-69).',
   'vigente', 'empirica',
   'Chromium 153 headless (Playwright) / contenedor Ubuntu 24.04',
   '2026-10', 'apoya:SC-69',
   NULL,
   1440, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-144 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-144';

COMMIT;

SELECT codigo, estado, titulo FROM entradas
 WHERE codigo IN ('GV-138', 'GV-142', 'GV-143', 'GV-144', 'SC-69')
 ORDER BY prefijo, numero;
