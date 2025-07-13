$ct = [ChurchTools]::new($CT_API_URL, $CT_API_TOKEN)
$log = [Log]::new("wer-bin-ich")

try {
    Write-Host "Angemeldet als $($ct.User.firstName) $($ct.User.lastName)"
    Write-Host "Email: $($ct.User.email)"
} catch {
    $log.Write("Error: $_")
}