function Out-Message {
    param (
        [string]$Message,
        [ValidateSet('info', 'warning', 'error', 'debug')]
        [string]$Type = 'info'
    )

    switch ($Type) {
        'warning' {
            Write-Host $Message -ForegroundColor Yellow
        }
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
        [ValidateSet('info', 'warning', 'error', 'debug')]
        [string]$Type = 'info'
    )
    Write-Host ""

    $width = $Host.UI.RawUI.WindowSize.Width
    $Message = ("_" * $width)
    switch ($Type) {
        'warning' {
            Write-Host $Message -ForegroundColor Yellow
        }
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
