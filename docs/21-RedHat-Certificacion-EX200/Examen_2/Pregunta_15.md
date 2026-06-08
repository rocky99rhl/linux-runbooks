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


# 🔖 Pregunta 15



### Configure Passwordless SSH

On **Node1**, configure **passwordless SSH login** for the **root user** to **Node2** with the following requirements:

- Root on Node1 must be able to SSH **into Node2 without entering a password**.

----
<br>

## Explicación general

### Solution – Question 14
<br>

Configure Passwordless SSH for Root from Node1 to Node2

**1. Ensure SSH service is running on both Nodes**

```bash
# dnf install sshd
# systemctl enable --now sshd
```

----
<br>

**2. Verify that root login via SSH is allowed**

Edit the SSH daemon configuration on Node2:

```bash
# vim /etc/ssh/sshd_config
```

Ensure the following line is present and uncommented:

```bash
PermitRootLogin yes
```

Save and exit, then restart SSH:

```bash
# systemctl restart sshd
```

----
<br>

**3. Open SSH port in the firewall on Node2**

```bash
# firewall-cmd --permanent --add-service=ssh
# firewall-cmd --reload
```

Ensures Node1 can connect to Node2 over SSH.

----
<br>

**4. Generate SSH key pair on Node1 as root**

```bash
# ssh-keygen
```

----
<br>

**5. Copy the public key to Node2 root account**

```bash
# ssh-copy-id root@<Node2-IP>
```

- Enter root password for Node2 once to install the key.

- After this, passwordless login will work.

----
<br>

**6. Verify passwordless login**

```bash
# ssh root@<Node2-IP>
```

- You should be logged in immediately without entering a password.

<br>

!!! info "Tips"
    Avoid enabling root login without strong security in production environments; for exams, this is standard practice.

