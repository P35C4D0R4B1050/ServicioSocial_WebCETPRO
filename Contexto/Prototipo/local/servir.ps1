# Servidor estático mínimo para ejecutar el prototipo sin Node.
# Uso (desde cualquier carpeta):
#   powershell -ExecutionPolicy Bypass -File Contexto\Prototipo\local\servir.ps1
# Luego abra http://localhost:5173/local/index.html
param([int]$Port = 5173, [int]$Minutos = 60)

$raiz = Split-Path -Parent $PSScriptRoot          # carpeta del proyecto (Prototipo)
$tipos = @{
    '.html' = 'text/html; charset=utf-8'; '.css' = 'text/css; charset=utf-8'
    '.js' = 'text/javascript; charset=utf-8'; '.tsx' = 'text/plain; charset=utf-8'
    '.ts' = 'text/plain; charset=utf-8'; '.json' = 'application/json; charset=utf-8'
    '.svg' = 'image/svg+xml'; '.png' = 'image/png'; '.md' = 'text/plain; charset=utf-8'
}
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
Write-Host "Prototipo en http://localhost:$Port/local/index.html  (Ctrl+C para detener; se cierra solo en $Minutos min)"
$fin = (Get-Date).AddMinutes($Minutos)
try {
    while ((Get-Date) -lt $fin) {
        $t = $l.GetContextAsync()
        while (-not $t.IsCompleted -and (Get-Date) -lt $fin) { Start-Sleep -Milliseconds 100 }
        if (-not $t.IsCompleted) { break }
        $ctx = $t.Result
        $ruta = Join-Path $raiz ([uri]::UnescapeDataString($ctx.Request.Url.LocalPath.TrimStart('/')))
        # Solo sirve archivos dentro de la carpeta del proyecto
        if ((Test-Path $ruta -PathType Leaf) -and ((Resolve-Path $ruta).Path.StartsWith($raiz))) {
            $ext = [System.IO.Path]::GetExtension($ruta).ToLower()
            $ctx.Response.ContentType = if ($tipos.ContainsKey($ext)) { $tipos[$ext] } else { 'application/octet-stream' }
            $bytes = [System.IO.File]::ReadAllBytes($ruta)
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else { $ctx.Response.StatusCode = 404 }
        $ctx.Response.Close()
    }
} finally { $l.Stop() }
