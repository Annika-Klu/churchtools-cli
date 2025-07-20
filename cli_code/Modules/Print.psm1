function Out-Message {
    param (
        [string]$Message,
        [ValidateSet('info', 'error', 'debug')]
        [string]$Type = 'info'
    )

    switch ($Type) {
        'info' {
            Write-Host $Message -ForegroundColor Green
        }
        'error' {
            Write-Host $Message -ForegroundColor Red
        }
        'debug' {
            Write-Host $Message -ForegroundColor White
        }
    }
}

function Out-Line {
        param (
        [ValidateSet('info', 'error', 'debug')]
        [string]$Type = 'info'
    )
    Write-Host ""

    $width = $Host.UI.RawUI.WindowSize.Width
    $Message = ("_" * $width)
    switch ($Type) {
        'info' {
            Write-Host $Message -ForegroundColor Green
        }
        'error' {
            Write-Host $Message -ForegroundColor Red
        }
        'debug' {
            Write-Host $Message -ForegroundColor White
        }
    }
    Write-Host ""
}

Export-ModuleMember -Function Out-Message, Out-Line