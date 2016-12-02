Param (
    [string] $name = [string]::Empty,
    [string] $group = [string]::Empty
)

if ($name -ne [string]::Empty -and $group -ne [string]::Empty)
{
   Try
   {
        New-LocalUser -AccountNeverExpires -Name $name -NoPassword -ErrorAction Stop | Out-Null
        Add-LocalGroupMember -Group $group -Member $name -ErrorAction Stop | Out-Null
   }
   Catch [Microsoft.PowerShell.Commands.UserExistsException] {
        Write-Output "User $name already Exists!"
   }
   Catch [Microsoft.PowerShell.Commands.MemberExistsException] {
        Write-Output "User $name already in group $group."
   }
}
