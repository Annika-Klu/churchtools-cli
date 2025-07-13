$classesPath = Join-Path $PSScriptRoot 'Classes'
Get-ChildItem -Path $classesPath -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

$modulesPath = Join-Path $PSScriptRoot 'Modules'
Get-ChildItem -Path $modulesPath -Filter *.psm1 -Recurse | ForEach-Object {
    Import-Module $_.FullName -Force
}