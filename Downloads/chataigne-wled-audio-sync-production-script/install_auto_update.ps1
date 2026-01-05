
# install.ps1 with auto-update detection
$localVersion = "1.0.0"
$remoteUrl = "https://raw.githubusercontent.com/Crosby121/chataigne-wled-audio-sync-production-script/main/install.ps1"
$logPath = "C:\production_backup\install_log.txt"
$versionLogPath = "C:\production_backup\version.txt"

# Function to compare versions
function IsNewerVersion($remote, $local) {
    $r = [Version]$remote
    $l = [Version]$local
    return $r -gt $l
}

# Attempt to download and extract version info from remote script
try {
    $remoteScript = Invoke-WebRequest -Uri $remoteUrl -UseBasicParsing -ErrorAction Stop
    if ($remoteScript.Content -match '\$localVersion\s*=\s*\"([0-9.]+)\"') {
        $remoteVersion = $matches[1]
        Write-Output "Remote script version: $remoteVersion"
        Write-Output "Local script version: $localVersion"

        if (IsNewerVersion $remoteVersion $localVersion) {
            Write-Output "Newer version found. Updating..."
            Invoke-WebRequest -Uri $remoteUrl -OutFile "$PSScriptRoot\install.ps1" -UseBasicParsing -ErrorAction Stop
            & "$PSScriptRoot\install.ps1"
            Exit
        }
    }
} catch {
    Write-Warning "Could not fetch or parse remote script. Continuing with local copy."
}

# Skip if already installed
if (Test-Path $logPath) {
    Write-Output "Setup has already been completed. Skipping..."
    Exit
}

Write-Output "Starting full WLED + Chataigne sync setup..."

# Simulate install actions
Start-Sleep -Seconds 2

# Finalize
if (!(Test-Path "C:\production_backup")) {
    New-Item -Path "C:\production_backup" -ItemType Directory
}
"Setup completed at $(Get-Date)" | Out-File -FilePath $logPath -Encoding UTF8
$localVersion | Out-File -FilePath $versionLogPath -Encoding UTF8
