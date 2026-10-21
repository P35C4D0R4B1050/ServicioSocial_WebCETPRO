# Revisión del prototipo de Figma

Contrasta el prototipo que el equipo compartió (`Contexto/Prototipo`, exportado de Figma Make) con esta documentación. El prototipo es **solo referencia** y se **afinará** en función de la propuesta final; este documento dice qué se conserva, qué cambia y por qué. No modifica el prototipo.

> **Alcance (21-oct-2026).** El equipo aclaró que el prototipo es de una **versión anterior** y **no tiene por qué coincidir** con esta documentación: lo compartió solo como referencia. Este análisis **no lo exige**; se conserva como insumo del futuro documento de UI/UX y de la identidad visual (paleta, tipografía y sistema de diseño completos), que se redactarán después de cerrar la documentación.

## 1. Qué es y cómo se revisó

| Aspecto | Detalle |
| :--- | :--- |
| Origen | Proyecto de Figma Make (React 19, Vite 8, Tailwind 4, `exceljs`, `jspdf`). Un solo archivo de interfaz (`src/App.tsx`) y su hoja de estilos. Publicado en <https://sheet-slot-37176734.figma.site/>. |
| Cómo se ejecutó | **Sin Node**: se agregó `Contexto/Prototipo/local/` (con `README.md`, `index.html` y `servir.ps1`), que compila `App.tsx` en el navegador y no toca los archivos originales. Requiere Internet (CDN). |
| Qué se revisó | El **código fuente completo** (pantallas, reglas, textos, estilos) y la **ejecución en el navegador integrado** (ingreso y panel). Las capturas completas de cada pantalla no se pudieron tomar de forma fiable; las conclusiones salen del código y del texto renderizado. |
| Datos | Todos **ficticios** (nombres, DNI, usuarios, convenios, montos, clave `CJLA2026`). **No son datos del CETPRO** y no deben copiarse a los requisitos. |
| Fecha de la revisión | 21 de octubre de 2026. |

## 2. Qué contiene el prototipo

| Área | Pantallas y funciones |
| :--- | :--- |
| **Acceso** | Ingreso con usuario y contraseña; tres usuarios de demostración (Matrícula, Directivo, Admin). |
| **Dashboard** | Resumen con tres cifras y las cinco últimas matrículas. |
| **Matrícula** | Listado con búsqueda (código, DNI o nombre), filtros (especialidad, turno, estado) y paginación; acciones ver, editar, anular y emitir constancia. **Ficha** en tres secciones (Estudiante, Académico, Pago y beneficios) con validaciones; pantalla de éxito con el código; detalle de la matrícula. |
| **Especialidades** | Pestañas *Catálogo* (nombre, modalidad, familia profesional, estado) y *Ofertas por periodo* (turno, docente, cupo referencial y matriculados). |
| **Reportes** | Constancia individual (PDF) y nómina de matriculados (PDF y Excel) con filtros; historial de documentos. |
| **Administración** | Pestañas *Usuarios* (alta, restablecer contraseña, bloquear) y *Convenios* (institución, porcentaje máximo hasta 50 %, vigencia, estado). |
| **Roles** | Matrícula y Admin ven todo el menú; el Directivo ve solo *Reportes* y no puede editar. |

## 3. Qué se conserva (alineado con la documentación)

| Elemento del prototipo | Por qué se conserva |
| :--- | :--- |
| **Estructura**: barra lateral por rol, barra superior con ruta y periodo, contenido en paneles. | Coincide con el mapa de pantallas por rol. |
| **Ficha en secciones** en una sola página, con campos obligatorios marcados y ejemplos de formato. | Patrón recomendado ([sistema de diseño](01-identidad-y-sistema-de-diseno.md)). |
| **Validaciones visibles** antes de guardar (edad, DNI, duplicado, origen, tope de beca). | Principio «mostrar la verdad». |
| **Cupo referencial** con la leyenda «los cupos son referenciales» y barra de avance. | RN-04: el cupo no es un límite. |
| **Beca ligada a un convenio** con máximo por convenio y tope general. | RN-06. |
| **Insignias de estado con punto y texto**; acciones de fila con `aria-label`. | El color no es la única señal. |
| **Filtros y búsqueda** sobre el listado; paginación. | RF-12, RF-41. |
| **Mensajes** claros («Usuario o contraseña incorrectos», «Este DNI ya tiene una matrícula registrada»). | Tono de [contenido y mensajes](08-contenido-y-mensajes.md). |
| **Pantalla de éxito** con el código y las acciones siguientes. | Flujo de CU-01. |
| **Foco visible** (`:focus-visible`) y etiquetas asociadas a los campos. | Base de accesibilidad. |

## 4. Diferencias a afinar

**Gravedad:** *Alta* = contradice un requisito o la privacidad; *Media* = falta una función prevista; *Baja* = ajuste de vocabulario o de forma.

### 4.1 Seguridad y acceso

| ID | Prototipo | Documentación | Cambio propuesto | Grav. |
| :--- | :--- | :--- | :--- | :---: |
| D-01 | Solo usuario y contraseña; no cuenta intentos fallidos. | RN-07, RF-19, CTL-17, CTL-19: segundo factor obligatorio, bloqueo tras 5 fallos, último ingreso e intentos. | Agregar la pantalla del código TOTP, la configuración del segundo factor en el primer ingreso, el aviso de bloqueo y el «último ingreso» tras entrar. | Alta |
| D-02 | El ingreso muestra el bloque «Acceso de demostración» con la contraseña; al restablecer, la **clave temporal aparece en pantalla**. | CTL-18: la contraseña temporal no se muestra en la interfaz; se entrega por un canal seguro y se cambia al primer ingreso. | Retirar ambos fuera del prototipo; en el sistema, la persona define su contraseña con un enlace o una clave de un solo uso entregada por el Administrador. | Alta |
| D-03 | El rol *Admin* ve **todas** las pantallas, incluidas matrículas y reportes. | AD-33: el Administrador no ve datos de estudiantes por defecto. | Menú por permisos: el Administrador ve Usuarios, Parámetros, Respaldos y la bitácora técnica. | Alta |
| D-04 | El *Directivo* ve solo *Reportes* y desde allí puede **emitir constancias**. | Matriz: el Directivo consulta matrículas y matriculados, la bitácora y las alertas; emite nómina y Anexo 1; **no** emite constancias. | Dar al Directivo consulta de matrículas, alertas y bitácora; quitar la constancia. | Media |
| D-05 | Sin aviso de sesión por vencer ni bloqueo por inactividad. | CTL-22: aviso 2 minutos antes; borrador conservado. | Agregar el aviso y el borrador. | Media |

### 4.2 Modelo y reglas de matrícula

| ID | Prototipo | Documentación | Cambio propuesto | Grav. |
| :--- | :--- | :--- | :--- | :---: |
| D-06 | «Especialidad» y «Modalidad: Título Técnico · 2 años / Auxiliar Técnico · 1 año». | AD-25: *programa de estudios* y *ciclo* (Técnico o Auxiliar Técnico). | Renombrar; la «modalidad» del Anexo 1 es otra cosa (presencial, semipresencial). | Baja |
| D-07 | La matrícula no incluye **módulo**, plan ni periodo académico. | AD-28, AD-32: matrícula por oferta con módulo y periodo académico; plan con resolución. | Agregar el módulo en la ficha; agregar plan, módulos y unidades al catálogo. | Alta |
| D-08 | Turnos **Mañana, Tarde y Noche**. | RN-04 y la entrevista: mañana y tarde. | El turno es un catálogo configurable; las fuentes mencionan mañana y tarde y ninguna habla de turno noche, así que no se considera. | Baja |
| D-09 | Solo DNI de 8 dígitos. | AD-18: DNI, carné de extranjería, pasaporte o PTP. | Selector de tipo de documento con validación por tipo. | Alta |
| D-10 | «Apellidos» en un campo; sin sexo, grado de instrucción ni ubigeo; correo opcional. | RF-01, AVANZA (no admite celdas vacías): apellido paterno y materno, sexo, grado, ubigeo, dirección, correo y celular. | Separar apellidos; agregar sexo, grado de instrucción y ubigeo; mantener el correo como «requerido para AVANZA» con aviso. | Alta |
| D-11 | Edad mínima 16 **fija en el código**; mensaje con el valor escrito. | RN-01, AD-19: parámetro `edad_minima` y fecha de referencia. | El mensaje usa el valor vigente del parámetro. | Media |
| D-12 | Código correlativo `2026-000123`. | RN-09: el código es el **número de documento**. | Mostrar el número de documento como código. | Alta |
| D-13 | Ingreso: Nuevo, Reingresante, Trasladado, Retirado antes. | AD-21: Nuevo, Ratificación, Reincorporación, Trasladado, Retirado anteriormente. | Usar los tipos de la LAG (RF-04); «reingresante» no figura en ninguna fuente y no se considera. | Baja |
| D-14 | Estados Vigente, Retirada, Anulada; anular pide solo una confirmación del navegador. | AD-21: también **Licencia**; RN-15: **motivo obligatorio**. | Agregar Licencia y un diálogo de anulación con campo de motivo. | Alta |
| D-15 | «Especialidad o institución de origen» como texto libre; sin convalidación. | RF-05, RN-12: convalidación con resolución directoral, justificación y similitud. | Pantalla de convalidación para reincorporados y trasladados. | Media |
| D-16 | «Monto de matrícula» con **S/ 150** por defecto; sin comprobante ni fecha. | RF-07: monto, comprobante y fecha; el monto está **por definir** (P-04). | Sin valor por defecto; el monto sale del parámetro `derecho_inscripcion_monto`; agregar comprobante y fecha. | Alta |
| D-17 | Tope de beca 50 % escrito en el código. | RN-06: parámetro `beca_porcentaje_maximo`. | Leer el tope del parámetro. | Media |
| D-18 | Sin requisitos verificados, situación específica, borrador, ratificación ni licencia. | RF-40, RF-42, RF-43, RF-21, RF-22, RF-23. | Agregar las pantallas previstas en [pantallas y recorridos](02-pantallas-y-recorridos.md). | Media |
| D-19 | El duplicado se detecta **al guardar**. | RF-41: avisar al ingresar el documento y reutilizar los datos. | Buscar mientras se escribe el documento. | Media |

### 4.3 Documentos y reportes

| ID | Prototipo | Documentación | Cambio propuesto | Grav. |
| :--- | :--- | :--- | :--- | :---: |
| D-20 | «Ficha / constancia de matrícula» incluye **información económica** (monto, beca, convenio, descuento). | RN-17, AD-10: no exponer datos económicos ni de becas (dato sensible); RF-16: constancia de estudios con código y QR. | Quitar la información económica; rotular «Constancia de estudios»; agregar código único, QR y *hash*. | Alta |
| D-21 | La nómina (PDF y Excel) incluye dirección, correo, teléfono, monto y beca; el Excel suma «monto registrado». | AD-10, AD-24: nómina con datos mínimos; el archivo para AVANZA es otro, con las columnas de su plantilla. | Nómina mínima; no incluir contacto ni datos económicos. | Alta |
| D-22 | No hay Anexo 1 ni archivo para AVANZA, ni validación de datos faltantes. | RF-26, RF-27, CU-13. | Agregar la pantalla de generación con validación previa, lista de faltantes y lista informativa del orden de carga; **dejar claro que la carga es externa**. | Media |
| D-23 | El «Historial de documentos» vive en la sesión del navegador. | RF-34, `documento_emitido`: queda en la base y en la bitácora. | Historial real, por usuario y con descarga registrada. | Media |
| D-24 | PDF y Excel se generan **en el navegador** (`jspdf`, `exceljs`). | AD-15: se generan en el servidor (QuestPDF, ClosedXML) con celdas saneadas. | Solo como maqueta; el sistema real genera en el servidor. | Baja |

### 4.4 Cumplimiento y operación

| ID | Prototipo | Documentación | Cambio propuesto | Grav. |
| :--- | :--- | :--- | :--- | :---: |
| D-25 | No hay alertas, bitácora, aviso de privacidad, solicitudes de derechos, incidentes, parámetros, informe de privilegios, permisos editables ni verificación pública. | RF-28, RF-30, RF-32 a RF-37, RF-39. | Diseñar esas pantallas con el patrón de listas y formularios ya existente. | Media |
| D-26 | El Dashboard muestra cifras **fijas** (suma de 1.239 y 18). | Datos reales o ninguna cifra. | Reemplazar por matriculados por programa y turno frente al cupo, alertas y plazos. | Media |
| D-27 | Usuarios: estado «Bloqueado» manual; alta sin segundo factor. | RF-29: alta, desactivar (no borrar) y restablecer; segundo factor. | Distinguir *desactivar* y *bloqueo temporal*; configurar el segundo factor en el alta. | Media |
| D-28 | Convenios: vigencia como texto libre. | Tabla `convenio`: fecha de inicio y fin. | Dos campos de fecha. | Baja |
| D-29 | No hay etiqueta de entorno. | ISO 27002 8.31: etiqueta visible. | Agregar en la barra superior. | Baja |
| D-30 | Diseño con menú móvil. | RNF-04: solo escritorio. | No es requisito; no se invierte esfuerzo en móvil. | Baja |

## 5. Observaciones visuales y de accesibilidad

Medidas calculadas sobre la hoja de estilos del prototipo (WCAG 2.2).

| ID | Hallazgo | Medida | Propuesta |
| :--- | :--- | :--- | :--- |
| V-01 | Texto secundario `#7b889b` (y variantes `#8998a9`, `#8290a3`, `#8b9aad`). | 3,6:1 sobre blanco y 3,44:1 sobre el fondo; las variantes, entre 2,87:1 y 3,25:1. **No cumple 4,5:1.** | Oscurecer a `#5f6f86` (5,12:1 sobre blanco y 4,89:1 sobre `#f8fafd`) o más. |
| V-02 | *Placeholder* `#aab5c2`. | 2,08:1. | Oscurecerlo (≥ 4,5:1) o no depender de él. |
| V-03 | Anillo de foco `#90a9d3`. | 2,39:1 sobre blanco; el mínimo para un indicador es 3:1. | Usar `#2e5395` (7,53:1). |
| V-04 | Bordes de campos y tarjetas `#e7ebf1`. | 1,2:1. | Los campos de formulario necesitan un borde de al menos 3:1 (por ejemplo `#7c8aa0`, 3,5:1 sobre blanco); los de las tarjetas pueden seguir suaves. |
| V-05 | Tamaño de texto: 67 declaraciones de 9 a 11 px y 27 de 12 a 13 px. | Muy pequeño para uso diario. | Base de **14 px** en tablas y formularios; nada por debajo de 12 px. |
| V-06 | No se respeta `prefers-reduced-motion`. | — | Desactivar transiciones con esa preferencia. |
| V-07 | Anular y los errores usan `window.confirm` y `window.alert`. | Poco accesibles y sin campo de motivo. | Diálogo con `role="dialog"`, foco atrapado y campo de motivo. |
| V-08 | Color principal `#1f3864` sobre `#f8fafd`; blanco sobre `#2e5395`. | 11,11:1 y 7,53:1. | Conservar. |
| V-09 | Verde `#3f7f6f` y ámbar `#b45309` sobre blanco. | 4,69:1 y 5,02:1. | Conservar (cumplen 4,5:1). |

## 6. Paleta y estilo que se toman como propuesta

| Elemento | Valor del prototipo | Uso propuesto |
| :--- | :--- | :--- |
| Azul institucional (barra lateral, títulos) | `#1f3864` | Texto principal, barra lateral, tablas de documentos. |
| Azul de acción | `#2e5395` | Botón primario y enlaces. |
| Fondo | `#f8fafd` | Fondo de la aplicación. |
| Verde | `#3f7f6f` | Estados positivos (vigente, activo). |
| Ámbar | `#b45309` | Avisos. |
| Texto base | `#26344b` (11,99:1 sobre `#f8fafd`) | Cuerpo de texto. |
| Tipografía | Inter (con respaldo del sistema) | Interfaz y documentos; autoalojada en producción. |
| Documentos | Encabezado azul con monograma «CJLA» y pie «Uso interno» | Constancia, nómina y Anexo 1, con el escudo o logotipo oficial **por confirmar** con la Dirección (P-08). |

La identidad (monograma «CJLA», lema «una gestión académica más clara, cada día») es del prototipo: se conserva solo si la Dirección la aprueba. Los valores corregidos de la sección 5 reemplazan a los originales.

## 7. Próximos pasos

Se hacen **después** de cerrar la documentación y de redactar el documento de UI/UX; no bloquean las specs de la Fase 1.

1. Redactar el documento de UI/UX y la identidad visual completa (paleta, tipografía, componentes) usando este análisis como insumo.
2. Al afinar el prototipo en Figma, atender las diferencias de gravedad *Alta* (D-01, D-02, D-03, D-07, D-09, D-10, D-12, D-14, D-16, D-20, D-21) antes de escribir las specs de pantallas.
3. Agregar al prototipo las pantallas faltantes (D-18, D-22, D-25) con los patrones existentes.
4. Corregir los hallazgos visuales V-01 a V-07 en los tokens del sistema de diseño.
5. Repetir esta revisión cuando el prototipo se afine.
