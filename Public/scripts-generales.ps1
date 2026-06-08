function Invoke-CleanNvim
{
  param($ArgsList)
    
  # 1. Forzamos la limpieza del rastro de fzf
  Clear-Host
    
  # 2. Usamos 'start' con -Wait para que Neovim corra en su propio proceso
  # pero dentro de la misma ventana. Esto evita el "ghosting".
  Start-Process -FilePath "nvim.exe" -ArgumentList $ArgsList -Wait -NoNewWindow
    
  # 3. Al regresar, reseteamos la terminal por completo
  Clear-Host
  Write-Host "`n" 
  Write-Host "  󰄬 Edición finalizada." -ForegroundColor Green
  Write-Host "  󱊄 Presiona ENTER para volver al menú..." -ForegroundColor Cyan -NoNewline
  [Console]::CursorVisible = $true
}
# =======================================================
# funciones para git 
# =======================================================

function Get-GitBlame
{
  $file = git ls-files | fzf --prompt="Blame archivo > " --reverse
  if (-not $file)
  { return 
  }

  $selected = git blame --color=always $file |
    fzf --ansi --no-sort --reverse --prompt="Blame línea > " `
      --preview "git show --color=always {1}"

  if ($selected)
  {
    # Extraer número de línea de forma más limpia
    $line = ($selected -split '\s+')[2]
    Invoke-CleanNvim @("+$line", "--", "$file")  
  }
}
function Get-GitFiles
{
  git rev-parse --git-dir 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0)
  {
    Write-Host "No estás en un repositorio Git" -ForegroundColor Yellow
    return
  }

  git ls-files |
    fzf --prompt="Archivo > "
}

function Get-FzfFiles
{
  param([string]$Path = ".")
    
  $hasBat = Get-Command bat -ErrorAction SilentlyContinue
  $previewCmd = if ($hasBat)
  { 'bat --style=numbers --color=always {}' 
  } else
  { 'type {}' 
  }

  $selected = fd . $Path --type f 2>$null | fzf --prompt="Archivo > " --preview $previewCmd
    
  if ($selected)
  {
    Invoke-CleanNvim @("+$line", "--", "$file")    
  }
}

function Restore-GitStash
{

  $stashRef = Get-GitStash
  if (-not $stashRef)
  { return 
  }

  git stash pop $stashRef
}

function Remove-GitStash
{
  $stashRef = Get-GitStash
  if (-not $stashRef)
  { return 
  }

  # Limpiamos antes de preguntar para ver bien el mensaje
  Clear-Host
  Write-Host "⚠️ ¿Eliminar $stashRef ? (y/N): " -ForegroundColor Yellow -NoNewline
  $confirm = Read-Host
  if ($confirm -eq 'y')
  {
    git stash drop $stashRef | Out-Host
  }
}

function Get-GitStash
{
  git rev-parse --git-dir 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0)
  { return 
  }

  $stash = git stash list |
    fzf --reverse --prompt="Git stash > " `
      --preview 'git stash show --color=always -p {1}'

  if (-not $stash)
  { return $null 
  }
  return ($stash -split ':')[0]
}

function Get-GitStash
{

  git rev-parse --git-dir 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0)
  {
    Write-Host "No estás en un repositorio Git" -ForegroundColor Yellow
    return
  }

  $stash = git stash list |
    fzf --reverse `
      --prompt="Git stash > " `
      --preview 'git stash show --color=always -p {1}'

  if (-not $stash)
  { return 
  }

  # Devuelve la línea seleccionada
  return ($stash -split ':')[0]
}

function gac($mensaje)
{
  if (-not $mensaje)
  {
    Write-Host "❌ Error: Te falta el mensaje del commit." -ForegroundColor Red
    Write-Host "Uso: gac 'mi mensaje de cambio'"
    return
  }

  git add .
  git commit -m "$mensaje"
    
  Write-Host "✅ Cambios guardados localmente." -ForegroundColor Green
    
  # Preguntar si quieres hacer push de una vez
  $respuesta = Read-Host "¿Quieres hacer push ahora? (s/n)"
  if ($respuesta -eq "s" -or $respuesta -eq "S")
  {
    git push
    Write-Host "🚀 ¡Todo arriba en la nube!" -ForegroundColor Cyan
  } else
  {
    Write-Host "👍 Ok, commit guardado pero sin push." -ForegroundColor Yellow
  }
}

function Get-GitLog
{
  git rev-parse --is-inside-work-tree 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0)
  { return 
  }

  $logFormat = "%C(yellow)%h%C(reset) %C(green)%ad%C(reset) %s"
    
  while ($true)
  {
    $selection = git log --graph --color=always --format="$logFormat" --date=short | 
      fzf --ansi --no-sort --reverse --height="100%" `
        --preview "git show --color=always {2}" `
        --header "ENTER: Detalle | ESC: Volver"

    if (-not $selection)
    { break 
    }

    # Regex robusto para capturar el hash de 7 caracteres
    $hash = ([regex]::Match($selection, '[a-f0-9]{7,40}')).Value

    if ($hash)
    {
      Clear-Host
      # Usamos Out-Host -Paging para evitar que 'less' trabe la terminal
      git show --color=always $hash | Out-Host -Paging
      Clear-Host
    }
  }
}
# Ver el historial de commits
function Show-GitCommit
{
  git rev-parse --git-dir 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0)
  { return 
  }

  $commit = git log --oneline --decorate --color=always |
    fzf --ansi --no-sort --reverse --prompt="Git commit > " --preview 'git show --color=always {1}'

  if ($commit)
  {
    $hash = ($commit -split ' ')[0]
    Clear-Host
    # Usamos less para que puedas navegar por el commit
    git show --color=always $hash | less -R # o Out-Host -Paging
  }
}

function Get-GitBranch
{
  if (Get-Command git -ErrorAction SilentlyContinue)
  {
    $branch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($branch)
    { return $branch 
    }
  }
  return ""
}

# Seleccionar una rama visualmente
function Switch-GitBranch
{
  $branch = git branch --color=always | fzf --ansi --reverse --prompt="Checkout a rama > "
  if ($branch)
  {
    git checkout ($branch.Trim() -replace '^\* ', '')
  }
}

# =======================================================
# funciones rebase 
# =======================================================

function Update-GitRebase
{
  git rev-parse --git-dir 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0)
  {
    Write-Host "No estás en un repositorio Git" -ForegroundColor Yellow
    return
  }

  $commit = git log --oneline --decorate --color=always |
    fzf --ansi --reverse --prompt="Rebase desde (commit base) > " `
      --preview 'git show --color=always {1}'

  if ($commit)
  {
    $hash = ($commit -split ' ')[0]
    # REGLA DE ORO: Para rebase interactivo, usamos Invoke-CleanNvim
    # Pasamos los argumentos de git rebase como un array
    Invoke-CleanNvim @("-c", "git rebase -i $hash^") 
  }
}

function Update-GitRebaseLast
{
  $limit = Read-Host "¿Cuántos commits hacia atrás?"
  if ($limit -match '^\d+$')
  {
    # Lanzamos el rebase de forma aislada
    Invoke-CleanNvim @("-c", "git rebase -i HEAD~$limit")
  }
}

# =======================================================
# funciones bisect 
# =======================================================

function Start-GitBisect
{
  git rev-parse --git-dir 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0)
  { return 
  }

  # Selección de commit MALO
  $bad = git log --oneline --decorate --color=always |
    fzf --ansi --reverse --prompt="1. Seleccione commit MALO (con bug) > " `
      --preview 'git show --color=always {1}'
  if (-not $bad)
  { return 
  }
  $badHash = ($bad -split ' ')[0]

  # Selección de commit BUENO
  $good = git log --oneline --decorate --color=always |
    fzf --ansi --reverse --prompt="2. Seleccione commit BUENO (limpio) > " `
      --preview 'git show --color=always {1}'
  if (-not $good)
  { return 
  }
  $goodHash = ($good -split ' ')[0]

  # Ejecución de comandos git
  git bisect start
  git bisect bad $badHash
  git bisect good $goodHash
    
  Write-Host "`n✅ Bisect iniciado en: $badHash...$goodHash" -ForegroundColor Green
  Write-Host "Usa 'Set-GitBisectGood' o 'Set-GitBisectBad' según tus pruebas." -ForegroundColor Cyan
}

function Set-GitBisectGood
{
  git bisect good
}

function Set-GitBisectBad
{
  git bisect bad
}

function Reset-GitBisect
{
  git bisect reset
}

# =======================================================
# funciones cherry 
# =======================================================

function Copy-GitCherryPick-dry
{
  git rev-parse --git-dir 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0)
  { return 
  }

  $commit = git log --oneline --decorate --color=always |
    fzf --ansi --reverse --prompt="Ver commit antes de aplicar > " `
      --preview 'git show --color=always {1}'

  if ($commit)
  {
    # Usamos el regex que ya probamos que es robusto
    $hash = ([regex]::Match($commit, '[a-f0-9]{7,40}')).Value
    Clear-Host
    Write-Host "--- DETALLE DEL COMMIT: $hash ---" -ForegroundColor Cyan
    git show --color=always $hash | Out-Host -Paging
    Clear-Host
  }
}

function Copy-GitCherryPick
{
  git rev-parse --git-dir 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0)
  { return 
  }

  $commit = git log --oneline --decorate --color=always |
    fzf --ansi --reverse --prompt="Cherry-pick (aplicar commit) > " `
      --preview 'git show --color=always {1}'

  if ($commit)
  {
    $hash = ([regex]::Match($commit, '[a-f0-9]{7,40}')).Value
    Write-Host "`n󰄬 Aplicando cherry-pick de $hash..." -ForegroundColor Yellow
    git cherry-pick $hash
    # Pequeña pausa para ver si hubo conflictos antes de volver al menú
    Start-Sleep -Seconds 1
  }
}

# =======================================================
# funciones Blame 
# =======================================================
function Show-GitBlamePreview
{
  git rev-parse --git-dir 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0)
  { return 
  }

  $file = git ls-files | fzf --prompt="Archivo para Blame > " --reverse
  if (-not $file)
  { return 
  }

  # El preview no necesita nvim, solo mostrar quién hizo qué
  git blame --color=always $file |
    fzf --ansi --no-sort --reverse --prompt="Blame: $file > " `
      --header "ESC: Volver al menú"
}

# =======================================================
# funciones cherry 
# =======================================================

function Get-FilesHere
{
  # Llama a la función principal pasando el directorio actual
  Get-FzfFiles -Path (Get-Location)
}

function Show-NavExplorer-fzf
{
  while ($true)
  {
    $currentPath = (Get-Location).Path
    $items = @()
        
    # 1. Opción para subir
    if ($currentPath -ne (Get-Item $currentPath).Root.FullName)
    {
      $items += [PSCustomObject]@{ 
        FullName = (Get-Item $currentPath).Parent.FullName 
        Name = ".. [Subir Nivel]" 
      }
    }
        
    # 2. Listamos todo (FullName para estabilidad)
    $items += Get-ChildItem -Path $currentPath -Exclude "vendor",".git" -ErrorAction SilentlyContinue

    if ($items.Count -eq 0)
    { break 
    }

    # 3. fzf con proporciones ajustadas
    # Cambiamos right:40% para que el código no ocupe tanto y la ruta sí
    $selectedPath = $items | Select-Object -ExpandProperty FullName | fzf --reverse --height 95% `
      --prompt="󰉋 $(Split-Path $currentPath -Leaf) > " `
      --header "ENTER: Abrir/Entrar | ESC: Volver" `
      --preview-window "right:40%:border-left" `
      --preview "bat --color=always --style=numbers --line-range :500 {}"

    if (-not $selectedPath)
    { break 
    }

    # 4. Acción
    if (Test-Path $selectedPath -PathType Container)
    {
      Set-Location $selectedPath
    } else
    {
      Invoke-CleanNvim $selectedPath
      Clear-Host
    }
  }
}

function Invoke-ProjectJumper
{
  $current = Get-Location
    
  while ($true)
  {
    $items = @()
    if ((Get-Item $current).Root.FullName -ne $current.Path)
    {
      $items += [PSCustomObject]@{ FullName = (Get-Item $current).Parent.FullName; Name = ".. [Subir Nivel]" }
    }
    $items += Get-ChildItem $current -Directory -Exclude "vendor",".git","node_modules" -ErrorAction SilentlyContinue

    $selectedName = $items | Select-Object -ExpandProperty Name | fzf --reverse --height 40% `
      --prompt="󱊲 Saltar a > " `
      --header "ENTER: Entrar / Seleccionar | ESC: Cancelar"

    if (-not $selectedName)
    { return 
    }

    $selection = $items | Where-Object { $_.Name -eq $selectedName } | Select-Object -First 1
        
    Set-Location $selection.FullName
    $current = Get-Location

    # --- BLOQUE CORREGIDO ---
    # Comprobamos cada uno por separado para evitar el error de parámetros
    $isGoMod = Test-Path "go.mod"
    $isMain  = Test-Path "main.go"
    $isGit   = Test-Path ".git"

    if ($isGoMod -or $isMain -or $isGit)
    {
      Clear-Host
      Write-Host "🚀 Contexto actualizado: $($current.Path)" -ForegroundColor Cyan
      Start-Sleep -Milliseconds 600
      break 
    }
    # ------------------------
  }
}
