# ==========================================
# DevDashboard Portable Installer
# ==========================================
$currentDir = Get-Location
$moduleName = "DevDashboard"
$moduleRoot = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "PowerShell\Modules"
$targetPath = Join-Path $moduleRoot $moduleName

Write-Host "🚀 Preparando entorno para Juan Carlos..." -ForegroundColor Cyan

# 1. Verificar PowerShell
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "PowerShell 7 o superior es requerido." -ForegroundColor Red
    return
}

# 1. Crear directorios si no existen
if (-not (Test-Path $moduleRoot)) { New-Item -ItemType Directory -Path $moduleRoot -Force | Out-Null }

# 2. Copia Inteligente (No borra, sobreescribe)
Write-Host "📦 Sincronizando módulo en $targetPath..." -ForegroundColor Yellow
# Creamos la carpeta si no existe
if (-not (Test-Path $targetPath)) { New-Item -ItemType Directory -Path $targetPath -Force | Out-Null }

# Copiamos TODO (incluyendo este instalador) para que lo lleves siempre contigo
Copy-Item -Path "$currentDir\*" -Destination $targetPath -Recurse -Force -ErrorAction SilentlyContinue

# 3. Configuración del $PROFILE
$profilePath = $PROFILE
$importLine = "Import-Module $moduleName -DisableNameChecking"

if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Path $profilePath -Force | Out-Null }

if (-not (Select-String -Path $profilePath -Pattern $importLine -Quiet)) {
    Add-Content -Path $profilePath -Value "`n# --- DevDashboard ---`n$importLine`ndash"
    Write-Host "✅ Líneas de carga añadidas al Perfil." -ForegroundColor Green
}

# 4. Verificación rápida de bat (vital para tu explorador)
if (-not (Get-Command bat -ErrorAction SilentlyContinue)) {
    Write-Host "💡 Sugerencia: Instala 'bat' para que el explorador se vea genial." -ForegroundColor Magenta
}

# 5. Verificar dependencias (con ripgrep 'rg')
Write-Host "`n🔍 Verificando herramientas de sistema..." -ForegroundColor Cyan
$deps = @{ 
    "git"  = "Git"
    "fzf"  = "Fuzzy Finder"
    "nvim" = "Neovim"
    "rg"   = "RipGrep (grep rápido)"
    "go"   = "Go Compiler"
    "docker" = "Docker Desktop/Engine"
}

$missingDeps = @()

foreach ($dep in $deps.Keys) {
    if (-not (Get-Command $dep -ErrorAction SilentlyContinue)) {
        Write-Host "  ✖ $($deps[$dep]) no encontrado instalar" -ForegroundColor Red
        $missingDeps += $deps[$dep]
    } else {
        Write-Host "  ✔ $($deps[$dep]) encontrado" -ForegroundColor Green
    }
}

# 6. Recordatorio Final (En lugar de limpiar pantalla)
Write-Host "`n" ("="*45) -ForegroundColor Gray
if ($missingDeps.Count -gt 0) {
    Write-Host "⚠️  RECORDATORIO DE CONFIGURACIÓN:" -ForegroundColor Yellow
    Write-Host "Para que todas las funciones de tu Dash funcionen al 100%,"
    Write-Host "debes instalar las herramientas faltantes ($($missingDeps -join ', '))."
    Write-Host "Tip: Puedes usar 'winget install [nombre]' en una terminal como Admin." -ForegroundColor DarkGray
} else {
    Write-Host "✅ ¡Todo listo! Tu entorno está completo." -ForegroundColor Green
}
Write-Host ("="*45) -ForegroundColor Gray

Write-Host "`n✨ Instalación de DevDashboard finalizada." -ForegroundColor Cyan
Write-Host "👉 Cierra esta terminal y ábrela de nuevo " -ForegroundColor White
