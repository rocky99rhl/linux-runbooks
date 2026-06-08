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


# 🔖 Pregunta 2


### Configure Local Repository Access

On **Node1**, configure **local YUM/DNF/RPM repository access** using the installation media only. The repositories must include:

- **BaseOS** repository

- **AppStream** repository

**Requirements:**

- Mount the installation media (ISO or virtual media) persistently so it can serve as a repository source.

- Configure the repositories to be available via either:

   - `/etc/yum.repos.d/*`.repo files or

   - `dnf config-manager` commands

- No internet or external repositories should be used; the solution must rely **entirely on local media**.

- The configuration must allow package installation with **`dnf install`** for any package present on the media.

----
<br>

## Explicación general


### Solution - Question 2

**Step 1 — Identify the Local Installation Media**

List available block devices:

```bash
# lsblk
```

The installation media is typically exposed as an optical device such as sr0 or sr1.

When mounted automatically, it may appear under paths such as:

- **`/run/media/student/RHEL-9-6-0-BaseOS-aarch64`** (commonly seen on macOS-based setups)

- **`/run/media/student/RHEL-9-6-0-BaseOS-x86_64 (commonly seen on x86_64 systems)`**

This directory contains the **BaseOS** and **AppStream** repository data.

----
<br>

**Step 2 — Mount the Media Persistently**

Create a mount point:

```bash
# mkdir /repo
```

Edit **`/etc/fstab`** and add an entry similar to:

```bash
/dev/sr0  /repo  iso9660  ro  0  0 
```

OR 

```bash
/dev/sr0  /repo  iso9660  defaults  0  0
```

- Filesystem type: iso9660


- Mounting read-only is sufficient and recommended.

Mount the filesystem and verify contents are available on /repo:

```bash
# mount -a
# ls /repo
```

----
<br>

**Step 3 — Use the Local Media as a Repository Source**

Once mounted, the local installation media can be used as a repository source.

You may configure access using **either method**:


**Option 1: Using `dnf config-manager` and handle `gpgcheck`**

- Add repositories pointing to:

   - file:///repo/BaseOS (#dnf config-manager --add-repo=file///repo/BaseOS)

   - file:///repo/AppStream ((#dnf config-manager --add-repo=file///repo/AppStream)

   - Then append gpgcheck=0 in each of both files.


----
<br>

**Option 2: Manual Configuration**

- Create repository files under **`/etc/yum.repos.d/`**

- Create a repo for the file AppStream:

```bash
# vim /etc/yum.repos.d/appstream.repo
```

Add the following content:

```bash
[appstream]
name=AppStream
baseurl=file:///repo/AppStream
enabled=1
gpgcheck=0
```

- Create a repo file for BaseOS:

```bash
# vim /etc/yum.repos.d/baseos.repo
```

Add the following content:

```bash
[baseos]
name=BaseOS
baseurl=file:///repo/AppStream
enabled=1
gpgcheck=0
```

<br>

!!! info "Exam Note"
    Using a local repository is standard practice in the RHCSA exam simulation environment, ensuring dependable 
    access to essential packages without depending on external network connections. Properly mounting the media 
    and configuring the repository are essential for successful package installation. In the actual EX200 exam, 
    the full-path repository links will be provided. Just replace the baseurl values with corresponding links.


