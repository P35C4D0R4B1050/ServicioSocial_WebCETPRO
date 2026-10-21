# Accesibilidad (WCAG 2.2 nivel AA)

Concreta RNF-16, RNF-LEG-12 y AC-05: la interfaz conforma **WCAG 2.2 nivel AA** en todas las pantallas (ingreso, ficha de matrícula, listados, reportes, administración y verificación pública). La conformidad se verifica con revisión automática (axe) en las pruebas E2E y con una lista manual de teclado y lector de pantalla. Los criterios de éxito se citan por su nombre; antes de una declaración formal, se verifican contra el texto de WCAG 2.2 (ISO/IEC 40500:2025).

## 1. Criterios aplicados por principio

### Perceptible

| Criterio | Cómo se cumple |
| :--- | :--- |
| Alternativas de texto (1.1.1) | Las imágenes con función (QR, logo) llevan texto alternativo; los iconos decorativos se ocultan a la tecnología de apoyo. |
| Información y relaciones (1.3.1), propósito de los campos (1.3.5) | Estructura semántica, etiquetas asociadas y atributos `autocomplete` en nombre, correo y teléfono. |
| Uso del color (1.4.1) | Los estados (vigente, anulada, retirada, licencia, alertas) llevan texto e icono. |
| Contraste mínimo (1.4.3) y contraste no textual (1.4.11) | Texto ≥ 4,5:1 y componentes de interfaz ≥ 3:1. |
| Reflujo (1.4.10) | Sin desplazamiento horizontal a 320 píxeles de ancho (aunque el uso sea de escritorio, para usuarios con zoom). |
| Espaciado del texto (1.4.12) | El diseño tolera el aumento de interlineado y espaciado sin perder contenido. |
| Contenido al pasar o enfocar (1.4.13) | Los paneles de sugerencias del buscador se descartan con `Esc`, se mantienen al pasar el cursor y no tapan lo necesario. |

### Operable

| Criterio | Cómo se cumple |
| :--- | :--- |
| Teclado (2.1.1), sin trampas (2.1.2) | Todo se maneja con teclado; los diálogos devuelven el foco al cerrar. |
| Saltar bloques (2.4.1) | Enlace «Saltar al contenido». |
| Orden del foco (2.4.3), foco visible (2.4.7) | Orden lógico; anillo de foco visible. |
| **Foco no oculto (2.4.11, nuevo en 2.2)** | Las barras fijas no tapan el elemento enfocado. |
| Propósito de los enlaces (2.4.4), títulos de página (2.4.2) | Textos descriptivos; título único por pantalla. |
| **Gestos de arrastre (2.5.7, nuevo)** | Todo lo que se arrastra tiene alternativa con botones. |
| **Tamaño del objetivo mínimo (2.5.8, nuevo)** | Objetivos de al menos 24×24 píxeles; las acciones principales, más grandes. |
| Tiempos (2.2.1) | La sesión avisa 2 minutos antes del vencimiento y permite continuar; el borrador se conserva. |
| Movimiento reducido | `prefers-reduced-motion` elimina animaciones sin perder funcionalidad. |

### Comprensible

| Criterio | Cómo se cumple |
| :--- | :--- |
| Idioma de la página (3.1.1) | `lang="es-PE"`. |
| Identificación y sugerencia de errores (3.3.1, 3.3.3) | Mensajes junto al campo, con causa y sugerencia (ver [contenido y mensajes](08-contenido-y-mensajes.md)). |
| Etiquetas o instrucciones (3.3.2) | Cada campo con etiqueta visible y formato de ejemplo. |
| Prevención de errores en transacciones (3.3.4) | Resumen de revisión antes de confirmar; confirmación antes de anular o desactivar. |
| **Ayuda consistente (3.2.6, nuevo)** | La ayuda siempre en el mismo lugar. |
| **Entrada redundante (3.3.7, nuevo)** | No se pide de nuevo lo ya ingresado en el mismo proceso. |
| **Autenticación accesible, mínima (3.3.8, nuevo)** | El ingreso no exige pruebas cognitivas; los campos permiten pegar y usar administradores de contraseñas, incluidos los códigos de un solo uso. |

### Robusto

| Criterio | Cómo se cumple |
| :--- | :--- |
| Nombre, función, valor (4.1.2) | Componentes del sistema de diseño con roles y estados correctos. |
| Mensajes de estado (4.1.3) | Avisos de éxito y error con `role="status"` o `role="alert"` sin mover el foco. |

## 2. Documentos generados

Las constancias, nóminas y el Anexo 1 en PDF se generan con estructura legible (títulos y tablas con encabezados, orden de lectura lógico y texto seleccionable). Los archivos Excel tienen encabezados claros.

## 3. Verificación

| Nivel | Cómo | Cuándo |
| :--- | :--- | :--- |
| **Automática** | axe en las pruebas E2E de Playwright sobre las pantallas clave. Falla ante incumplimientos críticos o serios. | Cada cambio de interfaz |
| **Lista manual de teclado** | Recorrer el flujo de matrícula sin ratón: orden del foco, atajos, diálogos, menús. | Antes de dar por terminada cada pantalla |
| **Lector de pantalla** | NVDA con Firefox o Chrome en Windows sobre el flujo de matrícula. | Antes de cada despliegue mayor |
| **Zoom y reflujo** | 200 % y 400 % de zoom; 320 píxeles de ancho. | Antes de cada despliegue mayor |
| **Contraste** | Verificación de tokens. | Al cambiar tokens |

La revisión automática detecta solo una parte de los problemas; por eso la lista manual no es opcional.

## 4. Criterio de cierre

Una pantalla no pasa a **Done** con incumplimientos AA críticos abiertos. Los hallazgos menores se registran en `progress/` con responsable y fecha. La declaración de accesibilidad del proyecto indica el alcance, los criterios no cubiertos y cómo reportar un problema.
