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


# 🔖 Pregunta 20


### Resize Logical Volume

On **Node2**, resize the previously created logical volume **lvdata** in the **vgstore** volume group to use a total of **85 physical extents.**

Ensure that the filesystem on the logical volume is adjusted appropriately so that the new space is available for use.

**Requirement:**

   - Ensure the logical volume remains mounted at **/mnt/data** and is usable after resizing.


----


<br>

# Explicación general


### Solution – Question 20

<br>
**1. Verify current LV and VG**

```bash
# lvs
# vgs
# lvdisplay /dev/vgstore/lvdata
```

- Current LV: 50 extents

- Target LV: 85 extents

- Check free extents in **`vgstore`** (should be ≥ 35):

```bash
# vgs
# vgdisplay vgstore
```

----

<br>
**2. Extend the logical volume and resize filesystem automatically**

```bash
# lvextend -l 85 -r /dev/vgstore/lvdata
```

**Note:** The **`-r`** flag resizes the filesystem automatically along with the logical volume.

----

<br>
**3. Optional: Manually resize filesystem if -r was forgotten**

```bash
# resize2fs /dev/vgstore/lvdata
```

----
<br>
**4. Verify changes**

```bash
# lvs /dev/vgstore/lvdata
# df -h /mnt/data
```

- Confirm LV now uses **85 extents**.

- Confirm filesystem reflects the new size.



