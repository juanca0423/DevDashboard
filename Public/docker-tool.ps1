function Test-DockerProject {
    Test-Path "docker-compose.yml"
}
function Show-DockerMenu {
    while ($true) {
        Clear-Host
        Show-DashboardHeader
        $items = @(
            @{Label = "🐳 Status (ps)"; Action = { Clear-Host; docker-compose ps -a | Out-Host }},
            @{Label = "🚀 Levantar (up)"; Action = { docker-compose up --build -d | Out-Host }},
            @{Label = "🛑 Detener (down)"; Action = { docker-compose down | Out-Host }},
            @{Label = "💻 Shell (entrar)"; Action = { 
                $c = docker ps --format "{{.Names}}" | fzf --reverse --header " Selecciona Contenedor "
                if ($c) { 
                    Clear-Host
                    Start-Process "docker" -ArgumentList "exec", "-it", $c, "sh" -Wait -NoNewWindow
                }
            }},
            @{Label = "« Volver";             Action = { return "BACK" }}
        )

        $selected = Invoke-Menu "DOCKER MENU" $items
        if ($null -eq $selected) { continue }
        if ($selected.Label -eq "« Volver") { break }

        & $selected.Action

        if ($selected.Label -notlike "*Shell*") {
            Write-Host "`n[Presiona una tecla para continuar]" -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
}
