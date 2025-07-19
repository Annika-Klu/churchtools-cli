try {
    Show-Help
} catch {
    $log.Write("Error: $($_.Exception.Message)")
}