
# DevDashboard.psm1

$Public  = Join-Path $PSScriptRoot 'Public'
$Private = Join-Path $PSScriptRoot 'Private'

# Cargar .env y .env.local si existen (.env.local tiene prioridad)
function Load-DotEnv {
    param([string]$BasePath = "$PSScriptRoot")
    $files = @("$BasePath\.env.example", "$BasePath\.env.local")
    foreach ($file in $files) {
        if (Test-Path $file) {
            Get-Content $file | ForEach-Object {
                $line = $_
                if ($line -match '^\s*([^#=]+)=(.*)$') {
                    $name = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    # Quitar comillas simples o dobles al inicio y final
                    if ($value.StartsWith('"') -and $value.EndsWith('"')) { $value = $value.Substring(1, $value.Length - 2) }
                    elseif ($value.StartsWith("'") -and $value.EndsWith("'")) { $value = $value.Substring(1, $value.Length - 2) }
                    if (-not [string]::IsNullOrWhiteSpace($value) -and $value -notmatch '^tu-.*-aqui$') {
                        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
                    }
                }
            }
        }
    }
}
Load-DotEnv

# Cargar funciones privadas
Get-ChildItem $Private -Filter *.ps1 -Recurse |
  ForEach-Object { . $_.FullName }

# Cargar funciones públicas
Get-ChildItem $Public -Filter *.ps1 -Recurse |
  ForEach-Object { . $_.FullName }

Export-ModuleMember -Function * -Alias *
