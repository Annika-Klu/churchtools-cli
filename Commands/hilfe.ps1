function Show-Help {
    Write-Host "Verfügbare Befehle:`n"
    Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 | ForEach-Object {
        $name = $_.BaseName
        $descFile = $_.FullName -replace "\.ps1$", ".md"

        if (Test-Path $descFile) {
            $desc = Get-Content $descFile -Raw
            $firstLine = $desc -split "`n" | Select-Object -First 1
        } else {
            $firstLine = "(Keine Beschreibung)"
        }

        Write-Host ("- {0}`t{1}" -f $name, $firstLine)
    }
}

Show-Help