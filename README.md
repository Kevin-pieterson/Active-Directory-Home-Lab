# Active Directory Home Lab

A fully functional enterprise-style Windows domain environment built inside VirtualBox — simulating the core infrastructure used in real corporate networks.

---

## What Was Built

| Component | Details |
|---|---|
| Hypervisor | Oracle VirtualBox |
| Domain Controller | Windows Server 2022 (DC01) |
| Client Machine | Windows 10 Enterprise (WIN10-CLIENT) |
| Domain | corp.local |
| Static IP | 192.168.10.10 |
| Services | AD DS · DNS · DHCP · Group Policy |
| Users Created | 16 domain user accounts |
| OUs Created | IT · HR · Finance · Sales |

---

## Lab Architecture

```
Your Physical Machine
        │
   VirtualBox (Hypervisor)
        │
   ┌────┴────┐
   │         │
  DC01    WIN10-CLIENT
  (Server)  (Employee PC)
   │
   ├── Active Directory Domain Services
   ├── DNS Server  →  resolves corp.local
   ├── DHCP Server →  192.168.10.100–200
   └── Group Policy → Disable Control Panel (Sales OU)
```

---

## Screenshots

| # | Screenshot | What It Shows |
|---|---|---|
| 01 | VirtualBox Manager | Both VMs created (DC01 + WIN10-CLIENT) |
| 02 | Server Manager | DC01 renamed, still in Workgroup (pre-AD promotion) — shows hardware specs and event log |
| 03 | Static IP | 192.168.10.10 assigned to DC01 |
| 04 | AD DS Installed | Server Manager Dashboard with AD DS tile |
| 05 | corp.local | Active Directory Users and Computers — domain created |
| 06 | OUs | IT, HR, Finance, Sales Organizational Units |
| 07 | Users | 16 users distributed across all 4 OUs |
| 08 | DNS | DNS Manager — corp.local Forward Lookup Zone |
| 09 | DHCP Scope | Office Scope 192.168.10.0 active |
| 10 | GPO | "Disable Control Panel" policy linked to Sales OU |
| 12 | Domain Join | WIN10-CLIENT joined to corp.local |
| 13 | Domain User Login | john.smith logging into the domain |
| 14 | whoami | `corp\john.smith` — domain authentication confirmed |

---

## Key Skills Demonstrated

- **Windows Server Administration** — installation, configuration, Server Manager
- **Active Directory** — domain creation, OU structure, user account management
- **Networking** — static IP assignment, DNS zone configuration, DHCP scoping
- **Group Policy** — creating and linking GPOs to specific OUs
- **Virtualization** — building isolated lab networks using VirtualBox internal networking
- **Domain Authentication** — joining clients to a domain, logging in as domain users

---

## Files in This Repo

| File | Description |
|---|---|
| `README.md` | This file — project overview |
| `setup-guide.md` | Full step-by-step build guide |
| `commands.md` | All commands used during the lab |
| `troubleshooting.md` | Common errors and how to fix them |
| `create-users.ps1` | PowerShell script to bulk-create domain users |

---

## Relevance to Cybersecurity

Active Directory is the backbone of most enterprise Windows environments. Understanding it is foundational for:

- **SOC Analyst** — investigating failed logins, suspicious AD changes
- **Blue Team** — detecting domain attacks, privilege escalation
- **IT Support / Sysadmin** — managing users, computers, and policies
- **Penetration Testing** — understanding what attackers target (Kerberoasting, Pass-the-Hash, GPO abuse)
