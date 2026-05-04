# Especificación de Rediseño: Markdown Studio (SwiftUI)

Este documento detalla la evolución de la interfaz hacia un sistema de diseño moderno, optimizado para una experiencia multiplataforma (macOS/iOS) utilizando SwiftUI.

## 1. Identidad Visual y Fundamentos
* **Concepto:** Minimalismo Funcional con Glassmorphism.
* **Paleta de Colores:** * Fondo Base: `Color(NSColor.windowBackgroundColor)` o `SecondarySystemBackground`.
    * Acento: Indigo Moderno (`#5E5CE6`).
    * Superficies: `Material.thin` (Efecto de cristal).
* **Tipografía:** * UI: Inter o San Francisco (Variable).
    * Editor: JetBrains Mono o SF Mono (Monoespaciada de alta legibilidad).

## 2. Arquitectura de Componentes (SwiftUI)

### A. Sidebar (NavigationSplitView)
* **Estructura:** Usar `List(selection:)` con `NavigationLink`.
* **Estilo:** Aplicar `.listStyle(.sidebar)`. 
* **Mejoras:**
    * Iconografía dinámica usando `Label` con `SF Symbols`.
    * Footer: Implementar un `HStack` con el perfil del usuario y el selector de Workspace fijo en la base mediante un `.safeAreaInset(edge: .bottom)`.

### B. Listado de Notas (Columna Central)
* **Card Design:** Crear una `View` personalizada `NoteRow`.
    * `CornerRadius`: 12pt.
    * `Padding`: 12pt interno.
    * **Jerarquía:** Título en `.headline`, preview en `.subheadline` con color `.secondary` y máximo de 2 líneas.
    * **Tags:** Un `ScrollView` horizontal con `HStack` de píldoras (`Capsule`).

### C. Editor de Markdown (Vista Detalle)
* **Contenedor:** Un `VStack` con un ancho máximo de 800pt (`.frame(maxWidth: 800)`) centrado.
* **Editor:** `TextEditor` personalizado con soporte para `AttributedString` para renderizado en tiempo real.
* **Floating Toolbar:** Un `HStack` con `.background(.ultraThinMaterial)` y `.clipShape(Capsule())` posicionado mediante `.overlay` o un `ToolbarItem(placement: .keyboard)`.

## 3. Guía de Ejecución para el Agente de IA

### Fase 1: Limpieza y Estructura
1. Migrar la vista principal a `NavigationSplitView`.
2. Definir el modelo `Note` con propiedades para `id`, `title`, `content`, `tags` y `lastModified`.

### Fase 2: Estilizado de UI
1. Sustituir colores planos por `Material` (glassmorphism).
2. Implementar `ViewModifier` para las tarjetas de la lista: 
   - Fondo: `.background(Color.secondary.opacity(0.05))`
   - Hover: `.onHover` para cambiar la opacidad.

### Fase 3: Experiencia del Editor
1. Configurar el `TextEditor` con `font(.custom("JetBrains Mono", size: 16))`.
2. Añadir `lineSpacing(6)`.
3. Implementar el "Empty State" con un `ContentUnavailableView` (Disponible en iOS 17+/macOS 14+).

---
**Notas Técnicas:**
* Mantener compatibilidad con modo claro y oscuro de forma nativa.
* Asegurar que el `Change Workspace` sea una `Sheet` o un `Menu` contextual para reducir el ruido visual.
