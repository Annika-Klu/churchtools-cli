$ct = [ChurchTools]::new($CT_API_URL, $CT_API_TOKEN)

try {
    Write-Host "Angemeldet als $($ct.User.firstName) $($ct.User.lastName)"
    Write-Host "Email: $($ct.User.email)"
} catch {
    $log.Write("Error in hilfe.ps1 $($_.Exception.Message)")
}