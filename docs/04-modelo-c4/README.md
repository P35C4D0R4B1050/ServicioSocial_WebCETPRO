# Modelo C4

Vistas de la arquitectura del Sistema de Matrícula en tres niveles de zoom, según el [modelo C4](https://c4model.com) (Simon Brown). Complementan, y no reemplazan, el [estilo arquitectónico](../02-arquitectura-de-software/03-estilo-arquitectonico.md), el [despliegue](../02-arquitectura-de-software/05-despliegue.md) y el [diseño de software](../03-diseno-de-software/01-clean-architecture.md). Su propósito es comunicar la estructura a personas.

| Nivel | Documento | Pregunta que responde |
| :--- | :--- | :--- |
| 1. Contexto | [contexto y contenedores](01-contexto-y-contenedores.md) §1 | ¿Quién usa el sistema y con qué sistemas externos se relaciona? |
| 2. Contenedores | [contexto y contenedores](01-contexto-y-contenedores.md) §2 | ¿Qué piezas desplegables hay y cómo se comunican? |
| 3. Componentes | [componentes](02-componentes.md) | ¿Qué módulos tiene la aplicación y de qué dependen? |
| 4. Código | No se elabora | Lo cubren las specs, los planes y el propio código. |

## Convenciones

- Los diagramas están en Mermaid, igual que el resto de `docs/`.
- Los **componentes** (nivel 3) son los módulos M1 a M6 de [módulos y contratos](../03-diseno-de-software/04-modulos-y-contratos.md) y los puertos de [Clean Architecture](../03-diseno-de-software/01-clean-architecture.md). No son clases: los nombres definitivos los fija el `plan.md` de cada spec.
- Cada componente cita la spec que lo define. Si una spec cambia, el diagrama se revisa en el mismo cambio.
- Una flecha es una dependencia de uso: «A → B» significa que A llama a B. Las líneas punteadas son llamadas opcionales, de validación o fuera del sistema.
- Las dependencias internas siguen la regla de dependencia de Clean Architecture: los componentes de Aplicación usan puertos que implementa la Infraestructura.

## Relación con otros documentos

| Documento | Relación |
| :--- | :--- |
| [Mapeo a IEEE 1016](../03-diseno-de-software/07-mapeo-ieee-1016.md) | Los niveles 2 y 3 son las vistas de composición y de interfaz de la descripción de diseño. |
| [Modelo de amenazas](../05-seguridad/01-modelo-de-amenazas.md) | Las fronteras de confianza se dibujan sobre el nivel 2. |
| [Modelo de dominio](../01-analisis-de-sistema/07-modelo-de-dominio.md) | Las entidades viven dentro de los componentes del nivel 3. |
