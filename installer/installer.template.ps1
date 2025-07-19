Add-Type -AssemblyName Microsoft.VisualBasic

$releaseVersion = "__RELEASE_TAG__"
$ZipUrl = "__UPDATE_URL__"
$ZipFile = "$env:TEMP\ct.zip"
$InstallPath = "$env:USERPROFILE\.ct"
$MainPS1File = Join-Path $InstallPath "ct.ps1"
$CmdShim = Join-Path $env:USERPROFILE "AppData\Local\Microsoft\WindowsApps\ct.cmd"
$EnvFile = Join-Path $InstallPath ".env"

function Check-Compatibility {
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -lt 5) {
        return "PowerShell-Version 5 oder höher erforderlich. Aktuelle Version: $psVersion"
    }

    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    if ([version]$os.Version -lt [version]"10.0.0.0") {
        return "Windows 10 oder höher erforderlich. Aktuelles Betriebssystem: $($os.Version)"
    }
    return "OK"
}

function Get-CLICode {
    try {
        Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile -UseBasicParsing
    } catch {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Fehler beim Herunterladen der ZIP-Datei: $_", "OKOnly,Critical", "Download-Fehler")
        exit 1
    }
    Expand-Archive -Path $ZipFile -DestinationPath $InstallPath -Force
    Remove-Item $ZipFile -Force
}

function Add-InitFlag {
    $DummyFile = Join-Path $InstallPath "init"
    New-Item -ItemType File -Path $DummyFile | Out-Null
}

function Write-EnvFile {
    $content = @"
UPDATE_URL=$ZipUrl
VERSION=$releaseVersion
CT_SUBDOMAIN=__CT_SUBDOMAIN__
"@
    Set-Content -Path $EnvFile -Value $content -Encoding UTF8
}

function Set-CmdShim {
    $shimContent = @"
@echo off
PowerShell -NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$MainPS1File`" %*
"@
    Set-Content -Path $CmdShim -Value $shimContent -Encoding ASCII
}

try {
    $compatibility = Check-Compatibility
    if ($compatibility -ne "OK") {
        [Microsoft.VisualBasic.Interaction]::MsgBox($compatibility, "OKOnly,Critical", "Inkompatible Umgebung.")
        exit 1
    }

    if (!(Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath | Out-Null
    }

    Get-CLICode
    Add-InitFlag
    if (!(Test-Path $MainPS1File)) {
        [Microsoft.VisualBasic.Interaction]::MsgBox("Fehler: Die Haupt-Skriptdatei wurde nicht gefunden.", "OKOnly,Critical", "Datei nicht gefunden")
        exit 1
    }
    Write-EnvFile
    Set-CmdShim

    [Microsoft.VisualBasic.Interaction]::MsgBox(
        "ChurchTools CLI wurde erfolgreich installiert.`n`nDu kannst jetzt in PowerShell den Befehl `ct hilfe` verwenden.",
        "OKOnly,Information",
        "Installation abgeschlossen"
    )
} catch {
    [Microsoft.VisualBasic.Interaction]::MsgBox("Fehler bei der Installation: $_", "OKOnly,Critical", "Fehler")
    exit 1
}