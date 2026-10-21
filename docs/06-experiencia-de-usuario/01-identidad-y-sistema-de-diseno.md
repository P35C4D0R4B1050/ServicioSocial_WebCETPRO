# Identidad y sistema de diseño

Define cómo debe comportarse la interfaz del sistema y qué restricciones tiene el sistema de diseño. **No fija la identidad visual definitiva**: esa sale del prototipo de Figma una vez afinado con la propuesta final. Lo que sigue son principios, restricciones técnicas y la estructura del sistema de diseño, para que las pantallas se construyan sobre una base común. No cambia la estructura funcional del análisis; la traduce a pantallas.

## 1. Principios

| Principio | Qué implica |
| :--- | :--- |
| **Rápido en el mostrador** | La tarea más frecuente (registrar una matrícula) se completa con teclado, sin saltos innecesarios. La latencia pesa más que cualquier adorno. |
| **Igual que la ficha en papel** | Mismos nombres, orden y agrupación que la ficha física y el Anexo 1; términos del CETPRO. |
| **Mostrar la verdad** | Las validaciones (edad, duplicado, requisitos) y lo que falta para AVANZA se ven *antes* de guardar o exportar. |
| **Privacidad visual** | La pantalla se ve desde el mostrador: documento parcial en listados, bloqueo por inactividad, nada de datos sensibles a quien no los necesita. |
| **Un solo patrón por tarea** | Mismas listas, formularios, filtros y mensajes en las tres áreas (matrícula, dirección, administración). |
| **Seguro sin fricción innecesaria** | La seguridad se explica con mensajes claros, sin revelar si una cuenta existe. |
| **Sin movimiento innecesario** | Cada animación comunica una respuesta del sistema y se desactiva con `prefers-reduced-motion`. |
| **Solo escritorio** | Se diseña para pantallas de computadora, con impresión y teclado; no hay diseño móvil (RNF-04). |

## 2. Restricciones técnicas

| Restricción | Decisión |
| :--- | :--- |
| Renderizado | Razor Pages en el servidor y HTMX para fragmentos (AD-02); sin SPA. |
| JavaScript | Mínimo: HTMX y pocos scripts propios, servidos desde el propio origen (sin terceros). |
| CSS | CSS ligero propio con **tokens** (variables CSS); un solo archivo compilado y minificado. La elección de librería (por ejemplo, una capa utilitaria) se decide en la spec `web-base`. |
| Navegadores | Chrome, Edge y Firefox recientes. |
| Idioma | `lang="es-PE"`; fechas dd/mm/aaaa; importes en soles (`S/ 1 234,50`). |
| Impresión | Hoja de estilos de impresión para constancia, nómina y Anexo 1. |
| Fuentes | Pila del sistema o una tipografía autoalojada (sin servidores externos). |

## 3. Sistema de diseño (estructura)

| Elemento | Decisión |
| :--- | :--- |
| **Tokens** | Colores, espaciado, radios, sombras y tipografía como variables CSS con nombres semánticos (`--color-accion`, `--color-peligro`, `--color-fondo`, `--color-texto`). Ningún componente tiene colores propios. |
| **Temas** | Claro como tema base. Un tema oscuro es opcional y, si se agrega, comparte jerarquía, espaciado y estados; solo cambian los tokens. |
| **Contraste** | Texto normal ≥ 4,5:1; texto grande y componentes de interfaz ≥ 3:1 (WCAG). Cada par de colores se mide antes de aprobarlo. |
| **Color nunca es la única señal** | Estados (error, aviso, éxito, vigente, anulada) llevan texto e icono además del color. |
| **Iconos** | Conjunto de trazo fino, siempre con texto o `aria-label`. |
| **Colores institucionales** | **Propuesta tomada del prototipo** (azul `#1f3864`, azul de acción `#2e5395`, fondo `#f8fafd`, verde `#3f7f6f`, ámbar `#b45309`, texto `#26344b`; tipografía Inter), solo como punto de partida: la identidad visual completa (paleta, tipografía y sistema de diseño) se define en el documento de UI/UX, que se redacta después de cerrar la documentación, y la aprueba la Dirección. Los grises secundarios, el anillo de foco y los bordes de campos del prototipo **no cumplen** el contraste y se corrigen (ver [revisión del prototipo](10-revision-del-prototipo.md), sección 5). |
| **Tamaño de texto** | Base de **14 px** en tablas y formularios; nada por debajo de 12 px (el prototipo usa 9 a 11 px en 67 declaraciones). |

## 4. Componentes base

| Componente | Notas |
| :--- | :--- |
| Barra superior y navegación por rol | Muestra solo lo permitido; entorno visible (desarrollo, pruebas, producción). |
| Formulario por secciones | Una página con secciones, campos obligatorios primero, secciones plegables para lo opcional. |
| Campo con ayuda y error | Etiqueta visible, formato de ejemplo, mensaje junto al campo. |
| Búsqueda con resultados | Por documento o apellidos mientras se escribe; resultados paginados; documento parcialmente oculto. |
| Tabla de listado | Encabezados, orden, filtros, paginación con tope, selección múltiple (ratificación). |
| Insignia de estado | Vigente, anulada, retirada, licencia, activa, atendida: con texto e icono. |
| Aviso (éxito, información, advertencia, error) | `role="status"` o `role="alert"`; no bloquea; no mueve el foco. |
| Diálogo de confirmación | Solo para acciones destructivas (anular, desactivar). Pide motivo cuando la regla lo exige. |
| Indicador de guardado y de conexión | «Guardado hace 5 s», «Sin conexión, reintentando». |
| Vista previa e impresión | Constancia, nómina y Anexo 1 con vista previa, impresión directa y descarga. |
| Panel de alertas | Contador por rol; atender o descartar. |

## 5. Patrones de entrada de datos

| Tema | Propuesta |
| :--- | :--- |
| Ficha de matrícula | Una página con secciones (datos personales, contacto, matrícula, pago), no un asistente de muchas pantallas. |
| Búsqueda y duplicados | Primero se escribe el documento; el sistema avisa si el estudiante ya existe y reutiliza sus datos. |
| Validación | En el momento (al salir del campo) y al enviar; marca qué falta, no solo «error». |
| Fechas y teléfonos | Máscaras y formato peruano; acepta lo que se pega. |
| Borradores | Guardado automático de la ficha en el servidor para sobrevivir a cortes o al vencimiento de sesión. |
| Conflictos | Si dos personas editan lo mismo, avisa y muestra quién cambió qué. |
| Anulaciones | Motivo obligatorio, visible en el historial, solo para quien tenga permiso. |
| Ratificación por periodo | Flujo corto con los datos cargados y opción de ratificar varios a la vez tras revisar la lista. |
| Licencia y reincorporación | Acciones propias en la ficha, con la fecha límite visible y aviso cuando se acerca. |
| Ingreso | Muestra la fecha del último ingreso y los intentos fallidos desde entonces. |
| Constancia | Vista previa, impresión directa y descarga en PDF con QR. Se rotula **constancia de estudios**. |

## 6. Prototipos

| Prototipo | Ubicación | Estado |
| :--- | :--- | :--- |
| Figma | <https://sheet-slot-37176734.figma.site/> (copia local en `Contexto/Prototipo`) | Referencia en afinación; contrastado en la [revisión del prototipo](10-revision-del-prototipo.md). |

Lo aprobado en el prototipo se refleja en este documento antes de escribir las vistas Razor.
