try {
    $version = $VERSION
    $latestRelease = Get-LatestRelease -ReleasesUrl $RELEASES_URL
    if ($version -eq $latestRelease.tag_name) {
        Out-Message "BGH-CLI ist aktuell ($VERSION)"
    } else {
        $newEnvVar = @{ "VERSION" = $latestRelease.tag_name }
        Update-Dotenv -KeyValuePairs $newEnvVar
        $TempUpdateFilePath = Invoke-UpdateBootstrap -InstallPath $PWD
        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -NoExit -File `"$TempUpdateFilePath`" -InstallPath `"$PWD`""
        Out-Message "Update vorbereitet."
        exit 0
    }
} catch {
    $log.Write("ERROR in update.ps1 $($_.Exception.Message)")
}
