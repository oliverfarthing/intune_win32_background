# Create download script configuration
$sourceUrl = "https://stdevicedeployment.blob.core.windows.net/clientresources/backgroundmain.jpg"
$DesktopImagePath = "C:\WINDOWS\Personalization\DesktopImage\DesktopImage_blVUKUE0kcvVOTIQ7MIA.jpg"
$LockScreenImagePath = "C:\WINDOWS\Personalization\LockScreenImage\LockScreenImage Uj9r7BDAHkaEMNZjlrxhjg.jpg"
$taskName = "backgroundmain_sync"
$scriptPath = "C:\Windows\backgroundmain_sync.ps1"
$runTime = "2:00PM"

# Ensure script directory exists
$scriptFolder = Split-Path $scriptPath
If (!(Test-Path $scriptFolder)) {
    New-Item -ItemType Directory -Path $scriptFolder -Force
}

# Create download script
$downloadScript = @"
# Download background images
`$sourceUrl = '$sourceUrl'
`$desktopPath = '$DesktopImagePath'
`$lockScreenPath = '$LockScreenImagePath'

foreach (`$destinationPath in @(`$desktopPath, `$lockScreenPath)) {
    `$dir = Split-Path `$destinationPath
    if (!(Test-Path `$dir)) {
        New-Item -ItemType Directory -Path `$dir -Force
    }

    Invoke-WebRequest -Uri `$sourceUrl -OutFile `$destinationPath -UseBasicParsing

    Write-Output "Download complete: `$destinationPath"
}

if (-not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP")) {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "PersonalizationCSP" -Force | Out-Null
}

New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImagePath" -Value "C:\WINDOWS\Personalization\LockScreenImage\LockScreenImage Uj9r7BDAHkaEMNZjlrxhjg.jpg" -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImageStatus" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "LockScreenImageUrl" -Value "https://stdevicedeployment.blob.core.windows.net/clientresources/backgroundmain.jpg" -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "DesktopImageStatus" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "DesktopImagePath" -Value "C:\WINDOWS\Personalization\DesktopImage\DesktopImage_blVUKUE0kcvVOTIQ7MIA.jpg" -PropertyType String -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Name "DesktopImageUrl" -Value "https://stdevicedeployment.blob.core.windows.net/clientresources/backgroundmain.jpg" -PropertyType String -Force
"@

Set-Content -Path $scriptPath -Value $downloadScript -Encoding UTF8

# Create Scheduled Task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At $runTime
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description "Downloads the background images daily"

Start-ScheduledTask -TaskName $taskName