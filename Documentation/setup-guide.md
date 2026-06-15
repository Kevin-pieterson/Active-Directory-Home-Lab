# Setup Guide — Active Directory Home Lab

Complete walkthrough of building a Windows Server 2022 Active Directory environment in VirtualBox.

---

## Prerequisites

### Minimum PC Specs
- CPU: Intel Core i5 or equivalent
- RAM: 8 GB (16 GB recommended)
- Free Disk: 100 GB
- OS: Windows 10 or 11

### Downloads Required
- [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Windows Server 2022 Evaluation ISO](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022) (~5 GB)
- [Windows 10 Enterprise Evaluation ISO](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise)

---

## Day 1 — Install VirtualBox

1. Download and install VirtualBox using default settings.
2. Open VirtualBox Manager — you should see an empty VM list.
3. Take screenshot: `01-VirtualBox.png`

---

## Day 2 — Create the Domain Controller VM (DC01)

### Create New VM
1. Click **New** in VirtualBox
2. Set:
   - Name: `WindowsServer2022`
   - Type: `Microsoft Windows`
   - Version: `Windows 2022 (64-bit)`
   - RAM: `4096 MB`
   - Disk: `60 GB`

### Install Windows Server 2022
1. Start the VM and select the Server 2022 ISO
2. Choose: **Windows Server 2022 Standard Evaluation (Desktop Experience)**
   > Do NOT choose Core — you need the GUI
3. Create an Administrator password (e.g. `LabAdmin@123`)

### Rename the Server
1. Open **Server Manager → Local Server**
2. Click the computer name → rename to `DC01`
3. Restart

Take screenshot: `02-ServerManager.png`

---

## Day 3 — Configure Networking

### Set Internal Network in VirtualBox
1. Power off DC01
2. Go to **Settings → Network → Adapter 1**
3. Set to: **Internal Network**, Name: `LabNet`
4. Start DC01

### Assign Static IP Inside DC01
1. Open **Network Connections** (`ncpa.cpl`)
2. Right-click Ethernet → **Properties**
3. Double-click **IPv4**
4. Set:
   - IP Address: `192.168.10.10`
   - Subnet Mask: `255.255.255.0`
   - Default Gateway: `192.168.10.1`
   - Preferred DNS: `192.168.10.10`
   > ⚠️ Important: DNS must be `192.168.10.10` — double-check you haven't accidentally typed `192.169.10.10` (wrong — 169 not 168). A wrong DNS here is the most common cause of domain join failures.
5. Click OK

Test with: `ping 127.0.0.1`

Take screenshot: `03-Static-IP.png`

---

## Day 4 — Install Active Directory

### Add the AD DS Role
1. Open **Server Manager → Manage → Add Roles and Features**
2. Select: **Active Directory Domain Services**
3. Click through and install

### Promote to Domain Controller
1. Click the yellow notification flag in Server Manager
2. Click **Promote this server to a domain controller**
3. Select: **Add a new forest**
4. Root domain name: `corp.local`
5. Set a DSRM password
6. Click through all defaults → **Install**
7. Server will reboot automatically

After reboot, Server Manager will show AD DS in the dashboard.

Take screenshot: `04-ADDS-Installed.png`

---

## Day 5 — Create Domain Structure

### Open Active Directory Users and Computers
- Server Manager → **Tools → Active Directory Users and Computers**
- You will see `corp.local` in the tree

Take screenshot: `05-Corp-local.png`

### Create Organizational Units (OUs)
Right-click `corp.local` → **New → Organizational Unit**

Create these 4 OUs:
- `IT`
- `HR`
- `Finance`
- `Sales`

Take screenshot: `06-OUs.png`

### Create User Accounts
Right-click each OU → **New → User**

**IT Department:**
- Emma Reed
- Jack Hill
- john smith
- Luke cole

**HR Department:**
- Ella shaw
- Liam ford
- Mia rose
- Noah west

**Finance Department:**
- Ben scott
- gwen bell
- Kate price
- Max brooks

**Sales Department:**
- Lily dean
- Owen clark
- Ryan
- Zoe stone

> Set a password for each user (e.g. `Password123!`) and uncheck "User must change password at next logon"

Take screenshot: `07-Users.png`

> Alternatively, use `create-users.ps1` to bulk create all users automatically.

---

## Day 6 — Configure DNS and DHCP

### DNS (auto-configured during AD DS install)
1. Server Manager → **Tools → DNS**
2. Expand DC01 → **Forward Lookup Zones → corp.local**
3. You should see the SOA, NS, and Host (A) record for dc01 pointing to `192.168.10.10`

Take screenshot: `08-DNS.png`

### Install DHCP
1. Server Manager → **Manage → Add Roles and Features**
2. Select: **DHCP Server** → Install
3. Click the notification flag → **Complete DHCP configuration**
4. Server Manager → **Tools → DHCP**
5. Expand `dc01.corp.local → IPv4`
6. Right-click IPv4 → **New Scope**
   - Scope name: `Office Scope`
   - Start IP: `192.168.10.100`
   - End IP: `192.168.10.200`
   - Subnet mask: `255.255.255.0`
   - DNS Server: `192.168.10.10`
7. Activate the scope

Take screenshot: `09-DHCP-Scope.png`

---

## Day 6 (continued) — Configure Group Policy

### Create a GPO
1. Server Manager → **Tools → Group Policy Management**
2. Expand: `Forest: corp.local → Domains → corp.local`
3. Right-click the `Sales` OU → **Create a GPO in this domain and Link it here**
4. Name it: `Disable Control Panel`
5. Right-click the GPO → **Edit**
6. Navigate to:
   `User Configuration → Policies → Administrative Templates → Control Panel`
7. Double-click **Prohibit access to Control Panel and PC settings** → set to **Enabled**
8. Close the editor

Take screenshot: `10-GPO.png`

---

## Day 7 — Create Windows 10 Client VM (WIN10-CLIENT)

### Create New VM
1. Click **New** in VirtualBox
2. Set:
   - Name: `Windows10`
   - Type: `Microsoft Windows`
   - Version: `Windows 10 (64-bit)`
   - RAM: `4096 MB`
   - Disk: `50 GB`
3. Network: **Internal Network → LabNet** (same as DC01)

### Install Windows 10
1. Start VM, select the Windows 10 ISO
2. Install Windows 10 Enterprise Evaluation
3. Complete setup (use local account for now)

### Set DNS on Windows 10
1. Open `ncpa.cpl`
2. Right-click Ethernet → Properties → IPv4
3. Set Preferred DNS: `192.168.10.10`

### Join the Domain
1. Press `Win + R` → type `sysdm.cpl`
2. Go to **Computer Name** tab → click **Change**
3. Select **Domain** → type `corp.local`
4. Enter credentials:
   - Username: `corp\Administrator`
   - Password: (your DC01 admin password)
5. You will see: **Welcome to the corp.local domain**
6. Restart

Take screenshot after restart: `12-Domain-Join.png`

### Login as Domain User
1. At login screen, click **Other user**
2. Enter:
   - Username: `corp\john.smith`
   - Password: `Password123!`
3. Desktop loads

Take screenshot: `13-Domain-User-Login.png`

### Verify with whoami
Open Command Prompt and run:
```
whoami
```
Expected output: `corp\john.smith`

Take screenshot: `14-Whoami.png`

---

## Lab Complete

You now have a fully functional Active Directory domain with:
- A Domain Controller (DC01) running AD DS, DNS, DHCP, and Group Policy
- A domain-joined Windows 10 client (WIN10-CLIENT)
- 16 user accounts across 4 OUs
- A GPO applied to the Sales OU
