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


# 🔖 Pregunta 7


### Create a User

On **Node1**, create a user account named **alain** with the following requirements:

- The user must have a fixed UID of **3445**.

- The user must belong to the supplementary group **sysgrp**.

- Set the user’s password to "passwd".

Configure the account so that the password **expires on 12 June 2029**, after which the user must change the password at next login.

----
<br>

## Explicación general

### Solution - Question 7

**1. Create the user with fixed UID and supplementary group**

```bash
# useradd -u 3445 -G sysgrp alain
```

- **`-u 3445`** sets the fixed UID.

- **`-G opsgrp`** adds alain to the supplementary group sysgrp.

----
<br>

**2. Set the user’s password**

Interactive method:

```bash
# passwd alain
```

Enter the desired password when prompted.

**Automated one-liner method:**

```bash
# echo "passwd" | passwd --stdin alain
```

----
<br>

**3. Set password expiration date**

```bash
# chage -E 2029-06-12 alain
```

- **`-E`** sets the account expiration date.

- Use the **`YYYY-MM-DD`** format.

<br>

**Tip:**

- Use **`timedatectl`** to check the current system date format if unsure.

- **`chage --help`** is a good reference to confirm which flags set password expiration and other user aging parameters.

----
<br>

**4. Verify configuration**

```bash
# chage -l alain
```

- Output should show:

   - Account expires: **`Jun 12, 2029`**

   - Password expiration and aging info

```bash
# id alain
```

- Confirms UID is **3445** and supplementary group is **sysgrp**.


