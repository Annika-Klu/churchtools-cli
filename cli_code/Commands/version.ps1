try {
    Out-Message $VERSION
} catch {
    $log.Write("ERROR in version.ps1 $($_.Exception.Message)")
}