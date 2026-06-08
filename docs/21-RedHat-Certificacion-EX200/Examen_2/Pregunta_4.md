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


# 🔖 Pregunta 4


### Create a Collaborative Group Directory

On **Node1**, create a directory named **/home/manager** to be used for group collaboration with the following requirements:

- The directory must have its group ownership set to **opsgrp**.

- Members of the **opsgrp** group must have full access (read, write, execute) to the directory.

- Users who are not members of **opsgrp** must have no access to the directory except root.

- Any new files or subdirectories created inside **/home/manager** must automatically inherit the **opsgrp** group ownership.

----
<br>

## Explicación general


### Solution – Question 4

**1. Create the directory**

```bash
# mkdir /home/manager
```

----
<br>

**2. Set group ownership to `opsgrp`**

```bash
# chown root:opsgrp /home/manager
```

The owner remains root.

The group owner becomes opsgrp so group permissions can be enforced.

----
<br>

**3. Set permissions to allow full access only for group members**

```bash
# chmod 770 /home/manager
``` 

- **`7`** (owner=root): full access

- **`7`** (group=opsgrp): full access

- **`0`** (others): no access

This ensures only root and members of opsgrp can access the directory.

----
<br>

**4. Enable SGID so new files inherit the group**

```bash
# chmod g+s /home/manager
```

- The SGID bit forces all newly created files and subdirectories inside **`/home/manager`** to automatically inherit the group **opsgrp**.

(Alternatively, **`chmod 2770 /home/manager`** will achieve the above two objectives in one go)

----
<br>

**5. Verify configuration**

```bash
# ls -ld /home/manager
```

Expected output will resemble:

```bash
drwxrws---. root opsgrp /home/manager
```

The **`s`** in the group field confirms SGID is set.


