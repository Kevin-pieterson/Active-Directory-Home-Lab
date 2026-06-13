Get-ADUser -Filter \*

New-ADOrganizationalUnit -Name "IT" -Path "DC=corp,DC=local"

Get-ADComputer -Filter \*

Test-ComputerSecureChannel -Verbose

