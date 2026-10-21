-- ============================================================
-- gbCorpus — actualización 52: controles de LaTeX y HTML crudo en
--            el .md (SC-54) y resaltado de \sptext (GV-119)
-- Esquema: 1
-- Origen: conversación del 21/10. Alberto probó en Mint la letra
--         volada (SC-62) en libros y revistas: PDF, HTML y EPUB bien.
--         Descartó normalizar el Word al ingresar: se resuelve sobre el
--         .md. Aprobó los tres controles nuevos con nivel error, solo en
--         libros por ahora. Mini-tests en el contenedor (Pandoc 3.1.3;
--         gb.highlight 3.19 con un banco que corre TextHighlighter.Run;
--         fuente de gb.highlight 3.22.2).
-- Fecha:  2026-10-21
-- Aplicar: después de act-51
--
-- ALTAS:
--   GV-119  gb.highlight: $(nombre)=valor y estados hijos dentro de un
--           from … to
-- MODIFICA:
--   SC-54   tres controles nuevos: latex_en_linea, latex_suelto,
--           html_crudo; pendiente (revistas)
--   SC-62   probada en Mint; resaltado; la normalización del Word,
--           descartada
--   GV-116  sin pendiente: el control existe
-- ============================================================

BEGIN TRANSACTION;

CREATE TEMP TABLE verificacion (paso TEXT, ok INTEGER CHECK (ok = 1));

-- ------------------------------------------------------------
-- 1. ESTADO DE PARTIDA
-- ------------------------------------------------------------
INSERT INTO verificacion SELECT 'GV-118 última GV', MAX(numero) = 118 FROM entradas WHERE prefijo = 'GV';
INSERT INTO verificacion SELECT 'GV-119 libre', COUNT(*) = 0 FROM entradas WHERE codigo = 'GV-119' OR (prefijo = 'GV' AND numero = 119);
INSERT INTO verificacion SELECT 'SC-54 ancla de la tabla (una vez)', (length(cuerpo) - length(replace(cuerpo, '    [WARNING] de pandoc       aviso   entre ellos, nota definida y nunca llamada', ''))) = length('    [WARNING] de pandoc       aviso   entre ellos, nota definida y nunca llamada') FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 sin los controles nuevos', instr(cuerpo, 'latex_en_linea') = 0 FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 pendiente con (1)', instr(pendiente, '(1) Revistas: usar el mismo filtro') = 1 FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-62 ancla de VERIFICADO (una vez)', (length(cuerpo) - length(replace(cuerpo, '

VERIFICADO EN EL CONTENEDOR

', ''))) = length('

VERIFICADO EN EL CONTENEDOR

') FROM entradas WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'SC-62 ancla del Word (una vez)', (length(cuerpo) - length(replace(cuerpo, '- La normalización al ingresar el Word (`limpiar_docx.lua`)', ''))) = length('- La normalización al ingresar el Word (`limpiar_docx.lua`)') FROM entradas WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'SC-62 ancla de Queda para decidir (una vez)', (length(cuerpo) - length(replace(cuerpo, '(«20 °C»). Queda para decidir.', ''))) = length('(«20 °C»). Queda para decidir.') FROM entradas WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'SC-62 sin resaltado', instr(cuerpo, 'RESALTADO') = 0 FROM entradas WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'GV-116 con pendiente', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-116' AND pendiente IS NOT NULL;

-- ------------------------------------------------------------
-- 2. GV-119
-- ------------------------------------------------------------
INSERT INTO entradas
  (prefijo, numero, codigo, titulo, cuerpo, estado, evidencia, entorno,
   fecha_verificacion, relaciones, pendiente, orden, fecha_alta, fecha_modificacion)
VALUES
  ('GV', 119, 'GV-119', 'gb.highlight: $(nombre)=valor define una sustitución; un estado hijo de un from … to se busca dentro del tramo',
   'Dos recursos de los archivos `.highlight`, leídos en el fuente de gb.highlight 3.22.2 (`TextHighlighter.CreateCustomHighlighter`, `CState.Subst`, `CCommandFrom.Compile`) y medidos con 3.19.

SUSTITUCIÓN

Una línea `$(nombre)=valor`, sin sangría, define una sustitución. `CState.AddCommand` la aplica a cada argumento de un comando, así que el patrón se escribe una vez y se usa en varios estados:

    $(sptext)=/\\sptext\{[^}\n]*\}/
    …
      match $(sptext)

ESTADOS HIJOS

Un estado con más sangría que el anterior es su hijo. En un `from … to`, `CCommandFrom.Compile` prueba los hijos en cada posición del tramo, antes de buscar el cierre. Sin un hijo, todo lo que está entre `*` y `*` toma el color de la bastardilla, sin ninguna regla de adentro.

    italic.star{Comment}:
      from * to *
      latex.sptext.dentro{Function}:
        match $(sptext)

Varios hijos con el mismo nombre, uno en cada estado, no chocan. Un `match` no busca hijos adentro: sus hijos se prueban después del tramo. Por eso un título (`header`, `match /^#{1,6}.*$/`) queda entero en `Header`.

MEDIDO con un banco que registra la gramática con `TextHighlighter.Register` y corre `Run` línea por línea, como `m_ResaltadoSintaxis`:

    El n\sptext{o} 3                [Function:\sptext{o}]
    *con el 3\sptext{er} piso*      [Comment:*con el 3][Function:\sptext{er}][Comment: piso*]
    **la C\sptext{ía}**             [Keyword:**la C][Function:\sptext{ía}][Keyword:**]
    # Título del n\sptext{o} 1      [Header:# Título del n\sptext{o} 1]

Recordar GV-76: un espacio literal en un patrón no carga, porque `AddCommand` separa los argumentos por espacio.',
   'vigente', 'empirica',
   'gb.highlight 3.19 / gb.pcre / contenedor Ubuntu 24.04; fuente de gb.highlight 3.22.2 (gitlab.com/gambas/gambas)',
   '2026-10', 'apoya:SC-62,vinculo:GV-76,vinculo:SC-15,vinculo:GV-48',
   'Confirmar en Mint con 3.22: el resaltado de \sptext suelto y dentro de bastardilla, negrita y tachado, en el editor y en la ayuda del panel.',
   1190, datetime('now','localtime'), datetime('now','localtime'));
INSERT INTO verificacion SELECT 'GV-119 dado de alta', COUNT(*) = 1 FROM entradas WHERE codigo = 'GV-119';

-- ------------------------------------------------------------
-- 3. SC-54: LOS TRES CONTROLES
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo,
         '    [WARNING] de pandoc       aviso   entre ellos, nota definida y nunca llamada',
         '    latex_en_linea            error   una orden de LaTeX en el texto que no es
                                      \sptext{…} (GV-116)
    latex_suelto              error   una orden de LaTeX sola entre párrafos,
                                      fuera de ::: espaciov
    html_crudo                error   HTML escrito en el .md, menos los
                                      comentarios <!-- … -->
    [WARNING] de pandoc       aviso   entre ellos, nota definida y nunca llamada') || '

LaTeX Y HTML CRUDOS

Lo que Pandoc lee como LaTeX o HTML crudo se pierde en las tres salidas: los escritores de XML lo descartan sin aviso (GV-116). Decisión de Alberto: los tres controles son `error`, y por ahora solo en libros, como los demás (pendiente 1).

- En el texto, la única orden de LaTeX admitida es `\sptext{…}`, que traduce `volada.lua` (SC-62); su forma la valida ese filtro y no este control. El mensaje nombra la orden y muestra el contexto con el texto crudo a la vista: `stringify` lo descarta, y sin eso quedaban huecos.
- Suelto entre párrafos, el LaTeX solo vale dentro de `::: espaciov`, que valida `espacio-vertical.lua` (SC-39). El recorrido es de arriba abajo (`traverse = "topdown"`) y no baja a un `espaciov`.
- Los comentarios HTML `<!-- … -->`, en línea o en bloque, también de varias líneas, no son texto y no se informan. Un `<div>` no es HTML crudo: Pandoc lo lee como un `Div`.
- Como `revisar_inlines`, el recorrido en línea no baja al contenido de una nota: sus párrafos los visita el walk de bloques, y así no se informan dos veces.

MEDIDO: un título, un párrafo, una bastardilla, una nota y una celda con órdenes de LaTeX; `<sup>`, `</sup>` y `<br>`; `\newpage` suelto; un comentario de dos líneas y uno en línea; `\bigskip` dentro de `espaciov`. Salen los diez hallazgos esperados, los comentarios y el `espaciov` no; un .md limpio deja el informe vacío. Sobre los ejemplos del catálogo, el único hallazgo es `paleographic`: sus `<ue>`, `<iem>` y `<er>` hoy se pierden (una de las filas con pendiente).',
       pendiente = replace(pendiente, '(1) Revistas: usar el mismo filtro', '(1) Revistas: usar el mismo filtro, con los controles de LaTeX y HTML crudos,'),
       relaciones = relaciones || ',vinculo:GV-116,vinculo:SC-62,vinculo:SC-39',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 con los controles en la tabla', instr(cuerpo, '    latex_en_linea            error') > 0 FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 con la sección nueva', instr(cuerpo, 'LaTeX Y HTML CRUDOS') > 0 FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 pendiente nuevo', instr(pendiente, 'con los controles de LaTeX y HTML crudos') > 0 FROM entradas WHERE codigo = 'SC-54';
INSERT INTO verificacion SELECT 'SC-54 relaciones', instr(relaciones, ',vinculo:GV-116,vinculo:SC-62,vinculo:SC-39') > 0 FROM entradas WHERE codigo = 'SC-54';

-- ------------------------------------------------------------
-- 4. SC-62: PROBADA, RESALTADO, WORD DESCARTADO
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(replace(replace(replace(cuerpo,
         '

VERIFICADO EN EL CONTENEDOR

',
         '

RESALTADO

`Markdown.highlight`: el estado `latex.sptext`, con el estilo `Function` de los shortcodes, que los nueve temas ya definen en `[Markdown]`. El patrón se escribe una vez con `$(sptext)` y se repite como hijo dentro de la bastardilla, la negrita y el tachado (GV-119). En un título la línea queda entera en `Header`.

VERIFICADO EN EL CONTENEDOR

'),
         '- La normalización al ingresar el Word (`limpiar_docx.lua`)',
         '- DESCARTADO (decisión de Alberto, 21/10): la normalización al ingresar el Word (`limpiar_docx.lua`). Se resuelve sobre el .md. Lo que se había evaluado'),
         '(«20 °C»). Queda para decidir.',
         '(«20 °C»).'),
         '- El control general de las órdenes de LaTeX en línea que se pierden (GV-116).',
         '- El control general de las órdenes de LaTeX en línea que se pierden (GV-116): hecho en SC-54, en libros.') || '

PROBADO EN MINT

Alberto, 21/10, con un libro y una revista reales: PDF, HTML y EPUB bien.',
       pendiente = 'Falta en Mint: la inserción desde el panel, un caso que frene y el resaltado (GV-119). El ODT, cuando se encare (decisión de Alberto, 21/10).',
       relaciones = relaciones || ',vinculo:GV-119,vinculo:SC-54',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'SC-62 con resaltado', instr(cuerpo, 'RESALTADO') > 0 FROM entradas WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'SC-62 con Word descartado', instr(cuerpo, 'DESCARTADO (decisión de Alberto, 21/10)') > 0 FROM entradas WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'SC-62 sin Queda para decidir', instr(cuerpo, 'Queda para decidir') = 0 FROM entradas WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'SC-62 control hecho', instr(cuerpo, 'hecho en SC-54, en libros') > 0 FROM entradas WHERE codigo = 'SC-62';
INSERT INTO verificacion SELECT 'SC-62 probada en Mint', instr(cuerpo, 'PROBADO EN MINT') > 0 FROM entradas WHERE codigo = 'SC-62';

-- ------------------------------------------------------------
-- 5. GV-116: EL CONTROL EXISTE
-- ------------------------------------------------------------
UPDATE entradas
   SET cuerpo = replace(cuerpo,
         'Las demás siguen perdiéndose sin aviso: lo cubriría un control en `controles_md.lua`.',
         'Las demás las informan, en libros, los controles `latex_en_linea`, `latex_suelto` y `html_crudo` de `controles_md.lua` (SC-54).'),
       pendiente = NULL,
       relaciones = relaciones || ',vinculo:SC-54',
       fecha_modificacion = datetime('now','localtime')
 WHERE codigo = 'GV-116';
INSERT INTO verificacion SELECT 'GV-116 con el control', instr(cuerpo, 'los controles `latex_en_linea`') > 0 AND pendiente IS NULL FROM entradas WHERE codigo = 'GV-116';

COMMIT;

SELECT codigo, estado, pendiente FROM entradas
 WHERE codigo IN ('GV-116', 'GV-119', 'SC-54', 'SC-62')
 ORDER BY prefijo, numero;
