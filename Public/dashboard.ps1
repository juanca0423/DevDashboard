# Base path del script
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Cargar módulos internos
. "$ScriptRoot\misscripts.ps1"
. "$ScriptRoot\scripts-generales.ps1"
. "$ScriptRoot\grep.ps1"
. "$ScriptRoot\symbols.ps1"
. "$ScriptRoot\projects.ps1"
. "$ScriptRoot\git-search.ps1"
#. "$ScriptRoot\git-workflow.ps1"
#. "$ScriptRoot\git-advanced.ps1"
. "$ScriptRoot\git-tools.ps1"
. "$ScriptRoot\docker-tool.ps1"



function Show-Dashboard {
    while ($true) {
        Clear-Host
        Show-DashboardHeader        
        $items = @(
            @{Label = "⚙  Configuración"; Action = { return "EDIT_PROFILE" }}, 
            @{Label = "📂 Ir a Proyectos";  Action = { Show-ProjectsMenu }},
            @{Label = "🌿 Menú Git";        Action = { Show-GitMenu }},
            @{Label = "🐳 Menú Docker";      Action = { Show-DockerMenu }},
            @{Label  = "󱊲 Cambiar de Proyecto / Carpeta"; Action = { Invoke-ProjectJumper }}
            @{Label = "📂 Explorador de Archivos (FZF)"; Action = { Show-NavExplorer-fzf }},
            @{Label = "🔐 Editar Variables (.env)"; Action = { Invoke-CleanNvim ".env" }},
            @{Label = "Salir";              Action = { return "EXIT" }}
        )

        $selected = Invoke-Menu "DASHBOARD INTERACTIVO" $items
        if ($null -eq $selected) { break }
        
        if ($selected.Action -is [scriptblock]) {
          $result = & $selected.Action
        }else{
          $result = $selected.Action
        }

        if ($result -eq "EXIT") { 
            Clear-Host; break 
        }
        elseif ($result -eq "EDIT_PROFILE") {
            Clear-Host
            nvim $PROFILE
        }
        elseif ($result -eq "IN_PROJECT") {
            Clear-Host
            if (Get-Command ll -ErrorAction SilentlyContinue) { ll } 
            Write-Host "`n Directorio: $(Get-Location)" -ForegroundColor Magenta
            break
        }

    }
}
function dash { Show-Dashboard }
