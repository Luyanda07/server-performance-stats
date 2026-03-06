# server-stats.ps1

Write-Host "==========================" 
Write-Host "  SERVER STATS"
Write-Host "=========================="

# OS & Uptime
Write-Host "`n--- OS & Uptime ---"
(Get-CimInstance Win32_OperatingSystem).Caption
(Get-CimInstance Win32_OperatingSystem).Version
$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
"Uptime: $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
"Logged in users: $((query user 2>$null | Select-Object -Skip 1).Count)"

# CPU
Write-Host "`n--- CPU Usage ---"
$cpu = (Get-CimInstance Win32_Processor).LoadPercentage
"Used: ${cpu}%  Idle: $(100-$cpu)%"

# Memory
Write-Host "`n--- Memory Usage ---"
$os = Get-CimInstance Win32_OperatingSystem
$totalGB = [math]::Round($os.TotalVisibleMemorySize/1MB,1)
$freeGB = [math]::Round($os.FreePhysicalMemory/1MB,1)
$usedGB = $totalGB - $freeGB
$pct = [math]::Round(($usedGB/$totalGB)*100,1)
"Total: ${totalGB}GB  Used: ${usedGB}GB  Free: ${freeGB}GB  Usage: ${pct}%"

# Disk
Write-Host "`n--- Disk Usage ---"
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $total = [math]::Round($_.Size/1GB,1)
    $free = [math]::Round($_.FreeSpace/1GB,1)
    $used = $total - $free
    $pct = [math]::Round(($used/$total)*100,1)
    "$($_.DeviceID)  Size:${total}GB  Used:${used}GB  Free:${free}GB  Use:${pct}%"
}

# Top 5 by CPU
Write-Host "`n--- Top 5 Processes by CPU ---"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 |
    Format-Table Id, @{N='CPU(s)';E={[math]::Round($_.CPU,1)}}, ProcessName -AutoSize

# Top 5 by Memory
Write-Host "`n--- Top 5 Processes by Memory ---"
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 |
    Format-Table Id, @{N='Mem(MB)';E={[math]::Round($_.WorkingSet64/1MB,1)}}, ProcessName -AutoSize

Write-Host "=========================="