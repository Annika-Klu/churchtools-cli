Add-Type -AssemblyName System.Windows.Forms

$ZipUrl = "__ZIP_URL__"
$ZipFile = "$env:TEMP/ct.zip"

$InstallPath = "$env:USERPROFILE\.ct"

function Get-CLICode {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile -UseBasicParsing
    Expand-Archive -Path $ZipFile -DestinationPath $InstallPath -Force
    Remove-Item $ZipFile
}

function Add-InstallPath {
    $oldPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    if ($oldPath -notlike "*$InstallPath*") {
        $newPath = "$oldPath;$InstallPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
    }
}

function Get-Form {
    param(
        [string]$InitText
    )
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "CLI Installer"
    $form.Size = New-Object System.Drawing.Size(400,200)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(380,80)
    $label.Text = $InitText
    $form.Controls.Add($label)
    $form.Tag = @{ Label = $label }
    return $form
}

function Set-FormText {
    param(
        [System.Windows.Forms.Form]$Form,
        [string]$NewText
    )
    $Form.Tag.Label.Text = $NewText
    [System.Windows.Forms.Application]::DoEvents()
}

$progressForm = Get-Form -InitText "Starte Installation..."
$progressForm.Show()
$modalForm = Get-Form -InitText ""

function Check-Compatibility {
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -lt 5) {
        return "PowerShell-Version 5 oder höher erfoderlich. Aktuelle Version: $psVersion"
    }
    $osVersion = [System.Environment]::OSVersion.Version

    if ($osVersion.Major -lt 10) {
        return "Windows 10 oder höher erfoderlich. Aktuelles Betriebssystem: $($osVersion.ToString())"
    }
    return "OK"
}

try {
    $compatibilityInfo = Check-Compatibility
    if ($compatibilityInfo -notlike "OK") {
        $progressForm.Close()
        Set-FormText -Form $modalForm -NewText $compatibilityInfo
        $modalForm.ShowDialog()
        exit 0
    }

    if (!(Test-Path -Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath | Out-Null
    }

    Set-FormText -Form $progressForm -NewText "Dateien werden heruntergeladen..."
    Get-CLICode

    Set-FormText -Form $progressForm -NewText  "Pfad wird zu Umgebungsvariablen hinzugefügt..."
    Add-InstallPath
    $progressForm.Close()

    Set-FormText -Form $modalForm -NewText "Fertig! Das CLI ist einsatzbereit.`nÖffne Windows PowerShell und tippe ein: 'ct hilfe',`num verfügbare Befehle zu sehen.`nMöglicherweise musst du dich neu anmelden oder PowerShell neu öffnen, damit der Befehl 'ct' erkannt wird."
    $modalForm.ShowDialog()
} catch {
    Set-FormText -Form $modalForm -NewText "Leider ist ein Fehler aufgetreten: $_"
    $modalForm.ShowDialog()
}