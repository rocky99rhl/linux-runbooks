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


# 🔖 Pregunta 5


### Schedule a Recurring Cron Job

On **Node1**, configure a recurring cron job for the user **linda** with the following requirements:

- The job must run every **2 minutes**.

- Each time it runs, it must log the message:

```bash
RHCSA EX200 Practice Test 2 In Progress!
```

----
<br>


## Explicación general

### Solution – Question 5

A cron job that runs every 2 minutes uses the time field **`*/2 * * * *`**.

You can review the meaning of the cron time fields with:

```bash
# cat /etc/crontab
```

This shows the order of fields:

```bash
minute hour day-of-month month day-of-week
```

----
<br>

**Option 1 – Switch to user linda and edit her crontab**

```bash
# su - linda
# crontab -e
```

Add the following line:

```bash
*/2 * * * * /usr/bin/logger "RHCSA EX200 Practice Test 2 In Progress!"
```

Save and exit.

Note: Just logger should work fine but it's safer to include the full path. To obtain full path, run the command:

```bash
# which logger
```

----
<br>

**Option 2 – Edit linda’s crontab directly as root**

```bash
# crontab -u linda -e
```

Add the same line:

```bash
*/2 * * * * urs/bin/logger "RHCSA EX200 Practice Test 2 In Progress!"
```

Save and exit.

**Verify the cron job is installed**

```bash
# crontab -u linda -l
```

(or, if logged in as linda)

```bash
# crontab -l
```

You should see the cron entry listed.

**Verify that it works**

Wait at least **2 minutes**, then check the system journal for the logged message:

```bash
# journalctl | grep "RHCSA"
```

You should see "RHCSA EX200 Practice Test 2 In Progress!"

Each execution of the job will create a new log entry.
