param (
    [string]$Command,
    [string[]]$Args
)

Set-Location -Path $PSScriptRoot

. "$PSScriptRoot/preflight/run.ps1"

$initFile = Join-Path $PSScriptRoot "init"
$envPath = Join-Path $PSScriptRoot ".env"

try {
    if (Test-Path $initFile) {
        Set-CliEnv -EnvPath $envPath
        Remove-Item $initFile -ErrorAction SilentlyContinue
        Get-DotEnv -Path $envPath
    }

    $commandsDir = Join-Path $PSScriptRoot "Commands"

    if (-not $Command) {
        Write-Host "Kein Befehl angegeben. Benutzung:`nct <Befehl>`nDann mit der Eingabetaste bestätigen."
        Write-Host "Mit 'ct hilfe' kannst du verfügbare Befehle anzeigen lassen."
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
    $log.Write("Error in ct.ps1 $($_.Exception.Message)")
}
