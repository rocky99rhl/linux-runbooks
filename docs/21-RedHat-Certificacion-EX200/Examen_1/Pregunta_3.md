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


# 🔖 Pregunta 3

### Configuring and Securing an Apache HTTP Service

On **Node1**, configure the **Apache HTTP Server** to meet the following requirements:

The Apache web service must be installed, enabled, and running.

The web server must listen on **TCP port 85**.

The service must be accessible from **both the local system and external hosts**.

When curled or accessed via a web browser, the server must display the following message:

```bash
 Welcome to the Apache Web Server!
```

----


# Explicación general

### Solution – Question 3

<br>
**Step 1: Install Apache (httpd)**

Ensure the Apache web server package is installed.

```bash
# dnf install -y httpd
```

----

<br>
**Step 2: Configure Apache to Listen on Port 85**

Edit the Apache main configuration file.

```bash
# vim /etc/httpd/conf/httpd.conf
```

Locate the Listen directive and modify it as follows:

```bash
Listen 85
```

Save and exit.

----

<br>
**Step 3: Create the Web Content**

Create or edit the default index page.
```bash
# vim /var/www/html/index.html
```

Add the required content:

```bash
Welcome to the Apache Web Server!
```
Save and exit.

----

<br>
**Step 4: Allow Port 85 Through the Firewall (External Access)**

Add port 85 to the firewall permanently and reload the rules.
```bash
# firewall-cmd --permanent --add-port=85/tcp
# firewall-cmd --reload
```

----

<br>
**Step 5: Configure SELinux to Allow Apache on Port 85**

Apache is restricted by SELinux to specific ports. You must explicitly allow port 85.

First, verify whether port 85 is already allowed:

```bash
# semanage port -l | grep http
```

If port 85 is not listed, add it:

You can use man pages to find good syntax examples to use here by running # man semanage port, search for examples using /EXAMPLE , copy and modify as relevant:

```bash
# semanage port -a -t http_port_t -p tcp 85
```
<br>
**Note:** The above step is mandatory on the exam if SELinux is enforcing (it is by default).

----

<br>
**Step 6: Enable and Start Apache**

Ensure Apache starts now and automatically at boot.

```bash
# systemctl enable --now httpd
```

----

<br>
**Step 7: Verification**

From the local system:

```bash
# curl http://localhost:85
```

From an external system (browser or curl):

```bash
# curl http://<node1-ip>:85
```

Expected output:

```bash
Welcome to the Apache Web Server!
```

----

