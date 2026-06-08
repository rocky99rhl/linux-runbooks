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


### Locate, Copy, and Secure Files

On **Node1**, perform the following tasks:

Locate all **regular files** under the **/etc** directory that are **larger than 5 MB but smaller than 10 MB.**

Copy all matching files to the directory **/find/largefiles.**

Preserve the original file **ownership, permissions, and timestamps** during the copy operation.

----

<br>
# Explicación general


### Solution - Question 10


<br>
**Step 1: Create the destination directory (if it does not already exist)**


```bash
# mkdir -p /find/largefiles
```

----

<br>
**Step 2: Locate and copy the required files**


Find regular files under **/etc** that are **larger than 5 MB but smaller than 10 MB,** and copy them while **preserving ownership, permissions, and timestamps:**

<br>
```bash
# find /etc -type f -size +5M -size -10M -exec cp -a {} /find/largefiles/ \;
```

----

<br>
**🔍 Explanation (exam clarity)**

`-type f` → ensures only **regular files** are matched

`-size +5M` → files **greater than 5 MB**

`-size -10M` → files **less than 10 MB**

`cp -a` → preserves:

   - ownership

   - permissions

   - timestamps

   - SELinux context




