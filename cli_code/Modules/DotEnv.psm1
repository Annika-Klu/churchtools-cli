$EnvPath = Join-Path $PWD ".env"

function Get-DotEnv {
    if (-Not (Test-Path $EnvPath)) {
        Throw "File not found: $EnvPath"
    }

    Get-Content $EnvPath | ForEach-Object {
        if ($_ -match '^\s*([^#][\w\.]+)\s*=\s*(.*)$') {
            $name, $value = $matches[1], $matches[2]
            Set-Variable -Name $name -Value $value -Scope Global
        }
    }
}

Export-ModuleMember -Function Get-DotEnv

function Update-DotEnv {
    param(
        [hashtable]$KeyValuePairs
    )

    $envContent = Get-Content $EnvPath
    if (-not $envContent) {
        $envContent = @()
    }

    foreach ($key in $KeyValuePairs.Keys) {
        $value = $KeyValuePairs[$key]

        $found = $false

        for ($i = 0; $i -lt $envContent.Count; $i++) {
            if ($envContent[$i] -match "^\s*$key\s*=") {
                $envContent[$i] = "$key=$value"
                $found = $true
                break
            }
        }

        if (-not $found) {
            $envContent += "$key=$value"
        }
    }

    $envContent | Set-Content -Path $EnvPath -Encoding UTF8
}

Export-ModuleMember -Function Update-DotEnv