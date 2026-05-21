# 🧰 Runbook
# Validar Storage Presentation


# 📌 Objetivo

Validar que los discos presentados desde cabina SAN o storage externo sean visibles correctamente en el sistema operativo Rocky Linux / RHEL, verificando paths, WWID, multipath y disponibilidad de dispositivos.

---

# 🧱 Requisitos

- Acceso root o privilegios sudo.
- Multipath instalado y habilitado.
- Discos presentados desde cabina SAN.
- Número de serie o WWID de cada disco.  
  Ejemplo:`naa.60060e8012b170005040b17000000930`

- Acceso por consola o SSH.

---

# 🚀 Inicio del Procedimiento

### Paso 1 — Reescanear discos a nivel de SO

```bash
/usr/bin/rescan-scsi-bus.sh -a -m
```

---

### Paso 2 — Listar números de serie de discos detectados

```bash
ls -l /dev/disk/by-id/
```

---

### Paso 3 — Limpiar mapas huérfanos o fallidos (Opcional)

```bash
multipath -F
```

---

### Paso 4 — Detectar y crear nuevos dispositivos multipath

```bash
multipath
```

---

### Paso 5 — Recargar servicio multipathd

```bash
systemctl reload multipathd
```

---

# 🔍 Validaciones Post-instalación

### Validar dispositivos multipath

```bash
multipath -ll
```

Ejemplo esperado:

```text
[root@laboratorio01 ~]# multipath -ll

mpathb (360060e8012b170005040b17000000930) dm-41 HITACHI,OPEN-V
size=1.0T features='0' hwhandler='0' wp=rw
`-+- policy='service-time 0' prio=1 status=active
  |- 5:0:0:1  sdc  8:32   active ready running
  |- 10:0:0:1 sdj  8:144  active ready running

[root@laboratorio01 ~]#
```

Confirmar:

- Paths activos.
- Estado `active ready running`.
- WWID visibles correctamente.

---

### Validar estado de paths

```bash
multipathd show paths
```

---

### Validar dispositivos detectados

```bash
lsblk
```

---

### Validar logs relacionados a storage

```bash
journalctl -xe | grep -Ei "multipath|scsi|sd"
```

---

# 📚 Referencias


---

# ✅ Fin del Procedimiento
