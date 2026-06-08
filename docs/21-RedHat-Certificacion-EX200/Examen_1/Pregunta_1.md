<style>
p,
li {
  font-size: 14px;
  line-height: 1.6;
}

code {
  font-size: 14px;
}
</style>


# 🔖 Pregunta 1

### Network Configuration

On **Node1**, you are logged into a Red Hat Enterprise Linux system.

Determine the system’s **current local network configuration**, then configure the default network interface `ensXXX` to meet the following requirements:

- Configure a **static IPv4 address** using:
    - An IP address within the **same network** as the current configuration, with a **host ID of 50**
    - Netmask: `255.255.255.0`
    - Default gateway within the same network, with a **host ID of 1**

- Configure the system to use the following DNS settings:
    - DNS server: `8.8.8.8`
    - DNS search domain: `example.local`

- Set the system hostname to:
    - `rhel-node1.example.com`

 Ensure the network configuration is **persistent across reboots** and active immediately.


---

<br>
# Explicación general

### Solution – Question 1

While both **`nmtui`** and **`nmcli`** are fully acceptable and score equally, this solution uses **`nmtui`** for its efficiency and reduced risk of error in a timed exam environment (For reference, I used nmtui and I got 100% in Networking). That said, candidates are free to use the method they are most comfortable with.

<br>
**Preparation**

Identify the current network configuration by running the command:

```bash
# ip a
```

**Example output:**

```bash
... inet 172.16.18.142/24 ... 
```

**Interpretation:**

**Subnet mask:** **`/24`** → **`255.255.255.0`**

**Network ID:** **`172.16.18.0/24`**

**Host ID:** **`142`**

To remain within the same local network, select an unused host address in this range.

**Chosen configuration that aligns with task to use Host ID of 50:**

**IP address:** **`172.16.18.50/24`**

**Gateway:** **`172.16.18.1`**

----

<br>
### Solution

<br>
**Step 1 — Edit the Network Connection**

Launch the Network Manager TUI:

```bash
# nmtui
```

- Select **Edit a connection**

- Choose the active interface (e.g. **`ensXXX`**) → Edit

- Navigate to **`IPv4 CONFIGURATION`**

- Change method from **Automatic** to **Manual**

- Select **Show**

----

<br>
**Step 2 — Apply IPv4 Settings**

Enter the required values:

- **Addresses:** **`172.16.18.50/24`**

- **Gateway:** **`172.16.18.1`**

- **DNS servers:** **`8.8.8.8`**

- **Search domains:** **`example.local`**

Select **OK**, then exit.

----

<br>
**Step 3 — Activate the Configuration (Critical)**

Configuration changes do **not** take effect until the connection is reactivated.

- From the main **`nmtui`** menu, select **Activate a connection**

- With **`ensXXX`** selected:

    - Deactivate

    - Activate

    - Exit

⚠️ Failure to activate the connection results in **zero networking points**.

----

<br>
**Step 4 — Set the Hostname**

Choose one of the following methods:

Using **`nmtui`**:

- Select **Set system hostname**

- Enter and save:

```bash
rhel-node1.example.com
```

OR 

using the command line:

```bash
# hostnamectl set-hostname rhel-node1.example.com
```

OR 

```bash
# hostnamectl hostname rhel-node1.example.com
```

(Preferred over manual file edits.)

----

<br>
**Step 5 — Ensure NetworkManager Is Enabled**

Ensure NetworkManager is running and enabled at boot:

```bash
# systemctl enable --now NetworkManager
# systemctl restart NetworkManager
```

<br>
**Verification**

Confirm the configuration:

```bash
# ip a
```

Verify the hostname:

```bash
# hostname
``` 

OR

```bash
# cat /etc/hostname
```

<br>
**Exam Note**

In the actual RHCSA exam, the IP details are explicitly provided. This approach demonstrates how to ensure the assigned address resides within the local subnet. Using an incorrect or out-of-range IP may isolate the system and break essential services such as SSH, ICMP, and DNS resolution, or even communication between different nodes.

Remember to always include the network mask in the IP address configuration **`172.16.18.50/24`**. That means if the subnet mask is given as **`255.255.255.0`**, you should include **`/24`** at the end of the static IP address.


