param (
    [string]$Command,
    [string[]]$Args
)

. "$PSScriptRoot/installRequirements.ps1"
. "$PSScriptRoot/loadClassesAndModules.ps1"

$envPath = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envPath)) {
    New-Item -Path $envPath -ItemType File -Force | Out-Null
    Set-CliEnv -EnvPath $envPath
}

Get-DotEnv -Path $envPath

$log = [Log]::new("ct")

function Show-Help {
    Write-Host "Verfügbare Befehle:`n"

    Get-ChildItem -Path $commandsDir -Filter *.ps1 | ForEach-Object {
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

    Write-Host "`nBenutzung: meinclient <Befehl> [Argumente]"
}

try {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $commandsDir = Join-Path $scriptDir "Commands"

    if (-not $Command) {
        Write-Host "Kein Befehl angegeben."
        Show-Help
        exit 1
    }

    $subScript = Join-Path $commandsDir "$Command.ps1"

    if (-not (Test-Path $subScript)) {
        Write-Host "Befehl '$Command' wurde nicht gefunden.`n"
        Show-Help
        exit 1
    }

    Write-Host "Starte '$Command' ..."
    & $subScript @($Args)

    exit 0
} catch {
    $log.Write("Error: $_")
}
