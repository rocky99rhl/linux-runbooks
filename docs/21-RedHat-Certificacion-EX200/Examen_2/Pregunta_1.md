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


### Configure IPv6

On **Node1**, configure the network interface **ensXXX** using a static IPv6 configuration with the following requirements:

IPv6 Address: **fd02::42/64**

IPv6 Default Gateway: **fd02::1**

IPv6 DNS Server: **fd02::222**

DNS Search Domain: **example.local**

Set the hostname to **node1.example.local**

<br>

**Requirements:**

Apply the configuration to the network profile **ensXXX**.

Ensure the configuration persists across reboots.

----
<br>

## Explicación general

### Solution - Question 1

**Preparation: Check current network configuration**

```bash
# ip a
```

Identify the interface name (**`ensXXX`**) and confirm no conflicts.

**Option 1 – Using `nmtui` (interactive, recommended for exams)**

```bash
# nmtui
```

Steps inside **nmtui**:

Select **Edit a connection** → choose **ensXXX** → **`<Edit…>`**

Go to **IPv6 CONFIGURATION**

Change from **Automatic** to **Manual**

Enter:

- **Addresses: `fd02::42/64`**

- **Gateway: `fd02::1`**

- **DNS servers: `fd02::222`**

- **Search domains: `example.local`**

**`<OK>`** → Exit

Back in main **nmtui**, select **Activate a connection**

Deactivate and then Activate **ensXXX**

----
<br>

**Option 2 – Using nmcli (non-interactive)**

```bash
# nmcli connection modify ensXXX ipv6.method manual
# nmcli connection modify ensXXX ipv6.addresses fd02::42/64
# nmcli connection modify ensXXX ipv6.gateway fd02::1
# nmcli connection modify ensXXX ipv6.dns fd02::222
# nmcli connection modify ensXXX ipv6.dns-search example.local
# nmcli connection up ensXXX
```

----
<br>

**Step 3 – Set the hostname**

```bash
# hostnamectl set-hostname node1.example.local
```

Or use nmtui

----
<br>

**Step 4 – Restart NetworkManager to ensure persistence**

```bash
# systemctl enable --now NetworkManager
# systemctl restart NetworkManager
```

----
<br>

**Step 5 – Verification**

```bash
# ip -6 a show ensXXX          # Confirm IPv6 address is assigned
# ip -6 route                  # Confirm default gateway is set
# cat /etc/resolv.conf         # Check DNS server and search domain
# hostnamectl                  # Confirm hostname
```

----
<br>

!!! info "Tips"
    - **`nmtui`** is often faster and safer during exams, especially for IPv6, as syntax errors are avoided.
    - Using **`nmcli`** is faster for automation or scripting but requires careful syntax.



