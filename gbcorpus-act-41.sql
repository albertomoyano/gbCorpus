-- ============================================================
-- gbCorpus — actualización 41: SC-58, sin \enquote dentro de \enquote;
--            probado en Mint
-- Esquema: 1
-- Origen: decisión de Alberto (17/10). Medición en el contenedor con Verona
--         y con un documento sin biblatex; manual de csquotes v5.2p
--         (2026-05-19, §2.1 y §8.1); TeX Live 2023 trae csquotes v5.2n.
--         Prueba de Alberto en Mint con APA. Numerado contra la base de
--         Alberto (~/.gbcorpus/corpus.sqlite, 17/10, con act-40 aplicado).
-- Fecha:  2026-10-17
-- Aplicar: después de act-40
--
-- MODIFICA:
--   SC-58  la regla del anidamiento; el pendiente
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'act-40 aplicado (SC-58)', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-58' AND estado = 'vigente';
INSERT INTO verificacion SELECT 'SC-58 ancla de la regla', instr(cuerpo, 'Los puntos suspensivos se escriben `...`, como en el Markdown: Markdown no es LaTeX.') > 0 FROM entradas WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-58 ancla del pendiente', instr(pendiente, ' Sin probar en Mint.') > 0 FROM entradas WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-58 sin la regla nueva', instr(cuerpo, 'UN SOLO NIVEL DE \enquote') = 0 FROM entradas WHERE codigo = 'SC-58';

-- ------------------------------------------------------------
-- 2. LA REGLA DEL ANIDAMIENTO
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo,
         'Los puntos suspensivos se escriben `...`, como en el Markdown: Markdown no es LaTeX.',
         'Los puntos suspensivos se escriben `...`, como en el Markdown: Markdown no es LaTeX.

UN SOLO NIVEL DE \enquote

Un `\enquote` dentro de otro no se admite (decisión de Alberto: los casos son muy raros y aislados). csquotes admite dos niveles de comillas (`maxlevel`, por omisión 2; manual §2.1), y Verona y biblatex-iso690 ya ponen entre comillas el título de un artículo: un `\enquote` adentro es el segundo nivel, y otro dentro de ese sería el tercero.

MEDIDO: con Verona, `\enquote{huelga \enquote{general}}` en el título de un artículo corta el PDF («Package csquotes Error: Unbalanced groups or invalid nesting») y el HTML de tex4ht sale con «huelga __general__». Sin biblatex, `\enquote{a \enquote{b \enquote{c}}}` da el mismo error. Con un solo nivel, Verona compone «El 1.º de mayo y la “huelga general”».

Se descartaron dos caminos. `maxlevel=3` es documentado y compila, pero el tercer nivel reusa los signos exteriores («a “b «c»”», medido) y no da las ‘ ’ de SC-30: el manual no tiene un comando para un tercer par de signos (`\DeclareQuoteStyle`, §8.1, recibe un par exterior y uno interior). Las ‘ ’ en el tercer nivel solo se lograrían con macros internas de csquotes, sin documentar.'),
       pendiente = replace(pendiente, ' Sin probar en Mint.',
         ' Probado por Alberto en Mint con APA: las tres salidas y los tres controles. Medido en el contenedor con Verona: \sptext y \emph bien en el PDF y en tex4ht.'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-58 actualizada',
  instr(cuerpo, 'UN SOLO NIVEL DE \enquote') > 0 AND instr(pendiente, 'Probado por Alberto en Mint con APA') > 0
  AND instr(pendiente, 'Sin probar en Mint') = 0
  FROM entradas WHERE codigo = 'SC-58';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo = 'SC-58';
