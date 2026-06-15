# Troubleshooting Guide — Active Directory Home Lab

Common problems encountered during setup and how to fix them.

---

## Problem 1 — Cannot Join Domain: "Domain not found" or "DNS name does not exist"

**Symptom:**
When trying to join `corp.local` from WIN10-CLIENT, you get an error saying the domain cannot be found.

**Cause:**
Windows 10 is pointing to the wrong DNS server.

**Fix:**
1. On WIN10-CLIENT, open `ncpa.cpl`
2. Right-click Ethernet → Properties → IPv4
3. Set **Preferred DNS Server** to `192.168.10.10` (your DC01 IP)
4. Click OK
5. Try joining the domain again

**Verify DNS is correct:**
```
nslookup corp.local
```
Expected: should resolve to `192.168.10.10`

---

## Problem 2 — Cannot Ping DC01 from WIN10-CLIENT

**Symptom:**
`ping 192.168.10.10` times out or says "Request timed out."

**Cause:**
Both VMs are not on the same internal network, or DC01 firewall is blocking ICMP.

**Fix — Check VirtualBox Network Settings:**
1. Power off both VMs
2. On DC01: Settings → Network → Adapter 1 → **Internal Network** → Name: `LabNet`
3. On WIN10-CLIENT: same — **Internal Network** → Name: `LabNet`
4. Both must use the exact same name

**Fix — Disable Windows Firewall on DC01 (for lab purposes):**
```
netsh advfirewall set allprofiles state off
```

---

## Problem 3 — Domain Join Asks for Credentials but Rejects Them

**Symptom:**
You enter `corp\Administrator` and the correct password but get "Logon failure: unknown user name or bad password."

**Cause:**
The username format is wrong, or DC01 is not reachable.

**Fix:**
Try these username formats:
- `corp\Administrator`
- `Administrator@corp.local`
- `Administrator` (without domain prefix)

Also confirm DC01 is running and pingable before trying the join.

---

## Problem 4 — "The network path was not found" During Domain Join

**Symptom:**
Error appears when clicking OK after typing `corp.local`.

**Cause:**
DNS is not resolving the domain, or DC01 is offline.

**Fix:**
1. Confirm DC01 is running
2. On WIN10-CLIENT, run: `nslookup corp.local` — should return `192.168.10.10`
3. If nslookup fails, set DNS to `192.168.10.10` manually (see Problem 1)
4. Try: `ping dc01.corp.local` — should get a reply

---

## Problem 5 — WIN10-CLIENT Gets IP 169.254.x.x (APIPA Address)

**Symptom:**
Running `ipconfig` shows an IP starting with `169.254` — this means DHCP failed.

**Cause:**
DHCP server is not running, scope is not active, or network settings are wrong.

**Fix:**
1. On DC01, open DHCP Manager
2. Confirm the scope `192.168.10.0` is active (green icon)
3. Right-click scope → Activate if it shows inactive
4. On WIN10-CLIENT, run:
```
ipconfig /release
ipconfig /renew
ipconfig
```
Should now show an IP in the range `192.168.10.100–200`

---

## Problem 6 — Can't Login as Domain User After Domain Join

**Symptom:**
After joining the domain and restarting, logging in as `corp\john.smith` fails.

**Cause:**
The user account may not exist, the password is wrong, or DC01 is offline.

**Fix:**
1. Confirm DC01 is running first
2. On the login screen, click **Other user**
3. Type username exactly as: `corp\john.smith`
4. Use the password you set when creating the user in AD
5. If you forgot the password, reset it on DC01:
   - Active Directory Users and Computers → find the user → right-click → **Reset Password**

---

## Problem 7 — whoami Shows Local User Instead of Domain User

**Symptom:**
After logging in, `whoami` shows `win10-client\john` instead of `corp\john.smith`.

**Cause:**
You logged in with a local account, not a domain account.

**Fix:**
Log out and log back in:
1. Click **Other user** on the login screen
2. Username: `corp\john.smith` (must include `corp\`)
3. Enter the domain user's password

---

## Problem 8 — Group Policy Not Applying

**Symptom:**
The "Disable Control Panel" GPO is linked to the Sales OU but the user can still open Control Panel.

**Fix:**
1. Log in as a user inside the Sales OU (e.g. `corp\lily.dean`)
2. Run `gpupdate /force` in Command Prompt
3. Log out and log back in
4. Check what policies are applied:
```
gpresult /r
```
5. In the output, look for the GPO name under "Applied Group Policy Objects"

If still not applying, verify:
- The user's account is inside the **Sales** OU (not just the domain root)
- The GPO is linked to the Sales OU (check Group Policy Management)
- The GPO is **Enabled** (Link Enabled = Yes)

---

## Problem 9 — Server Manager Shows AD DS with Errors/Warnings

**Symptom:**
After promotion, Server Manager AD DS tile shows red or warning banners.

**Common Causes and Fixes:**

| Warning | Fix |
|---|---|
| "Windows Time Service" warnings | Normal in a lab, ignore |
| "DNS not responding" | Check DNS service is running: `Get-Service DNS` |
| "DFSR" warnings | Normal for single-DC lab, ignore |
| "Replication" errors | Only relevant with multiple DCs |

For a single-DC lab, most warnings in event logs are non-critical and can be ignored.

---

## Problem 10 — VirtualBox VM Won't Start (VERR_SVM_DISABLED or VT-x error)

**Symptom:**
VM fails to start with a virtualization error.

**Fix:**
Enable virtualization in BIOS/UEFI:
1. Restart your physical PC
2. Enter BIOS (usually F2, F10, Delete, or Esc during boot)
3. Find **Intel VT-x** or **AMD-V / SVM** setting
4. Enable it
5. Save and exit

---

## Quick Diagnostic Commands

Run these in sequence on WIN10-CLIENT to diagnose most issues:

```
ipconfig /all
ping 192.168.10.10
nslookup corp.local
whoami
```

Run these on DC01 to confirm services are healthy:

```powershell
Get-Service ADWS, DNS, DHCPServer | Select-Object Name, Status
```

All three should show `Running`.
