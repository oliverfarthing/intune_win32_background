# Detection script for Intune
$FilePath = "C:\Windows\backgroundmain_sync.ps1"

if (Test-Path $FilePath) {
    Write-Output "File exists: $FilePath"
    exit 0
} else {
    Write-Output "File does not exist: $FilePath"
    exit 1
}
