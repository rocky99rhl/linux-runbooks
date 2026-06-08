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


### Configure Sudo Access

On **Node1**, perform the following tasks:

   - Ensure that the user `john` can execute commands with **`sudo`**.

   - Configure the system so that **all members of the group `admins`** can execute commands with **`sudo` without being prompted for a password.**

   - The configuration must persist across reboots and apply system-wide.
<br>
----

# Explicación general


### Solution - Question 15

### Option 1 – Using Groups


**Step 1: Add john to the wheel group (default sudo access):**

```bash
# usermod -aG wheel john
```

<br>
Step 2: Allow members of admins group to use sudo without password:

```bash
# vim /etc/sudoers.d/admins
```

Add:

```bash
%admins ALL=(ALL) NOPASSWD: ALL
```

----

<br>
### Option 2 – Using visudo

**Step 1: Grant john explicit sudo access:**

```bash
# visudo
```

Add the following line at the end or where appropriate:

```bash
john ALL=(ALL) ALL
```

   - Grants john full sudo privileges with a password prompt.

----

<br>
**Step 2: Grant admins group passwordless sudo:**

```bash
# visudo
```

Add the following line at the end or where appropriate:

```bash
%admins ALL=(ALL) NOPASSWD: ALL
```

   - **`%admins`** → applies to all members of the admins group

   - **`NOPASSWD: ALL`** → allows running commands without being prompted for a password

----

<br>
**Step 3: Verification**

As **john:**

```bash
# sudo whoami
```

   - Should succeed with a password prompt.

As a member of **admins:**

```bash
# sudo whoami
```

Should succeed without a password prompt.

----

<br>
💡 **Exam Tips**

   - **Option 1** is quicker for standard scenarios.

   - **Option 2** using **`visudo`** is safest for explicit control and avoids syntax errors.

   - Always test sudo configuration after changes to prevent lockouts.

   - Passwordless sudo is applied to groups with **`%groupname`** syntax (check **`%wheel`** example in visudo as reference).





