Add-Type -AssemblyName Microsoft.VisualBasic

$releaseVersion = "__RELEASE_TAG__"
$ReleasesUrl = "__RELEASES_URL__"
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
        $response = Invoke-WebRequest -Uri $ReleasesUrl
        $releases = $response.Content | ConvertFrom-Json
        if ($releases.Count -eq 0) {
            throw "Kein Release gefunden."
        }
        $latestRelease = $releases | Sort-Object { [datetime]$_.published_at } -Descending | Select-Object -First 1
        $assetsResponse = Invoke-WebRequest -Uri $latestRelease.assets_url
        $assets = $assetsResponse.Content | ConvertFrom-Json
        if ($assets.Count -eq 0) {
            throw "Keine Assets für Release $($latestRelease.tag_name) gefunden."
        }
        $cliAsset = $assets | Where-Object { $_.name -eq "ct-cli.zip" }
        if (-not $cliAsset) {
            throw "Die relevanten Dateien wurden nicht in den Release Assets gefunden."
        }
        Invoke-WebRequest -Uri $cliAsset.browser_download_url -OutFile $ZipFile -UseBasicParsing
    } catch {
        throw "ZIP-Datei konnte nicht heruntergeladen werden: $_"
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
RELEASES_URL=$ReleasesUrl
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