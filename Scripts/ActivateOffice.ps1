param (
    # Office<$Version>: -version 16
    [string] $version = "16",
    # KMS Server address: -server <kms_server>
    [string] $server = "10.0.0.1",
    # KMS Server port: -port <kms-server port>
    [string] $port = "1688",
    # Office Product Key
    [string] $pkey = ""

)

function _run {
    Param(
    [string] $ospp_args = ""
    )

    $ps = new-object System.Diagnostics.Process
    $ps.StartInfo.Filename = "C:\Windows\system32\cscript.exe"
    $ps.StartInfo.Arguments = '"' + $office_install_path + '"' + ' ' + $ospp_args
    $ps.StartInfo.RedirectStandardOutput = $True
    $ps.StartInfo.UseShellExecute = $false
    $ps.StartInfo.CreateNoWindow = $True
    $ps.start()
    $ps.WaitForExit()

    [string] $output = $ps.StandardOutput.ReadToEnd()

    if ($output.Contains("ERROR CODE: 0x80070005"))
    {
        Write-Host "ERROR CODE: 0x80070005 - Permission denied"
        return -1
    }

    if ($output.Contains("ERROR CODE: 0xC004F074"))
    {
        Write-Host "ERROR CODE: 0xC004F074 - No Key Management Sevice (KMS) could be contacted."
        return -1
    }

    if ($output.Contains("ERROR CODE: 0xC004F050"))
    {
        Write-Host "ERROR CODE: 0xC004F050 - The product key is invalid."
        return -1
    }
    
    if ($output.Contains("<Product activation successful>"))
    {
        Write-Host "<Product activation successful>"
        return 0
    }
    
    if ($output.Contains("<Successfully applied setting.>"))
    { 
        Write-Host "Successfully applied setting."
        return 0
    }

    # It seems something was wrong
    return -1
}

# Handle /sethst command
function Set-Server {
    Param()
    if (_run "/sethst:$server" -eq 0) {
        return 0
    }
    else
    {
        return -1
    }
}

# Handle /setprt command
function Set-Serverport {
    Param()
    if (_run "/setprt:$port" -eq 0) {
        return 0
    }
    else
    {
        return -1
    }
}

# Handle /inpkey command
function Set-Product-Key {
    Param()
    if (_run "/inpkey:$pkey" -eq 0) {
        return 0
    }
    else
    {
        return -1
    }
}

#Handle /act command
function Activate {
    param()
    
    Write-Host "Activating Office $version against $server on port $port..."
    if (_run "/act" -eq 0) {}
}

# Get the path where Office is installed
[string] $office_install_path = ""
Try
{
    if ([Environment]::Is64BitOperatingSystem) {
        $office_install_path = (get-item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\$version.0\Common\InstallRoot").GetValue("Path") + "ospp.vbs"
    }
    else
    {
        $office_install_path = (get-item "HKLM:\SOFTWARE\Microsoft\Office\$version.0\Common\InstallRoot").GetValue("Path") + "ospp.vbs"
    }

    [object] $retval = -1

    if ($pkey -ne "")
    {
        $retval = Set-Product-Key
    }
    else
    {
        if ($port -ne "1688")
        {
            $retval = Set-Serverport
        }
    
        $retval = Set-Server
        $retval = Activate
    }
}
Catch [System.Management.Automation.ItemNotFoundException]
{
    Write-Host "Something was wrong!"
}
