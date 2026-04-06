function grep {
    param([Parameter(Mandatory)][string]$Pattern)
    
    $isRepo = git rev-parse --is-inside-work-tree 2>$null
    if ($isRepo) {
        # Git grep es fantástico porque ignora el .gitignore automáticamente
        git grep -nI --heading --break --color=always $Pattern | Out-Host -Paging
    } else {
        Get-ChildItem -File -Recurse -Exclude "*.exe","*.dll","node_modules" -ErrorAction SilentlyContinue | 
            Select-String -Pattern $Pattern | 
            ForEach-Object {
                Write-Host "`n $($_.Path):$($_.LineNumber)" -ForegroundColor Yellow
                Write-Host "  $($_.Line.Trim())" -ForegroundColor White
            }
        Write-Host "`n[Fin de búsqueda]" -ForegroundColor DarkGray
    }
}

function grep-here {
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
    )
    grep $Pattern (Get-Location)
}

function grep-fzf {
    param(
        [string]$Pattern,
        [string]$Path = "."
    )

    if (-not $Pattern) {
        $Pattern = Read-Host "🔍 Texto a buscar"
        if ([string]::IsNullOrWhiteSpace($Pattern)) { return }
    }

    # Usamos ripgrep (rg) con un formato que fzf entiende perfectamente: archivo:linea:columna:texto
    $hasRg = Get-Command rg -ErrorAction SilentlyContinue
    if ($hasRg) {
        $results = rg --line-number --column --no-heading --color=always --smart-case $Pattern $Path 2>$null
    } else {
        $results = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
            Select-String -Pattern $Pattern |
            ForEach-Object { "$($_.Path):$($_.LineNumber):1:$($_.Line.Trim())" }
    }

    if (-not $results) {
        Write-Host "No se encontraron coincidencias." -ForegroundColor Yellow
        return
    }

    # RESTAURAMOS EL PREVIEW
    # --delimiter ":" nos permite separar la ruta de la línea para el preview
    $selected = $results | fzf --ansi --reverse --delimiter ":" `
        --nth 4.. `
        --preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>$null || type {1}' `
        --header "ENTER: Editar | ESC: Volver"

    if ($selected) {
        # Separamos con cuidado para NO incluir el texto del código en la ruta
        $parts = $selected -split ":"
        $file  = $parts[0].Trim()
        $line  = $parts[1].Trim()

        if (Test-Path $file) {
            # Invocamos la limpieza que ya comprobamos que funciona
            Invoke-CleanNvim @("+$line", "$file")
        }
    }
}
