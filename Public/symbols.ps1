function go-symbols-fzf {
    # Excluimos vendor para que no se tarde mil años
    $results = Get-ChildItem -Recurse -Filter *.go -Exclude "vendor","node_modules" -ErrorAction SilentlyContinue |
        Select-String '^(func|type)\s' |
        ForEach-Object { "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())" }

    if (-not $results) { 
        Write-Host "No se encontraron símbolos de Go." -ForegroundColor Yellow
        return 
    }

    $selected = $results | fzf --delimiter "`t" --nth 3.. `
        --prompt="Go symbol > " `
        --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' `
        --reverse --height 40%

    if ($selected) {
        $parts = $selected -split "`t"
        # Invocamos Neovim en la línea exacta
        Invoke-CleanNvim "+$($parts[1])" "$($parts[0])"
    }
}

function py-symbols-fzf {
    $results = Get-ChildItem -Recurse -Filter *.py -ErrorAction SilentlyContinue |
        Select-String '^(def|class)\s+\w+' |
        ForEach-Object { "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())" }

    if (-not $results) { return }

    $selected = $results | fzf --delimiter "`t" --nth 3.. --prompt="Python symbol > " --reverse

    if ($selected) {
        $parts = $selected -split "`t"
        Invoke-CleanNvim @("+$($parts[1])", "$($parts[0])")
    }
}

function js-symbols-fzf {
    $results = Get-ChildItem -Recurse -Include *.js,*.mjs,*.cjs |
        Select-String '^(function|class|const|let|var)\s+\w+' |
        ForEach-Object {
            "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())"
        }

    if (-not $results) {return}

    $selected = $results | fzf --delimiter "`t" --nth 3.. --prompt="JS symbol > " --reverse

    if ($selected) {  
      $parts = $selected -split "`t"
      Invoke-CleanNvim @("+$($parts[1])", "$($parts[0])")
    }
}

function css-symbols-fzf {
    $results = Get-ChildItem -Recurse -Include *.css,*.scss |
        Select-String '^[.#$@]\w+' |
        ForEach-Object {
            "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())"
        }

    if (-not $results) { return }

    $selected = $results | fzf --delimiter "`t" --nth 3.. --prompt="CSS symbol > " --reverse

    if ($selected) {
      $parts = $selected -split "`t"
      Invoke-CleanNvim @("+$($parts[1])", "$($parts[0])")
    }
}

function hbs-symbols-fzf {
    $results = Get-ChildItem -Recurse -Filter *.hbs |
        Select-String '{{[#/>]?\s*\w+' |
        ForEach-Object {
            "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())"
        }

    if (-not $results) {return}

    $selected = $results | fzf --delimiter "`t" --nth 3.. --prompt="HBS symbol > " --reverse

    if ($selected) {
      $parts = $selected -split "`t"
      Invoke-CleanNvim @("+$($parts[1])", "$($parts[0])")
    }
}

function symbols-fzf {
    if (-not (Test-Path "tags")) {
        Write-Host "⏳ Generando tags..." -ForegroundColor Cyan
        ctags -R --exclude="node_modules" --exclude="vendor" .
    }

    if (-not (Test-Path "tags")) { return }

    $lines = Get-Content tags | Where-Object { $_ -notmatch '^!' }
    if (-not $lines) { return }

    $selected = $lines | fzf --delimiter "`t" `
        --prompt="Símbolo > " `
        --nth=1,4 `
        --preview 'bat --style=numbers --color=always --highlight-line {3} {2}' `
        --reverse

    if ($selected) {
        $parts = $selected -split "`t"
        $file  = $parts[1].Trim()
        
        # Extraer línea: ctags usa line:123 al final de la fila
        $line = 1
        if ($selected -match 'line:(\d+)') { $line = $matches[1] }

        if (Test-Path $file) {
            Invoke-CleanNvim @("+$line", "$file")
        }else {
            Write-Host "Archivo no encontrado: $file" -ForegroundColor Red
        }

    }
}

function go-symbols-fzf {
    # Excluimos vendor para que no se tarde mil años
    $results = Get-ChildItem -Recurse -Filter *.go -Exclude "vendor","node_modules" -ErrorAction SilentlyContinue |
        Select-String '^(func|type)\s' |
        ForEach-Object { "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())" }

    if (-not $results) { 
        Write-Host "No se encontraron símbolos de Go." -ForegroundColor Yellow
        return 
    }

    $selected = $results | fzf --delimiter "`t" --nth 3.. `
        --prompt="Go symbol > " `
        --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' `
        --reverse --height 40%

    if ($selected) {
        $parts = $selected -split "`t"
        # Invocamos Neovim en la línea exacta
        Invoke-CleanNvim "+$($parts[1])" "$($parts[0])"
    }
}

function go-symbols-fzf {
    # Buscamos: func (metodos), func Nombre, type Nombre struct, e interfaces
    $results = Get-ChildItem -Recurse -Filter *.go -Exclude "vendor","node_modules" -ErrorAction SilentlyContinue |
        Select-String '^(func|type)\s' |
        ForEach-Object { "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())" }

    if (-not $results) { return }

    $selected = $results | fzf --delimiter "`t" --nth 3.. `
        --prompt="󰟝 Go Symbol > " `
        --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' `
        --reverse --height 50%

    if ($selected) {
        $parts = $selected -split "`t"
        Invoke-CleanNvim "+$($parts[1])" "$($parts[0])"
    }
}
