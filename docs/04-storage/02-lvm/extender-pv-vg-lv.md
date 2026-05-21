# 🧰 Runbook
# Extender PV, VG y LV con Multipath en Rocky Linux

&nbsp;

# 📌 Objetivo

Extender almacenamiento LVM en Rocky Linux / RHEL utilizando discos presentados desde cabina SAN Hitachi mediante Multipath.

El procedimiento contempla:

- Agregar nuevos discos a un VG existente.
- Extender un PV existente mediante resize de LUN SAN.
- Extender el filesystem XFS posterior al crecimiento del almacenamiento.

---

# 🧱 Requisitos

- Acceso root o privilegios sudo.
- Multipath instalado y habilitado.
- Volume Group (VG) y Logical Volume (LV) previamente creados.
- Nuevos discos presentados desde cabina SAN o ampliación de LUN existente.
- Acceso por consola o SSH.


---

&nbsp;

# 🚀 Escenario 1 — Agregar Nuevos Discos al VG Existente

### Paso 1 — Validar `mpath` de los nuevos discos asignados

```bash
multipath -ll
```

<small>*Ejemplo esperado:*</small>

```text
mpathc (360060e8012b170005040b17000000932) dm-20 HITACHI,OPEN-V
size=16G features='0' hwhandler='0' wp=rw

mpathd (360060e8012b170005040b17000000933) dm-21 HITACHI,OPEN-V
size=16G features='0' hwhandler='0' wp=rw
```

!!! info
    Se debe aplicar el runbook `Validar Storage Presentation` antes de visualizar los nuevos discos físicos.

---

&nbsp;

### Paso 2 — Validar discos visibles en el sistema

```bash
lsblk
```

---

&nbsp;

### Paso 3 — Crear Physical Volumes (PV)

```bash
pvcreate /dev/mapper/mpathc
pvcreate /dev/mapper/mpathd
```

---

&nbsp;

### Paso 4 — Validar PV creados

```bash
pvs
```

---

&nbsp;

### Paso 5 — Extender Volume Group (VG)

```bash
vgextend vg_datos /dev/mapper/mpathc

vgextend vg_datos /dev/mapper/mpathd
```

---

&nbsp;

### Paso 6 — Validar VG extendido

```bash
vgs
```

---

&nbsp;

### Paso 7 — Extender Logical Volume (LV)

<small>*Ejemplo extendiendo 20GB al LV existente.*</small>

```bash
lvextend -L +20G /dev/vg_datos/lv_app
```


---

&nbsp;

### Paso 8 — Extender filesystem XFS(Opcional)

```bash
xfs_growfs /app
```

---

&nbsp;

# 🚀 Escenario 2 — Extender PV por Resize de LUN SAN

!!! info
    Este escenario aplica cuando el mismo LUN SAN fue ampliado desde cabina storage y no cuando se agregan discos nuevos.

---

&nbsp;

### Paso 9 — Reescanear discos SCSI

```bash
/usr/bin/rescan-scsi-bus.sh -a -m
```

---

&nbsp;

### Paso 10 — Validar nuevo tamaño de discos a nivel del multipath

```bash
multipath -ll
```

---

&nbsp;

### Paso 11 — Extender Physical Volume existente

```bash
pvresize /dev/mapper/mpatha
```

---

&nbsp;
# 🔍 Validaciones Post-instalación

### Validar Physical Volumes, Volume Groups y Logical Volumes

```bash
pvs
vgs
lvs
```

---

# 📚 Referencias

- Red Hat LVM Administration Guide
- Red Hat Multipath Guide

---

# ✅ Fin del Procedimiento
