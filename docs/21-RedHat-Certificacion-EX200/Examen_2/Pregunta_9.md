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


# 🔖 Pregunta 9


### Extract Lines Containing a String from a File

On **Node1**, perform the following tasks:

- Search the file **/etc/passwd** for all lines containing the string **`bin`**.

- Save all matching lines **`in the same order`** to a file named **`/root/bin_lines`**.

- Ensure the resulting file preserves line order exactly as in the source.

----
<br>

# Explicación general

### Solution – Question 9

1. Extract lines and save to target file

```bash
# grep 'bin' /etc/passwd > /root/bin_lines
```

**Explanation:**

- **`grep 'bin' /etc/passwd`** searches for all lines containing the string **`bin`**.

- **`>`** redirects the output to **`/root/bin_lines`**, overwriting if the file exists.

- Line order is preserved automatically by **`grep`**.

----
<br>

**2. Verify the file**

```bash
# cat /root/bin_lines
# ls -l /root/bin_lines
```

- Ensures the file exists and contains the correct content.

**Optional Tips**

Use **`grep -n 'bin' /etc/passwd`** to also show line numbers for verification.

For appending instead of overwriting, use **`>>`** instead of **`>`**:

```bash
# grep 'bin' /etc/passwd >> /root/bin_lines
```

