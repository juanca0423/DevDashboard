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
