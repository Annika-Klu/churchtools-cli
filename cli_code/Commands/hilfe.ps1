try {
    Show-Help
} catch {
    $log.Write("Error in hilfe.ps1 $($_.Exception.Message)")
}