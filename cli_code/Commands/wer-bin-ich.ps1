$ct = [ChurchTools]::new($CT_API_URL, $CT_API_TOKEN)

try {
    Out-Message "Angemeldet als $($ct.User.firstName) $($ct.User.lastName)"
    Out-Message "Email: $($ct.User.email)"
} catch {
    $log.Write("Error in hilfe.ps1 $($_.Exception.Message)")
}