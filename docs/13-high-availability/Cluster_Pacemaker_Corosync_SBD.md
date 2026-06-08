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

# 🧰 Runbook
# Implementar Cluster de Alta Disponibilidad con Pacemaker, Corosync y SBD en Rocky Linux 10

&nbsp;

# 📌 Objetivo

Implementar un Cluster de Alta Disponibilidad (HA) en Rocky Linux 10 utilizando Pacemaker, Corosync, PCS y SBD, con almacenamiento compartido iSCSI, protección contra Split-Brain mediante STONITH y administración automática de recursos críticos mediante Failover Activo/Pasivo.

&nbsp;

La solución permitirá:

- Alta disponibilidad de aplicaciones críticas.
- Recuperación automática ante fallos de nodo.
- Protección contra corrupción de datos.
- Administración centralizada de recursos.
- Uso de almacenamiento compartido mediante iSCSI.
- Exposición de servicios mediante IP Virtual flotante.

---
&nbsp;

# 🧱 Requisitos

- Rocky Linux 10 o RHEL 10 instalado.
- Tres nodos para el Cluster.
- Un servidor iSCSI Target.
- Acceso root o privilegios sudo.
- Firewall habilitado.
- Resolución de nombres funcional.
- Conectividad entre nodos.
- Sincronización horaria mediante NTP.

### Topología de ejemplo

| Hostname | IP Privada |
|-----------|-----------|
| nodo1.laboratorio | 10.0.0.11 |
| nodo2.laboratorio | 10.0.0.12 |
| nodo3.laboratorio | 10.0.0.13 |
| nodo4.laboratorio | 10.0.0.20 | 

<small>El nodo4 es la maquina que simula la cabina SAN </small>

---

&nbsp;

# 🚀 Inicio del Procedimiento

## FASE 1 — Configuración de Red y Resolución de Nombres
&nbsp;

Antes de iniciar la Fase 1 de este procedimiento, se asume que las máquinas virtuales ya fueron desplegadas y configuradas conforme a lo establecido en el runbook Configuración de Laboratorio.

Esta validación previa garantiza que todos los componentes, dependencias y parámetros requeridos para el entorno se encuentran correctamente preparados, permitiendo ejecutar el laboratorio de Alta Disponibilidad de manera controlada y sin contratiempos derivados de configuraciones pendientes o incompletas.

En caso de que alguna de las configuraciones descritas en el runbook no haya sido aplicada, se recomienda completarla antes de continuar con las siguientes fases del procedimiento.


----
&nbsp;

### Paso 1 — Configurar resolución local


Editar:

```bash
vi /etc/hosts
```

Agregar:

```text
10.0.0.11 nodo1.laboratorio nodo1
10.0.0.12 nodo2.laboratorio nodo2
10.0.0.13 nodo3.laboratorio nodo3
10.0.0.20 nodo4.laboratorio nodo4
```

<small>Aplicar en: nodo1, nodo2 y nodo3</small>

---
&nbsp;

### Paso 3 — Validar resolución DNS local - **`nodo1, nodo2 y nodo3`**

```bash
ping -c 2 nodo1.laboratorio
ping -c 2 nodo2.laboratorio
ping -c 2 nodo3.laboratorio
```

---
&nbsp;

### Paso 4 — Abrir puertos de Alta Disponibilidad **`nodo1, nodo2 y nodo3`**

Ejecutar

```bash
firewall-cmd --permanent --add-service=high-availability
```

```bash
firewall-cmd --reload
```

---
&nbsp;

### Paso 5 — Validar reglas aplicadas - **`nodo1, nodo2 y nodo3`**

```bash
firewall-cmd --list-services
```

Debe visualizarse:

```text
high-availability
```

---
&nbsp;

## FASE 2 — Configuración de Almacenamiento Compartido iSCSI
&nbsp;

### Paso 1 — Instalar utilerías iSCSI - **`nodo1, nodo2 y nodo3`**

Ejecutar:

```bash
dnf install iscsi-initiator-utils -y
```

---
&nbsp;

### Paso 2 — Habilitar servicio iSCSI - **`nodo1, nodo2 y nodo3`**

```bash
systemctl enable --now iscsid
```


---

### Paso 3 — Descubrir Targets iSCSI

```bash
iscsiadm -m discovery -t sendtargets -p 10.0.0.20
```

Ejemplo:

```text
10.0.0.20:3260,1 iqn.2026-06.laboratorio.san:storage
```

---

### Paso 4 — Iniciar sesión contra la cabina SAN - **`nodo1, nodo2 y nodo3`**

```bash
iscsiadm -m node \
-T iqn.2026-06.laboratorio.san:storage \
-p 10.0.0.20 \
--login
```

---
&nbsp;

### Paso 5 — Validar nuevos discos - **`nodo1, nodo2 y nodo3`**

```bash
lsblk
```

Ejemplo:

```text
sda   1G
sdb  15G
```

---
&nbsp;

### Paso 6 — Configurar inicio automático de sesiones iSCSI

```bash
iscsiadm -m node --op update \
-n node.startup \
-v automatic
```

---
&nbsp;

### Paso 7 — Reiniciar servicio iSCSI

```bash
systemctl restart iscsid
```

---


## FASE 3 — Instalación de Pacemaker, Corosync y PCS
&nbsp;

### Paso 1 — Habilitar repositorio High Availability

Ejecutar en los tres nodos:

```bash
dnf config-manager --set-enabled highavailability
```

---
&nbsp;

### Paso 2 — Limpiar metadatos de repositorios

```bash
dnf clean all
```

---
&nbsp;

### Paso 3 — Instalar paquetes del Cluster

```bash
dnf install -y pacemaker pcs corosync sbd fence-agents-sbd
```

---
&nbsp;

### Paso 4 — Validar instalación

```bash
rpm -qa | egrep "pacemaker|pcs|corosync|sbd"
```

---
&nbsp;

### Paso 5 — Habilitar servicio pcsd

```bash
systemctl enable --now pcsd
```

---
&nbsp;

### Paso 6 — Configurar contraseña del usuario hacluster

Ejecutar en los tres nodos:

```bash
passwd hacluster
```

Utilizar exactamente la misma contraseña en todos los servidores.

---
&nbsp;

### Paso 7 — Validar servicio pcsd

```bash
systemctl status pcsd
```

Debe mostrarse:

```text
active (running)
```

---
&nbsp;

# FASE 4 — Creación del Cluster

⚠️ Los siguientes pasos se ejecutan únicamente desde:

```text
nodo1.laboratorio
```

---

### Paso 1 — Autenticar nodos

```bash
pcs host auth \
nodo1.laboratorio \
nodo2.laboratorio \
nodo3.laboratorio \
-u hacluster
```

Ingresar la contraseña cuando sea solicitada.

---
&nbsp;

### Paso 2 — Validar autenticación

```bash
pcs host auth
```

---

### Paso 3 — Crear Cluster
&nbsp;

```bash
pcs cluster setup cluster_laboratorio \
nodo1.laboratorio \
nodo2.laboratorio \
nodo3.laboratorio
```

---
&nbsp;

### Paso 4 — Arrancar Cluster

```bash
pcs cluster start --all
```

---
&nbsp;
### Paso 5 — Habilitar inicio automático

```bash
pcs cluster enable --all
```

---
&nbsp;

### Paso 6 — Verificar estado

```bash
pcs status
```

Ejemplo esperado:

```text
Cluster name: cluster_laboratorio
Stack: corosync
Current DC: nodo1
3 nodes configured
```

---
&nbsp;

### Paso 7 — Validar quorum

```bash
pcs quorum status
```

Debe mostrarse:

```text
Quorate: Yes
```

---
&nbsp;

### Paso 8 — Validar estado de Corosync

```bash
corosync-cfgtool -s
```

---
&nbsp;

### Paso 9 — Validar membresía del Cluster

```bash
corosync-quorumtool
```

Ejemplo:

```text
Membership information
----------------------
Node ID      Votes Name
1               1 nodo1
2               1 nodo2
3               1 nodo3
```

---
&nbsp;

# FASE 5 — Configuración de Fencing SBD

⚠️ Esta fase protege al Cluster contra Split-Brain.

---
&nbsp;

### Paso 1 — Validar disco dedicado para SBD

```bash
lsblk
```

Ejemplo:

```text
sda   1G
```

---
&nbsp;

### Paso 2 — Inicializar disco SBD

Ejecutar únicamente en nodo1:

```bash
sbd -d /dev/sda create
```

---

### Paso 3 — Validar metadata SBD

```bash
sbd -d /dev/sda dump
```

---
&nbsp;

### Paso 4 — Registrar cada nodo en SBD

Ejecutar en todos los nodos:

```bash
sbd -d /dev/sda allocate $(hostname)
```

---

### Paso 5 — Validar slots registrados

```bash
sbd -d /dev/sda list
```

Ejemplo:

```text
0 nodo1.laboratorio
1 nodo2.laboratorio
2 nodo3.laboratorio
```

---

### Paso 6 — Cargar Watchdog del Kernel

```bash
modprobe softdog
```

---

### Paso 7 — Configurar carga automática

```bash
echo softdog > /etc/modules-load.d/softdog.conf
```

---

### Paso 8 — Validar watchdog

```bash
ls -l /dev/watchdog
```

Debe existir:

```text
/dev/watchdog
```

---

### Paso 9 — Configurar SBD

Editar:

```bash
vi /etc/sysconfig/sbd
```

Configurar:

```bash
SBD_DEVICE="/dev/sda"
SBD_WATCHDOG_DEV="/dev/watchdog"
```

---

### Paso 10 — Habilitar servicio SBD

```bash
systemctl enable sbd
```

---

### Paso 11 — Reiniciar daemon

```bash
systemctl daemon-reload
```

---

### Paso 12 — Arrancar servicio SBD

```bash
systemctl start sbd
```

---

### Paso 13 — Verificar servicio

```bash
systemctl status sbd
```

Debe visualizarse:

```text
active (running)
```

---


# FASE 6 — Configuración de STONITH mediante SBD

⚠️ Todos los comandos de esta fase se ejecutan únicamente desde:

```text
nodo1.laboratorio
```

---

### Paso 1 — Crear recurso STONITH

```bash
pcs stonith create mi-fencing-sbd \
fence_sbd \
devices=/dev/sda \
pcmk_host_list="nodo1.laboratorio nodo2.laboratorio nodo3.laboratorio"
```

---

### Paso 2 — Verificar recurso creado

```bash
pcs stonith config
```

---

### Paso 3 — Verificar estado STONITH

```bash
pcs status
```

Debe visualizarse un recurso similar a:

```text
mi-fencing-sbd (stonith:fence_sbd)
```

---

### Paso 4 — Habilitar STONITH

```bash
pcs property set stonith-enabled=true
```

---

### Paso 5 — Verificar propiedad

```bash
pcs property config
```

Ejemplo:

```text
stonith-enabled=true
```

---

### Paso 6 — Validar configuración general

```bash
pcs status
```

No deben existir errores relacionados con:

```text
STONITH
Fencing
SBD
```

---

# FASE 7 — Preparación del Almacenamiento Compartido

⚠️ Debido a cambios en Rocky Linux 10, la arquitectura soportada utiliza:

```text
LVM-activate
vg_access_mode=tagging
```

No se utilizan:

```text
clvmd
DLM
Resilient Storage
```

---

### Paso 1 — Validar disco compartido

```bash
lsblk
```

Ejemplo:

```text
sdb 15G
```

---

### Paso 2 — Registrar disco en catálogo LVM

Ejecutar en todos los nodos:

```bash
lvmdevices --adddev /dev/sdb
```

---

### Paso 3 — Validar dispositivo registrado

```bash
lvmdevices
```

---

### Paso 4 — Crear Physical Volume

Ejecutar únicamente en nodo1:

```bash
pvcreate /dev/sdb
```

---

### Paso 5 — Validar PV

```bash
pvs
```

Ejemplo:

```text
PV         VG Fmt Attr PSize
/dev/sdb      lvm2 --- 15.00g
```

---

### Paso 6 — Crear Volume Group

```bash
vgcreate vg_datos_ha /dev/sdb
```

---

### Paso 7 — Validar VG

```bash
vgs
```

Ejemplo:

```text
VG          #PV #LV Attr   VSize
vg_datos_ha   1   0 wz--n- 15.00g
```

---

### Paso 8 — Forzar descubrimiento en nodos secundarios

Ejecutar en nodo2 y nodo3:

```bash
vgscan
```

---

### Paso 9 — Crear Logical Volume

```bash
lvcreate \
-l 100%FREE \
--name lv_almacenamiento \
vg_datos_ha
```

---

### Paso 10 — Validar LV

```bash
lvs
```

Ejemplo:

```text
LV                VG
lv_almacenamiento vg_datos_ha
```

---

### Paso 11 — Formatear volumen XFS

```bash
mkfs.xfs /dev/vg_datos_ha/lv_almacenamiento
```

---

### Paso 12 — Validar Filesystem

```bash
blkid
```

Ejemplo:

```text
/dev/mapper/vg_datos_ha-lv_almacenamiento: TYPE="xfs"
```

---

### Paso 13 — Desactivar Volume Group

⚠️ Paso obligatorio.

```bash
vgchange -an vg_datos_ha
```

---

### Paso 14 — Verificar VG inactivo

```bash
vgs
```

La columna Attr debe indicar que el VG no se encuentra activo.

---

# FASE 8 — Configuración de Exclusión de Activación Automática

⚠️ Ejecutar en todos los nodos.

---

### Paso 1 — Respaldar configuración LVM

```bash
cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.bak
```

---

### Paso 2 — Editar configuración

```bash
vi /etc/lvm/lvm.conf
```

---

### Paso 3 — Modificar sección activation

Buscar:

```text
activation {
```

Configurar:

```text
activation {

    volume_list = [ "vgsystem" ]

}
```

---

### Paso 4 — Validar sintaxis

```bash
grep -n volume_list /etc/lvm/lvm.conf
```

---

### Paso 5 — Regenerar initramfs

```bash
dracut -f --regenerate-all
```

---

### Paso 6 — Verificar finalización correcta

```bash
echo $?
```

Resultado esperado:

```text
0
```

---

### Paso 7 — Reiniciar servidor

Ejecutar nodo por nodo.

```bash
reboot
```

---

### Paso 8 — Validar que el VG compartido no se active automáticamente

```bash
lvs
```

El volumen compartido no debe encontrarse montado ni activo.

---

### Paso 9 — Validar estado general del Cluster

```bash
pcs status
```

Todos los nodos deben encontrarse Online.

---


# FASE 9 — Creación de Recursos del Cluster

⚠️ Todos los comandos de esta fase se ejecutan únicamente desde:

```text
nodo1.laboratorio
```

---

### Paso 1 — Crear recurso LVM-activate

```bash
pcs resource create vg_datos_ha \
ocf:heartbeat:LVM-activate \
vgname=vg_datos_ha \
vg_access_mode=tagging
```

---

### Paso 2 — Validar recurso

```bash
pcs resource config
```

---

### Paso 3 — Crear punto de montaje

Ejecutar en todos los nodos:

```bash
mkdir -p /datos
```

---

### Paso 4 — Crear recurso Filesystem

```bash
pcs resource create fs_datos \
ocf:heartbeat:Filesystem \
device="/dev/vg_datos_ha/lv_almacenamiento" \
directory="/datos" \
fstype="xfs"
```

---

### Paso 5 — Crear IP Virtual

```bash
pcs resource create vip_datos \
ocf:heartbeat:IPaddr2 \
ip=10.0.0.100 \
cidr_netmask=24
```

---

### Paso 6 — Verificar recursos creados

```bash
pcs resource show
```

---

# FASE 10 — Agrupación de Recursos

### Paso 1 — Crear grupo

```bash
pcs resource group add grupo_datos \
vg_datos_ha \
fs_datos \
vip_datos
```

---

### Paso 2 — Verificar grupo

```bash
pcs resource status
```

Ejemplo esperado:

```text
Resource Group: grupo_datos
    vg_datos_ha
    fs_datos
    vip_datos
```

---

### Paso 3 — Validar estado general

```bash
pcs status
```

Ejemplo:

```text
Cluster name: cluster_laboratorio

Online:
  nodo1
  nodo2
  nodo3

Resource Group: grupo_datos

  vg_datos_ha
  fs_datos
  vip_datos
```

---

# FASE 11 — Validación del Filesystem Compartido

### Paso 1 — Verificar montaje

```bash
df -h
```

Ejemplo:

```text
/dev/mapper/vg_datos_ha-lv_almacenamiento
```

Montado sobre:

```text
/datos
```

---

### Paso 2 — Crear archivo de prueba

```bash
touch /datos/test_cluster.txt
```

---

### Paso 3 — Validar escritura

```bash
ls -l /datos
```

---

### Paso 4 — Validar IP Virtual

```bash
ip addr
```

Ejemplo:

```text
10.0.0.100
```

---

### Paso 5 — Probar conectividad

Desde otro servidor:

```bash
ping 10.0.0.100
```

---

# FASE 12 — Prueba de Failover

### Paso 1 — Identificar nodo activo

```bash
pcs status
```

---

### Paso 2 — Colocar nodo en standby

Ejemplo:

```bash
pcs node standby nodo1.laboratorio
```

---

### Paso 3 — Verificar migración automática

```bash
pcs status
```

Validar:

- Grupo de recursos migrado.
- Filesystem montado en otro nodo.
- IP Virtual activa en nuevo nodo.

---

### Paso 4 — Validar acceso a datos

```bash
ls -l /datos
```

Debe visualizarse:

```text
test_cluster.txt
```

---

### Paso 5 — Regresar nodo al Cluster

```bash
pcs node unstandby nodo1.laboratorio
```

---

### Paso 6 — Verificar reintegración

```bash
pcs status
```

Todos los nodos deben aparecer:

```text
Online
```

---

# FASE 13 — Operación Diaria

### Estado general del Cluster

```bash
pcs status
```

---

### Estado detallado

```bash
pcs status --full
```

---

### Ver recursos

```bash
pcs resource show
```

---

### Ver propiedades

```bash
pcs property config
```

---

### Ver STONITH

```bash
pcs stonith config
```

---

### Ver quorum

```bash
pcs quorum status
```

---

### Ver configuración completa

```bash
pcs config
```

---

### Poner nodo en mantenimiento

```bash
pcs node standby <nodo>
```

---

### Regresar nodo a producción

```bash
pcs node unstandby <nodo>
```

---

### Reiniciar recurso

```bash
pcs resource restart <recurso>
```

---

### Limpiar recurso fallido

```bash
pcs resource cleanup
```

---

### Limpiar recurso específico

```bash
pcs resource cleanup <recurso>
```

---

# FASE 14 — Troubleshooting

### Ver eventos del Cluster

```bash
pcs status --full
```

---

### Logs de Pacemaker

```bash
journalctl -u pacemaker -f
```

---

### Logs de Corosync

```bash
journalctl -u corosync -f
```

---

### Logs de SBD

```bash
journalctl -u sbd -f
```

---

### Verificar membresía Corosync

```bash
corosync-quorumtool
```

---

### Verificar transporte Corosync

```bash
corosync-cfgtool -s
```

---

### Verificar recursos fallidos

```bash
pcs status
```

---

### Ver slots SBD

```bash
sbd -d /dev/sda list
```

---

### Ver metadata SBD

```bash
sbd -d /dev/sda dump
```

---

### Validar watchdog

```bash
ls -l /dev/watchdog
```

---

### Verificar discos iSCSI

```bash
lsblk
```

---

### Verificar sesiones iSCSI

```bash
iscsiadm -m session
```

---

### Verificar LVM

```bash
pvs
vgs
lvs
```

---

### Verificar montaje

```bash
df -h
```

---

# 🔍 Validaciones Post-instalación

Validar que:

- Los tres nodos estén Online.
- Exista quorum.
- STONITH esté habilitado.
- SBD esté activo.
- El Filesystem XFS se monte correctamente.
- La IP Virtual sea accesible.
- El failover funcione correctamente.
- Los datos permanezcan disponibles después de una migración.
- No existan recursos fallidos.
- No existan eventos de fencing inesperados.

---

# 📚 Referencias

- Red Hat High Availability Documentation
- Rocky Linux HA Documentation
- Pacemaker Documentation
- Corosync Documentation
- SBD Documentation
- LVM Administration Guide
- iSCSI Administration Guide

---

# ✅ Fin del Procedimiento


