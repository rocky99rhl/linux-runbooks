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


# 🔖 Pregunta 12


### Create a Shell Script

On **Node1**, create a shell script named **bash_users.sh** with the following requirements:

- The script must **find all users on the system whose login shell is `/bin/bash`**.

- Only display the **usernames**.

- The output should be saved to **/root/bash_users.txt**.

- The script must be **executable** and reusable (can be run multiple times to update the file).

- Run the script once and verify it works as expected.

----
<br>


## Explicación general

### Solution – Question 11
<br>

**1. Create the shell script file in /root**

```bash
# vim bash_users.sh
```

**Option 1: Add the following content using awk:**

```bash
#!/bin/bash
# Script to list all users with /bin/bash shell
 
awk -F: '$7=="/bin/bash" {print $1}' /etc/passwd > /root/bash_users.txt
```

Explanation:

- **`-F`**: → sets : as the field separator

- **`7=="/bin/bash"`** → selects lines where the 7th field (login shell) is /bin/bash

- **`{print $1}`** → prints only the username

----
<br>

**Option2: using grep and cut/awk:**

```bash
#!/bin/bash
# Script to list all users with /bin/bash shell
 
grep '/bin/bash' /etc/passwd | awk -F: '{print $1}' > /root/bash_users.txt
```

**Explanation:**

grep '/bin/bash' /etc/passwd → selects lines with /bin/bash

----
<br>

**2. Make the script executable**

```bash
# chmod +x bash_users.sh
```

----
<br>

**3. Run the script**

```bash
# ./bash_users.sh
```

----
<br>

**4. Verify the output**

```bash
# cat /root/bash_users.txt
```

Expected example output:

```bash
root
linda
michael
alain
...
```

!!! info "Tip"
    - The script can be run multiple times to refresh/update the **`/root/bash_users.txt`** file hence ensure you are 
    writing (**`>`**) not appending (**`>>`**). Appending will cause repetition every time the script is run.

    - Make sure **`/root/bash_users.sh`** has the correct shebang (**`#!/bin/bash`**) to execute properly.

    - The method used to create the script doesn't matter as long as it has the expected behaviour.



