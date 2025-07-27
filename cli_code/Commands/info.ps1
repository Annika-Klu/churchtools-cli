$ct = [ChurchTools]::new($CT_API_URL, $CT_API_TOKEN)

try {
    Out-Line
    Out-Message "CLI-Version $VERSION"
    Out-Message "Angemeldet als $($ct.User.firstName) $($ct.User.lastName)"
    Out-Message "Email: $($ct.User.email)"
    Out-Line
} catch {
    $log.Write("ERROR in info.ps1 $($_.Exception.Message)")
}