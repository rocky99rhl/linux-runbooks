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


# 🔖 Pregunta 11


### Boot Configuration and Troubleshooting

On **Node1**, ensure that system boot messages are displayed during startup to assist with troubleshooting.

Remove any kernel parameters that suppress boot messages so that verbose output is enabled.

The configuration must persist across reboots.


----


<br>
# Explicación general


### Solution – Question 11

To ensure boot messages are displayed (not silenced) and the change persists across reboots, follow these steps:

<br>
**Step 1. Edit the GRUB default configuration**

```bash
# vim /etc/default/grub
```

Locate the line that starts with `GRUB_CMDLINE_LINUX=`.

Remove any quieting parameters such as:

   - quiet

   - rhgb

**Example (before):**

```bash
GRUB_CMDLINE_LINUX="...x rhgb quiet"
```

**Example (after):**

```bash
GRUB_CMDLINE_LINUX="...x"
```

If other required kernel parameters exist, keep them—only remove quiet and rhgb.

<br>
**Step 2. Regenerate the GRUB configuration**

For BIOS-based systems:

```bash
# grub2-mkconfig -o /boot/grub2/grub.cfg
```

For UEFI-based systems:

```bash
# grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
```

<br>
**Step 3. Reboot the system to verify**

```bash
# reboot
```



