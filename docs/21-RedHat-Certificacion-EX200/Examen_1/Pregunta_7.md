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


# 🔖 Pregunta 7


### Cron Job for User

On **Node1**, as the user **bruce**, perform the following tasks:

1.- Create a cron job that executes **daily at 11:45 AM**.

2.- The job should print the message:

```bash
EX200 Practice Test!
```

3.- The job should continue to exist and run as expected **across reboots**.

**Hint**: Use the standard `crontab` for the user rather than placing scripts in `/etc/cron.d` unless explicitly instructed.


----

# Explicación general


### Solution – Question 7

<br>
**Step 1: Switch to the user bruce**

```bash
# su - bruce
```

----

<br>
**Step 2: Edit the user’s crontab**

```bash
$ crontab -e
```

OR

```bash
# crontab -u bruce -e (if running as root)
```

----

<br>
**Step 3: Add the cron job entry**

Add the following line:

```bash
45 0 * * * /usr/bin/echo "EX200 Practice Test!"    (full path - recommended)
OR
45 0 * * * echo "EX200 Practice Test!"    (should still work fine)
```

**Explanation (exam clarity):**

   - `45` → minute

   - `0` → hour (12:45 AM)

   - `* * *` → every day

To get the correct full path, run the command `which echo`, `which log`, etc.

Command prints the required message

----

<br>
**Step 4: Save and exit the editor (:wq!)**

The cron job is now registered in bruce’s user crontab.

----

<br>
**Step 5: Verify the cron job as user bruce**

```bash
$ crontab -l 
```

or

```bash
# crontab -l -u bruce (as root)
```

Expected output:

```bash
45 0 * * * /usr/bin/echo "EX200 Practice Test!"
```

----

<br>
**Step 6: Ensure persistence across reboots**

No extra action is required.

**Why:**
User crontabs are managed by the crond service and persist automatically across system reboots, provided the service is enabled (default on RHEL).

(Optional verification as root)

```bash
# systemctl status crond (ensure enabled and active)
# systemctl restart crond 
```


