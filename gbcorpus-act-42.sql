-- ============================================================
-- gbCorpus — actualización 42: SC-58, los niveles de \enquote dependen del
--            campo y del tipo de entrada; corrección sobre ISO 690
-- Esquema: 1
-- Origen: observación y decisión de Alberto (17/10): el problema está en el
--         título que el estilo pone entre comillas, no en cualquier campo.
--         Relevamiento del fuente (biblatex.def 3.19, philosophy-standard.bbx
--         v1.9.8g, ieee.bbx, apa.bbx v9.17, iso.bbx de TeX Live 2023) y
--         medición con Verona en el contenedor. Numerado contra la base de
--         Alberto (~/.gbcorpus/corpus.sqlite, 17/10, con act-41 aplicado).
-- Fecha:  2026-10-17
-- Aplicar: después de act-41
--
-- MODIFICA:
--   SC-58  la regla de los niveles; corrige «Verona y biblatex-iso690 ya
--          ponen entre comillas el título de un artículo»: ISO 690 no lo hace
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'act-41 aplicado', instr(cuerpo, 'UN SOLO NIVEL DE \enquote') > 0 FROM entradas WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-58 ancla del párrafo', instr(cuerpo, 'UN SOLO NIVEL DE \enquote

Un `\enquote` dentro de otro no se admite (decisión de Alberto: los casos son muy raros y aislados). csquotes admite dos niveles de comillas (`maxlevel`, por omisión 2; manual §2.1), y Verona y biblatex-iso690 ya ponen entre comillas el título de un artículo: un `\enquote` adentro es el segundo nivel, y otro dentro de ese sería el tercero.') > 0 FROM entradas WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-58 ancla de la tabla', instr(cuerpo, '    \enquote{…}   cita entre comillas; el nivel lo decide el anidamiento') > 0 FROM entradas WHERE codigo = 'SC-58';

-- ------------------------------------------------------------
-- 2. LA REGLA DE LOS NIVELES
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(replace(cuerpo,
         'UN SOLO NIVEL DE \enquote

Un `\enquote` dentro de otro no se admite (decisión de Alberto: los casos son muy raros y aislados). csquotes admite dos niveles de comillas (`maxlevel`, por omisión 2; manual §2.1), y Verona y biblatex-iso690 ya ponen entre comillas el título de un artículo: un `\enquote` adentro es el segundo nivel, y otro dentro de ese sería el tercero.',
         'NIVELES DE \enquote

csquotes admite dos niveles de comillas (`maxlevel`, por omisión 2; manual §2.1); el tercero corta el PDF. Algunos estilos ponen entre comillas el título de ciertos tipos de entrada, y ese es ya el primer nivel. La regla (decisión de Alberto; `m_Bibtex.NivelesEnquote`):

- EN EL TÍTULO Y EL SUBTÍTULO de article, conference, inbook, incollection, inproceedings, inreference, online, patent, report, thesis y unpublished: un solo nivel de `\enquote`. El subtítulo va dentro de las mismas comillas que el título (medido con Verona).
- EN CUALQUIER OTRO CAMPO O TIPO (el título de un libro, en cursiva; el nombre de la revista): hasta dos niveles. `\enquote{huelga \enquote{general}}` en el título de un libro es correcto.
- TRES NIVELES: nunca.

La lista es la unión de los estilos de la aplicación y no la del estilo del libro: el estilo se puede cambiar después (el criterio de RC-BL-02). Con APA o ISO 690, un artículo no puede llevar dos niveles en el título aunque esos estilos no le pongan comillas; son casos muy raros y aislados. Sale del fuente:

    biblatex.def (3.19, línea 580)   article inbook incollection inproceedings patent thesis unpublished
    philosophy-standard.bbx (290)    article inreference (287: thesis en cursiva)
    ieee.bbx (51)                    online report
    apa.bbx (482), iso.bbx (182)     ninguno

`conference` es el alias de `inproceedings` en biber.'),
         '    \enquote{…}   cita entre comillas; el nivel lo decide el anidamiento',
         '    \enquote{…}   cita entre comillas; el nivel lo decide el anidamiento (ver NIVELES)'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-58 con la regla nueva',
  instr(cuerpo, 'NIVELES DE \enquote') > 0 AND instr(cuerpo, 'UN SOLO NIVEL DE \enquote') = 0
  AND instr(cuerpo, 'Verona y biblatex-iso690 ya ponen') = 0 AND instr(cuerpo, '(ver NIVELES)') > 0
  FROM entradas WHERE codigo = 'SC-58';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo = 'SC-58';
