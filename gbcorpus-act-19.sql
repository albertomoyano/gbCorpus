-- ============================================================
-- gbCorpus — actualización 19: SC-51, el editor muestra las
--            coincidencias y se recarga al reemplazar
-- Esquema: 1
-- Origen: prueba de Alberto en Mint: el reemplazo regex escribía en disco
--         pero el editor seguía con el texto viejo. Causa: la recarga
--         pasaba por cmbArticulosRevista_Click, que sale sin hacer nada si
--         el archivo ya está abierto (GV-53). Decisión de Alberto: con el
--         formulario modal, el editor muestra cada coincidencia.
-- Fecha:  2026-10-10
--
-- MODIFICA:
--   SC-51  se agrega la sección sobre el editor; relaciones con SC-18,
--          GV-46 y GV-52
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: SC-51 EXISTE Y NO TIENE LA SECCIÓN
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-51 existe', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-51';
INSERT INTO verificacion SELECT 'SC-51 sin la sección nueva', instr(cuerpo, 'EL EDITOR MUESTRA LAS COINCIDENCIAS') = 0 FROM entradas WHERE codigo = 'SC-51';
INSERT INTO verificacion SELECT 'SC-51 sin relación con SC-18', instr(relaciones, 'SC-18') = 0 FROM entradas WHERE codigo = 'SC-51';

-- ------------------------------------------------------------
-- 2. SC-51: SECCIÓN NUEVA AL FINAL Y RELACIONES
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = cuerpo || '

EL EDITOR MUESTRA LAS COINCIDENCIAS Y SE RECARGA AL REEMPLAZAR (decisión de Alberto)

`FRegexResultados` es MODAL a propósito: mientras está abierto nadie escribe a mano en el editor. Con eso, el editor puede mostrar cualquier coincidencia sin riesgo de posiciones viejas.

- Antes de abrir el formulario, el editor tiene que ser igual al disco. El aviso de SC-06 ya pidió guardar o descartar, pero «Descartar» solo mueve el punto de control (`MarcarGuardado`): el texto descartado sigue en el editor. Si difiere del disco, `m_BuscarRegex.BuscarRegex` lo relee con `FMain.RecargarArchivoAbierto`.
- Elegir una fila de la grilla lleva el editor a la coincidencia (`m_BuscarRegex.MostrarCoincidencia`): abre su archivo si no es el abierto (`m_Estructura.AbrirArchivo`, por el combo, GV-53) y la deja seleccionada con su párrafo arriba de la vista (`m_EditorPrincipal.IrA`, GV-52), por línea y columna base 0, como las da el script. «Resaltar» es seleccionar: colorear con `Format` entraría en el deshacer (GV-46). Medido en banco: la selección se ve con el modal encima. No hace falta desplazar el editor a mano: el párrafo queda arriba.
- Después de escribir, `FRegexResultados` llama en el acto a `m_BuscarRegex.TrasReemplazo` con los archivos efectivamente escritos, también si la escritura se cortó a mitad. Para cada uno: árbol de estructura y referencias citadas en la base (`m_Bibtex.ExtraerYGuardarReferenciasDelEditor`), lo mismo que hace un guardado. Si uno es el abierto: `FMain.RecargarArchivoAbierto` (editor, árbol, comentarios y contador). Después se vuelve a buscar, así que las posiciones de la grilla vuelven a valer.
- Recargar es el punto de refresco 2 de SC-18: corta el deshacer. No se pierde nada: lo escrito por el reemplazo se deshace con git, que el guard del formulario exige o advierte.
- Al cerrar, el editor queda en la última coincidencia vista, con el foco.

NO SE RECARGA POR EL COMBO

La primera versión recargaba al cerrar el formulario disparando `cmbArticulosRevista_Click`. Ese handler sale sin hacer nada si la ruta es la del archivo abierto (GV-53), así que el reemplazo quedaba en disco y el editor con el texto viejo: un Ctrl+S lo pisaba. Releer un archivo abierto desde el disco se hace con `FMain.RecargarArchivoAbierto`, nunca con el Click del combo.',
       relaciones = relaciones || ',vinculo:SC-18,vinculo:GV-46,vinculo:GV-52',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-51';

INSERT INTO verificacion SELECT 'SC-51 actualizada', instr(cuerpo, 'NO SE RECARGA POR EL COMBO') > 0 AND instr(relaciones, 'vinculo:GV-52') > 0 FROM entradas WHERE codigo = 'SC-51';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo = 'SC-51';
