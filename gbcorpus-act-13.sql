-- ============================================================
-- gbCorpus — actualización: SC-49, la dedicatoria en verso
-- Esquema: 1
-- Origen: hallazgo al probar el verso (saltos de línea manuales en
--         prosa) y decisión de Alberto
-- Fecha:  2026-10-09
--
-- CAMBIO:
--   SC-49  «FUERA DE ESTA DECISIÓN» decía que un verso corto en una
--          dedicatoria se escribe con saltos de línea manuales. Medido:
--          hoy eso no funciona. Se corrige el texto y se deja la
--          decisión: caso casi atípico, se resuelve puntual si aparece.
--
-- REQUIERE gbcorpus-act-12.sql APLICADO (docs/corpus.md DEL REPO,
-- 57318c4, YA TIENE SC-49).
-- ============================================================

BEGIN TRANSACTION;

-- ------------------------------------------------------------
-- 1. SC-49
--    EL WHERE EXIGE QUE EL TEXTO VIEJO ESTÉ: SI NO ESTÁ, EL INFORME DEL
--    IMPORTADOR MUESTRA 0 FILAS Y NO SE PISA NADA A CIEGAS
-- ------------------------------------------------------------

UPDATE entradas
   SET cuerpo = replace(cuerpo,
         'La dedicatoria en verso (SC-45): un verso corto se escribe como texto con saltos de línea manuales (decisión de Alberto).',
         'La dedicatoria en verso (SC-45). Es un caso casi atípico en libros y revistas científicos: si aparece, se resuelve en ese momento con una solución puntual, sin redefinir el modelo (decisión de Alberto).

Los saltos de línea manuales en prosa (barra invertida o dos espacios al final de la línea) NO sirven hoy para eso. Medido con Pandoc 3.1.3:

    libro (DocBook)     el párrafo entero sale como <literallayout> sin role:
                        el PDF lo compone en verbatim y el HTML en <pre>
    revista (JATS)      el salto se pierde: queda un espacio
    epígrafe            el salto se pierde en los dos productos

Queda registrado para no usar ese camino creyendo que funciona.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-49'
   AND instr(cuerpo, 'un verso corto se escribe como texto con saltos de línea manuales') > 0;

COMMIT;

-- ============================================================
-- VERIFICACIÓN POSTERIOR: 1 EN LAS DOS COLUMNAS
-- ============================================================

SELECT codigo,
       instr(cuerpo, 'solución puntual') > 0 AS texto_nuevo,
       instr(cuerpo, 'se escribe como texto con saltos de línea manuales') = 0 AS sin_texto_viejo
  FROM entradas
 WHERE codigo = 'SC-49';
