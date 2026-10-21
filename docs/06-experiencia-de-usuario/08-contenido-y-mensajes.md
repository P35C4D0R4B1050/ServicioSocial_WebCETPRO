# Contenido y mensajes

Guía de redacción de los textos de la interfaz: tono, estructura de los mensajes y catálogo de mensajes de validación, de seguridad, de estado y de error. El objetivo es que cada mensaje diga **qué pasó, por qué y qué hacer**, **sin revelar información sensible** (ver [seguridad](../05-seguridad/README.md)).

## 1. Voz y tono

| Aspecto | Regla |
| :--- | :--- |
| Idioma | Español del Perú (es-PE); fechas dd/mm/aaaa y hora de Lima; importes en soles (`S/ 1 234,50`). |
| Tono | Claro, directo y sobrio; sin jerga técnica ni infantilismos. |
| Tratamiento | **Trato de usted** (el personal de una institución pública). *Propuesta, por validar con la Dirección.* |
| Longitud | Frases cortas; la acción en el verbo («Guardar», «Reintentar», «Anular matrícula»). |
| Términos | Los del [glosario](../glossary.md): *programa de estudios*, *módulo formativo*, *constancia de estudios*, *reincorporación*. Sin mezclar sinónimos («especialidad» solo si la ficha en papel la usa). |
| Humor | Ninguno en errores ni en seguridad. |

## 2. Estructura de un mensaje de error

> **Qué pasó** + **por qué (si ayuda)** + **qué hacer**.

| Parte | Ejemplo |
| :--- | :--- |
| Qué pasó | «No se pudo guardar la matrícula.» |
| Por qué | «La persona tiene 15 años y la edad mínima vigente es 16.» |
| Qué hacer | «Verifique la fecha de nacimiento o consulte con la Dirección.» |

Reglas: sin códigos internos visibles (el `code` estable y el identificador de seguimiento van en un detalle plegable «Soporte»); sin culpar a la persona; sin trazas; el foco pasa al mensaje o al primer campo con error y se anuncia con `role="alert"`.

## 3. Mensajes de validación de negocio

| Regla | Mensaje |
| :--- | :--- |
| Edad mínima (RN-01) | «La edad mínima para matricularse es 16 años. La persona tiene 15.» |
| Documento duplicado (RF-41) | «Ya existe un estudiante con este documento. Se cargaron sus datos para que los revise.» |
| Matrícula vigente (RN-13) | «Ya tiene una matrícula vigente en este programa y periodo.» |
| Ciclo Técnico (RN-14) | «Este programa es del ciclo Técnico y requiere primaria completa.» |
| Anulación sin motivo (RN-15) | «Escriba el motivo de la anulación para continuar.» |
| Beca sobre el tope (RN-06) | «El descuento supera el máximo permitido (50 %).» |
| Convalidación sin similitud (RN-12) | «La similitud de contenido es 70 %; se requiere al menos 80 %.» |
| Módulo de otro programa | «El módulo elegido no pertenece al programa de esta matrícula.» |
| Faltan datos para AVANZA (RN-16) | «Faltan datos que AVANZA exige: correo, celular. Puede guardar y completarlos después.» |
| Parámetro por definir | «Este dato aún no está definido por la institución. Pida al Administrador que lo configure.» |
| Licencia vigente | «Esta matrícula ya tiene una licencia vigente.» |
| Matrícula en licencia | «La matrícula está en licencia. Registre la reincorporación para continuar.» |
| Cambio de estado inválido | «No se puede pasar de “Anulada” a “Vigente”.» |
| Conflicto de edición | «Otra persona modificó esta matrícula. Revise los cambios y vuelva a intentarlo.» |

## 4. Mensajes de seguridad

Estos mensajes **no deben revelar** si una cuenta existe, qué dato falló ni detalles internos.

| Situación | Mensaje | Qué evita |
| :--- | :--- | :--- |
| Credenciales incorrectas | «El usuario o la contraseña no coinciden.» | Revelar cuál falló o si la cuenta existe. |
| Ingreso bloqueado | «Hizo varios intentos. Espere 15 minutos o solicite ayuda al Administrador.» (con la hora de reintento) | Distinguir cuentas existentes. |
| Segundo factor incorrecto | «El código no es válido. Si perdió su dispositivo, use un código de respaldo.» | Indicar si la contraseña era correcta. |
| Segundo factor bloqueado | «Hizo varios intentos. Podrá volver a probar a las 15:42.» | Dar pistas internas. |
| Contraseña temporal | «Defina su contraseña para continuar. La temporal vence a las 15:42.» | Mostrar la temporal. |
| Sesión por vencer | «Su sesión vence en 2 minutos. ¿Desea continuar?» | Perder datos. |
| Sesión vencida | «Su sesión venció por inactividad. Inicie sesión para continuar; guardamos lo que escribió.» | Perder datos. |
| Sin permiso | «Su cuenta no tiene acceso a esta sección.» + salidas permitidas | Revelar que el recurso existe. |
| Límite de uso | «Se hicieron varias consultas seguidas. Vuelva a intentarlo en 30 segundos.» | Acusar o dar pistas. |
| Verificación pública no válida | «El código no corresponde a una constancia válida.» | Distinguir inexistente de revocada. |
| Exportación registrada | «Esta descarga queda registrada en la bitácora.» | Ocultar la trazabilidad. |

## 5. Catálogo de mensajes por estado

| Estado | Título | Texto | Acción |
| :--- | :--- | :--- | :--- |
| Cargando | — | (esqueleto, sin texto) | — |
| Vacío (matrículas) | «Aún no hay matrículas» | «Registre la primera del periodo.» | Nueva matrícula |
| Vacío (búsqueda) | «No se encontraron resultados» | «Revise la ortografía o pruebe con menos filtros.» | Limpiar filtros |
| Error genérico | «Algo salió mal» | «No se pudo completar la acción. Intente de nuevo.» | Reintentar |
| Servicio no disponible | «No se puede mostrar esto ahora» | Nombra la parte afectada. | Reintentar |
| Sin conexión | «Sin conexión» | «Seguimos intentando. Lo que escribió está guardado en esta pantalla.» | — |
| Guardado | «Guardado» | «Hace 5 segundos.» | — |
| Borrador recuperado | «Recuperamos su borrador» | «Continúe donde se quedó.» | Continuar |
| Alerta nueva | «Tiene una alerta» | Texto breve de la alerta. | Ver alerta |
| Alerta de plazo AVANZA | «Plazo de registro en AVANZA» | «Faltan 7 días para cumplir un mes del inicio del periodo. El sistema no sabe si ya cargó los datos; marque la alerta como atendida cuando termine.» | Atender o descartar |
| Datos faltantes | «Faltan datos para AVANZA» | «3 estudiantes tienen campos vacíos.» | Ver quiénes |
| Archivo listo | «Archivo generado» | «Descárguelo y cárguelo en AVANZA según el procedimiento del CETPRO.» | Descargar |

## 6. Contenido legal y de privacidad

- El **aviso de privacidad** usa lenguaje claro, comprensible para adolescentes, con los diez elementos del art. 6 del DS 016-2024-JUS; muestra su versión y fecha de vigencia.
- El aviso nombra al **equipo técnico** y a **Oracle** como intervinientes y menciona el flujo hacia el exterior.
- El campo `observaciones` advierte: «No registre datos de salud ni de ingresos».
- La constancia de estudios indica el programa, el periodo y el código de verificación.
- Los mensajes y correos (cuando existan) **no contienen datos personales completos**.

## 7. Revisión de textos

La skill `ui-review` incluye una pasada de contenido: tono, claridad, términos del glosario, mensajes de seguridad que no filtran información y ausencia de texto en imágenes. Los textos viven en recursos de localización, no incrustados en el código de las vistas, para poder revisarlos en un solo lugar.
