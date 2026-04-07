# Base path del scripts-generales
# $ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Cargar módulos internos
# . "$ScriptRoot\misscripts.ps1"
# . "$ScriptRoot\scripts-generales.ps1"
# . "$ScriptRoot\grep.ps1"
# . "$ScriptRoot\symbols.ps1"
# . "$ScriptRoot\projects.ps1"
# . "$ScriptRoot\git-search.ps1"
# . "$ScriptRoot\git-tools.ps1"
# . "$ScriptRoot\docker-tool.ps1"



function Show-Dashboard
{
  while ($true)
  {
    Clear-Host
    Show-DashboardHeader        
    $items = @(
      @{Label = "⚙  Configuración"; Action = { return "EDIT_PROFILE" }}, 
      @{Label = "📂 Ir a Proyectos";  Action = { Show-ProjectsMenu }},
      @{Label = "🌿 Menú Git";        Action = { Show-GitMenu }},
      @{Label = "🐳 Menú Docker";      Action = { Show-DockerMenu }},
      @{Label  = "󱊲 Cambiar de Proyecto / Carpeta"; Action = { Invoke-ProjectJumper }},
      @{Label = "📂 Explorador de Archivos (FZF)"; Action = { Show-NavExplorer-fzf }},
      @{Label = "🔐 Editar Variables (.env)"; Action = { Invoke-CleanNvim ".env" }},
      @{Label = "Salir";              Action = { return "EXIT" }}
    )

    $selected = Invoke-Menu "DASHBOARD INTERACTIVO" $items
    if ($null -eq $selected)
    { break 
    }
        
    if ($selected.Action -is [scriptblock])
    {
      $result = & $selected.Action
    } else
    {
      $result = $selected.Action
    }

    if ($result -eq "EXIT")
    { 
      Clear-Host; break 
    } elseif ($result -eq "EDIT_PROFILE")
    {
      Clear-Host
      nvim $PROFILE
    } elseif ($result -eq "IN_PROJECT")
    {
      Clear-Host
      if (Get-Command ll -ErrorAction SilentlyContinue)
      { ll 
      } 
      Write-Host "`n Directorio: $(Get-Location)" -ForegroundColor Magenta
      break
    }

  }
}

function dsh
{
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [ArgumentCompleter({
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            
        $dashCommands = @{
          "Start-DockerEnv"      = "🚀 Levantar contenedores (up --build)"
          "Stop-DockerEnv"       = "🛑 Detener contenedores (down)"
          "Get-ContainerLog"     = "📜 Ver logs en tiempo real (-f)"
          "Get-ContainerList"    = "📜 Listar todos los contenedores (ps -a)"
          "Enter-App"            = "💻 Entrar a terminal del contenedor app"
          "Enter-DB"             = "🐘 Conectar a PostgreSQL del proyecto"
          "Show-AirClean"        = "🧹 Limpiar caché de Air y reiniciar"
          "Show-GitAll"          = "🌿 Sync: add, commit y push"
          "Switch-GitBranch"     = "🌿 Cambiar de rama (fzf)"
          "Get-GitLog"           = "🌿 Ver historial de commits (fzf)"
          "Show-GitCommit"       = "🌿 Ver detalles de un commit (fzf)"
          "Get-GitStash"        = "🌿 Listar stashes guardados"
          "Restore-GitStash"    = "🌿 Recuperar un stash (pop)"
          "Remove-GitStash"     = "🌿 Eliminar un stash (drop)"
          "Get-SymbolByLanguage" = "🔍 Buscador inteligente (Go/JS/PY)"
          "Get-Grep"             = "🔍 Búsqueda global (Ripgrep + FZF)"
          "Get-GoSymbols"       = "🔍 Buscador FZF de símbolos Go"
          "Get-FzfSymbol"       = "🔍 Buscador general mediante Ctags"
          "Get-GrepHere"        = "🔍 Búsqueda de texto en la carpeta actual"
          "New-Repo"            = "📁 Crear nuevo repositorio con estructura"
          "Show-Dashboard"      = "Abrir el panel principal DevDashboard"
        }

        $dashCommands.Keys | 
          Where-Object { $_ -like "$wordToComplete*" } | 
          Sort-Object |
          ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $dashCommands[$_])
          }
      })]
    $Command
  )

  if (-not $Command)
  {
    Show-Dashboard
  } else
  {
    & $Command[0]
  }
}

# Alias para comodidad
function dash
{ Show-Dashboard 
}

# IMPORTANTE: NO escribas "dash" o "dsh" aquí al final, 
# para que no se abra solo al recargar.
