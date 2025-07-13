class ChurchTools {
    [string]$BaseUrl
    [object]$Headers
    [pscustomobject]$User

    ChurchTools([string]$baseUrl, [string]$token) {
        $this.BaseUrl = $baseUrl.TrimEnd("/")
        $this.Headers = @{ Authorization = "Login $($token)" }
        $this.User = $this.CallApi("GET", "whoami", $null)
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
