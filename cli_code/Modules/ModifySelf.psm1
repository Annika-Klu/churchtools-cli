function Invoke-UpdateBootstrap {
    param(
        [string]$InstallPath
    )
    $TempDir = Join-Path $env:TEMP "ct-update"
    Remove-Item -Recurse -Force -Path $TempDir -ErrorAction SilentlyContinue

    $KeepFilesDir = Join-Path $TempDir "keep"
    New-Item -ItemType Directory -Path $KeepFilesDir | Out-Null
    Out-Message "Sichere Dateien..."
    $KeepFiles = @(".env", ".usercache.json")
    foreach ($file in $KeepFiles) {
        $originalPath = Join-Path $InstallPath $file
        if (Test-Path $originalPath) {
            Copy-Item -Path $originalPath -Destination $KeepFilesDir -Force
        }
    }

    Out-Message "Lade neuen CLI-Code herunter..."
    $latestRelease = Get-LatestRelease -ReleasesUrl $RELEASES_URL
    $cliCode = Get-ReleaseAsset -Release $latestRelease -AssetName "ct-cli.zip"
    $NewCodeZipFile = Join-Path $TempDir "ct-cli.zip"
    Invoke-WebRequest -Uri $cliCode.browser_download_url -OutFile $NewCodeZipFile -UseBasicParsing -Headers $GitHubHeaders
    Out-Message "Bereite Update-Skript vor..."
    $TempUpdateFilePath = Join-Path $TempDir "update.ps1"
    $FunctionContent = (Get-Command 'Register-UpdateWorker').Definition
    $FunctionContent | Out-File $TempUpdateFilePath

    return $TempUpdateFilePath
}

function Register-UpdateWorker {
    param(
        [string]$InstallPath
    )
    Add-Type -AssemblyName Microsoft.VisualBasic
    try {
        Write-Host "Extrahiere neuen Code ins Zielverzeichnis..."
        Expand-Archive -Path (Join-Path $PSScriptRoot "ct-cli.zip") -DestinationPath $InstallPath -Force
        Write-Host "Stelle gesicherte Dateien wieder her..."
        $KeepDir = Join-Path $PWD "keep"
        if (Test-Path $KeepDir) {
            Move-Item -Path "$KeepDir/*" -Destination $InstallPath -Force
        }
        Write-Host "Update erfolgreich abgeschlossen. Die Befehle sind wieder wie gewohnt verfügbar." -ForegroundColor Green
        $SelfPath = $MyInvocation.MyCommand.Definition
        Remove-Item -Path $SelfPath -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

Export-ModuleMember -Function Invoke-UpdateBootstrap, Register-UpdateWorker