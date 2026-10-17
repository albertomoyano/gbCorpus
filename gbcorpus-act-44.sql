-- ============================================================
-- gbCorpus — actualización 44: SC-58, el signo \& y los campos literales
-- Esquema: 1
-- Origen: hallazgo y decisión de Alberto (17/10): «&» aparece en algunos
--         journaltitle y se escribe \&. Medición en el contenedor (biblatex
--         3.19, make4ht v0.3m, Gambas 3.19). Numerado contra la base de
--         Alberto (~/.gbcorpus/corpus.sqlite, 17/10, con act-43 aplicado).
-- Fecha:  2026-10-17
-- Aplicar: después de act-43
--
-- MODIFICA:
--   SC-58  título y regla: \& admitido; «&» sin barra rechazado; los campos
--          literales (doi, eprint, file, url) no pasan por la regla
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'act-43 aplicado (RF-13)', COUNT(*) = 1 FROM entradas WHERE codigo = 'RF-13';
INSERT INTO verificacion SELECT 'SC-58 título', COUNT(*) = 1 FROM entradas WHERE codigo = 'SC-58'
  AND titulo = 'Órdenes de LaTeX en las referencias: solo \enquote, \sptext y \emph';
INSERT INTO verificacion SELECT 'SC-58 ancla', instr(cuerpo, 'Los puntos suspensivos se escriben `...`, como en el Markdown: Markdown no es LaTeX.

NIVELES DE \enquote') > 0 FROM entradas WHERE codigo = 'SC-58';

-- ------------------------------------------------------------
-- 2. EL SIGNO \& Y LOS CAMPOS LITERALES
-- ------------------------------------------------------------
UPDATE entradas
   SET titulo = 'Órdenes de LaTeX en las referencias: solo \enquote, \sptext, \emph y el signo \&',
       cuerpo = replace(cuerpo,
         'Los puntos suspensivos se escriben `...`, como en el Markdown: Markdown no es LaTeX.

NIVELES DE \enquote',
         'Los puntos suspensivos se escriben `...`, como en el Markdown: Markdown no es LaTeX.

EL SIGNO &

Va escapado, `\&`: aparece en algunos nombres de revista («Población \& Sociedad», en el `.bib` de Duek). Sin la barra, LaTeX lo toma como separador de columnas y el PDF corta («Misplaced alignment tab character &», medido); por eso un `&` sin barra se rechaza con su mensaje. `\&` da «&» en el PDF y `&amp;` en tex4ht (medido); en el canónico es el carácter, escapado (`&amp;`).

LOS CAMPOS LITERALES

`doi`, `eprint`, `file` y `url` no pasan por la regla (`m_Bibtex.EsCampoLiteral`): biblatex los toma sin interpretar LaTeX (tipos `verbatim` y `uri` de `blx-dm.def`, 3.19), y una URL puede llevar `&` sin escapar.

NIVELES DE \enquote'),
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-58';
INSERT INTO verificacion SELECT 'SC-58 con el signo &',
  instr(titulo, 'y el signo \&') > 0 AND instr(cuerpo, 'EL SIGNO &') > 0 AND instr(cuerpo, 'LOS CAMPOS LITERALES') > 0
  FROM entradas WHERE codigo = 'SC-58';

COMMIT;

SELECT codigo, estado, titulo FROM entradas WHERE codigo = 'SC-58';
