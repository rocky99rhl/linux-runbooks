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


# 🔖 Pregunta 17



### Reset Root Password

On **Node2, assume the root password is unknown.** Reset the root password to:

**`rootpass`**

Ensure the system boots normally and the new password works for root login.

----


<br>
# Explicación general


### Solution - Question 17


✅ **Preferred Solution: Using `init=/bin/bash`**

Steps

1.- Reboot the system.

2.- At the GRUB menu, highlight the default kernel and press **`e`**.

3.- Locate the line starting with **`linux`** or **`linux16`**.

4.- Append the following to the end of that line:

```bash
init=/bin/bash
```

5.- Boot with **Ctrl + X**.

6.- Remount the root filesystem as read-write:

```bash
# mount -o remount,rw /
```

7.- Set the new root password:

```bash
# passwd
```

8.- Enter the new password:

```bash
rootpass
```

9.- Ensure SELinux relabeling on next boot:

```bash
# touch /.autorelabel
```

10.- Reboot the system:

```bash
# exec /usr/lib/systemd/systemd
```

----

<br>
✅ Alternative Solution: Using rd.break

Steps

1.- Reboot the system.

2.- At the GRUB menu, select the default kernel and press **`e`**.

3.- Locate the kernel line and append:

```bash
rd.break
```

4.- Boot with **Ctrl + X**.


5.- You will be dropped into an initramfs shell. Remount the sysroot as read-write:

```bash
# mount -o remount,rw /sysroot
```

6.- Change root into the system environment:

```bash
# chroot /sysroot
```

7.- Set the new root password:

```bash
# passwd
```

Enter:

```bash
rootpass
```

8.- Create the SELinux relabel file:

```bash
# touch /.autorelabel
```

9.- Exit and reboot:

```bash
# exit
# reboot
```

