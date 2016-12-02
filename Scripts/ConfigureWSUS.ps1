Param (
# Enable WSUS 
[int] $enable = 1,

# WSUS Server address
[string] $server = "http://localhost:8530",

# WSUS Server group
[string] $group = "AUTO"
)

[string] $registyPath = "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
[string] $verstring = (Get-CimInstance Win32_OperatingSystem).Version
[string[]] $parts = $verstring.Split(".")

if ($group -eq "AUTO") {
    if ($parts[0] -eq "10" -and $parts[1] -eq "0")
    {
        $group = "WIN10"
    }

    if ($parts[0] -eq "6" -And $parts[1] -eq "3")
    {
        $group = "WIN81"
    }

    if ($parts[0] -eq "6" -And $parts[1] -eq "1")
    {
        $group = "WIN7"
    }

    if ($parts[0] -eq "6" -And $parts[1] -eq "0")
    {
        $group = "VISTA"
    }
}

if ($group -ne "AUTO" -and $server -ne "") {
    Write-Host "WSUS Group: $group"
    Write-Host "WSUS Server: $server"

    # Create the Key...
    if (!(Test-Path $registyPath)) {
        New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows" -Name "WindowsUpdate" -Force | Out-Null
        New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "AU" -Force | Out-Null
    }

    New-ItemProperty -Path $registyPath -Name UseWUServer -Value $enable -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $registyPath -Name TargetGroupEnabled -Value 1 -PropertyType DWORD -Force | Out-Null

    New-ItemProperty -Path $registyPath -Name WUServer -Value $server -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registyPath -Name WUStatusServer -Value $server -PropertyType String -Force | Out-Null
    New-ItemProperty -Path $registyPath -Name TargetGroup -Value $group -PropertyType String -Force | Out-Null

    if ($enable -eq 1) {
        Write-Host "WSUS Mode enabled!"
    }
    else {
        Write-Host "WSUS Mode disabled!"
    }
}
