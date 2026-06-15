# create-users.ps1
# Active Directory Home Lab — Bulk User Creation Script
# Run this on DC01 as Administrator in PowerShell
#
# Usage:
#   1. Open PowerShell as Administrator on DC01
#   2. Set-ExecutionPolicy RemoteSigned
#   3. .\create-users.ps1

# -------------------------------------------------------
# CONFIGURATION — edit these if your domain name differs
# -------------------------------------------------------
$domain     = "corp.local"
$password   = ConvertTo-SecureString "Password123!" -AsPlainText -Force

# -------------------------------------------------------
# OU DEFINITIONS
# -------------------------------------------------------
$OUs = @("IT", "HR", "Finance", "Sales")

# -------------------------------------------------------
# USER LIST — Name, OU
# -------------------------------------------------------
$users = @(
    # IT Department
    @{ First="Emma";  Last="Reed";   OU="IT"      },
    @{ First="Jack";  Last="Hill";   OU="IT"      },
    @{ First="John";  Last="Smith";  OU="IT"      },
    @{ First="Luke";  Last="Cole";   OU="IT"      },

    # HR Department
    @{ First="Ella";  Last="Shaw";   OU="HR"      },
    @{ First="Liam";  Last="Ford";   OU="HR"      },
    @{ First="Mia";   Last="Rose";   OU="HR"      },
    @{ First="Noah";  Last="West";   OU="HR"      },

    # Finance Department
    @{ First="Ben";   Last="Scott";  OU="Finance" },
    @{ First="Gwen";  Last="Bell";   OU="Finance" },
    @{ First="Kate";  Last="Price";  OU="Finance" },
    @{ First="Max";   Last="Brooks"; OU="Finance" },

    # Sales Department
    @{ First="Lily";  Last="Dean";   OU="Sales"   },
    @{ First="Owen";  Last="Clark";  OU="Sales"   },
    @{ First="Ryan";  Last="";       OU="Sales"   },
    @{ First="Zoe";   Last="Stone";  OU="Sales"   }
)

# -------------------------------------------------------
# STEP 1 — Create OUs if they don't already exist
# -------------------------------------------------------
Write-Host "`n[1/3] Creating Organizational Units..." -ForegroundColor Cyan

foreach ($ou in $OUs) {
    $ouPath = "OU=$ou,DC=corp,DC=local"
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $ou -Path "DC=corp,DC=local"
        Write-Host "  Created OU: $ou" -ForegroundColor Green
    } else {
        Write-Host "  OU already exists: $ou" -ForegroundColor Yellow
    }
}

# -------------------------------------------------------
# STEP 2 — Create User Accounts
# -------------------------------------------------------
Write-Host "`n[2/3] Creating user accounts..." -ForegroundColor Cyan

$created = 0
$skipped = 0

foreach ($user in $users) {
    $first    = $user.First
    $last     = $user.Last
    $ou       = $user.OU

    # Build username: firstname.lastname or just firstname if no last name
    if ($last -ne "") {
        $username    = "$($first.ToLower()).$($last.ToLower())"
        $displayName = "$first $last"
    } else {
        $username    = $first.ToLower()
        $displayName = $first
    }

    $ouPath = "OU=$ou,DC=corp,DC=local"

    # Check if user already exists
    if (Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue) {
        Write-Host "  Skipped (already exists): $username" -ForegroundColor Yellow
        $skipped++
        continue
    }

    try {
        $params = @{
            SamAccountName        = $username
            UserPrincipalName     = "$username@$domain"
            Name                  = $displayName
            GivenName             = $first
            Surname               = $last
            DisplayName           = $displayName
            Path                  = $ouPath
            AccountPassword       = $password
            Enabled               = $true
            PasswordNeverExpires  = $true
            ChangePasswordAtLogon = $false
        }

        New-ADUser @params
        Write-Host "  Created: $username  →  $ou" -ForegroundColor Green
        $created++
    }
    catch {
        Write-Host "  ERROR creating $username`: $_" -ForegroundColor Red
    }
}

# -------------------------------------------------------
# STEP 3 — Summary
# -------------------------------------------------------
Write-Host "`n[3/3] Summary" -ForegroundColor Cyan
Write-Host "  Users created : $created" -ForegroundColor Green
Write-Host "  Users skipped : $skipped" -ForegroundColor Yellow
Write-Host ""

# -------------------------------------------------------
# VERIFICATION — List all users per OU
# -------------------------------------------------------
Write-Host "Verifying users in each OU:" -ForegroundColor Cyan

foreach ($ou in $OUs) {
    $ouPath = "OU=$ou,DC=corp,DC=local"
    $ouUsers = Get-ADUser -Filter * -SearchBase $ouPath | Select-Object -ExpandProperty Name
    Write-Host "`n  [$ou]" -ForegroundColor White
    foreach ($u in $ouUsers) {
        Write-Host "    - $u"
    }
}

Write-Host "`nDone. All users can log in with password: Password123!" -ForegroundColor Green
Write-Host "Example login: corp\john.smith" -ForegroundColor Green
