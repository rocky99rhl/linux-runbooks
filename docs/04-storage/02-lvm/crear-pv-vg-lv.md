# 🧰 Runbook
# Crear PV, VG y LV con Multipath en Rocky Linux

&nbsp;
# 📌 Objetivo

Crear un Physical Volume (PV), Volume Group (VG) y Logical Volume (LV) utilizando discos presentados desde cabina SAN Hitachi mediante Multipath en Rocky Linux / RHEL.

---

# 🧱 Requisitos

- Acceso root o privilegios sudo.
- Multipath instalado y habilitado.
- Serial de discos presentados desde cabina SAN.
- Acceso por consola o SSH.

<small>*Ejemplo de seriales de discos:*<br>
*60060e8012b170005040b17000000930 -> 16GB*<br>
*60060e8012b170005040b17000000931 -> 16GB*</small>

---


&nbsp;
# 🚀 Inicio del Procedimiento


### Paso 1 — Validar `mapth` de los nuevos discos asignados

```bash
multipath -ll
```

<small>*Ejemplo esperado:*</small>

```text
mpatha (360060e8012b170005040b17000000930) dm-10 HITACHI,OPEN-V
size=16G features='0' hwhandler='0' wp=rw

mpathb (360060e8012b170005040b17000000931) dm-11 HITACHI,OPEN-V
size=16G features='0' hwhandler='0' wp=rw
```

!!! info
    Se debe aplicar el runbook `Validar Storage Presentation` antes de visualizar los nuevos discos fisicos.



---

&nbsp;
### Paso 2 — Validar discos visibles en el sistema

```bash
lsblk
```

---


### Paso 3 — Crear Physical Volumes (PV)

```bash

pvcreate /dev/mapper/mpatha 
pvcreate /dev/mapper/mpathb

```

---

&nbsp;
### Paso 4 — Validar PV creados

```bash
pvs
```

---

&nbsp;
### Paso 5 — Crear Volume Group (VG)

<small>*Ejemplo utilizando el nombre `vg_datos` para el Volume Group.*<br>
*El segundo comando crece un VG ya existente.*</small>

```bash
vgcreate vg_datos /dev/mapper/mpatha 

vgextend vg_datos /dev/mapper/mpathb
```

---

&nbsp;
### Paso 6 — Validar VG creado

```bash
root@laboratorio01:~# vgs
  VG         #PV #LV #SN Attr   VSize   VFree 
  vd_db_data   1   1   0 wz--n- <37.70g     0 
  vg_datos     2   0   0 wz--n-  31.99g 31.99g
  vg_system    1   9   0 wz--n-  79.00g     0 
  vg_web_app   1   1   0 wz--n-  10.00g     0 
root@laboratorio01:~# 

```

---

&nbsp;
### Paso 7 — Crear Logical Volume (LV)

<small>*Ejemplo creando un LV de 13G llamado `lv_app`*</small> 

```bash
root@laboratorio01:~# lvcreate -L 13G -n lv_app vg_datos
  Logical volume "lv_app" created.

root@laboratorio01:~# lvs
  LV            VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  var_lib_mysql vd_db_data -wi-ao---- <37.70g                                                    
  lv_app        vg_datos   -wi-a-----  13.00g                                                    
  bladelogic    vg_system  -wi-ao----   5.00g                                                    
  home          vg_system  -wi-ao----   5.00g                                                    
  opt           vg_system  -wi-ao----   5.00g                                                    
  root          vg_system  -wi-ao----  20.00g                                                    
  seguridad     vg_system  -wi-ao----   5.00g                                                    
  swap          vg_system  -wi-ao----   4.00g                                                    
  tmp           vg_system  -wi-ao----   5.00g                                                    
  var           vg_system  -wi-ao----  20.00g                                                    
  var_log       vg_system  -wi-ao----  10.00g                                                    
  var_www       vg_web_app -wi-ao----  10.00g                                                    
root@laboratorio01:~#
```

---

&nbsp;
# 🔍 Validaciones Post-instalación


---


### Validar Physical Volumes, Volumen Groups y Logial Volumes.

```bash
pvs
vgs
lvs

```

&nbsp;
!!! tip "Mejores Prácticas: Segmentación de Almacenamiento LVM"

    La segmentación óptima en escenarios reales de producción requiere aislar las cargas críticas en Grupos de Volúmenes (VGs) independientes:

    * **Bases de Datos**
        * `vg_db_bin`: Exclusivo para archivos binarios del motor.
        * `vg_db_data`: Datos transaccionales en discos flash rápidos de baja latencia.
        * `vg_db_redo`: Logs de transacciones para proteger las escrituras secuenciales.
    * **Servidores Web**
        * `vg_web_bin`: Código ejecutable y despliegues de la aplicación.
        * `vg_web_logs`: Logs de acceso para evitar caídas del sistema por saturación de espacio.
    * **Programas Producto (Control-M, NetBackup, Patrol)**
        * `vg_infra`: Agentes de monitoreo, respaldo y automatización. Permite aplicar parches y aislar el almacenamiento de infraestructura sin afectar las aplicaciones de negocio.

---


# 📚 Referencias

- Red Hat LVM Administration Guide
- Red Hat Multipath Guide

---



# ✅ Fin del Procedimiento
