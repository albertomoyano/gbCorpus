-- ============================================================
-- gbCorpus — actualización 18: SC-51, la biblioteca de patrones de la
--            pestaña RegExp
-- Esquema: 1
-- Origen: revisión de la búsqueda con expresiones regulares pedida por
--         Alberto, del lado de Gambas (el motor perl no cambia). Código
--         entregado en el mismo lote: m_PatronesRegex, FGuardarPatron,
--         m_BuscarRegex completo y parches de FMain y m_InicioCierre.
--         Compilado con el proyecto completo y probado bajo xvfb en
--         Gambas 3.19 (contenedor Ubuntu 24.04); falta Mint 3.22.1.
-- Fecha:  2026-10-10
--
-- ALTAS:
--   SC-51  Biblioteca personal de patrones de la pestaña RegExp
--   GV-97  Dialog.SaveFile con gb.form.dialog: la pregunta de
--          sobrescritura la hace gb.form
--   GV-98  JSON.Decode: listas como Variant[], null sin clave
--
-- MODIFICA:
--   SC-05  relación con SC-51
--
-- SUPUESTO: act-17 ya aplicada (SC-50 ocupado). El paso 1 lo comprueba.
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA: CÓDIGOS LIBRES Y SC-50 YA DADO DE ALTA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-50 existe (act-17)', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-50';
INSERT INTO verificacion SELECT 'SC-51 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'SC-51' OR (prefijo = 'SC' AND numero = 51);
INSERT INTO verificacion SELECT 'GV-97 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-97' OR (prefijo = 'GV' AND numero = 97);
INSERT INTO verificacion SELECT 'GV-98 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-98' OR (prefijo = 'GV' AND numero = 98);
INSERT INTO verificacion SELECT 'SC-05 sin relación previa', instr(relaciones, 'SC-51') = 0 FROM entradas WHERE codigo = 'SC-05';

-- ------------------------------------------------------------
-- 2. ALTA DE SC-51
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('SC', 51, 'SC-51', 'Búsqueda con expresiones regulares: biblioteca personal de patrones', 'DECISIÓN CERRADA (decisión de Alberto). La pestaña RegExp tiene una biblioteca de patrones personales: lo que se probó en el banco de pruebas se guarda con un nombre y se vuelve a cargar desde `cmbPatrones`. Los datos y el formato viven en `m_PatronesRegex`; la pestaña la gobierna `m_BuscarRegex`; nombre, descripción y texto de prueba los pide `FGuardarPatron`. El motor no cambia (SC-05).

PERSONALES, SIN JUEGO DE LA CASA

Cada usuario desarrolla sus patrones sobre sus propios textos. No viajan patrones en el paquete y no hay nada en la base.

- Carpeta `~/.gbpublisher/regex/`. La crea vacía `m_InicioCierre.DirectorioOcultoApp()`. No entra en la lista de copia de SC-11: no hay nada que copiar desde el sistema (el criterio de los snippets, SC-21).
- La carpeta es de la cuenta de Linux, no de la máquina: dos usuarios de gbpublisher que entran con la misma cuenta comparten los patrones; dos cuentas, no. Entre cuentas o entre máquinas se pasan con Compartir e Importar.

UN ARCHIVO POR PATRÓN

`<nombre>.json`, con un solo patrón dentro. El nombre es el del archivo: `a-z`, `0-9` y guion, de 1 a 60 caracteres. El nombre inválido se rechaza con un mensaje, no se convierte en silencio. Lo legible va en la descripción.

Al cargar se ignora en silencio todo archivo cuyo nombre no sea un nombre de patrón (respaldos con `~`, ajenos). Uno con nombre de patrón que no se puede usar —JSON roto, versión más nueva, más de un patrón, nombre interno distinto del archivo— se lista en un solo aviso, para que no desaparezca sin explicación (GV-23). La biblioteca se relee del disco en cada apertura de proyecto: un patrón corregido con un editor externo aparece al día.

FORMATO

    { "formato": "gbpublisher-regex",
      "version": 1,
      "patrones": [
        { "nombre": "...", "descripcion": "...", "patron": "...",
          "reemplazo": "...", "flags": "...", "texto_prueba": "..." } ] }

- `version` es un entero. Una más nueva que la que entiende la instalación se rechaza diciendo cuál es.
- Obligatorios: `nombre` y `patron`. Los demás, si faltan, valen "". Se leen siempre con `m_PatronesRegex.Campo`, que devuelve "" si la clave no está o no es texto: una clave con "" no existe en una `Collection` (GV-68), y un `null` de JSON tampoco (GV-98).
- `flags`: solo `i`, `m`, `s`, `x`, y se guardan en ese orden.
- Las claves desconocidas se ignoran.
- Se escribe a mano, con sangría y un `JSON.Encode` por valor, para que el archivo se pueda leer y corregir en un editor de texto. Van siempre los seis campos.

EL MISMO FORMATO PARA GUARDAR, COMPARTIR E IMPORTAR

- Compartir escribe SOLO el patrón elegido, y lo guardado: con cambios sin guardar, pide guardar antes. La sobrescritura del destino la pregunta el diálogo; el código pregunta solo si cambia la ruta después, al agregar la extensión `.json` que faltaba (GV-97, RC-GM-19).
- Importar acepta uno o varios patrones. Cada elemento se controla por separado: uno malo no invalida a los demás. Después pasa por el modo `validar` del motor: un solo motor decide la sintaxis (SC-05). Mismo nombre y mismo contenido: «ya estaba». Mismo nombre y otro contenido: pregunta si reemplazar u omitir, mostrando los dos patrones. Un nombre repetido dentro del archivo: vale el primero. Al final, un informe con las cuentas y los descartados con su motivo.
- Un patrón ajeno no es un riesgo: RC-PL-01 cubre el reemplazo, y perl rechaza `(?{...})` en un patrón que viene de variable.

LA PESTAÑA

- El primer ítem del combo es «(patrón libre)». Elegirlo conserva lo que hay en los campos.
- Elegir un patrón completa patrón, reemplazo y flags. Su texto de prueba entra en `areaEditor` solo si el área está vacía: así no se pisa un fragmento real pegado para probar varios patrones.
- `lblDescripcionPatron` muestra la descripción y la marca «modificado, sin guardar». La marca compara patrón, reemplazo y flags con lo guardado; la descripción y el texto de prueba no cuentan. Se compara contra lo guardado, no se siguen eventos: no importa qué asignación dispara qué.
- Reemplazar los campos con otro patrón pregunta si se perdería algo: un patrón libre escrito, o uno cargado con cambios. Es SC-06 aplicado a la pestaña. Volver a elegir el mismo patrón es volver a la versión guardada.
- Reponer el combo desde el código pasa por una bandera: asignar `Index` dispara `Click` (GV-53); `Clear` y `Add` no (GV-69).
- Guardar exige un patrón que el motor aceptó. `FGuardarPatron` propone el nombre cargado, su descripción y el contenido de `areaEditor` como texto de prueba, para recortarlo. Si el nombre existe, confirma: actualizar el mismo, o reemplazar otro distinto. Un nombre nuevo es «guardar como»: el anterior queda. No hay renombrar: se guarda como y se borra.
- Borrar deja los campos como patrón libre.

PRIMEROS PATRONES (DE ALBERTO, ERRORES QUE LLEGAN DE WORD A LAS REFERENCIAS)

    pagina-sin-espacio   (?<![\p{L}\p{N}])p\.(\d+)(?!\d|\s*(?:--|-|–)\s*\d)     ->  p. $1
    rango-paginas        (?<![\p{L}\p{N}])(?!pp\. \d+--\d)pp?\.\s*(\d+)\s*(?:--|-|–)\s*(\d+)   ->  pp. $1--$2

El lookbehind exige que delante de la `p` no haya letra ni dígito, en cualquier alfabeto: quedan fuera `Exp.2` y `ap.3`, y entra `(p.135)`. El primero deja los rangos para el segundo, así que el orden no importa. El segundo no toca un `pp. 20--24` ya correcto, y lleva el rango a `--` (SC-40): delante de `pp.` el contexto confirma el rango que `limpiar_docx.lua` solo puede avisar (`aviso_guion_entre_digitos`). Probados con `engine/buscar_regex.pl`, modo `probar`.', 'vigente', 'empirica',
   'gbpublisher / Gambas 3.19, proyecto completo compilado y flujo probado con gbx3 bajo xvfb / perl 5.38, engine/buscar_regex.pl / contenedor Ubuntu 24.04', '2026-10',
   'vinculo:SC-05,vinculo:RC-PL-01,vinculo:SC-21,vinculo:SC-11,vinculo:SC-06,vinculo:SC-40,vinculo:GV-53,vinculo:GV-69,vinculo:GV-68,vinculo:GV-97,vinculo:GV-98,vinculo:RC-GM-19,vinculo:GV-23',
   'Verificar en Linux Mint con Gambas 3.22.1 el flujo completo en la aplicación (guardar, elegir, marca de modificado, compartir, importar); el mini-test de JSON ya pasó (GV-98). Después, quitar este pendiente y poner el entorno de Mint.',
   510, datetime('now','localtime'), datetime('now','localtime'));

-- ------------------------------------------------------------
-- 3. ALTA DE GV-97 Y GV-98
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 97, 'GV-97', 'Dialog.SaveFile con gb.form.dialog: la pregunta de sobrescritura la hace gb.form', 'Con `gb.form.dialog` cargado —lo está en gbpublisher—, la clase `Dialog` es la del componente, escrita en Gambas (`Class.Load("Dialog").Component.Name` da `gb.form.dialog`, medido). `SaveFile` abre `FFileDialog`, que usa el `FileChooser` de `gb.form`.

LA PREGUNTA EXISTE, Y LA HACE gb.form

`FDirChooser.CheckFile` pregunta antes de aceptar un archivo existente: «This file already exists. Do you want to overwrite it?», con Overwrite y Cancel. Cancel deja el diálogo abierto. Leído en el fuente (etiqueta 3.22.1) y medido bajo xvfb: aparece con el nombre escrito tal cual y también con «Extensión automática», porque el campo ya muestra la extensión del filtro.

En `FFileDialog.fchChoose_Activate` hay otra copia del mismo control, COMENTADA (en 3.19.0, en 3.22.1 y en la rama principal). No significa que falte la pregunta: es un resto, y la que vale es la de `FDirChooser`.

CONSECUENCIAS

- No repetir la pregunta en el código después de `SaveFile`: saldría dos veces.
- Sí preguntar si el código cambia la ruta después del diálogo, por ejemplo al agregar una extensión que faltaba: esa ruta el diálogo no la vio.
- `SaveFile` y `OpenFile` devuelven True al cancelar (`Return Not Me.ShowModal()`), la misma convención que `SelectDirectory` (GV-16).

Caso del proyecto: `m_BuscarRegex.CompartirPatron` (SC-51).', 'vigente', 'empirica',
   'Código fuente de gb.form.dialog (FFileDialog.class) y gb.form (FDirChooser.class), etiquetas 3.19.0 y 3.22.1; medido en Gambas 3.19 / gb.qt5 con xvfb / contenedor Ubuntu 24.04', '2026-10',
   'vinculo:GV-16,vinculo:RC-GM-19,vinculo:SC-51', NULL,
   970, datetime('now','localtime'), datetime('now','localtime'));

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 98, 'GV-98', 'JSON.Decode: las listas llegan como Variant[] y un null no crea la clave', 'Cómo entrega `JSON.Decode` (gb.util.web) lo que lee, medido:

    objeto JSON              Collection
    lista JSON               Variant[] (Object.Type), no Collection[]
    elemento objeto          Collection
    entero                   Integer (TypeOf = gb.Integer)
    null                     la clave NO se crea (Exist da False)
    raíz que es una lista    asignarla a una Collection falla: Type mismatch
    JSON mal formado         error («Incorrect token», «String expected»)

Asignar el `Variant[]` a una variable `Collection[]` no da error (lo hace `m_Json.ImportarJSON`), pero para controlar un JSON ajeno conviene mirar `TypeOf` y `Object.Type` de cada valor antes de usarlo, en `If` separados: `Object.Type` sobre algo que no es objeto da error (RC-GM-17).

`JSON.Encode` de un texto devuelve el literal JSON con sus escapes. La ida y vuelta conserva barras invertidas, comillas, tabulador, salto de línea, NBSP, `ñ`, `«»` y el carácter 0x1F, con la misma cantidad de caracteres. Codificar valor por valor permite escribir a mano un JSON con sangría.

Lo mismo que GV-68 para una clave con cadena vacía: al armar una `Collection` para `JSON.Encode`, una clave con "" no se crea y no sale en el JSON.

Caso del proyecto: `m_PatronesRegex` (SC-51).', 'vigente', 'empirica',
   'Gambas 3.22.1 / gbs3 / gb.util.web / Linux Mint (mini-test json-patrones.gbs); antes, Gambas 3.19 / contenedor Ubuntu 24.04', '2026-10',
   'vinculo:GV-68,vinculo:RC-GM-17,vinculo:SC-51',
   NULL,
   980, datetime('now','localtime'), datetime('now','localtime'));

-- ------------------------------------------------------------
-- 4. SC-05: RELACIÓN CON SC-51
-- ------------------------------------------------------------
UPDATE entradas
   SET relaciones = relaciones || ',vinculo:SC-51',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-05';

-- ------------------------------------------------------------
-- 5. VERIFICACIÓN FINAL
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'SC-51 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-51' AND instr(cuerpo, 'PRIMEROS PATRONES') > 0;
INSERT INTO verificacion SELECT 'GV-97 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-97';
INSERT INTO verificacion SELECT 'GV-98 dada de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-98';
INSERT INTO verificacion SELECT 'SC-05 relacionada', instr(relaciones, 'vinculo:SC-51') > 0 FROM entradas WHERE codigo = 'SC-05';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo IN ('SC-05', 'SC-51', 'GV-97', 'GV-98') ORDER BY prefijo, numero;
