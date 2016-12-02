Param (
# Enable Cortana 
[int] $enable = 1,

# Allow Cortana to use my location
[int] $position = 1,

# Enable Cortana on the lock screen
[int] $lockscreen = 1
)

[string] $registyPath = "HKLM:\Software\Policies\Microsoft\Windows\Windows Search"

if (!(Test-Path $registyPath)) {
    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows" -Name "Windows Search" -Force | Out-Null
}

New-ItemProperty -Path $registyPath -Name AllowCortana -Value $enable -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $registyPath -Name AllowCortanaAboveLock -Value $lockscreen -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $registyPath -Name AllowSearchToUseLocation -Value $position -PropertyType DWORD -Force | Out-Null
if ($enable -eq 1) {
    Write-Host "Cortana enabeled!"
}
else {
    Write-Host "Cortana disabled!"
}
