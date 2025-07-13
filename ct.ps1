param (
    #[Parameter(Mandatory = $true)]
    [string]$Command,
    [string[]]$Args
)

. "$PSScriptRoot/installRequirements.ps1"
. "$PSScriptRoot/loadClassesAndModules.ps1"

$envPath = Join-Path $PSScriptRoot ".env"
Get-DotEnv -Path $envPath

function Show-Help {
    Write-Host "Verfügbare Befehle:`n"

    Get-ChildItem -Path $commandsDir -Filter *.ps1 | ForEach-Object {
        $name = $_.BaseName
        $descFile = $_.FullName -replace '\.ps1$', '.md'

        if (Test-Path $descFile) {
            $desc = Get-Content $descFile -Raw
            $firstLine = $desc -split "`n" | Select-Object -First 1
        } else {
            $firstLine = "(Keine Beschreibung)"
        }

        Write-Host ("- {0}`t{1}" -f $name, $firstLine)
    }

    Write-Host "`nBenutzung: meinclient <Befehl> [Argumente]"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$commandsDir = Join-Path $scriptDir 'Commands'

if (-not $Command) {
    Write-Host "❌ Kein Befehl angegeben."
    Show-Help
    exit 1
}

$subScript = Join-Path $commandsDir "$Command.ps1"

if (-not (Test-Path $subScript)) {
    Write-Host "❌ Befehl '$Command' wurde nicht gefunden.`n"
    Show-Help
    exit 1
}

Write-Host "➡️  Starte '$Command' ..."
& $subScript @($Args)

exit 0
