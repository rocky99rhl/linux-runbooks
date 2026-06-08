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


### Create Swap Partition

On **Node2**, perform the following tasks:

1.- Create a **512 MB swap partition** on the same disk used previously (vdb, sdb, or nvme0n2, as appropriate).

2.- Configure the system to use this partition as swap space.

3.- Ensure the swap is **enabled immediately** and **mounted persistently** so that it is active after a reboot.

----

<br>
# Explicación general

### Solution – Question 19

Create Swap Partition (Node2)

<br>
**1. Create the swap partition using fdisk**

```bash
# fdisk vdb
```

Inside **`fdisk`**:

Create a new partition, type **`n`**

Select **primary partition**, type **`p`**

Choose the partition number (e.g., **`2`** if first partition is **`1`**).

Accept default start sector by pressing **Enter**.

Set the size to **+512M**.

Change the partition type to **Linux swap**, type **`t`**

Enter the partition number **`(2)`** and code **`82`** for swap.

Write changes and exit, type **`w`**

----


**2. Inform the kernel of partition changes**

```bash
# partprobe vdb
```

----

**3.- Format the partition as swap**

```bash
# mkswap /dev/vdb2
```

----

**4.- Enable swap immediately**

```bash
# swapon /dev/vdb2
```

----

**5.- Verify swap is active**

```bash
# swapon --show
# free -h
```

----

**6. Configure persistent swap in** **`/etc/fstab`**

```bash
# vim /etc/fstab
```

Add the following line:

```bash
/dev/vdb2   swap   swap   defaults   0 0
```

----

**7.- Test persistence**

- Reboot the system:

```bash
# reboot
```

- Verify swap is active after reboot:

```bash
# swapon --show
# free -h
```





