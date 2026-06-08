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


# 🔖 Pregunta 16


### Create a User Script That Executes at Login

On **Node1**, perform the following tasks as the user john:

1.- Create a shell script that searches for the string **`"bash"`** in **`/etc/passwd`** and copies the matching lines, **in the same order**, to **`/home/john/bash-users.txt`**.

2.- Configure the script to **automatically run whenever john logs in**.

**Requirement:**

   - Use any name of the script.

   - Grant privileged access of **/etc/passwd** to user john if necessary.

   - The script must be user-specific; do **not modify system-wide** login scripts.

----

<br>
# Explicación general


### Solution – Question 16


**Step 1: Switch to user john**

```bash
# su - john
```

----

**Step 2: Create the script**

```bash
# vim /home/john/search_bash.sh
```

Add the following content:

```bash
#!/bin/bash
grep "bash" /etc/passwd > /home/john/bash-users.txt
```

   - `grep "bash" /etc/passwd` → searches for the string "bash" in /etc/passwd
   
   - `>` → redirects output to /home/john/bash-users.txt
   
   - Preserves **original order** of lines

Save and exit.

----

<br>
**Step 3: Make the script executable**
```bash
# chmod +x /home/john/search_bash.sh
```

----

<br>
**Step 4: Configure script to run at login**

Add the script to **john’s** **`.bash_profile`**:


```bash
# vim /home/john/.bash_profile
```

OR


```bash
# vim ~/.bash_profile (if already logged in as user john)
```

Append:


```bash
# /home/john/search_bash.sh
```

Save and exit.

----

<br>
**Step 5: Verify execution**

Log out and log back in as **john** (or start a new shell):

```bash
# su - john
```

Check the output file:

```bash
# cat /home/john/bash-users.txt
```

The file should be present and contain all lines from **`/etc/passwd`** that include **`"bash"`**, in original order.

----

<br>
💡 **Exam Tips**

The name of the script didn't matter in this case, it just has to run a certain task when user john logs in.

Always use **`> file`** to overwrite output, preserving line order. This also helps ensure running the script multiple times will not keep appending new results.

Adding the script to **`~/.bash_profile`** ensures it runs at **login** without affecting other users.

Ensure **execute permissions**; otherwise the script will not run.


