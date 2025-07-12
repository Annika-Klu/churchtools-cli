function Get-DotEnv {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-Not (Test-Path $Path)) {
        Throw "File not found: $Path"
    }

    Get-Content $Path | ForEach-Object {
        if ($_ -match '^\s*([^#][\w\.]+)\s*=\s*(.*)$') {
            $name, $value = $matches[1], $matches[2]
            Set-Variable -Name $name -Value $value -Scope Global
        }
    }
}

Export-ModuleMember -Function Get-DotEnv
