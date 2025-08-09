class ChurchTools {
    [string]$BaseUrl
    [object]$Headers
    [pscustomobject]$User
    [string]$CachePath

    ChurchTools([string]$apiUrl) {
        $this.BaseUrl = $apiUrl
        $tokenPath = Join-Path $PWD "ctlogintoken.sec"
        $token = Get-EncryptedToken -Path $tokenPath -AsPlainText
        $this.Headers = @{ Authorization = "Login $($token)" }
        $this.CachePath = "$PSScriptRoot\..\.usercache.json"
        $this.LoadUserData()
    }

    [object] CallApi([string]$Method, [string]$Path, [object]$Body, [string]$OutFile) {
        if ($Path -match '^https?://') {
            $uri = $Path
        } else {
            $uri = "$($this.BaseUrl)/$Path"
        }

        $params = @{
            Method      = $Method
            Uri         = $uri
            Headers     = $this.Headers
            ErrorAction = 'Stop'
        }

        if ($Body -ne $null) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            $params['Body'] = $jsonBody
            $params['ContentType'] = 'application/json'
        }

        if ($OutFile) {
            $params['OutFile'] = $OutFile
            Invoke-WebRequest @params
            return $OutFile
        } else {
            $response = Invoke-WebRequest @params
            $json = $response.Content | ConvertFrom-Json
            return $json.data
        }
    }

    [void] LoadUserData() {
        if (Test-Path -Path $this.CachePath) {
            $this.User = Get-Content $this.CachePath -Raw | ConvertFrom-Json
        } else {
            try {
                Out-Message "Lade Nutzerdaten..."
                $userData = $this.CallApi("GET", "whoami", $null, $null)
                $groups = $this.CallApi("GET", "persons/$($userData.id)/groups", $null, $null)
                $this.User = [PSCustomObject]@{
                    firstName   = $userData.firstName
                    lastName = $userData.lastName
                    email  = $userData.email
                    groups = $groups | ForEach-Object { $_.group.domainIdentifier }
                }
                $this.CacheUserData()
            } catch {
                Write-Warning "Nutzerdaten konnten nicht abgefragt werden."
                throw "Could not load user data: $_"
            }
        }
    }

    [void] CacheUserData() {
        $this.User | ConvertTo-Json | Set-Content -Path $this.CachePath
    }

    [bool] UserHasAccess([string[]]$allowedGroups) {
        if (-not $this.User -or -not $this.User.groups) {
            return $false
        }
        foreach ($group in $AllowedGroups) {
            if ($this.User.Groups -contains $group) {
                return $true
            }
        }
        return $false
    }
}
