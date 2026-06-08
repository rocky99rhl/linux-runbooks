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


# 🔖 Pregunta 6


### Configuring NFS + Autofs

On **Node1**, configure **autofs** to automatically mount remote user home directories with the following requirements:

   - Install and enable the autofs service.

   - Configure automounting so that user home directories are accessed under **/homes/remote**.

   - The remote NFS export is available from **server.example.com** at /exports/home. This directory contains many user home directories      such as /exports/home/john, **/exports/home/mary**, etc.

   - Home directories must be mounted **on demand** and unmounted automatically after 60s of inactivity.

   - The autofs configuration must persist across reboots.

   - Do not manually mount the filesystem.

**Configuring Node2 as an NFS Server so that Node1 is its NFS Client**

<br>
Step 1: Install required NFS packages

```bash
# dnf install -y nfs-utils
```

<br>
Step 2: Create the export directory

```bash
# mkdir -p /exports/home
```

(Optional but realistic for practice)

```bash
# chmod 755 /exports/home
```

Add the directories mary and john in /exports/home with any relevant contents.

<br>
Step 3: Configure NFS exports

Edit /etc/exports:

```bash
# vim /etc/exports
```

Add the following line:

```bash
/exports/home  *(rw,sync,no_root_squash) 
```

This allows read/write access and ensures predictable behavior for lab environments.
Note for simplicity, just

```bash
/exports/home  *(rw)
```

is sufficient and should work normally.
The `*` in `/exports/home *(rw)` allows access from any host; to restrict access explicitly to **Node1**, replace `*` with Node1's hostname or IP address, for example

`/exports/home node1.example.com(rw).`

`/exports/home 192.168.50.25(rw)`


<br>
Step 4: Enable and start the NFS services

```bash
# systemctl enable --now nfs-server
```

Confirm status:
```bash
# systemctl status nfs-server
```
<br>
Step 6: Configure the firewall to allow NFS access

```bash
# firewall-cmd --permanent --add-service=nfs
# firewall-cmd --permanent --add-service=mountd
# firewall-cmd --permanent --add-service=rpc-bind
```

OR scripted:

```bash
for service in nfs mountd rpc-bind; do firewall-cmd --add-service="$service" --permanent; done;
Next (very important)
```

```bash
# firewall-cmd --reload
```
<br>
Step 7: Verification (recommended)

From Node2:
```bash
# showmount -e localhost
```

Expected output should include:

```bash
/exports/home *
```

✅ Result

Node2 is now successfully configured as an **NFS server exporting** `/exports/home`, ready to be consumed by **autofs on Node1** for the RHCSA practice scenario.

----

# Explicación general

### Solution – Question 6

Node1 Autofs Client Configuration

<br>
**Step 1: Install required packages**

```bash
# dnf install -y autofs nfs-utils
```

`autofs` → automounting service
`nfs-utils` → ensures NFS client tools are available

----

<br>
**Step 2: Verify NFS exports from the server**

```bash
# showmount -e server.example.com 
```

(Will work in the exam but will only work locally if DNS resolution is configured in /etc/hosts such that Node2-IP is pointing to server.example.com)

```bash
# showmount -e <Node2-IP>
```

on the other hand, will always work if everything is well configured.

Expected output:

```bash
/exports/home *
```

Confirms the remote NFS server is accessible and exports the expected directory.

----

<br>
**Step 3: Configure the autofs master map**

Edit `/etc/auto.master` using vim:

```bash
# vim /etc/auto.master
```

Add the line:

```bash
/homes/remote /etc/auto.remote --timeout=60
/homes/remote → mount point for remote home directories
/etc/auto.remote → indirect map defining NFS shares
--timeout=60 → unmount after 60 seconds of inactivity
```

----

<br>
**Step 4: Create the autofs map file**

Create /etc/auto.remote using vim:

```bash
# vim /etc/auto.remote
```

Add the following line (Expected Solution During Exam):

```bash
*      -fstype=nfs,rw     server.example.com:/exports/home/&    
```

With Node2 as NFS Server - for practice only:

```bash
*      -fstype=nfs,rw     <Node2-IP>:/exports/home/&    
```

`*` → wildcard matching any username requested under /homes/remote<br>
`&` → replaced by the username, mapping to the corresponding NFS directory

----

<br>
**Step 5: Enable and start the autofs service**

```bash
# systemctl enable --now autofs
# systemctl status autofs
```

-----

<br>
**Step 6: Verify autofs mounts**

Check the mount point exists:

```bash
# ls -ld /homes/remote
```

Access a user directory to trigger on-demand mount:

```bash
# ls /homes/remote/john
```

Verify the mount:

```bash
# mount | grep remote
```

Expected output example:

```bash
server.example.com:/exports/home/john on /homes/remote/john type nfs ...
Optional: confirm automatic unmount after timeout:
```

```bash
# sleep 65
# mount | grep remote
```

Directory should unmount automatically.


