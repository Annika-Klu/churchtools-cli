$ErrorActionPreference = "Stop"

$requirements = Import-PowerShellDataFile -Path "$PWD/requirements.psd1"

foreach ($mod in $requirements.RequiredModules) {
    $name = $mod.Name
    $minVersion = $mod.MinimumVersion

    $installed = Get-Module -ListAvailable -Name $name | Where-Object { $_.Version -ge [Version]$minVersion }

    if (-not $installed) {
        Out-Message "Installiere Modul $name ($($mod.Description))..."
        Install-Module -Name $name -MinimumVersion $minVersion -Force -Scope CurrentUser
    }
}