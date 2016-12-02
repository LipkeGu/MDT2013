Param (
# Enable Memory Manager Agent 
[int] $enable = 0
)

if ($enable -eq 1)
{
    Write-Host "MMAgent: Enabled"

    Enable-MMAgent -PageCombining
    Enable-MMAgent -MemoryCompression
}
else
{
    Write-Host "MMAgent: Disabled"

    Disable-MMAgent -PageCombining
    Disable-MMAgent -MemoryCompression
}
