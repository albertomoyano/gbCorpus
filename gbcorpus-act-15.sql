-- ============================================================
-- gbCorpus — actualización: GV-96, Val y Str dependen del locale
-- Esquema: 1
-- Origen: error al guardar un formato PDF nuevo en FSysAdmin
--         (LeerNumero); mini-test en contenedor con Gambas 3.19,
--         locales C.UTF-8 y es_AR.UTF-8
-- Fecha:  2026-10-09
--
-- ALTAS:
--   GV-96  Val y Str dependen del locale; CFloat y CStr no
--
-- NUMERACIÓN TOMADA DE gbcorpus-act-12.sql (ÚLTIMA GV-95);
-- act-13 Y act-14 NO DAN ALTAS GV.
-- ============================================================

BEGIN TRANSACTION;

-- ------------------------------------------------------------
-- 1. GV-96
--    EL orden SE DERIVA DEL ÚLTIMO DE LA FAMILIA, NO SE ESCRIBE A MANO
-- ------------------------------------------------------------

INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
SELECT
  'GV', 96, 'GV-96',
  'Val y Str dependen del locale; CFloat y CStr no',
  '`Val` y `Str` usan el separador decimal y el de miles del locale. `CFloat` y `CStr` usan siempre el punto. Con `es_AR.UTF-8`, el locale de Mint en la editorial, la diferencia rompe la lectura de números escritos con punto.

MEDIDO (Gambas 3.19, contenedor)

    entrada          C.UTF-8          es_AR.UTF-8
    Val("15.5")      15.5             Null
    Val("15,5")      Null             15.5
    Val("1.234")     1.234            1234 (Integer)
    Val("")          Null             Null
    CFloat("15.5")   15.5             15.5
    CFloat("15,5")   Type mismatch    Type mismatch
    CFloat("")       Type mismatch    Type mismatch
    Str(15.5)        "15.5"           "15,5"
    CStr(15.5)       "15.5"           "15.5"

Las tres trampas:

- Asignar el Null de `Val` a un Float lanza «Type mismatch: wanted Float, got Null instead». El error aparece en la asignación, no en `Val`.
- `Val("1.234")` con `es_AR` devuelve 1234 sin error: el punto se lee como separador de miles. Es el peor caso, porque el número es válido y está mal.
- Lo que funciona en la máquina del desarrollador con un locale falla en otra con el otro: la misma dependencia del entorno que GV-03.

CASO QUE LO DESCUBRIÓ

`FSysAdmin.LeerNumero` normalizaba la coma a punto y llamaba a `Val`, con un comentario que lo creía locale-independiente. En Mint, guardar un formato PDF nuevo con decimales fallaba siempre; con un campo vacío, en cualquier locale.

REGLA

Para leer un número que escribe una persona: normalizar la coma a punto, descartar el vacío y convertir con `CFloat` dentro de un `Try`, con `If Error Then` inmediatamente después (RC-GM-02). Para escribir un número en un archivo, una consulta o un parámetro: `CStr`, no `Str`. `Str` y `Val` solo para mostrar o leer en el formato del usuario, sabiendo que dependen del locale.

`Str` al mostrar y `CFloat` al leer, después de normalizar la coma, son compatibles: el formulario muestra «15,5» y lo vuelve a leer como 15.5.',
  'vigente', 'empirica', 'Gambas 3.19 / gbs3 / contenedor Ubuntu 24.04 / locales C.UTF-8 y es_AR.UTF-8',
  '2026-10', 'vinculo:GV-03,vinculo:RC-GM-02',
  'Repetir el mini-test en Mint con Gambas 3.22.2 y el locale real. Revisar los demás Val sobre texto de usuario: m_Metadatos (numero_paginas, numero_figuras, numero_tablas, numero_ecuaciones, copyright_year) y FAutores (h_index, i10_index, numero_publicaciones) son enteros, pero «1.234» da 1234.',
  MAX(orden) + 10, datetime('now','localtime'), datetime('now','localtime')
  FROM entradas WHERE prefijo = 'GV';

COMMIT;

-- ============================================================
-- VERIFICACIÓN POSTERIOR: 1 FILA, GV-96 CON EL orden MÁS ALTO DE GV
-- ============================================================

SELECT codigo, titulo, estado, evidencia, orden,
       orden = (SELECT MAX(orden) FROM entradas WHERE prefijo = 'GV') AS ultimo
  FROM entradas
 WHERE codigo = 'GV-96';
