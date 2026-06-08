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


# 🔖 Pregunta 10

### Create a Compressed Archive

On **Node1**, create a **compressed archive** of the directory **/usr/local** with the following requirements:

- The archive must be saved as **/root/backup.tar.bz2**.

- Use **bzip2 compression**.

----
<br>

## Explicación general

### Solution – Question 10

**1. Check tar options for bzip2**

```bash
# man tar
```

- Search for **bzip2** inside the man page by typing:

```bash
/bzip2
```

- Alternatively:

```bash
# tar --help | less
```

- Then search with **`/bzip2`** or **`/gzip`** to see the corresponding compression flags (**`-j`** for bzip2, **`-z`** for gzip, etc).

**Tip**: This is helpful in an exam environment to quickly confirm the correct flag for the desired compression.

----
<br>

**2. Create the archive**

```bash
# tar -cvjf /root/backup.tar.bz2 /usr/local
```

**Explanation of flags:

- **`-c`** → create a new archive

- **`-v`** → verbose (allows you to see the process)

- **`-j`** → use bzip2 compression

- **`-f /root/backup.tar.bz2`** → output file name (Note the f flag must be at the end of the combined flags, just before destination file name else it will throw an error.)

- The command will preserve directory structure, permissions, and ownership by default but you can add a **`-p`** flag to be certain (optional unless explicityly required).

----
<br>

**3. Verify the archive**

```bash
# ls -lh /root/backup.tar.bz2
# tar -tvjf /root/backup.tar.bz2 | head  (optional)
```

- Confirms the archive exists and lists some contents to ensure correctness.


