$ErrorActionPreference = "Stop"

$requirements = Import-PowerShellDataFile -Path "$PSScriptRoot/requirements.psd1"

foreach ($mod in $requirements.RequiredModules) {
    $name = $mod.Name
    $minVersion = $mod.MinimumVersion

    $installed = Get-Module -ListAvailable -Name $name | Where-Object { $_.Version -ge [Version]$minVersion }

    if (-not $installed) {
        Write-Host "Installiere Modul $name (Min.-Version: $minVersion)..."
        Install-Module -Name $name -MinimumVersion $minVersion -Force -Scope CurrentUser
    }
}