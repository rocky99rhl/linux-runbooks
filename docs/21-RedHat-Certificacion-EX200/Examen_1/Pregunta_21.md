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


# 🔖 Pregunta 21


Enable Recommended Tuning Profile

On **Node2**, perform the following task:

Enable the **recommended tuning profile** to optimize the system performance according to Red Hat best practices.

Verify that the tuning profile has been successfully applied and is active.


----

<br>

# Explicación general


### Solution - Question 21

1.- **`tuned-adm list`** – Shows **all available profiles** and **currently active profile**.

Example output:

```bash
Available profiles:
- balanced
- desktop
- latency-performance
- virtual-guest  
- virtual-host
Active profile: balanced
```

- Here, the active profile is **`balanced`**.

2.- **`tuned-adm recommend`** – Shows the **recommended profile** for the system according to Red Hat best practices.

Example output:

```bash
Recommended profile for this system: virtual-guest
```

This is the command you use to **check what Red Hat recommends** before applying a profile.

<br>
✅ **Workflow in the exam:**

```bash
# tuned-adm list                    // see all available profiles and current active
# tuned-adm recommend               // check the recommended profile (virtual-guest)
# tuned-adm profile virtual-guest   // apply recommended profile
# tuned-adm active                  // confirm it’s active
# systemctl enable --now tuned      // ensure persistence
```

- This mirrors exactly what an RHCSA candidate would do: **verify, apply, confirm, persist.**



