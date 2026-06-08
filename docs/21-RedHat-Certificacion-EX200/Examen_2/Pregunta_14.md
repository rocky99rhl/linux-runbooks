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


# 🔖 Pregunta 14



### Configure System Timezone

On **Node1**, configure the system to use the timezone **Europe/London**

----


## Explicación general

### Solution – Question 14
<br>

**1. Check current timezone**

```bash
# timedatectl
```

- Shows current system timezone and time synchronization status.

----
<br>

**2. List available timezones (optional)**

```bash
# timedatectl list-timezones | grep Europe
```

- Confirms the exact spelling of the desired timezone (Europe/London).

----
<br>

**3. Set the timezone**

```bash
# timedatectl set-timezone Europe/London
```

- This applies the change system-wide and is persistent across reboots.

----
<br>

**4. Verify the change**

```bash
# timedatectl
# date
```

- Output should show:

```bash
Time zone: Europe/London (BST or GMT depending on date)
```

<br>

!!! info "Tips"
    - **`timedatectl status`** provides detailed info about NTP synchronization and timezone.

    - **Tip**: Tab completion is a helpful way to discover available commands and options. For example, type:

    ```bash
    # timedatectl
    ```

    then press the Tab key twice to see all possible subcommands. From the list, type the next appropriate 
    subcommand and press Tab twice again if needed, repeating this process until you reach the desired command.
    This method helps navigate options quickly without memorizing every flag or full command path.

    - No reboot is required; timedatectl changes take effect immediately.


