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


# 🔖 Pregunta 14


### Enforce Password Policies for New Users

On **Node1**, configure the system so that **all newly created users** meet the following password requirements:

   - Passwords must **expire after 30 days.**

   - Passwords must be at least **9 characters long.**

   - The configuration must apply automatically to **all future user accounts.**

<br>
----


# Explicación general


### Solution - Question 14


**Step 1: Configure password expiration defaults**


Set the default maximum password age to 30 days for all new users by editing **`/etc/login.defs`** Locate and modify (or add if missing) the following parameters:

```bash
PASS_MAX_DAYS   30
PASS_MIN_LEN    9
```

   - PASS_MAX_DAYS → sets maximum password age in days (30 in this case).

   - PASS_MIN_LEN → sets minimum password length (Currently obsolete)

Save and exit.

----

<br>
**Step 2: Enforce minimum password length (Right Approach)**

Edit the PAM password quality configuration:

```bash
# vim /etc/security/pwquality.conf
```

Set the following parameter:

```
# minlen = 9
```

   - This ensures **all new passwords must be at least 9 characters**.

----

<br>
**Step 3: Verification (optional but recommended)**


Create a test user to confirm defaults:

```bash
# useradd testuser
# chage -l testuser
# passwd testuser
```

Check that:

   - Maximum password age = 30 days

   - Password prompts enforce minimum length = 9 characters

<br>
💡 **Exam Tips**

   - Minimum password length enforcement is handled via `/etc/security/pwquality.conf` (PAM) and no longer in `/etc/login.defs`.

   - It's OK to verify by creating a dummy user


