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


# 🔖 Pregunta 9


### Configure NTP Client Synchronization

On **Node1**, configure the system to synchronize its system time with the NTP server **server.example.com** and meet the following requirements:

   - Configure Node1 to use server.example.com as its only time source.

   - Ensure time synchronization is enabled and active.

   - The configuration must persist across reboots.

   - Verify that the system clock is synchronized with the configured NTP server.


# Explicación general


### Solution – Question 9


<br>
**Step 1: Install the required time synchronization package**

```bash
# dnf install -y chrony
```

----

<br>
**Step 2: Configure the NTP server**


Edit the chrony configuration file:

```bash
# vim /etc/chrony.conf
```

Locate any existing server or pool lines and comment them out, then add:

server server.example.com iburst
(Use pool if provided with a set of servers e.g pool.example.com)
iburst allows faster initial synchronization.

----

<br>
**Step 3: Enable and start the chrony service**

```bash
# systemctl enable --now chronyd
# systemctl status chronyd
```

----

<br>
**Step 4: Enable NTP synchronization at the system level**


```bash
# timedatectl set-ntp true
```

Verify:

```bash
# timedatectl status
```

Ensure:

```bash
NTP service: active
System clock synchronized: yes
```

----

**Step 5: Verify synchronization with the NTP server**

```bash
# chronyc sources
```

Expected output should list:


`^*` server.example.com <br>
`^*` indicates the active synchronization source.


