# projects.ps1
$rutaProyectos = "C:\Users\Usuario\Documents\Desarrollo"

function Show-OneProjectPreview
{
  param($RawInput)
    
  if ([string]::IsNullOrWhiteSpace($RawInput))
  { return 
  }

  # 1. Quitar secuencias de escape ANSI (colores)
  $clean = $RawInput -replace '\x1b\[[0-9;]*m', ''
    
  # 2. Quitar el índice numérico inicial (ej: "2] ")
  $clean = $clean -replace '^\d+\]\s+', ''
    
  # 3. QUITAR EL CARÁCTER ^ Y OTROS SÍMBOLOS DE CONTROL [Arreglo image_d779e9]
  # Esta línea busca específicamente caracteres no imprimibles o el circunflejo
  $clean = $clean -replace '[\^\cA-\cZ]', ''
    
  # 4. Quitar iconos de carpeta y espacios extra
  $cleanName = ($clean -replace '📁', '').Trim()
    
  $fullPath = Join-Path $rutaProyectos $cleanName

  if (-not (Test-Path $fullPath))
  {
    Write-Host "Buscando en: $fullPath" -ForegroundColor DarkGray
    Write-Host "Ruta no válida: $cleanName" -ForegroundColor Red
    return 
  }

  # Si la ruta es válida, mostrar contenido
  Write-Host "`n── PROYECTO: $($cleanName.ToUpper()) ──" -ForegroundColor Cyan
  Get-ChildItem $fullPath | Select-Object -First 5 | ForEach-Object {
    Write-Host "  $($_.Name)"
  }
}

function Show-ProjectsMenu
{
  # 1. Obtener solo los nombres de las carpetas
  $items = Get-ChildItem $rutaProyectos -Directory | ForEach-Object { $_.Name }
    
  # 2. Configurar el preview (usando la limpieza de caracteres ^ que ya arreglamos)
  $previewCmd = "pwsh -NoProfile -Command `". '$PSCommandPath'; Show-OneProjectPreview -RawInput '{}'`""
    
  # 3. Lanzar fzf. Si seleccionas algo, $selected tendrá el nombre (ej: "EF")
  $selected = $items | fzf --reverse --header " SELECCIONA PROYECTO " --preview $previewCmd --preview-window "right:60%"

  if ($selected)
  {
    # Cambiamos de ubicación físicamente
    Set-Location (Join-Path $rutaProyectos $selected)
        
    # IMPORTANTE: Devolvemos este string exacto para que el Dashboard sepa qué hacer
    return "IN_PROJECT"
  }
  return $null
}
