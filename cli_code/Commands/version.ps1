try {
    Out-Message $VERSION
} catch {
    $log.Write("Error in version.ps1 $($_.Exception.Message)")
}