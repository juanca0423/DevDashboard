function Invoke-Menu {
    param([string]$Title, [array]$Items, [string]$PreviewCmd)
    
    $fzfList = for ($i = 0; $i -lt $Items.Count; $i++) {
        "$i] $($Items[$i].Label)"
    }
    
    $fzfArgs = @("--reverse", "--header", " $Title ", "--height", "20", "--border", "--cycle")
    if ($PreviewCmd) {
        $fzfArgs += @("--preview", $PreviewCmd, "--preview-window", "right:50%:wrap")
    }
    
    $choice = $fzfList | fzf $fzfArgs
    
    if ([string]::IsNullOrWhiteSpace($choice)) { return $null }
    
    $index = [int]($choice -split '\]')[0]
    return $Items[$index]
}
