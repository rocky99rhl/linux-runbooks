# 🔄 Rescan HBA Fibre Channel

## 🎯 Objetivo

Realizar un rescan de adaptadores Fibre Channel (HBA) para detectar nuevas LUNs presentadas desde cabina SAN sin reiniciar el servidor.

---

## 📌 Alcance

- Rocky Linux 8 / 9 / 10
- Entornos SAN Fibre Channel
- EMC, PowerStore, 3PAR, Pure, NetApp, IBM, Hitachi
- Multipath habilitado

---

## ⚠️ Consideraciones

!!! warning
    Validar con el equipo de Storage que la LUN ya fue presentada correctamente.

!!! info
    El rescan no genera interrupción de servicio.

!!! danger
    Nunca eliminar dispositivos manualmente sin validar multipath y LVM.

---

# ✅ Pre-checks

## Validar adaptadores FC

```bash
systool -c fc_host -v
```

---

## Validar WWPN

```bash
cat /sys/class/fc_host/host*/port_name
```

---

## Validar estado FC

```bash
cat /sys/class/fc_host/host*/port_state
```

Resultado esperado:

```text
Online
```

---

## Validar discos actuales

```bash
lsblk
```

```bash
multipath -ll
```

---

# 🚀 Ejecución

## 1. Identificar hosts FC

```bash
ls /sys/class/fc_host/
```

Resultado esperado:

```text
host0
host1
```

---

## 2. Ejecutar rescan FC

```bash
rescan-scsi-bus.sh

```

---

---

## 3. Refrescar multipath

```bash
multipath -r
```

---

## 4. Verificar nuevas LUNs

```bash
multipath -ll
```
Resultado esperado:

```text
active ready running
```

---

## Validar tamaño de LUN

```bash
fdisk -l
```

---

## Validar logs del kernel

```bash
dmesg | tail -50
```

---

## Validar eventos FC

```bash
journalctl -k | egrep -i 'scsi|multipath|fc'
```

---

---

# 🚨 Troubleshooting

## No aparecen nuevas LUNs

Validar:

- zoning SAN
- masking
- presentation
- estado FC
- paths activos

---

## Validar HBA

```bash
cat /sys/class/fc_host/host*/port_state
```

---

## Reiniciar multipath <small>online</small>

```bash
systemctl restart multipathd
```

---

## Reiniciar servicios SCSI <small>online</small>

```bash
systemctl daemon-reload
```

---

# 🔄 Rollback

No aplica rollback.

El rescan FC únicamente fuerza redetección de dispositivos.

---

# 📚 Comandos útiles

## Ver WWPN formateado

```bash
for host in /sys/class/fc_host/host*/port_name; do
  cat $host
done
```

---

## Ver fabricantes HBA

```bash
systool -c fc_host -v | egrep 'port_name|model|modeldesc'
```

---

## Ver discos SAN

```bash
lsblk -S
```

---

## Ver paths multipath

```bash
multipathd show paths
```

---

# 🧠 Notas

!!! tip
    Utilizar siempre multipath en ambientes SAN enterprise.

!!! info
    Después de presentar una nueva LUN normalmente se requiere:
    
    - rescan FC
    - refresh multipath
    - rescan LVM

!!! warning
    No utilizar dispositivos sdX directamente en ambientes SAN.

---

# ✅ Resultado esperado

- Nuevas LUNs detectadas
- Paths activos
- Multipath operativo
- Sin errores en logs
- Storage visible para LVM/filesystem
