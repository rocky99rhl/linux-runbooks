# 🧰 Runbook
# Regenerar Initramfs en Rocky Linux (Modo Initramfs)

# 📌 Objetivo

Regenerar el archivo `initramfs` en Rocky Linux / RHEL desde modo emergencia para resolver problemas relacionados con arranque del sistema, corrupción del initramfs, drivers faltantes o migraciones de discos por clonado o virtualización (Hitachi).

---

# 🧱 Requisitos

- Acceso a consola física, iLO, IDRAC, VMware Console o Hypervisor Console.
- Acceso al menú GRUB.
- Acceso root.
- Espacio suficiente en `/boot`.
- Identificar la versión del kernel instalada.

---


&nbsp;
## 🚀 Inicio del Procedimiento

## Paso 2 — Entrar al menú GRUB

Durante el arranque:

- Presiona `e` sobre la entrada de Rocky Linux.

![](imagenes/grub_ok.png)


---

### Paso 2 — Modificar parámetros de arranque

Ubicar la línea que inicia con `linux` o `linuxefi` y agregar al final:

```text
rd.break
```

Ejemplo:

![](imagenes/grub_3.png)

&nbsp;
---

### Paso 3 — Arrancar en Modo Initramfs

Presionar:

```text
Ctrl + X
```

o:

```text
F10
```

---

### Paso 4 — Remontar filesystem en modo escritura

```bash
mount -o remount,rw /sysroot
```

---

### Paso 5 — Cambiar raíz al sistema operativo

```bash
chroot /sysroot
```

---

### Paso 6 — Verificar versión del kernel

```bash
uname -r
```

---

### Paso 7 — Verificar archivos initramfs existentes

```bash
ls -lh /boot/initramfs*
```

---

### Paso 8 — Crear respaldo del initramfs actual

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

### Paso 9 — Regenerar initramfs

```bash
dracut -f
```

<small> *Crear archivo oculto para forzar el re-etiquetado completo de contextos SELinux en el siguiente reinicio del sistema.* </small> 
```bash
touch /.autorelabel
```



---

### Paso 10 — Validar generación del initramfs

```bash
ls -lh /boot/initramfs-$(uname -r).img
```

---

### Paso 11 — Salir del chroot

```bash
exit
```

---

### Paso 12 — Reiniciar servidor

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
