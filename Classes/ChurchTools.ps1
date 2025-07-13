class ChurchTools {
    [string]$BaseUrl
    [object]$Headers
    [pscustomobject]$User
    [string]$CachePath

    ChurchTools([string]$baseUrl, [string]$token) {
        $this.BaseUrl = $baseUrl.TrimEnd("/")
        $this.Headers = @{ Authorization = "Login $($token)" }
        $this.CachePath = "$PSScriptRoot\..\.usercache.json"
        $this.LoadUserData()
    }

    [void] LoadUserData() {
        if (Test-Path -Path $this.CachePath) {
            $this.User = Get-Content $this.CachePath -Raw | ConvertFrom-Json
        } else {
            try {
                $userData = $this.CallApi("GET", "whoami", $null)
                $groups = $this.CallApi("GET", "persons/$($userData.id)/groups", $null)
                $this.User = [PSCustomObject]@{
                    firstName   = $userData.firstName
                    lastName = $userData.lastName
                    email  = $userData.email
                    groups = $groups.data | ForEach-Object { $_.id }
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

    [object] CallApi([string]$Method, [string]$Path, [string]$OutFile) {
        if ($Path -match '^https?://') {
            $uri = $Path
        } else {
            $uri = "$($this.BaseUrl)/$Path"
        }

        if ($OutFile) {
            Invoke-WebRequest -Method $Method -Uri $uri -Headers $this.Headers -OutFile $OutFile -ErrorAction Stop
            return $Outfile
        } else {
            $response = Invoke-WebRequest -Method $Method -Uri $uri -Headers $this.Headers -ErrorAction Stop
            $json = $response.Content | ConvertFrom-Json
            return $json.data
        }
    }
}
