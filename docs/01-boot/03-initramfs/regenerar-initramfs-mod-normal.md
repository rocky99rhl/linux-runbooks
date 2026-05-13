# 🧰 Runbook
# Regenerar Initramfs en Rocky Linux (Modo Normal)


# 📌 Objetivo

Regenerar el archivo `initramfs` en Rocky Linux / RHEL para resolver problemas relacionados con arranque del sistema, drivers, módulos del kernel o corrupción del initramfs, o en caso de una migracion de discos por clonado o virtualizacion(Hitachi).

---

# 🧱 Requisitos

- Acceso root o privilegios sudo.
- Acceso por consola, SSH o modo rescue.
- Espacio suficiente en `/boot`.
- Identificar la versión actual del kernel.

---

# 🚀 Inicio del Procedimiento

### Paso 1 — Verificar versión del kernel actual

```bash
uname -r
```

Ejemplo:

```text
5.14.0-427.13.1.el9_4.x86_64
```

---

### Paso 2 — Verificar archivos initramfs existentes

```bash
ls -lh /boot/initramfs*
```

---

### Paso 3 — Crear respaldo del initramfs actual

```bash
cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak
```

---

!!! note

    Procedimiento opcional para servidores con CIS Hardening.

    Algunos perfiles de hardening bloquean el módulo `vfat`, lo que puede provocar errores durante la regeneración del initramfs.

    Crear respaldo del archivo CIS.conf, en caso de no existir este archivo CIS.conf podemos saltar este procedimiento de la nota:

    ```bash
    cp /etc/modprobe.d/CIS.conf /etc/modprobe.d/CIS.conf.bak
    ```

    Acceder al directorio:

    ```bash
    cd /etc/modprobe.d/
    ```

    Editar archivo:

    ```bash
    vi CIS.conf
    ```

    Buscar líneas similares a:

    ```text
    install vfat /bin/true
    blacklist vfat
    ```

    Comentarlas:

    ```text
    # install vfat /bin/true
    # blacklist vfat
    ```

    Montar partición EFI:

    ```bash
    mount /boot/efi
    ```

    Validar espacio disponible:

    ```bash
    df -hT /boot/efi
    ```

---

### Paso 4 — Regenerar initramfs

### Método recomendado con dracut

```bash
dracut -f
```

---


### Paso 5 — Reiniciar servidor

```bash
reboot
```

---

# 🔍 Validaciones Post-instalación

### Verificar arranque correcto

Validar que el sistema inicie normalmente.

---

### Verificar kernel activo

```bash
uname -r
```

---

### Verificar módulos cargados

```bash
lsmod | head
```

---

### Verificar errores de arranque

```bash
journalctl -b -p err
```

---

# 📚 Referencias




# ✅ Fin del Procedimiento
