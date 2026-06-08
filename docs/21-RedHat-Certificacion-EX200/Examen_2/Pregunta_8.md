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


# 🔖 Pregunta 8



### Locate and Copy User Files

On **Node1**, perform the following tasks:

- Locate all **regular files** under the filesystem that are **owned by the user linda** and whose sizes are **greater than 3 MB but less than 50 MB.**

- Copy all matching files to the directory **/root/linda-files.**

----
<br>

## Explicación general


###Solution – Question 8

**1. Create the destination directory**

```bash
# mkdir -p /root/linda-files
```

**`-p`** ensures parent directories are created if they don’t exist.

----
<br>

**2. Locate files owned by linda with size between 3 MB and 50 MB**

```bash
# find / -type f -user linda -size +3M -size -50M
```

**Explanation:**

- **`-type f`** → regular files only

- **`-user linda`** → files owned by linda

- **`-size +3M`** → files larger than 3 MB

- **`-size -50M`** → files smaller than 50 MB

<br>

**Tip:** You can test the command first without copying to ensure the correct files are identified.

----
<br>

**3. Copy the files to intended destination**

```bash
# find / -type f -user linda -size +3M -size -50M -exec cp {} /root/linda-files/ \;
```

**Explanation:**


- **`-exec cp {} /root/linda-files/ \;`** copies each file found

----
<br>

**4. Verify copied files**

```bash
# ls -l /root/linda-files
```

- Ensures files exist and attributes are preserved.


