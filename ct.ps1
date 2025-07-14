param (
    [string]$Command,
    [string[]]$Args
)

$minVersion = [Version]"5.1"

if ($PSVersionTable.PSVersion -lt $minVersion) {
    Write-Warning "Warnung: Deine PowerShell-Version ist $($PSVersionTable.PSVersion). Für dieses CLI wird mindestens Version $minVersion empfohlen."
}

. "$PSScriptRoot/installRequirements.ps1"
. "$PSScriptRoot/loadClassesAndModules.ps1"

$log = [Log]::new("ct")
try {
    [Console]::OutputEncoding = [Text.UTF8Encoding]::new()
    [Console]::InputEncoding = [Text.UTF8Encoding]::new()
} catch {
    log.Write("UTF-8 encoding could not be set: $_")
}

$envPath = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envPath)) {
    New-Item -Path $envPath -ItemType File -Force | Out-Null
    Set-CliEnv -EnvPath $envPath
}

Get-DotEnv -Path $envPath

try {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $commandsDir = Join-Path $scriptDir "Commands"

    if (-not $Command) {
        Write-Host "Kein Befehl angegeben. Benutzung:`nct <Befehl>`nDann mit der Eingabetaste bestätigen."
        Write-Host "Mit 'ct hilfe' kannst du verfügbare Befehle anzeigen lassen."
        Show-Help
        exit 1
    }

    $subScript = Get-ChildItem -Path $commandsDir -Filter "$Command.ps1" -Recurse | Select-Object -First 1
    if ($subScript) {
        $allowedCommands = Get-AllowedCommands
        $ct = [ChurchTools]::new($CT_API_URL, $CT_API_TOKEN)
        if ($allowedCommands.FullName -notcontains $subScript.FullName) {
            Write-Host "Du bist nicht berechtigt, diesen Befehl auszuführen."
            throw "User $($ct.User.email) is not allowed to run command '$Command'."
        }
        . $subScript.FullName @($Args)
    } else {
        Write-Host "Befehl '$Command' wurde nicht gefunden.`n"
        Show-Help
        exit 1
    }

    exit 0
} catch {
    $log.Write("Error: $_")
}
