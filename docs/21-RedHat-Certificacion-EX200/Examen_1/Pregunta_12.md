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

### Archive and Compress System Files

On **Node1**, create a compressed archive of the directory **/var/tmp** with the following requirements:

The archive must include all files and subdirectories under **/var/tmp**

The archive must be compressed using **gzip**

Save the resulting archive as **/root/backup.tar.gz**

The operation must preserve file permissions and directory structure


----

<br>
# Explicación general

### Solution - Question 12

Run the command `# man tar` and use `/gzip` to search what option is used with tar for gzip compression (z), then run

```bash
# tar -cvzpf /root/backup.tar.gz /var/tmp
```

**Tips (exam-relevant):**

   - `-c` creates the archive, `-v` for verbose, `-z` enables gzip compression, `-p` preserves permissions, and `-f` specifies the output file.

   - Always use an `f` tag just before the destination archive.

   - You can quickly verify the archive contents (without extracting) using:

```bash
# tar -tzf /root/backup.tar.gz
```




