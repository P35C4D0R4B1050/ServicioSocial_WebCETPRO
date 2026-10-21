# Estados, accesibilidad y criterios de aceptación visual

## 1. Estados de pantalla estándar

Cada pantalla de datos contempla los mismos estados, con el mismo patrón visual (RNF-07):

| Estado | Patrón |
| :--- | :--- |
| Cargando | Esqueleto con la forma del contenido; sin saltos de diseño; botón deshabilitado para evitar doble envío. |
| Vacío | Título breve, explicación y una acción clara («Aún no hay matrículas en este periodo. Registrar una»). |
| Error | Aviso con la causa en lenguaje simple y un botón para reintentar; identificador de seguimiento en un detalle plegable. |
| Sin permiso (403) | Mensaje de que la cuenta no tiene acceso, con salida a una pantalla permitida. |
| Servicio no disponible (503) | Informa qué parte no responde; no se pierde lo escrito. |
| Éxito | Aviso breve y no bloqueante, con `role="status"`. |
| Conflicto de edición | Aviso de que otra persona modificó el registro, con lo que cambió. |

## 2. Sesión y conexión

| Situación | Comportamiento |
| :--- | :--- |
| La sesión está por vencer | Aviso **2 minutos antes** con opción de continuar. |
| La sesión venció | Se conserva el borrador; al iniciar sesión se vuelve a la misma ficha. |
| Se pierde la conexión | Aviso visible y reintento automático; no se confirma como guardado lo que no lo está. |
| Operación lenta | Indicador de progreso y botón desactivado. |
| Cierre accidental | Aviso de «cambios sin guardar». |
| Equipo de mostrador | La sesión vence a los 30 minutos de inactividad (`sesion_inactividad_min`); el borrador se conserva y no quedan fichas abiertas. |

## 3. Microinteracciones y accesibilidad

| Elemento | Comportamiento |
| :--- | :--- |
| Botones | Cambio de color y desplazamiento mínimo; foco visible. |
| Buscador | Anillo de foco visible; resultados mientras se escribe. |
| Alertas | El contador cambia con una transición breve. |
| Guardado | Indicador «Guardado hace 5 s». |
| Fondo | Sin movimiento ambiental. |

Accesibilidad: contraste AA; navegación completa por teclado con foco visible; «saltar al contenido»; etiquetas y roles en formularios, tablas y diálogos; `prefers-reduced-motion` desactiva las animaciones sin perder funcionalidad; ninguna animación retrasa la respuesta de un control. Detalle en [accesibilidad](06-accesibilidad-wcag.md).

## 4. Cumplimiento visible

| Elemento | Dónde |
| :--- | :--- |
| Aviso de privacidad | Se muestra al registrar a cada estudiante, en lenguaje claro y comprensible para adolescentes. |
| Último ingreso e intentos fallidos | Tras el ingreso. |
| Etiqueta de entorno | En la barra superior. |
| Advertencia en `observaciones` | «No registre salud ni ingresos». |
| Contacto del ODP | Una vez designado, visible en el aviso. |

## 5. Criterios de aceptación visual

- [ ] La ficha de matrícula conserva el orden y los nombres de la ficha oficial.
- [ ] Una matrícula se completa con solo el teclado.
- [ ] El documento duplicado, la edad mínima y los datos que faltan para AVANZA se avisan antes de guardar o exportar.
- [ ] El estado de guardado y de conexión es visible.
- [ ] Los estados (vigente, anulada, retirada, licencia) nunca dependen solo del color.
- [ ] El documento aparece parcialmente oculto en los listados.
- [ ] Cada rol ve únicamente lo que su permiso permite.
- [ ] Los mensajes dicen qué pasó y qué hacer, sin códigos internos.
- [ ] La constancia, la nómina y el Anexo 1 se imprimen bien.
- [ ] Las animaciones son breves y tienen alternativa con movimiento reducido.
- [ ] La interfaz no sugiere que el sistema carga en AVANZA.

## 6. Prototipos

| Prototipo | Ubicación | Estado |
| :--- | :--- | :--- |
| Figma | <https://sheet-slot-37176734.figma.site/> (copia local en `Contexto/Prototipo`) | Referencia en afinación. Contrastado con esta documentación: ver [revisión del prototipo](10-revision-del-prototipo.md). |

Son descartables: no se construyen vistas Razor directamente de él sin pasar por la spec correspondiente. Lo aprobado en ellos queda reflejado en esta carpeta antes de escribir las vistas.
