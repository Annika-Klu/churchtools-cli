$classesPath = Join-Path $PSScriptRoot 'Classes'
Get-ChildItem -Path $classesPath -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

$modulesPath = Join-Path $PSScriptRoot 'Modules'
Get-ChildItem -Path $modulesPath -Filter *.psm1 -Recurse | ForEach-Object {
    Import-Module $_.FullName -Force
}

Get-DotEnv -Path ".env"
$log = [Log]::new("progress", $LOGS_DIR)

try {
    $log.Write("Let's log this message!")
} catch {
    $log.Write("X Error $_")
}