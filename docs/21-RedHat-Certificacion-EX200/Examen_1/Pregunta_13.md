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


# 🔖 Pregunta 13

### Configure Default File and Directory Permissions

On **Node1**, configure the system so that for the user bruce, the following default permissions apply:

Newly created **regular files** must have permissions set to **-r-------** by default.

Newly created **directories** must have permissions set to **dr-x------** by default.

The configuration must apply automatically to all future files and directories created by bruce.


----

<br>
# Explicación general


### Solution 

Configure Default Permissions for user **bruce**


**Step 1: Determine the required umask**

Required defaults:

   - Files: `-r-------` → `400`

   - Directories: `dr-x------` → `500`

Default base permissions:

   - Files: `666`

   - Directories: `777`

Calculated umask:

   - Files: `666 - 400 = 266`

   - Directories: `777 - 500 = 277`

✅ Final umask: `277`

----

<brs>
**Step 2: Set the umask for user `bruce`**

Edit the user’s shell configuration file:

```bash
# vim /home/bruce/.bashrc
```

Add the following line at the end of the file:

```bash
# umask 277
```

Save and exit.

----

<br>
**Step 3: Apply the configuration**

Log out and back in, or reinitialize the login shell:

```bash
# su - bruce
```

----

<br>
**Step 4: Verification (recommended)**

As user **`bruce`**, create a test file and directory:

```bash
# touch testfile
# mkdir testdir
# ls -l testfile testdir
```

Expected permissions:

   - `testfile` → `-r-------`

   - `testdir` → `dr-x------`

<br>

✅ **Result**

User **`bruce`** now creates:

   - Files readable only by himself

   - Directories accessible **(read + execute) only** by himself

----

<br>

💡 **Exam Tips**

**umask removes permissions**, it does not grant them, do not confuse it with **`chmod`** which grants permissions.

One umask must satisfy **both file and directory requirements.**

User-level umask settings in **`~/.bashrc`** or **`~/.bash_profile`** are **fully valid for RHCSA.**

Do not use ACLs unless explicitly required — umask is the expected solution here.



