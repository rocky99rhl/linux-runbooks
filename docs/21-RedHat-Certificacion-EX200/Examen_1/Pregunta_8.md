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


# 🔖 Pregunta 8


### Ownership, Permissions, and ACLs

On **Node1**, copy the file **/etc/fstab** to **/var/tmp** and configure its ownership and permissions to meet the following requirements:

   - The copied file must be owned by **root.**

   - The file must belong to the **admins** group.

   - The file must **not be executable** by any user.

   - User **harry** must have **read and write** access to the file.

   - User **bruce** can **read** but **not write** to the file.

   - User **natasha** must have **no read or write access** to the file.

   - All other users, including users created in the future, must have **read-only** access to the file.

----

# Explicación general

### Solution – Question 8

----

<br>
**Step 1: Copy the file to the target location**

```bash
# cp /etc/fstab /var/tmp/fstab
```

----

<br>
**Step 2: Set ownership and group ownership**

```bash
# chown root:admins /var/tmp/fstab
```

----

<br>
**Step 3 (Optional): Remove all executable permissions**


```bash
# chmod a-x /var/tmp/fstab
```

----

<br>
**Step 4: Set base permissions for owner, group, and others**

   - Owner (root): read and write

   - Group (admins): read-only (baseline)

   - Others: read-only

```bash
# chmod 664 /var/tmp/fstab
```

At this point:

   - Root → read/write ✅

   - Group admins → read/write ✅

   - Others → read-only ✅

----

<br>
**Step 5: Configure ACLs for specific user requirements**

Grant harry read and write access

```bash
# setfacl -m u:harry:rw /var/tmp/fstab
``` 

Grant bruce read-only access

```bash
# setfacl -m u:bruce:r /var/tmp/fstab
```

OR

```bash
# setfacl -m u:bruce:r-- /var/tmp/fstab
```

Explicitly deny natasha read and write access

```bash
# setfacl -m u:natasha:--- /var/tmp/fstab
```

----

**Step 6: Verify ACL configuration**

```bash
# getfacl /var/tmp/fstab
```

Expected key entries:

```bash
user::rw-
user:harry:rw-
user:bruce:r--
user:natasha:---
group::r--
other::r--
```

