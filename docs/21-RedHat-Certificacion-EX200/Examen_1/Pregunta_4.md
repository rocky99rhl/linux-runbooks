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

### User and Group Management

On **Node1**, perform the following user and group management tasks:

1.- Create a group named **admins** with a fixed GID of **3500**.

2.- Create a group named **users**

3.- Create the following user accounts with the specified requirements:

- **harry**

    - Primary group:  **admins**

    - Secondary group **users**

    - User ID **3455**

- **natasha**

    - Supplementary groups: admins and users

    - User ID of 3456

- **sarah**

    - Must not be a member of the admin group

    - Must not have access to an interactive shell

    - The account must still be able to authenticate

- **bruce**

    - Must belong to **admin**

    - Home directory must be created explicitly

    - Set the password for all created users to:

```bash
password
```

----

<br>

## Explicación general

### Solution – Question 4

<br>

**Step 1: Create the required groups**

Create the **admins** group with a fixed GID and the **users** group.

```bash
# groupadd -g 3500 admins
# groupadd users
```

----

<br>

**Step 2: Create user accounts**

**Create user harry**

Primary group: admins

Secondary group: users

Home directory under /home

```bash
# useradd -g admins -G users harry
```

----

<br>

**Create user natasha**

Supplementary groups: admins, users

```bash
# useradd -G admins,users natasha
```

----

<br>

**Create user sarah**

Not a member of admins

No interactive shell

Must still be able to authenticate

Home directory under /home

```bash
# useradd -s /sbin/nologin sarah
/sbin/nologin prevents interactive shell access while still allowing authentication for services.
```

----

<br>

**Create user bruce**

Must belong to admins

Home directory must be explicitly created

```bash
# useradd -G admins -m bruce
```

----

<br>

**Step 3: Set passwords for all users**

Set the password password for each account.

```bash
# passwd harry
# passwd natasha
# passwd sarah
# passwd bruce
(Enter password when prompted.)
```

OR scripted:

```bash
# for user in harry natasha sarah bruce; do echo "password" | passwd --stdin $user; done
```

----

<br>

**Step 4: Verification (Recommended in Exam)**

Verify group membership

```bash
# id harry
# id natasha
# id sarah
# id bruce
```

Verify home directory of user bruce

```bash
# ls -ld /home/bruce
```

Verify shell access

```bash
# getent passwd sarah
```

----
<br>

Expected output should show:

```bash
sarah:x:...:/home/sarah:/sbin/nologin
```


