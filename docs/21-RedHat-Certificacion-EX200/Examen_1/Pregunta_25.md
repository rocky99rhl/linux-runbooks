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


# 🔖 Pregunta 25


### Schedule a One-Time at Job

On **Node2**, as the user **russ**, schedule a **one-time job** to run **tonight at 21:30** that appends the line:

```bash
EX200 Mock Practice 1 Complete!
```

to the file **/home/russ/practice.log**.

----

<br>
# Explicación general

### Solution – Question 25

<br>
**1. Switch to the user russ (if not already)**

```bash
# su - russ
```

<br>
**Option 1 – Interactive at session (recommended)**

```bash
# at 21:30
at> echo "EX200 Mock Practice 1 Complete!" >> /home/russ/practice.log
at> <Ctrl+D>
```

**Explanation:**


Starts an interactive **`at`** session at the specified time.

Enter the command(s) line by line and press **Ctrl+D** to schedule.

----

<br>
**Option 2 – Shortened one-liner**

```bash
# echo 'echo "EX200 Mock Practice 1 Complete!" >> /home/russ/practice.log' | at 21:30
```

**Explanation:**

- Pipes the command directly to **`at`** without using interactive mode.

Additional Commands

- View scheduled jobs:

```bash
# atq
```

- Remove a scheduled job:

```bash
# atrm <job_number obtained from atq>
```

- Check that **`atd`** service is running (required for execution):

```bash
# systemctl status atd
# systemctl enable --now atd
# systemctl restart atd
```

