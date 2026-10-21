# Ejecutar el prototipo en local (sin Node)

El prototipo es un proyecto de Figma Make (React 19, Vite y Tailwind 4). El `index.html` de la raíz **no abre por sí solo** porque necesita compilar `src/App.tsx`. Esta carpeta `local/` lo ejecuta **sin instalar Node ni dependencias** y **sin modificar** ningún archivo del proyecto.

## Cómo abrirlo

```powershell
powershell -ExecutionPolicy Bypass -File Contexto\Prototipo\local\servir.ps1
```

Luego abra <http://localhost:5173/local/index.html>.

Acceso de demostración (del propio prototipo): usuarios `matricula`, `directivo` o `admin`; contraseña `CJLA2026`. Es una clave ficticia de demostración y **no debe usarse en el sistema real**.

## Qué hace

- `local/index.html` descarga `src/App.tsx` y `src/index.css`, transforma TypeScript y JSX en el navegador con Babel y monta la aplicación.
- React, ExcelJS y jsPDF se cargan desde un CDN (`esm.sh`), por eso **hace falta Internet**.
- Como se omite Tailwind, se incluye un reset mínimo equivalente; puede haber diferencias menores de espaciado frente a Figma Make.

## Alternativa con Node

Si instala Node (versión de `.mise.toml`) y pnpm: `pnpm install` y `pnpm dev`.
