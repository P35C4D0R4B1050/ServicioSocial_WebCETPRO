# Especificaciones (specs)

Cada funcionalidad del sistema tiene una carpeta con su `spec.md` (comportamiento en EARS, sin tecnología), su `plan.md`, sus `tasks.md` y su `verificacion.md`. Se escriben **después** de la documentación de `docs/` y siguen el [flujo SDD](../docs/07-proceso-de-desarrollo/01-flujo-sdd.md): ninguna línea de producción existe sin una spec aprobada y un plan aprobado.

> **Estado:** todavía no hay specs. Primero se prepara el marco (fase 0): `AGENTS.md`, plantillas, `SpecCheck`, skills y agentes, CI y el esqueleto de la solución.

## Specs previstas

La asignación completa (reglas, no funcionales, casos de uso, decisiones, amenazas, controles, parámetros y pendientes) está en la [matriz de trazabilidad](../docs/01-analisis-de-sistema/08-matriz-de-trazabilidad.md). Aquí solo se resumen la fase, los requisitos funcionales y las dependencias; toda spec de negocio (de CAT en adelante, excepto WEB y OPS) depende además de AUD e IDE; AUD, PAR, WEB y OPS no dependen de IDE, que a su vez depende de PAR y WEB.

| Fase | Spec (prefijo) | Requisitos funcionales | Depende de (además de AUD e IDE) |
| :---: | :--- | :--- | :--- |
| 1 | `transversal-auditoria` (AUD) | RF-34 | — |
| 1 | `parametros-institucionales` (PAR) | RF-32 | AUD |
| 1 | `web-base` (WEB) | — (RNF-01, RNF-04, RNF-07, RNF-16) | — |
| 1 | `identidad-seguridad` (IDE) | RF-19, RF-20, RF-29, RF-30, RF-39 | PAR, WEB |
| 1 (paralela) y 8 | `operacion-despliegue` (OPS) | — (RNF-02, 03, 06, 08, 09, 13, 17) | — |
| 2 | `catalogo-academico` (CAT) | RF-09, RF-10, RF-11, RF-25 | PAR |
| 2 | `periodos-ofertas` (OFE) | RF-24 | CAT, PAR |
| 3 | `estudiantes` (EST) | RF-40, RF-41 | PAR |
| 3 | `matricula-registro` (MAT) | RF-01 a RF-04, RF-07, RF-08, RF-42, RF-43 | CAT, OFE, EST, PAR |
| 4 y 6 | `docs-constancia` (CST) | RF-16, RF-28 | MAT, PAR |
| 4 y 6 | `docs-reportes` (REP) | RF-12, RF-17, RF-26 | MAT, CAT, OFE, PAR |
| 4, 6 y 7 | `cumplimiento-privacidad` (PRI) | RF-35, RF-36, RF-37, RF-38 | EST, PAR |
| 5 | `matricula-ratificacion-licencia` (RAT) | RF-21, RF-22, RF-23 | MAT, PAR |
| 5 | `matricula-convalidacion` (CON) | RF-05 | MAT, CAT, PAR |
| 5 | `matricula-becas` (BEC) | RF-06 | MAT, PAR |
| 6 | `docs-archivos-avanza` (AVZ) | RF-27 | MAT, CAT, PAR; plantillas de AVANZA (P-01) |
| 6 | `transversal-alertas` (ALE) | RF-33 | PAR; consume eventos de MAT, RAT, PRI, IDE y OPS |

`web-base` entra en la fase 1 con **tokens de diseño provisionales** (variables CSS): la identidad visual definitiva se incorpora después sin tocar las pantallas, porque ninguna usa colores propios.

Orden y fases detallados en el [plan de trabajo](../docs/07-proceso-de-desarrollo/01-flujo-sdd.md#8-plan-de-trabajo).
## Estructura prevista

```
specs/
├── README.md              este archivo
├── speccheck.json         configuración de SpecCheck (prefijos, orígenes)
├── TRACEABILITY.md        matriz requisito → spec → criterio → prueba
├── _template/             plantillas de spec, plan, tasks y verificacion
└── <nombre-de-la-spec>/   spec.md, plan.md, tasks.md, decisions.md, verificacion.md
```

## Reglas

1. Los identificadores de requisitos no se renumeran; los criterios se escriben `AC-<MÓDULO>-<NN>`.
2. Lo que está «Fuera» del sistema ([necesidad del negocio](../docs/01-analisis-de-sistema/01-necesidad-del-negocio.md), sección 3) no se especifica.
3. Un valor, plazo o texto legal que no esté en `docs/` queda como parámetro o pendiente; la IA pregunta, no supone.
4. Nunca se escribe un dato personal real en una spec.
