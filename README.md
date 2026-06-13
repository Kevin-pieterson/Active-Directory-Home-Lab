# Active Directory Home Lab

## Overview

This project demonstrates the design and implementation of a Windows Server Active Directory environment.

The purpose of this lab was to simulate a small enterprise network environment and practice system administration, identity management, and network services.

---

# Lab Environment

## Virtual Machines

| System | Purpose |
|---|---|
| Windows Server 2022 | Domain Controller |
| Windows 10 | Domain Client |
| VirtualBox | Virtualization Platform |

---

# Technologies Used

- Windows Server 2022
- Active Directory Domain Services (AD DS)
- DNS
- DHCP
- Group Policy
- Windows 10
- VirtualBox
- PowerShell

---

# Lab Architecture


Windows 10 Client

        |
        |
        |

Windows Server 2022

        |
        |
        
Active Directory
DNS
DHCP


---

# Implemented Features

## Active Directory

Configured:

- Domain Controller
- Domain Users
- Organizational Units
- Security Groups


## DNS

Configured:

- Internal domain name resolution
- DNS records
- Client DNS connectivity


## DHCP

Configured:

- IP address allocation
- DHCP scope
- Default gateway
- DNS settings


## Group Policy

Implemented:

- Password policies
- User restrictions
- Security configurations


## Domain Join

Successfully connected Windows 10 client machine to:
