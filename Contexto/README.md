# Contexto

Material de partida aportado por el equipo. **Solo referencia**: no se edita, y los documentos del proyecto lo citan por su ruta. La documentación de ejemplo (`DocumentacionEjemplo`) nunca se modifica.

| Carpeta o archivo | Qué es | Cómo se usó |
| :--- | :--- | :--- |
| `Normativa/` | Textos oficiales: DL 1375 (`dl-n-1375-…EDAD.pdf`), RVM 188-2020-MINEDU (`Lineamientos RVM 188-2020.pdf`, escaneada), DS 016-2024-JUS, ISO/IEC 27002:2022 en español (escaneada), lineamientos de nube de la PCM (`Lineamientos_Nube.pdf`) y su resolución (`RS_segdi_N_001_2018_PCM.pdf`), manual de AVANZA v3.5 y el Anexo 1 vigente (`.docx`). | Fuente del marco legal (`docs/01-analisis-de-sistema/03-marco-legal.md`, `Investigacion/01` y `02`). Los PDF escaneados se leyeron con OCR. |
| `Antecedentes/` | Documentos previos del equipo: Documento de Análisis v1.0 (`.docx`), esquema SQL v1.0 e Informe 004 de arquitectura y base de datos. | Base de la v1.1; la correspondencia v1.0 → v1.1 está en el Anexo A del ERS. |
| `Referencia-de-formato/` | `Propuesta_Librería.pdf`: propuesta de otro proyecto del equipo. | Modelo de formato de la propuesta en `.docx` (portada, tipografía, tablas y figuras). |
| `DocumentacionEjemplo/` | Documentación completa de otro proyecto del equipo (BabelHub). | Referencia de estructura y de método (SDD); se adaptó a este producto, no se copió. |
| `Prototipo/` | Exportación de Figma Make de una **versión anterior** de la interfaz (React + Vite + Tailwind). `local/` lo ejecuta sin Node (ver su `README.md`). | Referencia de pantallas; contrastada en [`docs/06-experiencia-de-usuario/10-revision-del-prototipo.md`](../docs/06-experiencia-de-usuario/10-revision-del-prototipo.md). No es el diseño final. |

**Qué no se versiona** (ver `.gitignore` en la raíz; los archivos siguen en el equipo): la norma ISO/IEC 27002 en español (`Normativa/ISO 2022-esp.pdf`, con derechos de autor), `DocumentacionEjemplo/` (otro proyecto del equipo), `Referencia-de-formato/` (nombres de docente y estudiantes) y el Informe 004 de `Antecedentes/` (nombres de integrantes, tutora y Directora, y la dirección del CETPRO). Los documentos que citan la norma ISO lo hacen por su número de control.

Fuera de esta carpeta: la entrevista original (`Plantilla_Entrevista_Requisitos_CETPRO_V2.docx`) está en `D:\Sistemas 2026 - II\Servicio Social\`. Los documentos del proyecto citan sus respuestas como «entrevista».
