Import-Module ActiveDirectory

$users = @(
    @{Name="John Smith"; Sam="john.smith"},
    @{Name="Jane Doe";   Sam="jane.doe"},
    @{Name="Bob Admin";  Sam="bob.admin"}
)

foreach ($u in $users) {
    New-ADUser `
        -Name            $u.Name `
        -SamAccountName  $u.Sam `
        -Enabled         $true `
        -AccountPassword (ConvertTo-SecureString "Password123!" `
                          -AsPlainText -Force)
    Write-Host "Created: $($u.Sam)"
}

Write-Host "All users created successfully."