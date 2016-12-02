param(
[int] $mode = 0,
[string] $name = "", 
[int] $remove = 0
)

if ($name -ne "")
{
    if ($mode -eq 1) 
    {
        Write-Host "Activating Feature: $name"
        Enable-WindowsOptionalFeature -Online -FeatureName "$name" -All -NoRestart
    }
    else
    {
        if ($remove -eq 1)
        {
            Write-Host "Removing Feature: $name"
            Disable-WindowsOptionalFeature -Online -FeatureName "$name" -NoRestart -Remove
        }
        else
        {
            Write-Host "Disabling Feature: $name"
            Disable-WindowsOptionalFeature -Online -FeatureName "$name" -NoRestart
        }
    }
}
else
{
    Write-Host "Please enter a name!" 
}