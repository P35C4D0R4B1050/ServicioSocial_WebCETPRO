# Experiencia de usuario y accesibilidad (sin diseño de interfaz)

**Alcance.** Solo principios, patrones y decisiones previas a la interfaz. **No se diseña ninguna pantalla**: falta recibir los prototipos aceptados (capturas o enlace de Figma). Cuando lleguen, se revisan contra esta lista.

## 1. Contexto de uso

| Hecho | Consecuencia de diseño |
| :--- | :--- |
| Usan el sistema **3 personas de matrícula y 2 directivos**, sin formación técnica avanzada (RNF-07). | Vocabulario y flujo iguales a los de la **ficha en papel**; ayuda en contexto; poca capacitación necesaria. |
| Se matricula con la persona **delante**, con papeles en la mano y a menudo con interrupciones. | Teclado primero, guardado de borradores, corrección sencilla. |
| Hay **picos de trabajo** (inicio de periodo). | Rapidez en la tarea más frecuente: registrar una matrícula. |
| Escritorio únicamente (RNF-04). | Sin diseño móvil; sí pantallas grandes, impresión y teclado. |
| Ahora el sistema **depende de Internet** (§10.2 del ERS). | Estados de conexión visibles, reintentos y **no perder datos** al desconectarse. |
| Los datos son de personas (parte menores). | La pantalla se ve desde el mostrador: **privacidad visual**. |

## 2. Las diez heurísticas de Nielsen aplicadas a la matrícula

| Heurística | Aplicación concreta |
| :--- | :--- |
| 1. Visibilidad del estado | Barra de progreso de la ficha; "Guardado hace 5 s"; estado de conexión; confirmación con número de matrícula. |
| 2. Relación con el mundo real | Mismos nombres, orden y agrupación que la ficha física; términos del CETPRO (turno mañana/tarde, especialidad, reingresante). |
| 3. Control y libertad | **Anular con motivo** en vez de borrar; cancelar un registro sin perder lo escrito; deshacer donde sea posible. |
| 4. Consistencia y estándares | Mismo patrón en todas las listas, formularios y mensajes; fechas dd/mm/aaaa y soles (S/). |
| 5. Prevención de errores | Calcular la edad al ingresar la fecha de nacimiento; **detectar DNI duplicado antes de guardar**; listas cerradas para turno y tipo de ingreso; confirmación solo en acciones destructivas. |
| 6. Reconocer en vez de recordar | Autocompletar especialidad y turno disponibles; resumen de la matrícula antes de confirmar. |
| 7. Flexibilidad y eficiencia | Atajos de teclado; **buscar por DNI o apellidos mientras se escribe**; repetir los datos de un estudiante que reingresa. |
| 8. Diseño estético y minimalista | Campos obligatorios primero; secciones plegables para lo opcional; sin adornos que distraigan. |
| 9. Ayudar con los errores | Mensajes en español claro: qué pasó y qué hacer ("El estudiante tiene 15 años; la edad mínima es 16"); nunca códigos técnicos. |
| 10. Ayuda y documentación | Ayuda breve junto al campo, guía de una página y enlace al manual; canal de reporte de problemas. |

## 3. Accesibilidad: WCAG 2.2 AA (ISO/IEC 40500:2025)

WCAG 2.2 agrega nueve criterios; seis de ellos son A o AA y **varios tocan directamente este sistema**:

| Criterio | Nivel | Relevancia aquí |
| :--- | :---: | :--- |
| 3.3.7 **Entrada redundante** | A | No volver a pedir datos ya ingresados (por ejemplo, al reingresar o al emitir la constancia). |
| 3.3.8 **Autenticación accesible (mínimo)** | AA | El ingreso debe permitir gestores de contraseñas y pegar; sin pruebas cognitivas. |
| 2.4.11 Foco no oculto (mínimo) | AA | Encabezados fijos no deben tapar el campo enfocado. |
| 2.5.8 Tamaño del objetivo (mínimo) | AA | Botones de al menos 24×24 px. |
| 2.5.7 Movimientos de arrastre | AA | Toda acción por arrastre tiene alternativa. |
| 3.2.6 Ayuda consistente | A | La ayuda siempre en el mismo lugar. |

Además: contraste suficiente, navegación completa por teclado con foco visible, etiquetas y mensajes de error asociados a los campos, **no depender solo del color**, lenguaje de página declarado (`es-PE`), tablas con encabezados y tamaño de texto ajustable. Verificar con **axe en las pruebas automáticas** más una revisión manual con teclado y lector de pantalla. (Ver también las normas peruanas en el marco legal.)

## 4. Patrones de entrada de datos propuestos

| Tema | Propuesta |
| :--- | :--- |
| Ficha de matrícula | Una página con **secciones** (datos personales, contacto, matrícula, pago), no un asistente de muchas pantallas, para ver todo de una vez. |
| Búsqueda y duplicados | Primero se escribe el **DNI**; el sistema avisa si el estudiante ya existe y **reutiliza** sus datos (reingresante). |
| Validación | En el momento (al salir del campo) y al enviar; marcar qué falta, no solo "error". |
| Fechas y teléfonos | Máscaras y formato peruano; aceptar lo que se pega. |
| Borradores | **Guardado automático de la ficha** en el servidor para sobrevivir a cortes o al vencimiento de sesión. |
| Conflictos | Si dos personas editan lo mismo, avisar y mostrar quién cambió qué (control de concurrencia). |
| Anulaciones | Motivo obligatorio, visible en el historial, solo para quien tenga permiso. |
| Ratificación por periodo | Cada 18 semanas hay que **ratificar la matrícula** de los estudiantes continuos (LAG 11.2.2): flujo corto, con los datos ya cargados, y opción de **ratificar varios a la vez** tras revisar la lista. |
| Licencia y reincorporación | Acciones propias en la ficha del estudiante, con fecha límite visible y aviso cuando se acerca. |
| Ingreso | Mostrar **fecha del último ingreso e intentos fallidos** desde entonces (ISO/IEC 27002, control 8.5). |
| Constancia | Vista previa, **impresión directa** (hoja de estilos de impresión) y descarga en PDF con **código QR** de verificación. Se rotula **constancia de estudios**, como en la LAG. |
| Registro oficial | Botón "Registro de matrícula (Anexo 1)" con los campos oficiales, para enviar a la UGEL **dentro del mes** del inicio del periodo. |
| Nómina | Filtros por especialidad, turno y periodo; vista previa; exportar PDF o Excel; exportaciones **registradas** y con celdas saneadas. |
| Listados | DNI parcialmente oculto (con "mostrar" registrado); resultados paginados. |

## 5. Sesión, conexión y errores

| Situación | Comportamiento propuesto |
| :--- | :--- |
| Vence la sesión por inactividad | **Aviso 2 minutos antes** con opción de continuar; si vence, se conserva el borrador y se vuelve a la misma ficha al iniciar sesión. |
| Se pierde la conexión | Aviso visible, **reintento automático**, sin pérdida de datos; no confirmar como guardado algo que no lo está. |
| Error del servidor | Mensaje claro con un código de seguimiento para soporte; nunca trazas. |
| Operación lenta | Indicador de progreso y botón desactivado para evitar doble envío (idempotencia). |
| Cierre accidental | Aviso de "cambios sin guardar". |

## 6. Privacidad en la interfaz

- El **aviso de privacidad** se muestra en lenguaje claro y breve al registrar a cada estudiante (ver marco legal).
- Bloqueo de pantalla por inactividad corta en el mostrador; no dejar fichas abiertas.
- Enmascarar el DNI en listados; registrar quién consultó a quién.
- No mostrar datos sensibles (becas por necesidad) a quien no los necesita.
- Mensajes y correos **sin datos personales completos**.

## 7. Contenido y tono

- Español de Perú, trato claro y respetuoso; sin tecnicismos.
- Los mensajes de error siguen la forma **qué ocurrió + cómo resolverlo**.
- Terminología tomada de la ficha oficial: **pendiente obtener la ficha física**.

## 8. Rendimiento percibido

Metas iniciales (propuesta, a medir): carga de pantallas principales **inferior a 2,5 s** con conexión doméstica típica; interacción **inferior a 200 ms**; poco desplazamiento de diseño. Aplicar compresión, caché de recursos estáticos y **pocas dependencias de JavaScript**. Como la persona está delante del estudiante, la **latencia en el flujo de matrícula** pesa más que cualquier otra métrica.

## 9. Cómo se comprobará la usabilidad

| Prueba | Detalle |
| :--- | :--- |
| **Pruebas de usabilidad** con las 5 personas usuarias reales | Tareas: registrar matrícula, corregir un dato, anular, emitir constancia, generar nómina. Observar, medir tiempo, errores y éxito. |
| **SUS** (cuestionario de usabilidad) | Antes y después del ajuste. Meta inicial: puntaje alto (por validar). |
| **Comparación con el papel** | Tiempo de una matrícula en papel frente al sistema. |
| **Accesibilidad** | axe + revisión manual con teclado y lector de pantalla. |
| **Observación en campo** | Una jornada real de matrícula. |

## 10. Ideas propuestas

1. **Constancia verificable por QR**: la página pública de verificación muestra solo "válida" con especialidad, periodo y nombre parcial, con límite de tasa.
2. **Panel simple para Dirección**: matriculados por especialidad y turno frente al cupo referencial (30) y evolución diaria.
3. **Importación inicial desde Excel** con validación, para cargar historial (si el CETPRO tiene hojas de cálculo).
4. **Búsqueda tolerante** a acentos y errores de escritura (por ejemplo `pg_trgm` y `unaccent` en PostgreSQL).
5. **Modo de contingencia**: cuadernillo de ficha impreso con los mismos campos para capturar luego sin pérdida.
6. **Registro de cambios por estudiante** visible ("Historial") para que la anulación y las correcciones sean transparentes.

## 11. Lo que se revisará cuando lleguen los prototipos

- ¿El orden y los nombres coinciden con la ficha física?
- ¿Se puede completar una matrícula solo con el teclado?
- ¿Se avisa del DNI duplicado y de la edad mínima antes de guardar?
- ¿Se ve el estado de guardado y de conexión?
- ¿Los mensajes son comprensibles y accionables?
- ¿Cumple contraste, foco visible, tamaño de objetivos y etiquetas?
- ¿Qué ve cada rol (Matrícula, Directivo, Administrador)?

## Fuentes

- [10 heurísticas de usabilidad (Nielsen Norman Group)](https://www.nngroup.com/articles/ten-usability-heuristics/).
- [Novedades de WCAG 2.2 (W3C)](https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/) y [ISO/IEC 40500:2025](https://www.iso.org/standard/91029.html).
