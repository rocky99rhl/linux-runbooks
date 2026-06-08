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


# 🔖 Pregunta 3



### Create Users with Supplementary Group Membership

On **Node1**, perform the following user and group management tasks:

- Create a group named **opsgrp**.

- Create two user accounts named **linda** and **michael**, and configure both users to belong to the supplementary group **opsgrp**.

- Create a user account named **david** with the following restrictions:

   - Must not be a member of the **opsgrp** group.

   - Must not have access to an interactive login shell.

- Set the password for all created users to:

```bash
 devops
```

-----
<br>

## Explicación general

### Solution – Question 3

1. Create the group

```bash
# groupadd opsgrp
```

----
<br>

**2. Create users linda and michael with supplementary group opsgrp**

```bash
# useradd linda
# usermod -aG opsgrp linda
# useradd -G opsgrp michael
```

----
<br>

**3. Create user david with a non-interactive shell and no membership in opsgrp**

```bash
# useradd -s /sbin/nologin david
```

- **`/sbin/nologin`** prevents interactive login while still allowing authentication for non-shell services if ever required.

----
<br>

**4. Set passwords for all users (interactive method)**

```bash
# passwd linda
# passwd michael
# passwd david
```

Enter the password **`devops`** when prompted for each user.

----
<br>

**5. Set passwords for all users (automated one-liner method)**

```bash
# for user in linda michael david; do echo "devops" | passwd --stdin "$user"; done
```

- This sets the same password non-interactively for all listed users.

----
<br>

**6. Verify group membership and shell settings**

```bash
# id linda
# id michael
# id david
# grep david /etc/passwd
```

- Confirm:

   - **`linda`** and **`michael`** show **`opsgrp`** in supplementary groups.

   - **`david`** does **not** show **`opsgrp`** and has shell **`/sbin/nologin`**.


