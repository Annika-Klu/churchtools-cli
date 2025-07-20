function Write-Line {
    $width = $Host.UI.RawUI.WindowSize.Width
    Write-Host ("_" * $width) -ForegroundColor Yellow
}

function Show-Help {
    Write-Host "`nListe der Befehle" -ForegroundColor Yellow

    $allowedCommands = Get-AllowedCommands
    $groups = $allowedCommands | Group-Object DirectoryName | Sort-Object Name

    foreach ($group in $groups) {
        Write-Line
        Write-Host ""
        
        $relativePath = $group.Name -replace [regex]::Escape($PSScriptRoot), ''
        $relativePath = $relativePath.TrimStart('\','/')
        $folderName = Split-Path $relativePath -Leaf

        if ($folderName -match "Commands") {
            Write-Host ("{0,-14} {1}" -f "Allgemein", "Verwendung: 'ct <befehl>'") -ForegroundColor Yellow
        } else {
            Write-Host ("{0,-14} {1}" -f $folderName , "Verwendung: 'ct $folderName <befehl>'") -ForegroundColor Yellow
        }
        Write-Host ("")

        $helpItems = foreach ($cmd in $group.Group | Sort-Object Name) {
            $name = $cmd.BaseName
            $descFile = $cmd.FullName -replace "\.ps1$", ".md"

            if (Test-Path $descFile) {
                $descLines = Get-Content $descFile
                if (-not ($descLines -is [System.Array])) {
                    $descLines = @($descLines)
                }
            } else {
                $descLines = @("(Keine Beschreibung)")
            }

            [PSCustomObject]@{
                Name        = $name
                FirstLine   = $descLines[0]
                ExtraLines  = $descLines | Select-Object -Skip 1
            }
        }

        foreach ($item in $helpItems) {
            Write-Host ("- {0,-12} {1}" -f $item.Name, $item.FirstLine) -ForegroundColor Yellow

            foreach ($line in $item.ExtraLines) {
                Write-Host ("  {0,-12} {1}" -f "", $line) -ForegroundColor Yellow
            }
        }
        Write-Host ""
    }
}