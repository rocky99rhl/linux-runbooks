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


# 🔖 Pregunta 13


### Configure an Automount Directory with Autofs

On **Node1**, configure **autofs** to automatically mount a shared directory from Node2 with the following requirements:

- The remote directory **/srv/shared** on **Node2** should be mounted on **Node1** at **/mnt/shared** whenever it is accessed. (Configure Node2 to export /srv/shared using NFS - Check Exam 1 for hints)

- Use **autofs** so that the mount occurs automatically on access and unmounts after **5 minutes of inactivity**.

- Ensure that the mount is **read-write** for all users on **Node1**.

- The configuration must be persistent and work automatically after a system reboot.


----
<br>

## Explicación general

### Solution – Question 12: Configure an Automount Directory with Autofs
<br>

**1. Install autofs (if not installed), and nfs-utils (to use showmount)**

```bash
# dnf install -y autofs nfs-utils
```

----
<br>

**2. Verify the remote share on Node2**

```bash
# showmount -e <Node2-IP>
```

- Confirms that **`/srv/shared`** is exported and available for mounting.

- Example output:

```bash
Export list for 192.168.1.20:
/srv/shared
```

----
<br>

**3. Configure the autofs master map**

Edit **`/etc/auto.master`**:

```bash
# vim /etc/auto.master
```

Add the following line at the end:

```bash
/mnt  /etc/auto.mnt  --timeout=300
```

**Explanation:**

- **`/mnt`** → mount point on Node1

- **`/etc/auto.mnt`** → map file containing mount instructions

- **`--timeout=300`** → unmount after 5 minutes of inactivity

----
<br>


**4. Create the map file**

```bash
# vim /etc/auto.mnt
```

Add the following content:

```bash
shared   -rw   <Node2-IP>:/srv/shared
```

**Explanation:**

- **`shared`** → maps to **`/mnt`** in auto.master, forming **`/mnt/shared`**, to receive the /srv/shared directory from Node 2

- **`-rw`** → mount read-write

- **`<Node2-IP>:/srv/shared`** → remote NFS directory to mount

----
<br>

**5. Enable and start autofs**

```bash
# systemctl enable --now autofs
```

- Starts the autofs service and ensures it runs after reboot.

----
<br>

**6. Verify the autofs mount**

```bash
# ls /mnt/shared
```

- Accessing the directory triggers the mount automatically.

- After 5 minutes of inactivity, the mount is released automatically.

```bash
# mount | grep shared
```

- Confirms the NFS share is mounted.

<br>

!!! info "Tips"
    - showmount -e <Node2-IP> is helpful to verify exports before configuring.
    - The timeout is set in seconds (300s = 5 minutes).
    - You can test unmounting by waiting for 5 minutes or using:
    ```bash
    # sudo umount /mnt/shared
    ```
    - This method avoids permanent mounts in /etc/fstab and provides on-demand access.
