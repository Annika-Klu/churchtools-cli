function Show-Help {
    Write-Host "Verfügbare Befehle:`n"

    $allCommands = Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 -Recurse
    $groups = $allCommands | Group-Object DirectoryName | Sort-Object Name
    foreach ($group in $groups) {
        $relativePath = $group.Name.Substring($PSScriptRoot.Length).TrimStart('\','/')

        if ([string]::IsNullOrEmpty($relativePath)) {
            Write-Host "Allgemein"
        } else {
            $folderName = Split-Path $relativePath -Leaf
            Write-Host "$folderName"
        }

        foreach ($cmd in $group.Group | Sort-Object Name) {
            $name = $cmd.BaseName
            $descFile = $cmd.FullName -replace "\.ps1$", ".md"

            if (Test-Path $descFile) {
                $desc = Get-Content $descFile -Raw
                $firstLine = $desc -split "`n" | Select-Object -First 1
            } else {
                $firstLine = "(Keine Beschreibung)"
            }

            Write-Host ("- {0,-10} {1}" -f $name, $firstLine)
        }

        Write-Host ""
    }
}

Show-Help