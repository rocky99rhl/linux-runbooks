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


# 🔖 Pregunta 23


### Configure SELinux Booleans

On **Node2**, perform the following tasks:

Enable the SELinux boolean **httpd_can_network_connect** so that the Apache web server is allowed to initiate **outbound network connections**.

Ensure the change **persists across reboots**.

----

<br>
# Explicación general

### Solution – Question 23
<br>
**1.- Check the current status of the boolean**

```bash
# getsebool httpd_can_network_connect
```

Example output:

```bash
httpd_can_network_connect --> off
```

----
<br>
**2.- Make the boolean change persistent across reboots**

```bash
# setsebool -P httpd_can_network_connect on
```


**`-P`** flag ensures the change is written to SELinux policy and survives reboots.

----
<br>
**3.- Verify the boolean is enabled and persistent**

```bash
# getsebool httpd_can_network_connect
```

- Output should now show:

```bash
httpd_can_network_connect --> on
```

- Confirms that the boolean is active and persistent.

**Tip**

- Use **`-P`** whenever you want a boolean change to persist; without it, the change will revert after a reboot.


