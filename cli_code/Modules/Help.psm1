function Write-Line {
    $width = $Host.UI.RawUI.WindowSize.Width
    Write-Host ("_" * $width) -ForegroundColor Yellow
}

function Show-Help {
    Write-Host "`nBenutze das CLI, indem du 'ct <befehl>' eingibst und mit Enter bestätigst.`nWähle einen der folgenden Befehle:`n" -ForegroundColor Yellow

    $allowedCommands = Get-AllowedCommands
    $groups = $allowedCommands | Group-Object DirectoryName | Sort-Object Name

    foreach ($group in $groups) {
        Write-Line
        Write-Host ""
        
        $relativePath = $group.Name -replace [regex]::Escape($PSScriptRoot), ''
        $relativePath = $relativePath.TrimStart('\','/')
        $folderName = Split-Path $relativePath -Leaf

        if ($folderName -match "Commands") {
            Write-Host "Allgemein" -ForegroundColor Yellow
        } else {
            Write-Host "$folderName" -ForegroundColor Yellow
        }
        Write-Host ("-" * 10) -ForegroundColor Yellow

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