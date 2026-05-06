# Plan Mayo — Mejoras de Usabilidad y Buenas Practicas

## Contexto

Este plan se basa en la implementacion actual de MarkFlow Studio y en el grafo generado con `graphify`.

Senales principales del grafo:

- `ContentView` es el nodo mas conectado, con 21 relaciones, lo que indica que concentra demasiada orquestacion de acciones, estado y flujos de UI.
- `ExportService`, `MarkdownPreviewParser`, `WikiLinkService`, `FolderService` y `DocumentService` son abstracciones centrales y deben protegerse con pruebas y contratos claros.
- Las comunidades `SwiftUI View Layer`, `App Orchestration Flow`, `Product Requirements` y `App Icon Variants` tienen baja cohesion, lo que sugiere oportunidades de separacion, documentacion y limpieza.
- Existen 86 nodos debilmente conectados, entre ellos componentes y conceptos como `MarkFlowTheme`, `heading`, `paragraph` y `bulletList`, lo que apunta a posibles vacios de documentacion, relaciones implicitas no modeladas o componentes que necesitan mayor integracion.

Objetivo de mayo: mejorar la experiencia diaria de escritura, reducir friccion en navegacion/exportacion y preparar el proyecto para crecer con menor riesgo tecnico.

## Principios

- Priorizar mejoras visibles para el usuario antes que refactors grandes.
- Mantener cambios pequenos, verificables y alineados con SwiftUI + SwiftData.
- Reducir acoplamiento en nodos centrales solo cuando desbloquee usabilidad, pruebas o mantenimiento.
- Preservar el enfoque offline-first y el workspace local/iCloud compatible.
- Mantener la direccion visual Liquid Glass sin sacrificar legibilidad, accesibilidad ni rendimiento.

## Prioridad 1 — Usabilidad Critica

### 1. Mejorar estados vacios y onboarding del workspace

Problema: el workspace es una pieza central, pero una primera apertura sin contexto puede sentirse tecnica.

Acciones:

- Crear un flujo inicial claro: seleccionar workspace, explicar que se guarda localmente y mostrar estructura esperada.
- Agregar ejemplos de acciones iniciales: crear documento, crear carpeta, probar preview.
- Mostrar estado de workspace persistente con ruta, estado de permisos y acceso rapido a `exports/`.
- Mejorar mensajes de error cuando falta workspace o falla acceso a archivos.

Criterios de aceptacion:

- Un usuario nuevo puede entender donde se guardan sus documentos sin leer README.
- Si el workspace no esta configurado, no aparecen controles inutiles o confusos.
- Los errores de workspace indican causa y siguiente accion.

### 2. Pulir navegacion iPhone y iPad

Problema: el flujo compacto ya fue corregido, pero el grafo marca `iPhone Navigation` como comunidad propia y relativamente aislada.

Acciones:

- Revisar flujo completo: Carpetas -> Documentos -> Editor -> Preview.
- Agregar acciones rapidas visibles en iPhone para crear documento y alternar preview.
- Mejorar titulos de navegacion y breadcrumbs ligeros para evitar perdida de contexto.
- Validar que crear documento desde carpeta abra el editor correcto de forma consistente.

Criterios de aceptacion:

- En iPhone, crear y editar un documento requiere el minimo de pasos posible.
- El usuario siempre sabe en que carpeta/documento esta.
- Preview y editor son accesibles sin competir por espacio.

### 3. Fortalecer la experiencia de escritura Markdown

Problema: `MarkdownPreviewParser`, `MarkdownHelper` y bloques Markdown son nodos centrales, pero algunos conceptos aparecen debilmente conectados.

Acciones:

- Agregar una barra de formato mas contextual: encabezados, listas, checklist, enlace wiki, codigo, cita.
- Mostrar contador de palabras y estado de autoguardado cerca del editor.
- Mejorar preview para casos comunes: tablas, checklist, imagenes, codigo y enlaces internos.
- Agregar busqueda dentro del documento si no existe todavia.

Criterios de aceptacion:

- El usuario puede escribir Markdown comun sin recordar toda la sintaxis.
- Preview representa correctamente los bloques usados en documentos tecnicos.
- El autoguardado se percibe confiable sin interrumpir.

## Prioridad 2 — Flujo de Conocimiento

### 4. Mejorar enlaces internos y backlinks

Problema: `WikiLinkService` es una abstraccion central. Los enlaces rotos y backlinks son una ventaja clave del producto.

Acciones:

- Crear panel de enlaces mas accionable: salientes, backlinks y rotos separados visualmente.
- Permitir crear documento destino desde enlace roto con titulo prellenado.
- Agregar sugerencias al escribir `[[` basadas en titulos existentes.
- Mostrar indicadores en tarjetas de documentos: cantidad de backlinks y enlaces rotos.

Criterios de aceptacion:

- Resolver un enlace roto requiere una accion clara.
- Los backlinks ayudan a navegar conocimiento, no solo a listar relaciones.
- La escritura de `[[Documento]]` se siente asistida.

### 5. Mejorar organizacion de documentos

Problema: carpetas y documentos ya existen, pero la usabilidad depende de busqueda, orden y acciones rapidas.

Acciones:

- Agregar orden por fecha modificada, titulo y cantidad de palabras.
- Incorporar filtros rapidos: todos, recientes, sin carpeta, con enlaces rotos.
- Mejorar accion de mover documento con busqueda de carpeta.
- Agregar confirmaciones no intrusivas para duplicar, mover y soft delete.

Criterios de aceptacion:

- Documentos grandes o numerosos siguen siendo faciles de encontrar.
- Mover documentos no requiere navegar manualmente una jerarquia larga.
- Las acciones destructivas mantienen el modelo de soft delete.

## Prioridad 3 — Exportacion Confiable

### 6. Convertir exportacion en flujo guiado

Problema: `ExportService` es el segundo nodo mas conectado y combina logica importante de Markdown, HTML, PDF, assets y carpetas.

Acciones:

- Crear pantalla o sheet de exportacion con formato, destino, nombre final y resumen.
- Mostrar preflight antes de exportar: workspace configurado, assets encontrados, enlaces internos detectados.
- Agregar feedback de progreso y resultado con acceso directo al archivo exportado.
- Documentar diferencias entre Markdown, HTML y PDF dentro de la UI.

Criterios de aceptacion:

- El usuario sabe que se va a exportar antes de confirmar.
- Los fallos de exportacion son accionables.
- Exportar carpeta no se siente como una accion opaca.

### 7. Validar salida HTML/PDF con casos reales

Problema: el pipeline de exportacion es parte central del valor del producto y debe ser predecible.

Acciones:

- Crear documentos fixture con headings, listas, tablas, codigo, imagenes y wiki links.
- Comparar export Markdown/HTML/PDF contra resultados esperados.
- Revisar manejo de assets relativos dentro de `exports/`.
- Definir estilos base de HTML/PDF alineados con la identidad visual.

Criterios de aceptacion:

- Exportar el mismo documento produce resultados consistentes.
- Los assets se copian y referencian correctamente.
- PDF mantiene legibilidad en documentos largos.

## Prioridad 4 — Buenas Practicas Tecnicas

### 8. Reducir responsabilidad de `ContentView`

Problema: `ContentView` aparece como god node. Esto no es un bug, pero aumenta el costo de mantenimiento.

Acciones:

- Extraer coordinacion de acciones a objetos pequenos o contextos existentes cuando reduzca duplicacion.
- Separar estado de seleccion, feedback y workspace en unidades claras.
- Mantener `ContentView` como composicion de alto nivel, no como centro de reglas.
- Evitar refactor masivo; trabajar por flujo: workspace, documentos, enlaces, exportacion.

Criterios de aceptacion:

- `ContentView` queda mas facil de leer y probar.
- Las acciones principales tienen responsabilidades ubicables.
- No se introducen abstracciones genericas sin uso inmediato.

### 9. Agregar pruebas alrededor de servicios centrales

Problema: no hay targets de tests, y los servicios centrales concentran reglas de negocio.

Acciones:

- Crear target de pruebas unitarias en Xcode.
- Probar `DocumentService`: crear, renombrar, duplicar, soft delete y busqueda.
- Probar `FolderService`: jerarquia, movimiento y bloqueo de ciclos.
- Probar `WikiLinkService`: parseo, sync, backlinks y enlaces rotos.
- Probar `ExportService` con fixtures ligeros y filesystem temporal.

Criterios de aceptacion:

- Las reglas principales pueden cambiar sin miedo a regresiones.
- Los errores de jerarquia y workspace se validan automaticamente.
- Las pruebas corren localmente con `xcodebuild`.

### 10. Formalizar estados de error y feedback

Problema: el grafo conecta `Service Error Handling` con UI/formatos, lo que sugiere que errores y feedback cruzan varias capas.

Acciones:

- Estandarizar errores recuperables: workspace faltante, jerarquia invalida, PDF no creado, documento no encontrado.
- Mapear errores de servicio a mensajes de usuario en una capa de presentacion.
- Diferenciar feedback informativo, exito, advertencia y error.
- Evitar que servicios dependan de detalles visuales.

Criterios de aceptacion:

- Cada error comun tiene mensaje claro y accion sugerida.
- La UI no replica logica de errores en multiples vistas.
- Los servicios siguen siendo testeables sin UI.

## Prioridad 5 — Accesibilidad, Rendimiento y Calidad Visual

### 11. Auditoria de accesibilidad Liquid Glass

Problema: glassmorphism puede afectar contraste y legibilidad si no se valida en light/dark mode.

Acciones:

- Revisar contraste de sidebar, cards, toolbar flotante e inspector.
- Validar Dynamic Type, Reduce Motion y VoiceOver en flujos principales.
- Ajustar materiales donde el fondo reduzca legibilidad.
- Agregar labels accesibles a botones icon-only.

Criterios de aceptacion:

- Los textos principales son legibles en light/dark.
- La app puede usarse con Reduce Motion activado.
- Controles icon-only tienen descripcion accesible.

### 12. Medir rendimiento de editor y preview

Problema: preview en tiempo real puede degradarse con documentos largos.

Acciones:

- Probar documentos largos con headings, tablas y bloques de codigo.
- Medir hitches al escribir y cambiar modo editor/preview.
- Evitar recalcular preview completo si no es necesario.
- Revisar uso de estado en vistas centrales antes de introducir optimizaciones prematuras.

Criterios de aceptacion:

- Escribir en documentos largos no produce retrasos perceptibles.
- Cambiar entre editor, preview y split es fluido.
- Las optimizaciones se justifican con medicion.

## Entregables Propuestos

### Semana 1

- Onboarding de workspace mejorado.
- Estados vacios claros.
- Feedback de errores de workspace/documentos.

### Semana 2

- Mejoras de navegacion iPhone/iPad.
- Acciones rapidas de escritura Markdown.
- Panel de enlaces/backlinks mas accionable.

### Semana 3

- Exportacion guiada con preflight.
- Fixtures de exportacion Markdown/HTML/PDF.
- Primer target de pruebas unitarias.

### Semana 4

- Refactor incremental de `ContentView`.
- Pruebas de servicios centrales.
- Auditoria de accesibilidad y rendimiento.

## Metricas de Exito

- Tiempo para crear el primer documento desde instalacion limpia: menor a 60 segundos.
- Crear documento, escribir, previsualizar y exportar requiere menos pasos visibles.
- Cero flujos principales sin estado vacio o mensaje de error accionable.
- Servicios centrales cubiertos por pruebas unitarias.
- `ContentView` reduce responsabilidad visible y deja la logica delegada a servicios/contextos claros.
- Exportacion de documento y carpeta verificada con fixtures.

## Riesgos

- Refactorizar `ContentView` demasiado pronto puede introducir regresiones en navegacion y seleccion.
- Mejoras visuales Liquid Glass pueden empeorar accesibilidad si no se mide contraste.
- Exportacion PDF puede requerir ajustes especificos por plataforma.
- Agregar demasiadas abstracciones antes de pruebas puede aumentar complejidad sin beneficio.

## Recomendacion de Orden

1. Mejorar onboarding, estados vacios y feedback.
2. Pulir navegacion compacta y acciones rapidas de escritura.
3. Hacer enlaces internos mas accionables.
4. Guiar exportacion y cubrirla con fixtures.
5. Crear pruebas de servicios centrales.
6. Refactorizar `ContentView` por partes, solo despues de tener pruebas basicas.
