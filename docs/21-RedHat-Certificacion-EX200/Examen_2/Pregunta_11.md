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


# 🔖 Pregunta 11


## Restore a Compressed Archive

On **Node1**, extract the contents of the archive **/root/backup.tar.bz2** with the following requirements:

- Restore the contents into the directory **/root/usr_local**.

----
<br>


## Explicación general


### Solution – Question 10: Extract bzip2 Compressed Archive to /root/usr_local

**1. Create the target directory (if it doesn’t exist)**

```bash
# mkdir -p /root/usr_local
```

----
<br>

**2. Extract the archive while preserving permissions, ownership, and directory structure**

```bash
# tar -xjf /root/backup.tar.bz2 -C /root/usr_local
```

**Explanation of flags:**

- **`-x`** → extract files from an archive

- **`-j`** → use bzip2 decompression

- **`-f /root/backup.tar.bz2`** → specify the archive file

- **`-C /root/usr_local`** → extract into this target directory

----
<br>

**3. Verify extraction**

```bash
# ls -l /root/usr_local
```

- Ensures that files and directories from **`/usr/local`** are present in **`/root/usr_local`**.

- Check that permissions and ownership match the original.

**Tip:**

- If unsure about flags, run:

```bash
# man tar
# tar --help | less
```

- Search for **`/bzip2`** in **`# man tar`** to confirm that **`-j`** is the correct option for bzip2 archives.


