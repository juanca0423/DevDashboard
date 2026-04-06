# --- 1. BUSCADORES Y LOGS ---
function Show-GitSearchMenu {
    while ($true) {
        Clear-Host
        Show-DashboardHeader
        $items = @(
            @{Label = "⚡ Buscar texto (grep + fzf)"; Action = { grep-fzf }}, 
            @{Label = "📜 Log detallado (fzf)";       Action = { git-log-fzf }},
            @{Label = "🕵️ Grep interactivo";           Action = { grep-fzf }},
            @{Label = "📝 Blame (fzf)";               Action = { git-blame-fzf }},
            @{Label = "🏷️ Símbolos Ctags";             Action = { symbols-fzf }},
            @{Label = " Símbolos Go";                Action = { go-symbols-fzf }},
            @{Label = "« Volver";                    Action = { return "BACK" }}
        )
        $selected = Invoke-Menu "GIT > BUSCAR" $items
        if ($null -eq $selected -or $selected.Label -eq "« Volver") { break }

        Clear-Host
        & $selected.Action
        while ($Host.UI.RawUI.KeyAvailable) { $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }
    }
}
