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



### Configure Apache to Use a Custom Port

On **Node1**, configure the Apache HTTP server to meet the following requirements:

- Install, enable, and start the Apache web service.

- Configure the web server to listen on TCP port **82**.

- Create a file named **file1** under **/var/www/html** containing the text:

```bash
RHCSA TEST 2
```

- Ensure the file has the correct SELinux context so that it can be served by Apache.

- When accessing the server locally using:

```bash
curl http://localhost:82/file1
```

the output must display:

```bash
RHCSA TEST 2
```

- Ensure the service remains accessible after a system reboot.

----
<br>

## Explicación general


### Solution - Configure Apache on Port 82 and Serve a File


**1. Install Apache**

```bash
# dnf install -y httpd
```

----
<br>

**2. Enable and start the Apache service**

```bash
# systemctl enable --now httpd
```

----
<br>

**3. Configure Apache to listen on port 82**

Edit the Apache main configuration file:

```bash
# vim /etc/httpd/conf/httpd.conf
```

Find the line:

```bash
Listen 80
```

Change it to:

```bash
Listen 82
```

Save and exit.

----
<br>

**4. Allow Apache to use port 82 in SELinux**

```bash
# semanage port -a -t http_port_t -p tcp 82
```

If the port already exists and the command fails, use:

```bash
# semanage port -m -t http_port_t -p tcp 82
```

Tip:

```bash
# man semanage-fcontext (go to EXAMPLE)
```

is a useful reference for correct SELinux syntax when managing file contexts.

----
<br>

**5. Open port 82 in the firewall**

```bash
# firewall-cmd --permanent --add-port=82/tcp
# firewall-cmd --reload
```

----
<br>

**6. Create the required file and content**

```bash
# echo "RHCSA TEST 2" > /var/www/html/file1
```

----
<br>

**7. Ensure correct SELinux context on the file**

```bash
# restorecon -v /var/www/html/file1
```

(If custom paths were used, you would define a context with **`semanage fcontext`** then run **`restorecon`**.)

----
<br>

**8. Restart Apache to apply changes**

```bash
# systemctl restart httpd
```

----

**9. Verify locally**

```bash
# curl http://localhost:82/file1
```

Expected output:

```bash
RHCSA TEST 2
```


