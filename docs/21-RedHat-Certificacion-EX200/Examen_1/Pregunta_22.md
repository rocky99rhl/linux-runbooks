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


# 🔖 Pregunta 22


### Containers/Flatpak Configuration



**RHCSA 9 ONLY - Run a Rootless Container as a Systemd Service**

On **Node2**, as the non-root user **russ**, create and manage a container with the following requirements:

Pull the container image **registry.redhat.io/ubi9/ubi** from the Red Hat registry (create a developers.redhat.com account if required and authenticate to the registry using valid credentials).

Run a container named **ubicon** based on this image.

Configure the container to:

- Map host port **8089** to container port **8089**

- Persist data by binding **two host directories**, including **/opt/out** on the host to **/opt/in** inside the container, and a second host directory **/opt/send** to **/opt/receive** in the container.

Finally, configure the container to be managed as a **user-level systemd service** with the name **container-ubicon**, ensuring it is enabled and automatically starts on system reboot without requiring root privileges.


----

<br>
**RHCSA 10 ONLY - Configure Flatpak Repositories**

On **Node1**, perform the following tasks:

1.- Install the **flatpak** package manager using the appropriate system package management tools.

2.- Add the official **flathub** remote repository to the system using the link:

```bash
https://flathub.org/repo/flathub.flatpakrepo
```

3.- Add the official rhel flatpak remote repository if not present. Use the link:

```bash
https://flatpaks.redhat.io/rhel.flatpakrepo
```

4.- Verify that all configured flatpak remotes are properly added to the system.

----

<br>
# Explicación general


### Solution – Question 22

----

<br>
**RHCSA 9 - Run a Rootless Container as a systemd Service**


<br>
**1. Create the user and set a password (run as root on Node2)**

```bash
# useradd russ
# passwd russ
```

<br>
**Explanation:**

The container must run rootless, so the required user must exist and be able to log in.

Enable lingering so the service starts at boot (run once as root)

```bash
# loginctl enable-linger russ
```

----

<br>
**2. Create host directories for persistent storage (run as root)**

```bash
# mkdir -p /opt/out /opt/send
```
<br>
**Explanation:**

Directories under **`/opt`** are outside any user’s home directory and are owned by root by default.
A non-root user cannot create directories here without elevated privileges.
(If the paths were under **`/home/russ/--`** e.g **`/home/russ/opt/out`** or **`~/opt/--`**, this step could be done as the user instead.)

----

<br>
**3. Set ownership and permissions for rootless container access**

```bash
# chown russ:russ /opt/out /opt/send
# chmod 777 /opt/out /opt/send
```

**Explanation:**

Rootless containers run entirely with the user’s UID and GID.
Changing ownership ensures the container process can read and write to the bind-mounted directories without permission errors.

----

<br>
**4. Switch to the user russ**

```bash
# ssh russ@localhost
```

**Explanation:**

All container and systemd-user operations must be performed as the same non-root user who owns and runs the container. **`SSH`** or **`console login`** is the recommended and reliable method for managing systemd user services, including rootless Podman containers. Do not use **`su`**.

----

<br>
**5. Log in to the Red Hat container registry**

```bash
# podman login registry.redhat.io
```

**Explanation:**

The UBI image is hosted on Red Hat’s authenticated registry.
Valid credentials from developers.redhat.com are required before pulling the image.

----
<br>
**6. Pull the required image**

```bash
# podman pull registry.redhat.io/ubi9/ubi
```

**Explanation:**

Pulling the image explicitly confirms registry access and avoids authentication failures during container startup.

----

<br>
**7. Run the container with required configuration**

```bash
# podman run -d --name ubicon -p 8089:8089 -v /opt/out:/opt/in:Z -v /opt/send:/opt/receive:Z registry.redhat.io/ubi9/ubi
```

**Explanation:**


- `-d` runs in the background (detached mode)

- `-p` 8089:8089 maps host traffic to the container

- `-v` binds host directories for persistent data

- `:Z` applies correct SELinux labels so the container can access the directories

----

<br>
**8. Create the user-level systemd unit directory**

```bash
# mkdir -p ~/.config/systemd/user
# cd ~/.config/systemd/user
```

**Explanation:**

User-level systemd services must reside in this directory for systemd to manage them without root privileges.

----
<br>
**9. Generate a systemd service for the container**

```bash
# podman generate systemd --name ubicon --files --new
```

**Explanation:**

This converts the running container into a systemd unit.
The resulting service file is named container-ubicon.service, which systemd requires.

----

<br>
**10. Reload systemd and enable the service**

```bash
# systemctl --user daemon-reload
# systemctl --user enable --now container-ubicon.service
```

**Explanation:**

- Reloading ensures systemd detects the new unit file

- Enabling the service ensures it starts automatically

- `--user` restricts management to the user scope

<br>
**Explanation:**


- User systemd services normally stop when the user logs out.
- Enabling lingering allows the container service to start automatically at system boot without requiring an active login.

- SSH or console login is preferred over using **`su`** when configuring systemd user services (including rootless containers) because it creates a **full user login session** managed by **`systemd-logind`**. This session initializes the user’s systemd instance, runtime directory (**`/run/user/<UID>`**), D-Bus session, and user environment required for **`systemctl --user`** to function correctly.

In contrast, switching users with **`su`** does **not** start a proper login session. As a result, the user-level systemd instance is not initialized, and commands such as **`systemctl --user`** may fail with errors like “Failed to connect to bus” or behave inconsistently.


----

<br>
**RHCSA 10 - Configure Flatpak**

<br>
**Step 1: Install the Flatpak Package Manager**

Flatpak itself is installed using the standard RHEL package manager (**dnf**), because Flatpak is just another RPM package.

Command:

```bash
# dnf install -y flatpak
```

**Explanation:**

- **`dnf`** → RHEL package manager

- **`install`** → install a package

- **`y`** → automatically answer yes

- **`flatpak`** → package name

This installs:

- Flatpak CLI tools

- Required dependencies

Verify installation:

```bash
# flatpak --version
```

If installed properly, it should return the version number.

You can also confirm via:

```bash
# rpm -q flatpak
```

----
<br>
**Step 2: Add the Flathub Remote Repository**

Flatpak uses **remotes**, not traditional yum repos.

A remote is simply a source where Flatpak applications are hosted.

We now add Flathub using the provided link.

Command:

```bash
# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

**Explanation:**

- **`remote-add`** → adds a new Flatpak repository

- **`--if-not-exists`** → prevents duplicate errors if already added

- **`flathub`** → name we assign to the remote

- **`URL`** → repository definition file

This downloads the repository metadata and configures it **system-wide**.

----

<br>
**Step 3: Add the RHEL Flatpak Remote Repository**

Now add the official Red Hat Flatpak remote.

⚠ **Important:**

If this is a real RHEL system, the **rhel** remote repo might be available by default. If it's not, then ensure the system is registered before running the following commands to add it, or login when prompted. (In the exam, you'd be given valid login credentials):

```bash
# flatpak remote-add --if-not-exists rhel https://flatpaks.redhat.io/rhel.flatpakrepo
```

**Explanation:**

- **`rhel`** → remote name

- **`URL`** → Red Hat’s Flatpak repository definition

Supplementary commands if not registered (Optional):

```bash
# subscription-manager status
# subscription-manager register
# subscription-manager attach --auto
```

Without subscription, access may fail.

----

<br>
**Step 4: Verify All Configured Flatpak Remotes**

Now confirm both remotes were added successfully.

Basic verification:

```bash
# flatpak remotes
```

Expected output should show:

```bash
flathub
rhel
```

Detailed verification (optional):

```bash
# flatpak remotes --show-details
```

This displays:

- Remote name
- URL
- Collection ID
- Priority

This confirms the system recognizes both repositories.



**Additional Notes:**

What Just Happened (Concept Clarification)

Traditional RHEL package workflow:

```bash
dnf → RPM repos → install system packages
```

Flatpak workflow:

```bash
flatpak → remotes → install sandboxed applications
```

Flatpak applications:

- Are user-space apps

- Run isolated from the base OS

- Do not modify core system libraries

This is why Flatpak is increasingly relevant in RHEL 10 environments.

Persistence

Flatpak remotes are stored under:

```bash
/etc/flatpak/
```

They persist across reboots automatically.

If troubleshooting:

- Use:

```bash
flatpak remote-list
flatpak remote-delete <name>
```

- Check DNS resolution issues (in case you get errors)

- Ensure subscription is active for RHEL remote



