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


# 🔖 Pregunta 5

### Shared Group Directories and Permissions
On **Node1**, create shared collaboration directories for group-based access with the following requirements:

1.- Create the following directories:

`/groups/admins`

`/groups/users`


2.- Configure **/groups/admins** as follows:

   - The group owner of the directory must be admins

   - Members of the admins group must have full access (read, write, and execute)

   - No access must be granted to users outside the admin group

   - The directory owner must remain root

   - All newly created files and directories within /groups/admins must automatically inherit the admin group ownership


3.- Configure **/groups/users** as follows:

   - The group owner must be users

   - Members of the users group must have read, write, and execute access
    
   - Other users must have no access

   - New files created in this directory can only be deleted by the file owner or root.

<br>
# Explicación general


## Solution – Question 5

<br>
**Step 1: Create the required directories**
```bash
# mkdir -p /groups/admins /groups/users
```

----

<br>
**Step 2: Set ownership**

Configure /groups/admins

Owner must remain root

Group owner must be admins
```bash
# chown root:admins /groups/admins
```
Configure /groups/users

Owner must remain root

Group owner must be users
```bash
# chown root:users /groups/users
```

----

<br>
**Step 3: Set directory permissions**

/groups/admins

Requirements:

Full access for members of admins

No access for others

SGID set so new files inherit group ownership
```bash
# chmod 2770 /groups/admins
```

**Explanation:**

2 → SGID bit (Can also be set using chmod g+s)

7 → rwx for owner (root)

7 → rwx for group (admins)

0 → no access for others

/groups/users

Requirements:

Full access for members of users

No access for others

Sticky bit set so only file owners or root can delete files
```bash
# chmod 1770 /groups/users
```

**Explanation:**

1 → Sticky bit (Can also be set using chmod +t)

7 → rwx for owner (root)

7 → rwx for group (users)

0 → no access for others

----

<br>
**Step 4: Verify configuration**
```bash
# ls -ld /groups/admins /groups/users
```

Expected output highlights:

/groups/admins shows drwxrws---

/groups/users shows drwxrwx--T

✅ Key Exam Takeaways

SGID (2) ensures group inheritance — critical for collaboration

Sticky bit (1) prevents users from deleting others’ files

Ownership + permissions together enforce access control

This task frequently appears in RHCSA and is high-value scoring





