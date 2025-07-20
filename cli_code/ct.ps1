param (
    [string]$Command,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AdditionalArgs
)

Set-Location -Path $PSScriptRoot

. "$PSScriptRoot/preflight/run.ps1"

$initFile = Join-Path $PSScriptRoot "init"
$envPath = Join-Path $PSScriptRoot ".env"

function Use-MentionHelp {
    Write-Host "Mit 'ct hilfe' kannst du eine Liste aller Befehle anzeigen lassen."  -ForegroundColor Blue
}

try {
    if (Test-Path $initFile) {
        Set-CliEnv -EnvPath $envPath
        Remove-Item $initFile -ErrorAction SilentlyContinue
        Get-DotEnv -Path $envPath
    }

    if (-not $Command) {
        Write-Host "Bitte Befehl eingeben und mit der Eingabetaste bestätigen." -ForegroundColor Blue
        Use-MentionHelp
        exit 1
    }

    $args = @{}
    if ($AdditionalArgs.Count -gt 0) {
        $argsStr = $AdditionalArgs -join " "
        $args = Get-ParsedArgs -ArgsStr $argsStr
    }

    if ($args.Flags.debug) {
        Write-Host "Subcommands: $($args.Subcommands -join ', ')"
        Write-Host "Arguments: $($args.Arguments | Out-String)"
        Write-Host "Flags: $($args.Flags | Out-String)"
    }
    
    $commandsDir = Join-Path $PSScriptRoot "Commands"
    $commandPath = Get-CommandPath -CommandsDir $commandsDir -Command $Command -SubCommands $args.Subcommands
    if (-not $commandPath) {
        Write-Host "'$Command $AdditionalArgs' ist kein gültiger Befehl." -ForegroundColor Blue
        Use-MentionHelp
        exit 1
    }

    $allowedCommands = Get-AllowedCommands
    $ct = [ChurchTools]::new($CT_API_URL, $CT_API_TOKEN)

    if ($allowedCommands.FullName -notcontains $commandPath) {
        Write-Host "Du bist nicht berechtigt, diesen Befehl auszuführen." -ForegroundColor Red
        throw "User $($ct.User.email) is not allowed to run command '$Command'."
    }
    . $commandPath @($AdditionalArgs)

    exit 0
} catch {
    Write-Host $_ -ForegroundColor Red
    $log.Write("Error in ct.ps1 $($_.Exception.Message)")
}
