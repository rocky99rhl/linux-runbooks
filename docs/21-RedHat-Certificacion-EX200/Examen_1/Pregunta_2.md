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

### Configure DNF/ RPM / YUM Repository Access

On **Node1**, configure repository access using the repositories located at:

https://repo.example.com/rhel9/BaseOS

https://repo.example.com/rhel9/AppStream

Ensure the repositories are enabled, **persist across reboots**, and can be used to install packages.

---



## Explicación general

### Solution – Question 2

### Method 1: Using dnf config-manager

- Enable repositories via `dnf config manager`:

```bash
 Enable repository access for BaseOS
# dnf config-manager --add-repo=https://repo.example.com/rhel9/BaseOS
 
 Enable repository access for AppStream
# dnf config-manager --add-repo=https://repo.example.com/rhel9/AppStream
```

- Verify that the repositories are available:
```bash
# dnf repolist
```

✅ Both repositories should appear as enabled, however, they cannot be used because gpgcheck is not set. Check the names given to them by dnf config-manager by running:


```bash
# ls /etc/yum.repos.d
```

Then for each of the two baseos and appstream repo files, open and enter `gpgcheck=0 at` the end, or run the commands:

```bash
# echo "gpgcheck=0" >> /etc/yum.repos.d/repo_BaseOS.repo
# echo "gpgcheck=0" >> /etc/yum.repos.d/repo_AppStream.repo
```

---

### Method 2: Manual Repository File Setup


Create a repo file for BaseOS:

```bash
# vim /etc/yum.repos.d/baseos.repo
```

Add the following content:

```bash

[baseos]
name=BaseOS
baseurl=https://repo.example.com/rhel9/BaseOS
enabled=1
gpgcheck=0
Create a repo file for AppStream:
```

```bash
# vim /etc/yum.repos.d/appstream.repo
```

Add the following content:

```bash
[appstream]
name=AppStream
baseurl=https://repo.example.com/rhel9/AppStream
enabled=1
gpgcheck=0
```

Verify repository availability:

```bash
dnf repolist
```

✅ Both repositories should be enabled and accessible.

---


### Notes / Exam Tips

When defining a repository, the identifier enclosed in square brackets must not contain spaces (for example, `[baseos]` is valid, whereas`[ baseos ]` will result in errors), as this identifier is used internally by DNF/YUM and must follow strict naming rules.

`gpgcheck=0` disables signature verification, which is acceptable in local/test repositories for exam purposes.

Both methods persist across reboots automatically.

Verification using `dnf repolist`  ensures repositories are functional.


---


### BONUS

CONFIGURING LOCAL REPOSITORY ACCESS (EXAM CONTEXT)

In this question, a **dummy HTTPS link** was used to illustrate repository configuration syntax as required in EX200 Exam. In the actual RHCSA exam, such a link will point to a **fully functional repository source**, enabling real package access and installations after configuring as we've done above.

A common and reliable approach in the local labs context is to configure a **local repository** using the installation media.

**Step 1 — Identify the Local Installation Media**

List available block devices:

```bash
# lsblk
```

The installation media is typically exposed as an optical device such as `sr0` or `sr1`.

When mounted automatically, it may appear under paths such as:

`/run/media/student/RHEL-9-6-0-BaseOS-aarch64` (commonly seen on macOS-based setups)

`/run/media/student/RHEL-9-6-0-BaseOS-x86_64` (commonly seen on x86_64 systems)

This directory contains the **BaseOS** and **AppStream** repository data.

**Step 2 — Mount the Media Persistently**

Create a mount point:

```bash
mkdir /repo
```

Edit `/etc/fstab` and add an entry similar to:

```bash
/dev/sr0  /repo  iso9660  ro  0  0 
OR 
/dev/sr0  /repo  iso9660  defaults  0  0
```

**Filesystem type:** `iso9660`

Mounting read-only is sufficient and recommended but defaults work fine too.

Mount the filesystem and verify contents are available on /repo:

```bash
mount -a
ls /repo
```

**Step 3 — Use the Local Media as a Repository Source**

Once mounted, the local installation media can be used as a repository source.

You may configure access using **either method:**

**Option 1:** Using `dnf config-manager`

Add repositories pointing to:

`file:///repo/BaseOS` (# dnf config-manager --add-repo=file///repo/BaseOS)

`file:///repo/AppStream` ((# dnf config-manager --add-repo=file///repo/AppStream)

Then configure `gpgckeck=0` as illustrated earlier



**Option 2: Manual Configuration**


Create repository files under `/etc/yum.repos.d/` as illustrated earlier.

Define repositories using:

`baseurl=file:///repo/BaseOS`

`baseurl=file:///repo/AppStream`

Ensure repositories are enabled and GPG checking is configured as required.

**Exam Note**

This local repository method is commonly used in the RHCSA exam environment and provides reliable access to essential packages without relying on external network connectivity. Correct mounting and repository configuration are critical for successful package installation and usage.




