function Get-GoSymbols
{
  # Excluimos vendor para que no se tarde mil años
  $results = Get-ChildItem -Recurse -Filter *.go -Exclude "vendor","node_modules" -ErrorAction SilentlyContinue |
    Select-String '^(func|type)\s' |
    ForEach-Object { "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())" }

  if (-not $results)
  { 
    Write-Host "No se encontraron símbolos de Go." -ForegroundColor Yellow
    return 
  }

  $selected = $results | fzf --delimiter "`t" --nth 3.. `
    --prompt="Go symbol > " `
    --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' `
    --reverse --height 40%

  if ($selected)
  {
    $parts = $selected -split "`t"
    # Invocamos Neovim en la línea exacta
    Invoke-CleanNvim "+$($parts[1])" "$($parts[0])"
  }
}

function Get-PySymbols
{
  $results = Get-ChildItem -Recurse -Filter *.py -ErrorAction SilentlyContinue |
    Select-String '^(def|class)\s+\w+' |
    ForEach-Object { "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())" }

  if (-not $results)
  { return 
  }

  $selected = $results | fzf --delimiter "`t" --nth 3.. --prompt="Python symbol > " --reverse

  if ($selected)
  {
    $parts = $selected -split "`t"
    Invoke-CleanNvim @("+$($parts[1])", "$($parts[0])")
  }
}

function Get-JsSymbols
{
  $results = Get-ChildItem -Recurse -Include *.js,*.mjs,*.cjs |
    Select-String '^(function|class|const|let|var)\s+\w+' |
    ForEach-Object {
      "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())"
    }

  if (-not $results)
  {return
  }

  $selected = $results | fzf --delimiter "`t" --nth 3.. --prompt="JS symbol > " --reverse

  if ($selected)
  {  
    $parts = $selected -split "`t"
    Invoke-CleanNvim @("+$($parts[1])", "$($parts[0])")
  }
}

function Get-CssSymbols
{
  $results = Get-ChildItem -Recurse -Include *.css,*.scss |
    Select-String '^[.#$@]\w+' |
    ForEach-Object {
      "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())"
    }

  if (-not $results)
  { return 
  }

  $selected = $results | fzf --delimiter "`t" --nth 3.. --prompt="CSS symbol > " --reverse

  if ($selected)
  {
    $parts = $selected -split "`t"
    Invoke-CleanNvim @("+$($parts[1])", "$($parts[0])")
  }
}

function Get-HbsSymbols
{
  $results = Get-ChildItem -Recurse -Filter *.hbs |
    Select-String '{{[#/>]?\s*\w+' |
    ForEach-Object {
      "$($_.Path)`t$($_.LineNumber)`t$($_.Line.Trim())"
    }

  if (-not $results)
  {return
  }

  $selected = $results | fzf --delimiter "`t" --nth 3.. --prompt="HBS symbol > " --reverse

  if ($selected)
  {
    $parts = $selected -split "`t"
    Invoke-CleanNvim @("+$($parts[1])", "$($parts[0])")
  }
}

# Añade un parámetro para forzar la actualización

function Get-FzfSymbol
{
  param([switch]$Update)

  # SEGURO DE VIDA: Si la ruta es muy corta (como C:\ o C:\Users), abortamos
  if ($PWD.Path.Length -le 10)
  {
    Write-Host "🛑 ERROR: Estás en una carpeta raíz o muy sensible. No generaré tags aquí." -ForegroundColor Red
    return
  }

  # Tu lógica normal...
  if ($Update -or -not (Test-Path "tags"))
  {
    Write-Host "⏳ Generando tags en $($PWD.Path)..." -ForegroundColor Cyan
    ctags -R --exclude="node_modules" --exclude="vendor" --exclude=".git" .
  }

  if (-not (Test-Path "tags"))
  {
    Write-Host "❌ No se pudo encontrar ni generar el archivo 'tags'." -ForegroundColor Red
    return 
  }

  # 2. Filtrar encabezados de ctags
  $lines = Get-Content tags | Where-Object { $_ -notmatch '^!' }
  if (-not $lines)
  {
    Write-Host "⚠️ El archivo de tags está vacío." -ForegroundColor Yellow
    return 
  }

  # 3. El buscador con FZF (Tu lógica de bat está genial)
  $selected = $lines | fzf --delimiter "`t" `
    --prompt="Símbolo > " `
    --nth=1,4 `
    --preview 'bat --style=numbers --color=always --highlight-line {3} {2}' `
    --reverse

  if ($selected)
  {
    $parts = $selected -split "`t"
    $file  = $parts[1].Trim()
        
    $line = 1
    if ($selected -match 'line:(\d+)')
    { 
      $line = $matches[1] 
    }

    if (Test-Path $file)
    {
      # Llamamos a tu función de apertura de Neovim
      Invoke-CleanNvim @("+$line", "$file")
    } else
    {
      Write-Host "Archivo no encontrado: $file" -ForegroundColor Red
    }
  }
}

# ALIAS PARA VELOCIDAD (Pon esto al final del archivo)
Set-Alias -Name "gsym" -Value Get-FzfSymbol
