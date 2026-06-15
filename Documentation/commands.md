# Commands Reference — Active Directory Home Lab

All commands used during the setup and verification of the lab environment.

---

## Network Configuration

### Test loopback (basic connectivity check)
```
ping 127.0.0.1
```

### Ping the Domain Controller from Windows 10
```
ping 192.168.10.10
```

### View IP configuration
```
ipconfig
```

### View full IP details (including DNS server assigned)
```
ipconfig /all
```

### Flush DNS cache
```
ipconfig /flushdns
```

### Test DNS resolution of the domain
```
nslookup corp.local
```

### Test if the Domain Controller is reachable by name
```
ping dc01.corp.local
```

---

## Domain Verification

### Check which domain/workgroup this computer belongs to
```
systeminfo | findstr /i "domain"
```

### Open System Properties (to check domain membership)
```
sysdm.cpl
```

### Open Network Connections
```
ncpa.cpl
```

---

## User and Session Commands

### Show current logged-in user and domain
```
whoami
```

Expected output when logged in as domain user:
```
corp\john.smith
```

### Show detailed user info
```
whoami /all
```

### Show all local and domain groups the current user belongs to
```
whoami /groups
```

### List all users on the local machine
```
net user
```

### List all users in the domain
```
net user /domain
```

### List all computers joined to the domain
```
net view /domain:corp
```

---

## Active Directory (Run on DC01)

### Check AD DS service status
```
Get-Service ADWS
```

### List all users in Active Directory
```
Get-ADUser -Filter *
```

### List all users with their OU location
```
Get-ADUser -Filter * -Properties DistinguishedName | Select-Object Name, DistinguishedName
```

### List all Organizational Units
```
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
```

### List all computers joined to the domain
```
Get-ADComputer -Filter * | Select-Object Name
```

### Check Domain Controller info
```
Get-ADDomainController
```

### Check the domain name
```
(Get-ADDomain).DNSRoot
```

---

## DNS Commands (Run on DC01)

### Test DNS from Windows 10 — find the DC
```
nslookup corp.local 192.168.10.10
```

### List all DNS records in the zone (run on DC01 in PowerShell)
```
Get-DnsServerResourceRecord -ZoneName "corp.local"
```

---

## DHCP Commands (Run on DC01)

### List DHCP scopes
```
Get-DhcpServerv4Scope
```

### List active DHCP leases
```
Get-DhcpServerv4Lease -ScopeId 192.168.10.0
```

---

## Group Policy Commands

### Force Group Policy update on the client
```
gpupdate /force
```

### View applied Group Policies on the client
```
gpresult /r
```

### View detailed GPO report (HTML output)
```
gpresult /h C:\gporeport.html
```

---

## PowerShell Execution Policy (needed before running scripts)

### Check current execution policy
```powershell
Get-ExecutionPolicy
```

### Allow local scripts to run
```powershell
Set-ExecutionPolicy RemoteSigned
```

---

## Quick Health Check Sequence

Run these on DC01 to confirm everything is working:

```powershell
# 1. Confirm domain
(Get-ADDomain).DNSRoot

# 2. Confirm DC
Get-ADDomainController | Select-Object Name, IPv4Address

# 3. List OUs
Get-ADOrganizationalUnit -Filter * | Select-Object Name

# 4. Count users
(Get-ADUser -Filter *).Count

# 5. List computers in domain
Get-ADComputer -Filter * | Select-Object Name

# 6. Check DHCP scope
Get-DhcpServerv4Scope

# 7. Check DNS zone
Get-DnsServerZone
```
