# git-tool.ps1
# =========================================================
# GIT TOOLS CONSOLIDADO (Versión Estable)
# =========================================================

# --- PREVIEW PARA EL DASHBOARD ---
function Show-GitPreview
{
  if (-not (Get-Command git -ErrorAction SilentlyContinue))
  { return 
  }
  $isRepo = git rev-parse --is-inside-work-tree 2>$null
  if (-not $isRepo)
  {
    Write-Host "`n  No estás en un repositorio Git" -ForegroundColor DarkGray
    return
  }

  $branch = git branch --show-current
  Write-Host "`n── GIT STATUS ────────────────" -ForegroundColor DarkGray
  Write-Host " Rama: $branch" -ForegroundColor Magenta
  git status --short 2>$null | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" }
}

# --- MENÚ PRINCIPAL DE GIT ---
function Show-GitMenu
{
  if (-not (git rev-parse --is-inside-work-tree 2> $null))
  {
    Write-Host "`n [!] No estás en un repositorio Git." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    return 
  }

  while ($true)
  {
    $items = @(
      @{Label = "🔍 Buscadores y Logs";     Action = { Show-GitSearchMenu }},
      @{Label = "📦 Flujo (Commit/Stash)";  Action = { Show-GitWorkflowMenu }},
      @{Label = "🛠️ Avanzado";               Action = { Show-GitAdvancedMenu }},
      @{Label = "🌿 Status";                Action = { git status | Out-Host }},
      @{Label = "🚀 Pull / Push";           Action = { git pull && git push | Out-Host }},
      @{Label = "« Volver";                 Action = { return "BACK" }}
    )

    $selected = Invoke-Menu "HERRAMIENTAS DE GIT" $items
    if ($null -eq $selected -or $selected.Label -eq "« Volver")
    { break 
    }

    Clear-Host
    $result = & $selected.Action
    if ($result -eq "BACK")
    { continue 
    }

    # Pausa de seguridad para comandos que no son submenús
    if ($selected.Label -match "Status|Pull")
    {
      Write-Host "`n[Presiona una tecla para continuar]" -ForegroundColor DarkGray
      $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
  }
}

# --- 1. BUSCADORES Y LOGS ---
function Show-GitSearchMenu
{
  while ($true)
  {
    Clear-Host
    Show-DashboardHeader
    $items = @(
      @{Label = "⚡ Buscar texto (grep + fzf)"; Action = { Get-Grep}}, 
      @{Label = "📜 Log detallado (fzf)"; Action = { Get-GitLog }},
      @{Label = "🕵️ Grep interactivo"; Action = {Get-Grep}},
      @{Label = "📝 Blame (fzf)"; Action = { Get-GitBlame }},
      @{Label = "🏷️ Símbolos GO"; Action = { Get-GoSymbols }},
      @{Label = "🏷️ Símbolos JS"; Action = { Get-JsSymbols }},
      @{Label = "🏷️ Símbolos HBS"; Action = { Get-HbsSymbols }},
      @{Label = " Símbolos Todos"; Action = {Get-SymbolByLanguage}},
      @{Label = "« Volver"; Action = { return "BACK" }}
    )
    $selected = Invoke-Menu "GIT > BUSCAR" $items
    if ($null -eq $selected -or $selected.Label -eq "« Volver")
    { break 
    }

    Clear-Host
    & $selected.Action
    while ($Host.UI.RawUI.KeyAvailable)
    { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
    }
  }
}

# --- 2. FLUJO DE TRABAJO (Commit/Stash) ---
function Show-GitWorkflowMenu
{
  while ($true)
  {
    Clear-Host
    Show-DashboardHeader
    $items = @(
      # --- ESTADO Y CAMBIOS ---
      @{Label = "🔍 Git Status (Detallado)"; Action = { git status | Out-Host }},
      @{Label = "📝 Ver Cambios Actuales"; Action = { git diff | Out-Host }},
      @{Label = "📦 Ver Cambios en Staging (Add)"; Action = { git diff --cached | Out-Host}}            # --- FLUJO DE TRABAJO ---
      @{Label = "➕ Add / Stage (fzf)";       Action = { Show-GitAll }},
      @{Label = "💾 Commit (Interactivo)";    Action = { 
          $msg = Read-Host "Mensaje del commit"
          if ($msg)
          { git add .; git commit -m $msg 
          }
        }
      },
      @{Label = " Cambiar Rama (Checkout)"; Action = { Switch-GitBranch }},
      @{Label = " Historial (Log FZF)";     Action = { Get-GitLog }},

      # --- GESTIÓN DE STASH ---
      @{Label = "📦 Stash: Guardar Actual";   Action = { 
          $sMsg = Read-Host "Nombre del Stash (opcional)"
          git stash save $sMsg 
        }
      },
      @{Label = "📥 Stash: Recuperar (Pop)";  Action = { Restore-GitStash }},
      @{Label = "󰆴 Stash: Borrar (Drop)";     Action = { Remove-GitStash }},
      @{Label = "« Volver";                   Action = { return "BACK" }}
    )

    $selected = Invoke-Menu "GIT > FLUJO INTEGRADO" $items
    if ($null -eq $selected -or $selected.Label -eq "« Volver")
    { break 
    }

    Clear-Host
    # Ejecutamos la acción seleccionada
    & $selected.Action
        
    if ($selected.Label -match "Status|Diff")
    {
      Write-Host "`n[Presiona cualquier tecla para volver al menú]" -ForegroundColor Cyan
      $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } else
    {
      Write-Host "`n[Operación finalizada]" -ForegroundColor DarkGreen
      Start-Sleep -Milliseconds 800
    }
  }
}

# --- 3. AVANZADO ---
function Show-GitAdvancedMenu
{
  while ($true)
  {
    Clear-Host
    Show-DashboardHeader
    $items = @(
      @{Label = "🔨 Rebase Interactivo (fzf)"; Action = { Update-GitRebase }},
      @{Label = "🍒 Cherry-pick (fzf)";       Action = { Copy-GitCherryPick }},
      @{Label = "🔍 Bisect: Iniciar búsqueda"; Action = { Start-GitBisect }},
      @{Label = "🧹 Bisect: Reset / Terminar"; Action = { git bisect reset; Write-Host "Bisect finalizado." -ForegroundColor Green; pause }},
      @{Label = "📋 Git Blame (Ver autoría)";  Action = { Show-GitBlamePreview }},
      @{Label = "🌳 Worktree: Crear nuevo";    Action = { New-GitWorktree }},
      @{Label = "🗑️ Worktree: Eliminar";       Action = { Remove-GitWorktree }},
      @{Label = "« Volver";                    Action = { return "BACK" }}
    )

    $selected = Invoke-Menu "GIT > AVANZADO" $items
    if ($null -eq $selected -or $selected.Label -eq "« Volver")
    { break 
    }

    Clear-Host
    & $selected.Action
        
    # Limpia el buffer de entrada para evitar saltos accidentales
    while ($Host.UI.RawUI.KeyAvailable)
    { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
    }
  }
}
