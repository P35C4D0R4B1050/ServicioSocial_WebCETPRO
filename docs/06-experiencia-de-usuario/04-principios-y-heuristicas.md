# Principios de UX y heurísticas

Define cómo se diseña la experiencia, no solo cómo se ve. Sigue el proceso de diseño centrado en las personas de **ISO 9241-210** y usa las **heurísticas de usabilidad de Nielsen** como lista de revisión. Complementa la [identidad y el sistema de diseño](01-identidad-y-sistema-de-diseno.md) y respalda NN-15, OB-08, AC-05 y RNF-07.

## 1. Proceso centrado en las personas (ISO 9241-210)

| Actividad | Cómo se aplica | Producto |
| :--- | :--- | :--- |
| **Comprender y especificar el contexto de uso** | Quién usa el sistema, dónde (mostrador del CETPRO, computadora de escritorio), con la persona delante y con interrupciones. | [Personas y tareas](05-personas-y-tareas.md) |
| **Especificar los requisitos de usuario** | Metas medibles de éxito de tarea, errores y satisfacción. | RNF-01, RNF-07, RNF-16; [pruebas de usabilidad](09-pruebas-de-usabilidad.md) |
| **Producir soluciones de diseño** | Prototipo navegable en Figma y luego pantallas reales por spec. | Prototipo; skill `ui-screen` |
| **Evaluar frente a los requisitos** | Revisión heurística, lista de accesibilidad y prueba con las personas usuarias. | [Accesibilidad](06-accesibilidad-wcag.md); skill `ui-review` |

El ciclo se repite por iteración: no se espera al final del proyecto para evaluar.

## 2. Principios de interacción

1. **Mostrar la verdad.** Las validaciones y lo que falta para AVANZA se ven antes de guardar o exportar.
2. **Un solo recorrido principal.** Buscar → ficha → resumen → constancia, sin pasos inútiles.
3. **Reducir la carga de memoria.** Datos ya conocidos se reutilizan; no se pide dos veces lo mismo (WCAG 3.3.7).
4. **Prevenir antes de corregir.** Formularios que validan al salir del campo, con ejemplos de formato; botones deshabilitados con explicación.
5. **Errores humanos y recuperables.** Todo error dice qué pasó y qué hacer; la persona nunca pierde lo escrito.
6. **Seguridad sin fricción innecesaria.** Mensajes claros («espere 12 minutos para intentarlo de nuevo»), sin revelar si una cuenta existe.
7. **Consistencia.** Mismos patrones y palabras en todas las áreas.
8. **Respeto por la atención.** Sin ventanas emergentes ni temporizadores falsos; los únicos contadores reales son el aviso de sesión y las esperas por bloqueo.
9. **Privacidad visual.** Lo sensible no se ve por encima del hombro de quien está en el mostrador.

## 3. Heurísticas de Nielsen aplicadas

| Heurística | Aplicación | Cómo se revisa |
| :--- | :--- | :--- |
| **Visibilidad del estado del sistema** | Guardado, conexión, estado de la matrícula, progreso de generación de documentos. | Estados estándar. |
| **Coincidencia con el mundo real** | Nombres, orden y agrupación de la ficha en papel; lenguaje del [glosario](../glossary.md) (turno mañana/tarde, programa de estudios, reincorporación). | Revisión de textos. |
| **Control y libertad del usuario** | Anular con motivo en vez de borrar; cancelar un registro sin perder lo escrito; deshacer donde sea posible. | Recorridos de cancelación. |
| **Consistencia y estándares** | Mismos componentes en todas las áreas; fechas dd/mm/aaaa y soles. | Revisión visual. |
| **Prevención de errores** | Calcular la edad al ingresar la fecha de nacimiento; detectar el documento duplicado antes de guardar; listas cerradas para turno y tipo de ingreso; confirmación solo en acciones destructivas. | Pruebas de formularios. |
| **Reconocer antes que recordar** | Autocompletar programa y turno disponibles; resumen antes de confirmar. | Revisión de la ficha. |
| **Flexibilidad y eficiencia** | Atajos de teclado; buscar por documento o apellidos mientras se escribe; repetir los datos de quien reingresa. | Recorridos del Personal de matrícula. |
| **Diseño estético y minimalista** | Campos obligatorios primero; secciones plegables para lo opcional; sin adornos. | Revisión visual. |
| **Ayudar a reconocer y recuperarse de errores** | Mensajes con causa y acción (ver [contenido y mensajes](08-contenido-y-mensajes.md)). | Lista de mensajes. |
| **Ayuda y documentación** | Ayuda breve junto al campo, guía de una página y canal de reporte de problemas. | Revisión de la ayuda. |

## 4. Revisión heurística

Antes de dar por terminada la pantalla de una spec, se revisa con esta lista y se registran los hallazgos con gravedad (0 cosmético a 4 catastrófico). Las gravedades 3 y 4 bloquean el paso de la spec a **Done**. La skill `ui-review` guía esta revisión.
