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


# 🔖 Pregunta 24



### Secure File Transfer  / Key-Based Authentication

On **Node2**, perform the following tasks as root or an appropriate privileged user:

1.- Configure **key-based, passwordless SSH authentication** from Node2 to Node1 for secure access to the user **natasha on Node1**.

2.- Once authentication is established, securely copy the file **/etc/fstab** from Node2 to **natasha’s home directory on Node1**.

3.- Ensure that the copied file is **owned by natasha** and retains appropriate permissions for her to read and write.

**Requirement:** Use a secure, encrypted method for the file transfer.

----

<br>
# Explicación general


### Solution – Question 23

<br>
**1. Generate an SSH key pair on Node2**

Run as the user performing the transfer (e.g., root or a privileged user):

```bash
# ssh-keygen
```

Press Enter until created, passphrase can be blank.

----

<br>
**2. Copy the public key to natasha’s account on Node1**

```bash
# ssh-copy-id natasha@<node1-IP> ( or root)
```

**Explanation:**

- This appends the public key to **`~/.ssh/authorized_keys`** for **`natasha`**

- Ensures passwordless SSH login from Node2 to Node1

----

<br>
**3. Test passwordless SSH login (optional)**

```bash
# ssh natasha@node1.example.com 'echo Key-based SSH working'
```

Should return: **`Key-based SSH working`** without prompting for a password

----

<br>
**4. Securely copy `/etc/fstab` to natasha’s home directory on Node1**

```bash
# scp /etc/fstab natasha@<node1-IP>:~/
```

OR

```bash
# scp /etc/fstab root@<node1-IP>:/home/natasha/ (if connecting to root)
```

**Explanation:**

- Uses SSH for encrypted transfer

- **`~`** refers to **`natasha`**’s home directory on Node1

----

<br>
**5. Verify ownership and permissions on Node1**

```bash
# ssh natasha@<node1-IP> 
```

then run 

```bash
# ls -l ~/fstab
```

- Confirm the file is owned by **`natasha`** and has read/write permissions as required


