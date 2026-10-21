# Pruebas de usabilidad

Plan para medir RNF-07 (tarea de matrícula sin ayuda) y detectar problemas de la interfaz durante el desarrollo, no solo al final. Es un plan **ligero y repetible**, adecuado a un equipo estudiantil y a cinco personas usuarias.

## 1. Objetivos y metas

| Meta | Valor | Fuente |
| :--- | :---: | :--- |
| Éxito de la tarea de matrícula (T-01), sin ayuda | ≥ 90 % de las personas | RNF-07 |
| Puntuación **SUS** (escala de usabilidad del sistema) | ≥ 68 | RNF-07 |
| Errores por tarea | < 1 en promedio | RNF-07 |
| Tiempo de una matrícula en el sistema frente al papel | Menor al del papel (a medir) | OB-01 |

El SUS de 68 se toma como referencia de «promedio» ampliamente citada; la meta es no quedar por debajo.

## 2. Método

| Aspecto | Decisión |
| :--- | :--- |
| Tipo | Prueba moderada con pensamiento en voz alta, presencial en el CETPRO, sobre el prototipo o la versión real. |
| Participantes | Las **cinco personas usuarias reales** (3 de matrícula y 2 directivos); más, en una ronda, una persona con tecnología de apoyo si se consigue. Con tan pocas personas, los porcentajes son indicativos. |
| Tareas | T-01 a T-08 para el Personal de matrícula; T-09 a T-11 para el Directivo; T-12 para el Administrador; T-13 la verifica una persona externa. Guion sin pistas. |
| Dispositivo | La computadora de escritorio del CETPRO. |
| Datos | Entorno de pruebas con **datos sintéticos**; nunca datos reales. |
| Consentimiento | Se informa el propósito, se pide permiso para registrar la pantalla y se puede retirar en cualquier momento; no se recopilan datos personales identificables. |
| Moderación | Una persona modera y otra anota; el moderador no ayuda salvo que la persona esté bloqueada más de 2 minutos (cuenta como «con ayuda»). |

## 3. Qué se registra

| Dato | Cómo |
| :--- | :--- |
| Éxito de cada tarea | Completa sin ayuda / con ayuda / no completa. |
| Tiempo por tarea | Cronómetro. |
| Errores | Conteo y descripción (clic equivocado, mensaje no entendido, retroceso). |
| Satisfacción | Cuestionario SUS de 10 preguntas al terminar. |
| Observaciones | Frases textuales, dudas y gestos de frustración. |
| Gravedad | Cada hallazgo de 0 (cosmético) a 4 (catastrófico). |

## 4. Análisis y decisiones

1. Se agrupan los hallazgos por pantalla y por gravedad.
2. Los de gravedad 3 y 4 se corrigen antes de seguir con la spec (bloquean **Done**).
3. Se actualizan el prototipo y el sistema de diseño si el problema es de patrón.
4. Se registra el resultado en `progress/` con fecha, número de personas, tareas y métricas.
5. Se repite la prueba sobre las tareas con problemas hasta cumplir las metas.

## 5. Calendario por iteración

| Momento | Qué se prueba |
| :--- | :--- |
| Tras afinar el prototipo de Figma | T-01 y T-02 sobre el prototipo (ronda 1). |
| Tras `matricula-registro` | T-01 a T-04 reales. |
| Tras `docs-constancia` y `docs-reportes` | T-01 completa con la constancia y T-08 con la nómina. |
| Tras `matricula-ratificacion-licencia` | T-05 y T-06. |
| Tras `docs-archivos-avanza` y alertas | T-08 y T-09. |
| Tras identidad | T-12 y T-15 con segundos factores reales. |
| Antes de cerrar | Pasada final con la lista de [accesibilidad](06-accesibilidad-wcag.md) y T-14. |

## 6. Plantilla de informe

```
Fecha: …            Ronda: …            Versión probada: …
Participantes: n =  (rol, equipo)
Resultados por tarea: éxito %, tiempo mediano, errores promedio
SUS promedio: …
Hallazgos (gravedad, pantalla, evidencia, propuesta)
Decisiones y responsables
```

## 7. Limitaciones

Con cinco personas, los porcentajes son indicativos: 9 de 10 equivale a 90 %, pero con mucha incertidumbre. Por eso se acumulan rondas y las decisiones se apoyan en los hallazgos cualitativos, no solo en el número. Las personas usuarias son quienes trabajan en el CETPRO: se cuida que la prueba no evalúe su desempeño laboral.
