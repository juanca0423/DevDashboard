
# DevDashboard.psm1

$Public  = Join-Path $PSScriptRoot 'Public'
$Private = Join-Path $PSScriptRoot 'Private'

# Cargar funciones privadas
Get-ChildItem $Private -Filter *.ps1 -Recurse |
    ForEach-Object { . $_.FullName }

# Cargar funciones públicas
Get-ChildItem $Public -Filter *.ps1 -Recurse |
    ForEach-Object { . $_.FullName }

Export-ModuleMember -Function * -Alias *
