# gbCorpus

Aplicación de escritorio para escribir, consultar y exportar un corpus de
reglas técnicas. Gambas 3 y SQLite, sin servidor y sin dependencias de
red: la base es un archivo que se copia y viaja.

Está pensada para un caso concreto —el corpus normativo de
[gbpublisher](https://github.com/albertomoyano/gbpublisher)— pero el
modelo no tiene nada específico de ese proyecto y sirve para cualquier
conjunto de reglas que crezca por acumulación y necesite mantenerse
coherente en el tiempo.

---

## El problema que le dio origen

gbpublisher es un sistema de producción editorial académica que se
desarrolla desde hace años con asistencia de modelos de lenguaje. Ese
trabajo fue dejando un sedimento de reglas: comportamientos del lenguaje
verificados a los golpes, decisiones de arquitectura que no conviene
rediscutir, trampas de la documentación oficial. Unas setenta entradas.

Ese material vivía en dos archivos de texto que se editaban a mano, y
tenía tres problemas que ningún editor resuelve.

**Las reglas cambian y las viejas no se van.** Una regla que se corrige
—porque el mecanismo que se le atribuía resultó falso— sigue en el
archivo junto a la nueva. Nada distingue una decisión vigente de un
error ya diagnosticado, y ambas se leen con la misma autoridad. En este
corpus llegó a haber dos reglas contradictorias sobre el mismo tema, las
dos afirmando ser normativas.

**Las reglas se apoyan unas en otras y eso no se ve.** Media docena de
reglas dependen de un mismo hallazgo empírico. Si ese hallazgo cambia
—porque se verificó en un entorno y no en otro— hay que saber cuáles se
caen. En un archivo de texto la pregunta solo se contesta releyendo
todo.

**Copiar y pegar pierde cosas en silencio.** Cada vez que ese texto se
resumía para pasarlo a otro contexto, se perdían los ejemplos concretos
—el nombre del módulo donde se manifestó el bug, la función que lo
provocó— y nadie se enteraba hasta necesitarlos.

gbCorpus convierte ese texto en datos: cada regla con su estado, su tipo
de evidencia, el entorno donde se verificó, sus vínculos con otras y sus
pendientes abiertos. El archivo Markdown pasa a ser una **salida
generada**, no el original.

---

## Qué hace

**Consulta y navegación.** Un combo filtra por familia de reglas o por
preguntas sobre el corpus entero: qué entradas tienen pendientes
abiertos, cuáles no tienen evidencia empírica detrás, cuáles ya no están
vigentes. La lista principal muestra las entradas; el panel derecho, el
detalle completo.

**Navegación por el grafo.** Una segunda lista muestra los vínculos de
la entrada abierta en las dos direcciones: los que ella declara y los de
las entradas que la apuntan. Un clic salta al otro extremo; un botón
vuelve. Los vínculos que apuntan a un código inexistente se muestran
marcados en lugar de desaparecer.

**Edición del texto.** El cuerpo de cada entrada se escribe en Markdown.
El guardado es explícito y hay guard de cambios sin guardar antes de
cualquier cambio de contexto.

**Tres perfiles de exportación.**

| Perfil | Contenido | Para qué |
|---|---|---|
| Documental | Todo: correcciones, entradas deprecadas, pendientes, evidencia | El archivo que va al repositorio. Es memoria. |
| Operativo | Solo familias marcadas como operativas y solo entradas vigentes | El bloque de instrucciones que se pasa a un asistente. Sin arqueología. |
| Volcado SQL | INSERT restaurables de todo el contenido | Respaldo en texto, que sí diffea en git. |

La separación entre los dos primeros es el punto: una regla corregida o
deprecada **no puede** llegar al perfil operativo, no porque alguien se
acuerde de sacarla sino porque su estado la excluye.

La salida es determinista. Orden fijo, sin fecha de generación, sin nada
que cambie entre corridas: dos exportaciones del mismo contenido
producen archivos idénticos, y el diff de git muestra solo lo que
efectivamente cambió.

---

## Lo que deliberadamente no hace

**No da de alta ni elimina entradas ni familias.** Eso son decisiones
sobre el corpus, y se toman discutiéndolas, no clickeando. Se aplican
por script SQL. La aplicación lee, navega y pule texto.

Es una restricción, no una carencia: una herramienta que permite crear
reglas con un botón termina llena de reglas que nadie decidió.

---

## Modelo de datos

Tres tablas.

`familias` — el prefijo de cada grupo de reglas, su orden en la
exportación, el ancho del número en el código y si entra en el perfil
operativo. Las familias se dan de alta como datos: agregar un grupo
nuevo no requiere tocar código.

`entradas` — reglas y hallazgos en una sola tabla, distinguidos por
familia. Cada una con `estado` (vigente, corregida, deprecada,
hipotesis), `evidencia` (empirica, doc_oficial, inferida), `entorno`,
fecha de verificación, cuerpo en Markdown, un campo `pendiente` y una
columna `relaciones`.

`esquema_version` — la versión del esquema, verificada al arrancar.

Las relaciones se escriben en una columna de texto con la forma
`tipo:CODIGO`, separadas por coma:

```
apoya:GV-24, contracara:GV-25, reemplazada_por:SC-05
```

El tipo es libre. La aplicación valida al guardar que todos los códigos
existan, y resuelve la dirección inversa recorriendo el corpus, no con
un `LIKE`: `GV-2` matchearía dentro de `GV-24`.

---

## Instalación

Requiere Gambas 3.21 o superior sobre Linux. Desarrollado y probado en
Linux Mint Cinnamon con X11.

Componentes del proyecto: `gb.form`, `gb.db`, `gb.db.sqlite3`,
`gb.settings` y `gb.desktop`.

Abrir el proyecto en el IDE de Gambas, **Proyecto → Limpiar**, luego
**Proyecto → Compilar**. En el primer arranque la aplicación crea
`~/.gbcorpus/corpus.sqlite` con el esquema y las familias sembradas.

Si la creación automática falla, la base se puede crear a mano:

```
sqlite3 ~/.gbcorpus/corpus.sqlite < esquema/corpus_esquema.sql
```

La carpeta es oculta a propósito, para que la aplicación pueda
instalarse en `/usr/bin` y la base siga estando en un lugar escribible.
El menú **Corpus → Ubicación de la base** la abre en el gestor de
archivos.

---

## Uso

Para moverse entre máquinas alcanza con copiar el `.sqlite`. Es un
archivo binario, así que la disciplina es una sola copia válida por vez;
el volcado SQL en el repositorio funciona como respaldo restaurable.

El flujo de trabajo típico:

1. Consultar o corregir texto en la aplicación.
2. Exportar el perfil documental al repositorio del proyecto y hacer
   commit. El diff muestra exactamente qué reglas cambiaron.
3. Exportar el perfil operativo cuando haga falta el bloque de reglas
   vigentes.

---

## Estructura del proyecto

```
FMain            vista maestro-detalle; handlers delgados
m_Base           conexión SQLite, creación de la base, versión de esquema
m_Corpus         estado de sesión y todo el acceso a familias y entradas
m_Relaciones     parseo, validación y resolución bidireccional de vínculos
m_Exportar       los tres perfiles de salida
CEntrada         una entrada, fuera del objeto Result
CRelacion        un vínculo ya resuelto, listo para mostrar
```

Ningún formulario consulta la base: le pide datos a los módulos. El
estado de sesión vive en variables de módulo y no en controles de la
interfaz.

---

## Licencia

GPL v3. Ver [LICENSE](LICENSE).

La licencia cubre el código de gbCorpus. El contenido del corpus de
gbpublisher no forma parte de este repositorio.
