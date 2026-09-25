-- ============================================================
-- gbCorpus — alta de la familia RC-BL y de tres entradas
-- Origen: sesión de desarrollo de FRelacionarBib (gbpublisher)
-- Fecha:  2026-09-07
--
-- ALTAS:
--   RC-BL (familia nueva) — Reglas críticas biblatex
--   RC-BL-01  related_type gana sobre related_string
--   RC-BL-02  El soporte de related depende del estilo
--   GV-34     Edit + Update escribe NULL de verdad
--
-- Ejecutar con:  sqlite3 ~/.gbcorpus/corpus.sqlite < corpus-alta-biblatex.sql
-- ============================================================

PRAGMA foreign_keys = ON;   -- ES POR CONEXIÓN, NO PERSISTE (GV-30)

BEGIN TRANSACTION;

-- ------------------------------------------------------------
-- 1. FAMILIA NUEVA: RC-BL
--    SE UBICA A CONTINUACIÓN DE RC-PL. EL orden NO SE ESCRIBE A MANO:
--    SE DERIVA DEL QUE TENGA RC-PL, Y LAS FAMILIAS POSTERIORES SE CORREN
--    UN LUGAR PARA DEJARLE SITIO.
-- ------------------------------------------------------------

UPDATE familias
   SET orden = orden + 1
 WHERE orden > (SELECT orden FROM familias WHERE prefijo = 'RC-PL');

INSERT INTO familias (prefijo, nombre, descripcion, orden, ancho_numero, en_operativo)
SELECT 'RC-BL',
       'Reglas críticas biblatex',
       'Modelo de relaciones entre entradas y su comportamiento según el estilo',
       orden + 1,
       2,
       1
  FROM familias
 WHERE prefijo = 'RC-PL';

-- ------------------------------------------------------------
-- 2. RC-BL-01
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('RC-BL', 1, 'RC-BL-01',
   'related_type gana sobre related_string y no hay aviso',
   'Una entrada con `related` cargado admite dos formas de describir la relación: el código de `related_type`, que biblatex traduce con su cadena localizada, y `related_string`, con redacción propia.

Si los dos campos están presentes, se imprime el de `related_type` y `related_string` NO SALE EN NINGUNA PARTE. Biber no avisa: el dato queda escrito en la base y nunca llega a la salida.

`related_string` solo, con `related_type` vacío, SÍ funciona: se imprime la redacción propia. Es el modo de trabajo habitual del proyecto.

Verificado con `translatedas`, tipo predefinido de biblatex, bajo estilo verona.

CONSECUENCIA PARA gbpublisher: los dos campos son mutuamente excluyentes en la interfaz. FRelacionarBib bloquea uno cuando el otro tiene contenido, exige que haya exactamente uno, y escribe NULL en el que no se usa para que la base distinga "no aplica" de "se escribió algo vacío".

Es la versión biblatex de GV-23: un dato que se guarda bien y se pierde en silencio lejos de donde se cargó.',
   'vigente', 'empirica', 'biblatex / biber / estilo verona',
   '2026-09', 'vinculo:RC-BL-02,apoya:GV-23', NULL,
   10, '2026-09-07', '2026-09-07');

-- ------------------------------------------------------------
-- 3. RC-BL-02
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('RC-BL', 2, 'RC-BL-02',
   'El modelo de relaciones depende del estilo de bibliografía',
   'No todos los estilos de biblatex implementan `related`. verona y el estilo por defecto lo imprimen; apa e ieee lo IGNORAN: la construcción no produce error ni aviso en el log, simplemente no aparece en la bibliografía.

Dos consecuencias que no son del mismo orden:

La relación sigue siendo un dato correcto aunque el estilo del momento no la imprima. Bloquear la carga según el estilo activo sería subordinar el modelo a una decisión de presentación, que además es reversible.

El estilo puede cambiar DESPUÉS de que la relación fue construida. En gbpublisher el estilo se elige por revista, en `estilo_cita`, así que una relación que hoy se imprime puede dejar de imprimirse mañana sin que nadie toque el registro.

DECISIÓN: el formulario de relaciones no consulta el estilo y no advierte nada. Es conocimiento del editor. Si alguna vez hace falta la advertencia, el lugar es la generación de la salida —donde el estilo se conoce y donde se ve también el cambio posterior— y no el momento de la carga.

ALCANCE: en revistas el modelo de relaciones no se usa. Es de libros.',
   'vigente', 'empirica', 'biblatex / biber',
   '2026-09', 'vinculo:RC-BL-01', 
   'Solo están medidos verona, el estilo por defecto, apa e ieee. Falta relevar el resto de los estilos en uso antes de afirmar nada general.',
   20, '2026-09-07', '2026-09-07');

-- ------------------------------------------------------------
-- 4. GV-34
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 34, 'GV-34',
   'Edit + Update escribe NULL de verdad',
   'Asignar `Null` a un campo dentro del patrón `Edit` + `Update` (RC-GM-15) escribe NULL en la columna, no cadena vacía. Verificado en MySQL sobre `bibtex.related_string`, comprobando la fila resultante en el cliente.

    rReg = hConn.Edit("tabla", "id = &1", iId)
    With rReg
      !campo_a = sValor
      !campo_b = Null
      Try .Update()
    End With

Importa porque hasta acá la única vía segura para escribir un NULL parecía ser un `Exec` con el literal en la sentencia, que es justamente lo que RC-GM-15 desaconseja. Con esto el patrón canónico cubre también el caso, y la distinción entre NULL —"no aplica"— y cadena vacía —"se escribió algo vacío"— se puede sostener desde la interfaz sin excepciones al patrón.

Aplicado en FRelacionarBib: de `related_type` y `related_string` se escribe uno y el otro va a NULL.',
   'vigente', 'empirica', 'Gambas 3.22.1 / gb.db.mysql / MySQL / Linux Mint',
   '2026-09', 'vinculo:RC-GM-15', NULL,
   340, '2026-09-07', '2026-09-07');

COMMIT;

-- ============================================================
-- VERIFICACIÓN POSTERIOR
-- ============================================================

SELECT prefijo, nombre, orden, en_operativo FROM familias ORDER BY orden;

SELECT codigo, titulo, estado, evidencia, orden
  FROM entradas
 WHERE codigo IN ('RC-BL-01', 'RC-BL-02', 'GV-34')
 ORDER BY prefijo, orden;
