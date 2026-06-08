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


## Reset Root Password

On **Node2**, perform the following task:

Assume you do not know the root password.

Break into the system during boot and reset the root password to:

redhat

Ensure that after resetting, the root account can log in normally.


Explicación general
Solution – Question 16

Preferred Method – Using init=/bin/bash

Reboot Node2 and access the GRUB menu.

Edit the kernel entry:

Press e at the GRUB menu.

Find the line starting with linux or linux16.

Append init=/bin/bash at the end of the line.

Boot into single-user shell:

Press Ctrl+x or F10 to boot.

Remount root filesystem as read-write:

# mount -o remount,rw /
Reset the root password:

# passwd root
Enter the new password:

redhat
Continue the boot process with systemd:

# exec /sbin/init
OR
# exec /usr/lib/systemd/systemd


Alternative Method – Using rd.break

Reboot Node2 and access the GRUB menu.

Edit the kernel entry:

Append rd.break at the end of the linux line.

Boot into emergency shell.

The root filesystem is mounted under /sysroot.

Switch to the real root filesystem:

# chroot /sysroot
Reset the root password:

# passwd
Enter the new password:

redhat
Relabel SELinux contexts (important for RHEL/CentOS):

# touch /.autorelabel
Exit chroot and continue boot:

# exit
# reboot
Verification

After reboot, log in as root with the new password.

