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


# 🔖 Pregunta 18



### Logical Volume Configuration

On **Node2**, create a logical volume named **lvdata** and configure it according to the following requirements:

- The logical volume must be created from a volume group named **vgstore** and must use exactly **50 physical extents**.

- The volume group **vgstore** must be created from an lvm partition on **vdb** (or **sdb**, **nvme0n2**, as appropriate) and must use a physical extent size of **8 MiB**.

- Format the logical volume with the **ext4** filesystem and mount it persistently on **/mnt/data**.


----

<br>
# Explicación general


### Solution – Question 18

**Note (exam mindset):** Always calculate required disk space before partitioning to ensure enough room for physical extents and LVM metadata.

**1.- Calculate required partition size**

- Physical extent (PE) size: 8 MiB

- Number of extents required: 50

Minimum space for LV:

   - 50 × 8 MiB = 400 MiB

Add space ( generally 1 extent) for:

   - LVM metadata

   - Alignment overhead



✅ Safe partition size: ~450–500 MiB (or larger if disk allows)


**2.- Create an LVM partition on the disk**

(Use the appropriate disk: **`vdb`**, **`sdb`**, or **`nvme0n2`**)

```bash
# fdisk /dev/vdb
```

Inside **`fdisk`**:

- Create a new primary partition

    - At the fdisk prompt, type **`n`**
    
    - Select primary partition by typing **`p`**

    - Choose the partition number (usually 1 for the first partition).

- Accept defaults for the start sector
    
     - Press Enter to accept the default starting sector suggested by fdisk.
    
     - This ensures proper alignment with the disk geometry.
    
- Set the partition size

    - When prompted for the last sector, specify +500M (or larger) to allocate at least 500 MiB.

    - This ensures enough space for 50 physical extents plus LVM metadata overhead.

- Change the partition type to Linux LVM

    - At the fdisk prompt, type:

```bash
t
```

   - Enter the partition number created (1)

   - Enter the code for Linux LVM: 8e or lvm

   - Write the changes to disk and exit

   - Type:

```bash
p (to see and verify all partition information)
```

then

```bash
w 
```

   - This writes the new partition table and exits fdisk.

3.- Inform the kernel of partition changes (optional) 

```bash
# partprobe /dev/vdb
```

4.- Create the physical volume

```bash
# pvcreate /dev/vdb1
```

5.- Create the volume group with 8 MiB extent size

```bash
# vgcreate -s 8M vgstore /dev/vdb1
```

6.- Create the logical volume using exactly 50 extents

```bash
# lvcreate -l 50 -n lvdata vgstore
```

7.- Format the logical volume with ext4

```bash
# mkfs.ext4 /dev/vgstore/lvdata
```

8.- Create the mount point

```bash
# mkdir -p /mnt/data
```

9.- Mount the logical volume

```bash
# mount /dev/vgstore/lvdata /mnt/data
```

10.- Configure persistent mounting


Edit `/etc/fstab` using **vim**:

```bash
# vim /etc/fstab
```

Add the following line:

```bash
/dev/vgstore/lvdata  /mnt/data  ext4  defaults  0 0
```

11.- Verify configuration

```bash
# df -h /mnt/data
# lvs
# vgs
```



