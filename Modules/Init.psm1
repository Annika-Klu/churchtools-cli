Import-Module "$PSScriptRoot\DotEnv.psm1"

function Set-ApiUrl {
    do {
        $subdomain = Read-Host "Welche Subdomain hat deine Gemeinde? (z. B. bei 'https://beispielgemeinde.church.tools' gib ein 'beispielgemeinde'.)"
        $churchUrl = "https://$subdomain.church.tools"

        $errorMsg = "Ungültige Eingabe: '$subdomain.church.tools' existiert nicht."

        try {
            $response = Invoke-WebRequest -Uri $churchUrl -TimeoutSec 5 -ErrorAction Stop
            $body = $response.Content
            if ($body -match "Finde deine Gemeinde") {
                Write-Host $errorMsg
                $isValid = $false
            } else {
                Write-Host "Deine Gemeinde: $churchUrl"
                $isValid = $true
            }
        } catch {
            Write-Host $errorMsg
            $isValid = $false
        }

    } until ($isValid)
    return "$churchUrl/api"
}

function Set-ApiToken {
    param(
        [string]$ApiUrl
    )
    do {
        try {
            $token = Read-Host "Bitte gib dein API-Token ein"
            $ct = [ChurchTools]::new($ApiUrl, $token)
            $response = $ct.CallApi("GET", "whoami", $null)
            Write-Host "Authentifiziert als $($response.firstName) $($response.lastName)"
            $isValid = $true
        } catch {
            Write-Host "Das Token ist ungültig. $_"
            $isValid = $false
        }
    } until ($isValid)
    return $token
}

function Set-CliEnv {
    param(
        [string]$EnvPath
    )
    $envVars = @{}
    $envVars["CT_API_URL"] = Set-ApiUrl
    $envVars["CT_API_TOKEN"] = Set-ApiToken -ApiUrl $envVars["CT_API_URL"]
    Update-DotEnv -EnvPath $EnvPath -KeyValuePairs $envVars
}