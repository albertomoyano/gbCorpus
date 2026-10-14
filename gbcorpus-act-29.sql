-- ============================================================
-- gbCorpus — actualización 29: la lanzadora muestra que trabaja; el PDF
--            pasa por ella
-- Esquema: 1
-- Origen: pedido de Alberto: durante la composición LaTeX no había ningún
--         aviso y parecía que la máquina se había colgado. Decisión: los
--         tres pasos (PDF por la lanzadora, puntero ocupado, lblMensajes con
--         el tiempo transcurrido). Cotejado con la carpeta local de gbCorpus
--         (último script: act-28) y con una copia de la base local.
-- Fecha:  2026-10-14
--
-- ALTAS:
--   GV-100  Application.Busy en gb.qt5: cursor de espera global, y Message
--           lo suspende solo
--
-- MODIFICA:
--   SC-53  sección QUÉ VE QUIEN OPERA; LOS USOS con el EPUB y el PDF
--   SC-13  pendiente: el compilador del PDF ya no es deuda
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-100 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-100' OR (prefijo = 'GV' AND numero = 100);
INSERT INTO verificacion SELECT 'GV-99 es la última GV', MAX(numero) = 99 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'SC-53 ancla MIENTRAS', (length(cuerpo) - length(replace(cuerpo, 'con un solo camino de salida (RC-GM-20).

CÓDIGOS', ''))) / length('con un solo camino de salida (RC-GM-20).

CÓDIGOS') = 1 FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 usos de partida', (length(cuerpo) - length(replace(cuerpo, '`ensamblar_libro.sh`, `generar_html_libro.sh` y `generar_canonicos_capitulos.sh`.', ''))) / length('`ensamblar_libro.sh`, `generar_html_libro.sh` y `generar_canonicos_capitulos.sh`.') = 1 FROM entradas WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-13 inventario de partida', (length(pendiente) - length(replace(pendiente, 'm_InicioCierre y GenerarPDFLibro en m_GenerarSalidasLibro.', ''))) / length('m_InicioCierre y GenerarPDFLibro en m_GenerarSalidasLibro.') = 1 FROM entradas WHERE codigo = 'SC-13';

-- ------------------------------------------------------------
-- 2. GV-100
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 100, 'GV-100', 'Application.Busy en gb.qt5: cursor de espera global, y Message lo suspende solo',
   'Leído en el código fuente de Gambas 3.22.1.

`Application.Busy` lo implementa `APPLICATION_set_busy` en `gb.qt4/src/CScreen.cpp`, que `gb.qt5` enlaza:

    al pasar de 0 a más de 0    qApp->setOverrideCursor(Qt::WaitCursor)
    al volver a 0               qApp->restoreOverrideCursor()
    un valor negativo           se toma como 0

Es un cursor de anulación de Qt: vale para todas las ventanas y queda puesto hasta que se restaura, aunque el bucle de eventos siga corriendo (`Wait`). Lo que cuenta es el paso por cero, así que `Inc` / `Dec` anidan bien y `= 1` pisaría a otro que ya lo tuviera en uso.

`Message` (`comp/src/gb.gui.base/.src/Message/FMessage.class`) guarda `Application.Busy`, lo pone en 0 mientras muestra el diálogo y lo restaura al cerrarlo: el cuadro aparece con el puntero normal sin que el llamador haga nada.

En el proyecto ya se usaba alrededor de bloques que no ceden el control (FEstadisticas, m_Estructura, CVisorResaltado); en la lanzadora se usa por primera vez durante una espera con `Wait` (SC-53).',
   'vigente', 'doc_oficial', 'Código fuente de Gambas 3.22.1 (gb.qt4/src/CScreen.cpp, enlazado por gb.qt5; comp/src/gb.gui.base/.src/Message/FMessage.class)', '2026-10',
   'apoya:SC-53,vinculo:GV-17', 'Confirmar en Mint, con la lanzadora, que el puntero queda ocupado durante toda la espera y vuelve al terminar, y que la pregunta del plazo aparece con el puntero normal. Hecho eso, pasar la evidencia a empirica y quitar este pendiente.',
   1000, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-100 alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-100' AND orden = 1000;

-- ------------------------------------------------------------
-- 3. SC-53
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(replace(cuerpo, 'con un solo camino de salida (RC-GM-20).

CÓDIGOS', 'con un solo camino de salida (RC-GM-20).

QUÉ VE QUIEN OPERA

Mientras espera, la lanzadora muestra que está trabajando. Sin eso, una composición LaTeX de varios minutos parecía una máquina colgada.

- El puntero ocupado en toda la aplicación: `Inc Application.Busy` al bloquear y `Dec` al desbloquear, en el mismo único camino de salida. `Inc` y no `= 1`: si otra cosa ya lo tenía en uso, vuelve a ese valor. Los diálogos de `Message`, incluida la pregunta del plazo, lo ponen en cero y lo restauran solos (GV-100).
- `FMain.lblMensajes`, sobre la terminal: qué se está generando —el parámetro opcional `sQue` de `EjecutarScriptSalida`, o el nombre del script si falta— y el tiempo transcurrido, una vez por segundo. Es tiempo, no un porcentaje: solo dice que el proceso sigue vivo. Se vacía al desbloquear.

Al dejar de esperar también se desbloquea y se vuelve al puntero normal: el script sigue corriendo, pero la aplicación ya no lo sigue y no puede seguir diciendo que trabaja.

CÓDIGOS'), '`ensamblar_libro.sh`, `generar_html_libro.sh` y `generar_canonicos_capitulos.sh`.', '`ensamblar_libro.sh`, `generar_html_libro.sh`, `generar_epub_libro.sh`, `generar_canonicos_capitulos.sh` y `compilar_pdf_libro.sh`. Este último fue el último en pasar: se tipeaba en la terminal, Gambas no sabía cuándo terminaba y no informaba el resultado; además tenía su propia copia de las funciones de salida, con un `aviso` que no contaba. Ahora carga `comun.sh` y sus avisos (citas sin entrada en el .bib, entradas de índice descartadas, referencias cruzadas sin destino o repetidas, falta del .bib) llegan como código 3.'),
       relaciones = relaciones || ',vinculo:GV-100',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-53';
INSERT INTO verificacion SELECT 'SC-53 actualizada', instr(cuerpo, 'QUÉ VE QUIEN OPERA') > 0 AND instr(cuerpo, 'compilar_pdf_libro.sh` y') = 0 AND instr(cuerpo, '`compilar_pdf_libro.sh`. Este último') > 0 AND instr(relaciones, 'GV-100') > 0 FROM entradas WHERE codigo = 'SC-53';

-- ------------------------------------------------------------
-- 4. SC-13: EL INVENTARIO
-- ------------------------------------------------------------
UPDATE entradas
   SET pendiente = replace(pendiente, 'm_InicioCierre y GenerarPDFLibro en m_GenerarSalidasLibro.', 'm_InicioCierre y los echo de GenerarPDFLibro antes de lanzar el compilador (el compilador ya pasa por la lanzadora).'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-13';
INSERT INTO verificacion SELECT 'SC-13 actualizada', instr(pendiente, 'ya pasa por la lanzadora') > 0 FROM entradas WHERE codigo = 'SC-13';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('GV-100', 'SC-13', 'SC-53') ORDER BY prefijo DESC, numero;
