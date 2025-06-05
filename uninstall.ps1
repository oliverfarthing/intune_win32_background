# Variables
$taskName = "backgroundmain_sync"
$scriptPath = "C:\Windows\backgroundmain_sync.ps1"
$desktopImage = "C:\WINDOWS\Personalization\DesktopImage\DesktopImage_blVUKUE0kcvVOTIQ7MIA.jpg"
$lockScreenImage = "C:\WINDOWS\Personalization\LockScreenImage\LockScreenImage Uj9r7BDAHkaEMNZjlrxhjg.jpg"
$desktopDir = Split-Path $desktopImage
$lockScreenDir = Split-Path $lockScreenImage

# 1. Delete image files
Remove-Item -Path $desktopImage, $lockScreenImage -ErrorAction SilentlyContinue

# Optionally delete folders if empty
if ((Test-Path $desktopDir) -and ((Get-ChildItem $desktopDir).Count -eq 0)) {
    Remove-Item -Path $desktopDir -Force
}
if ((Test-Path $lockScreenDir) -and ((Get-ChildItem $lockScreenDir).Count -eq 0)) {
    Remove-Item -Path $lockScreenDir -Force
}

# 2. Delete scheduled task
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

# 3. Delete the PowerShell script
Remove-Item -Path $scriptPath -Force -ErrorAction SilentlyContinue

Write-Host "Cleanup complete. All changes undone."

# Variables
$scriptName = "backgroundmain_uninstall.ps1"
$scriptPath = "C:\Windows\$scriptName"
$taskName = "TempScheduledTask"

# 1. Create the PowerShell script file
$scriptContent = @"
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP") {
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" -Recurse -Force
}
"@

Set-Content -Path $scriptPath -Value $scriptContent -Force

# 2. Register the scheduled task to run the script
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)  # Scheduled 1 minute from now
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force

# 3. Run the scheduled task immediately
Start-ScheduledTask -TaskName $taskName

# Wait for task to finish (simple wait, adjust as needed)
Start-Sleep -Seconds 10

# 4. Cleanup: delete the task and script
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
Remove-Item -Path $scriptPath -Force