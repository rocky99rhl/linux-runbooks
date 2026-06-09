<style>
p,
li {
  font-size: 15px;
  line-height: 1.6;
}

code {
  font-size: 15px;
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
- Una direccion de IP Publica y una Privada por host.
- Sincronización horaria mediante NTP.

### Topología de ejemplo

| Hostname | IP Privada |
|-----------|-----------|
| nodo1.laboratorio | 10.0.0.11 |
| nodo2.laboratorio | 10.0.0.12 |
| nodo3.laboratorio | 10.0.0.13 |
| nodo4.laboratorio | 10.0.0.20 | 

<small>El nodo4 es la maquina que simula la cabina SAN por iSCSI</small>


!!! info
    Antes de iniciar la Fase 1 de este procedimiento, se asume que las máquinas virtuales ya fueron desplegadas y configuradas conforme a lo establecido en el runbook Configuración de Laboratorio.

    Esta validación previa garantiza que todos los componentes, dependencias y parámetros requeridos para el entorno se encuentran correctamente preparados, permitiendo ejecutar el laboratorio de Alta Disponibilidad de manera controlada y sin contratiempos derivados de configuraciones pendientes o incompletas.

    En caso de que alguna de las configuraciones descritas en el runbook no haya sido aplicada, se recomienda completarla antes de continuar con las siguientes fases del procedimiento.


---

&nbsp;

# 🚀 Inicio del Procedimiento

## FASE 1 — Configuración de Red y Resolución de Nombres
&nbsp;

<small>Aplicar en: **nodo1, nodo2 y nodo3**</small>

**Configurar resolución local**

Editar:

```bash
# vi /etc/hosts
```

Agregar:

```text
#Red privada para el cluster
# ip	 hostname	alias
10.0.0.11 nodo1.laboratorio nodo1
10.0.0.12 nodo2.laboratorio nodo2
10.0.0.13 nodo3.laboratorio nodo3
10.0.0.20 nodo4.laboratorio nodo4
```

- ¿Qué hace?: Garantiza la comunicación inmediata por nombre a través de la 
  red privada de baja latencia, aislando el tráfico crítico clúster.

---

&nbsp;

**Validar resolución DNS local**

<small>Aplicar en: **nodo1, nodo2 y nodo3**</small>

Ejecutar:

```bash
# ping -c 2 nodo1.laboratorio
# ping -c 2 nodo2.laboratorio
# ping -c 2 nodo3.laboratorio
```

- El comando envía dos mensajes ICMP al host especificado para verificar la conectividad de red y confirmar que el nombre del servidor puede resolverse correctamente.
    - `ping`: Herramienta utilizada para comprobar la comunicación entre equipos a través de la red.
    - `-c 2`: Indica que se enviarán únicamente dos solicitudes de eco (ping).
    - `nodo1.laboratorio`: Nombre del host o servidor al que se realizará la prueba de conectividad.


---

&nbsp;

**Abrir puertos de Alta Disponibilidad** 

<small>Aplicar en: **nodo1, nodo2 y nodo3**</small>
&nbsp;

Ejecutar:

```bash
# firewall-cmd --permanent --add-service=high-availability
```

- El comando agrega de forma permanente la regla de firewall necesaria para permitir las comunicaciones utilizadas por los servicios de alta disponibilidad, como Pacemaker y Corosync.
    - `firewall-cmd`: Herramienta de administración de reglas de firewall en sistemas que utilizan firewalld.
    - `--permanent`: Indica que el cambio se guardará de forma permanente y persistirá después de reiniciar el sistema.
    - `--add-service=high-availability`: Agrega el servicio predefinido `high-availability`, habilitando los puertos y protocolos requeridos para el funcionamiento del clúster de alta disponibilidad.

&nbsp;


```bash
# firewall-cmd --reload
```

- El comando recarga la configuración de firewalld para aplicar los cambios realizados en las reglas o servicios configurados previamente.
    - `firewall-cmd`: Herramienta de administración de reglas de firewall en sistemas que utilizan firewalld.
    - `--reload`: Recarga la configuración activa del firewall sin necesidad de reiniciar el servicio o el sistema operativo.

&nbsp;

```bash
# firewall-cmd --list-services
```

- El comando muestra la lista de servicios actualmente permitidos en la configuración activa del firewall, permitiendo verificar qué reglas de acceso se encuentran habilitadas.
    - `firewall-cmd`: Herramienta de administración de reglas de firewall en sistemas que utilizan firewalld.
    - `--list-services`: Muestra todos los servicios autorizados en la zona activa del firewall.

---

&nbsp;

## FASE 2 — Configuración de Almacenamiento Compartido iSCSI
&nbsp;

⚠️ <small>Aplicar en: **nodo4**</small>

**Habilitar los puertos para iscsi en el firewall**

```bash
# firewall-cmd --permanent --add-service=iscsi-target
```

- El comando habilita de forma permanente el servicio de iSCSI Target en el firewall, permitiendo que otros sistemas puedan descubrir y conectarse al almacenamiento exportado por el servidor iSCSI.
    - `firewall-cmd`: Herramienta utilizada para administrar reglas del firewall en sistemas que usan firewalld.
    - `--permanent`: Indica que la regla se guardará de forma permanente y persistirá después de reiniciar el sistema.
    - `--add-service=iscsi-target`: Habilita el servicio predefinido de iSCSI Target, abriendo los puertos necesarios para la comunicación iSCSI.

&nbsp;

```bash
# firewall-cmd --reload
```

- El comando recarga la configuración de firewalld para aplicar los cambios realizados en las reglas o servicios configurados previamente.
    - `firewall-cmd`: Herramienta de administración de reglas de firewall en sistemas que utilizan firewalld.
    - `--reload`: Recarga la configuración activa del firewall sin necesidad de reiniciar el servicio o el sistema operativo.


&nbsp;

```bash
# dnf install targetcli -y
```

- El comando instala la herramienta `targetcli`, utilizada para configurar y administrar targets iSCSI en el sistema, permitiendo exportar almacenamiento en red.
    - `dnf`: Gestor de paquetes utilizado en distribuciones basadas en Red Hat (como RHEL, Rocky Linux o AlmaLinux) para instalar, actualizar o eliminar software.
    - `install`: Indica que se realizará la instalación de un paquete.
    - `targetcli`: Paquete que proporciona una interfaz para configurar targets iSCSI (LIO).
    - `-y`: Responde automáticamente “sí” a todas las confirmaciones durante la instalación, evitando interacción manual.

&nbsp;

```bash
# systemctl enable --now target
```

- El comando habilita e inicia inmediatamente el servicio `target`, encargado de gestionar los targets iSCSI en el sistema, asegurando que el almacenamiento exportado esté disponible de forma persistente después de cada reinicio.
    - `systemctl`: Herramienta utilizada para administrar servicios gestionados por systemd.
    - `enable`: Configura el servicio para que se inicie automáticamente al arranque del sistema.
    - `--now`: Inicia el servicio de forma inmediata sin necesidad de un reinicio.
    - `target`: Servicio de LIO/targetd que gestiona la exportación de almacenamiento iSCSI en el sistema.

&nbsp;

```bash
# lsblk -l
```

- El comando muestra la lista de dispositivos de bloques del sistema en formato de lista, permitiendo identificar discos, particiones y volúmenes disponibles, incluyendo aquellos conectados por iSCSI.
    - `lsblk`: Herramienta utilizada para listar dispositivos de bloque como discos, particiones y volúmenes lógicos.
    - `-l`: Muestra la salida en formato de lista (uno por línea) en lugar de una vista en árbol.

&nbsp;


```bash
# targetcli
```

- El comando inicia la interfaz interactiva de `targetcli`, utilizada para configurar y administrar targets iSCSI en el sistema mediante el framework LIO.
    - `targetcli`: Herramienta de línea de comandos interactiva para gestionar la configuración de targets iSCSI (LIO), incluyendo creación de backstores, LUNs, ACLs y exportación de almacenamiento.

&nbsp;

```bash
/backstores/block create name=san-quorum dev=/dev/nvme0n2

/backstores/block create name=san-datos dev=/dev/nvme0n3

/iscsi create iqn.2026-06.laboratorio.san:storage

cd /iscsi/iqn.2026-06.laboratorio.san:storage/tpg1/

luns/ create /backstores/block/san-quorum

luns/ create /backstores/block/san-datos

set attribute authentication=0 demo_mode_write_protect=0 generate_node_acls=1

exit
```

- Configura un target iSCSI en la cabina SAN, creando dos discos exportados (san-quorum y san-datos) a partir de dispositivos locales, definiendo el IQN del target, asignando ambos como LUNs disponibles para los nodos del clúster y habilitando el acceso sin autenticación para que puedan conectarse y utilizarlos como almacenamiento compartido.


----

&nbsp;

**Instalar utilerías iSCSI**

<small>Aplicar en: **nodo1, nodo2 y nodo3**</small>

Ejecutar:

```bash
# dnf install iscsi-initiator-utils -y
```

- El comando instala las utilidades necesarias para que el sistema funcione como iniciador iSCSI, permitiendo descubrir, conectar y administrar sesiones con targets de almacenamiento remoto.
    - `dnf`: Gestor de paquetes utilizado en distribuciones basadas en Red Hat (como RHEL, Rocky Linux o AlmaLinux) para instalar, actualizar o eliminar software.
    - `install`: Indica que se realizará la instalación de un paquete.
    - `iscsi-initiator-utils`: Paquete que proporciona las herramientas `iscsiadm` y servicios necesarios para conectarse a targets iSCSI.
    - `-y`: Responde automáticamente “sí” a todas las confirmaciones durante la instalación, evitando interacción manual.

&nbsp;

```bash
# systemctl enable --now iscsid
```

- ¿Qué hace?: Descarga las utilidades de almacenamiento por red e inicia el 
  demonio encargado de simular discos duros locales sobre la red TCP/IP.


&nbsp;

**Descubrir Targets iSCSI**

```bash
# iscsiadm -m discovery -t sendtargets -p 10.0.0.20
```

- El comando realiza el descubrimiento de los targets iSCSI disponibles en el servidor especificado, permitiendo identificar los recursos de almacenamiento que pueden ser utilizados por el sistema.
    - `iscsiadm`: Herramienta de administración y configuración de conexiones iSCSI.
    - `-m discovery`: Indica que la operación se realizará en modo de descubrimiento de targets iSCSI.
    - `-t sendtargets`: Especifica el método SendTargets para solicitar al servidor la lista de targets disponibles.
    - `-p 10.0.0.20`: Define la dirección IP del servidor iSCSI que será consultado.

&nbsp;

**Iniciar sesión contra la cabina SAN**


```bash
# iscsiadm -m node -T iqn.2026-06.laboratorio.san:storage -p 10.0.0.20 --login
```

- El comando establece una conexión con el target iSCSI especificado, permitiendo que el sistema acceda al almacenamiento remoto exportado por el servidor iSCSI.
    - `iscsiadm`: Herramienta de administración y configuración de conexiones iSCSI.
    - `-m node`: Indica que la operación se realizará sobre un nodo iSCSI previamente descubierto.
    - `-T iqn.2026-06.laboratorio.san:storage`: Especifica el IQN (iSCSI Qualified Name) del target al que se desea conectar.
    - `-p 10.0.0.20`: Define la dirección IP del portal iSCSI donde se encuentra publicado el target.
    - `--login`: Inicia la sesión iSCSI y establece la conexión con el target especificado.

&nbsp;

**Validar nuevos discos**


```bash
# lsblk
```

- El comando muestra la lista de dispositivos de bloques del sistema en formato de lista, permitiendo identificar discos, particiones y volúmenes disponibles, incluyendo aquellos conectados por iSCSI.
    - `lsblk`: Herramienta utilizada para listar dispositivos de bloque como discos, particiones y volúmenes lógicos.
    - `-l`: Muestra la salida en formato de lista (uno por línea) en lugar de una vista en árbol.

&nbsp;

**Configurar inicio automático de sesiones iSCSI**

```bash
# iscsiadm -m node --op update -n node.startup -v automatic
```

- El comando configura los nodos iSCSI para que las conexiones se establezcan automáticamente al iniciar el sistema operativo, asegurando que los discos remotos estén disponibles después de cada reinicio.
    - `iscsiadm`: Herramienta de administración y configuración de conexiones iSCSI.
    - `-m node`: Indica que la operación se realizará sobre los nodos iSCSI configurados en el sistema.
    - `--op update`: Especifica que se modificará un parámetro de configuración existente.
    - `-n node.startup`: Define el parámetro de configuración relacionado con el comportamiento de inicio de la conexión iSCSI.
    - `-v automatic`: Establece el valor del parámetro para que la conexión iSCSI se inicie automáticamente durante el arranque del sistema.


&nbsp;

```bash
# systemctl restart iscsid
```

- El comando reinicia el servicio iscsid, responsable de gestionar las conexiones y sesiones iSCSI en el sistema. Esto permite aplicar cambios recientes en la configuración y restablecer la comunicación con los dispositivos de almacenamiento iSCSI.
    - `systemctl`: Herramienta utilizada para administrar servicios gestionados por systemd.
    - `restart`: Indica a systemctl que debe detener e iniciar nuevamente el servicio especificado.
    - `iscsid`: Nombre del servicio iSCSI Daemon que administra las sesiones y autenticación de las conexiones iSCSI.

---
&nbsp;

## FASE 3 — Instalación de Pacemaker, Corosync y PCS

&nbsp;

<small>Aplicar en: **nodo1, nodo2 y nodo3**</small>

**Habilitar repositorio High Availability**


Ejecutar:

```bash
# dnf config-manager --set-enabled highavailability
```

- El comando habilita el repositorio de alta disponibilidad (High Availability) en el sistema, permitiendo la instalación de paquetes necesarios para clústeres como Pacemaker, Corosync y herramientas relacionadas.
    - `dnf`: Gestor de paquetes utilizado en distribuciones basadas en Red Hat para instalar, actualizar y gestionar software.
    - `config-manager`: Subcomando de DNF que permite gestionar repositorios del sistema.
    - `--set-enabled`: Activa un repositorio deshabilitado previamente.
    - `highavailability`: Nombre del repositorio que contiene paquetes relacionados con soluciones de alta disponibilidad.

&nbsp;

```bash
# dnf clean all
```

- El comando limpia la caché local de DNF, eliminando metadatos y paquetes almacenados para forzar que el sistema descargue información actualizada de los repositorios.
    - `dnf`: Gestor de paquetes utilizado en sistemas basados en Red Hat para instalar y administrar software.
    - `clean`: Subcomando que indica que se realizará una limpieza de la caché.
    - `all`: Especifica que se eliminará toda la caché de DNF (metadatos, paquetes descargados y datos temporales).

&nbsp;

```bash
# dnf install -y pacemaker pcs corosync sbd fence-agents-sbd
```

- El comando instala los componentes necesarios para configurar un clúster de alta disponibilidad basado en Pacemaker, Corosync y SBD, incluyendo herramientas de gestión y agentes de fencing.
    - `install`: Indica que se realizará la instalación de paquetes.
    - `-y`: Acepta automáticamente todas las confirmaciones durante la instalación.
    - `pacemaker`: Motor de clúster encargado de gestionar recursos y garantizar alta disponibilidad.
    - `pcs`: Herramienta de administración para configurar y gestionar el clúster.
    - `corosync`: Sistema de mensajería que permite la comunicación entre nodos del clúster.
    - `sbd`: Servicio de STONITH Block Device utilizado para fencing en entornos de alta disponibilidad.
    - `fence-agents-sbd`: Paquete que proporciona agentes de fencing para integrar SBD con Pacemaker.


&nbsp;

```bash
# rpm -qa | egrep "pacemaker|pcs|corosync|sbd"
```

- El comando lista los paquetes instalados en el sistema y filtra aquellos relacionados con Pacemaker, PCS, Corosync y SBD para verificar que los componentes del clúster estén correctamente instalados.
    - `rpm`: Herramienta de gestión de paquetes en sistemas basados en Red Hat.
    - `-qa`: Lista todos los paquetes instalados en el sistema.
    - `|`: Redirige la salida del comando anterior como entrada del siguiente.
    - `egrep`: Filtra la salida usando expresiones regulares extendidas.
    - `"pacemaker|pcs|corosync|sbd"`: Expresión que busca paquetes que coincidan con cualquiera de esos nombres.

&nbsp;

```bash
# systemctl enable --now pcsd
```

- El comando habilita e inicia el servicio `pcsd`, que es el demonio encargado de la comunicación y administración remota del clúster mediante la herramienta PCS.
    - `systemctl`: Herramienta utilizada para administrar servicios gestionados por systemd.
    - `enable`: Configura el servicio para que se inicie automáticamente al arrancar el sistema.
    - `--now`: Inicia el servicio inmediatamente sin necesidad de reiniciar.
    - `pcsd`: Servicio (daemon) que permite la administración y configuración del clúster Pacemaker/Corosync mediante PCS.

&nbsp;

**Configurar contraseña del usuario hacluster**

<small>Aplicar en: **nodo1, nodo2 y nodo3**</small>

Ejecutar:

```bash
# passwd hacluster
```

Utilizar exactamente la misma contraseña en todos los servidores.


&nbsp;

**Validar servicio pcsd**

```bash
# systemctl status pcsd
```

Debe mostrarse:

```text
active (running)
```

---
&nbsp;

## FASE 4 — Creación del Cluster

⚠️ <small>Aplicar SOLO en: **nodo1**</small>

&nbsp;

**Autenticar nodos**

```bash
# pcs host auth nodo1.laboratorio nodo2.laboratorio nodo3.laboratorio -u hacluster
```

- Ingresar la contraseña cuando sea solicitada.

- El comando autentica los nodos especificados para que puedan formar parte del clúster y comunicarse entre sí mediante la herramienta PCS (Pacemaker/Corosync Configuration System).
    - `pcs`: Herramienta utilizada para administrar y configurar clústeres basados en Pacemaker y Corosync.
    - `host auth`: Indica que se realizará el proceso de autenticación entre los nodos del clúster.
    - `nodo1.laboratorio nodo2.laboratorio nodo3.laboratorio`: Lista de nodos que serán autenticados para participar en el clúster.
    - `-u hacluster`: Especifica el usuario utilizado para la autenticación entre los nodos, normalmente el usuario de administración del clúster.

&nbsp;

**Validar autenticación**

```bash
# pcs host auth
```

&nbsp;

**Crear Cluster**

```bash
# pcs cluster setup cluster_laboratorio nodo1.laboratorio nodo2.laboratorio nodo3.laboratorio
```

- El comando crea y configura un nuevo clúster de Pacemaker/Corosync utilizando los nodos especificados, estableciendo la configuración inicial necesaria para la comunicación y gestión de alta disponibilidad.
    - `pcs`: Herramienta utilizada para administrar y configurar clústeres basados en Pacemaker y Corosync.
    - `cluster setup`: Indica que se realizará la creación y configuración inicial de un clúster.
    - `cluster_laboratorio`: Nombre asignado al clúster.
    - `nodo1.laboratorio nodo2.laboratorio nodo3.laboratorio`: Lista de nodos que formarán parte del clúster.


&nbsp;

**Arrancar Cluster**

```bash
# pcs cluster start --all
```

- El comando inicia los servicios del clúster en todos los nodos configurados, permitiendo que Pacemaker y Corosync comiencen a operar y gestionar los recursos de alta disponibilidad.
    - `pcs`: Herramienta utilizada para administrar y configurar clústeres basados en Pacemaker y Corosync.
    - `cluster start`: Indica que se iniciarán los servicios del clúster.
    - `--all`: Especifica que la acción se ejecutará en todos los nodos que forman parte del clúster.


&nbsp;

**Habilitar inicio automático**
```bash
# pcs cluster enable --all
```

- El comando habilita los servicios del clúster en todos los nodos configurados para que se inicien automáticamente durante el arranque del sistema operativo.
    - `pcs`: Herramienta utilizada para administrar y configurar clústeres basados en Pacemaker y Corosync.
    - `cluster enable`: Indica que los servicios del clúster serán habilitados para iniciar automáticamente.
    - `--all`: Especifica que la acción se aplicará a todos los nodos que forman parte del clúster.



&nbsp;

**Verificar estado del cluster**

```bash
# pcs status
```

- El comando muestra el estado general del clúster, incluyendo los nodos, recursos, servicios y condiciones actuales de Pacemaker y Corosync.
    - `pcs`: Herramienta utilizada para administrar y configurar clústeres basados en Pacemaker y Corosync.
    - `status`: Muestra un resumen del estado operativo del clúster y sus componentes.



&nbsp;

**Validar quorum**

```bash
# pcs quorum status
```

- El comando muestra información detallada sobre el estado del quórum del clúster, permitiendo verificar si existe el número suficiente de nodos activos para mantener la operación y evitar situaciones de partición del clúster.
    - `pcs`: Herramienta utilizada para administrar y configurar clústeres basados en Pacemaker y Corosync.
    - `quorum status`: Muestra el estado actual del quórum y la información relacionada con la membresía del clúster.


&nbsp;

**Validar estado de Corosync**

```bash
# corosync-cfgtool -s
```

- El comando muestra el estado de la comunicación y conectividad de Corosync entre los nodos del clúster, permitiendo verificar que los enlaces de red se encuentren operativos.
    - `corosync-cfgtool`: Herramienta utilizada para consultar y administrar la configuración y el estado de Corosync.
    - `-s`: Muestra el estado actual de los enlaces y la comunicación entre los nodos del clúster.


&nbsp;

**Validar membresía del Cluster**

```bash
# corosync-quorumtool
```

- El comando muestra información sobre el quórum del clúster, permitiendo verificar si existe el número suficiente de nodos activos para que el clúster pueda operar correctamente.
    - `corosync-quorumtool`: Herramienta utilizada para consultar el estado del quórum y la membresía del clúster gestionado por Corosync.

---

&nbsp;

## FASE 5 — Configuración de Fencing SBD

<small>Aplicar en: **nodo1**</small>

⚠️ Esta fase protege al Cluster contra Split-Brain.

&nbsp;

**Validar disco de **1GiB** dedicado para SBD**

```bash
# lsblk
```

&nbsp;

**Inicializar disco SBD**

```bash
# sbd -d /dev/sda create
```

- El comando inicializa y crea la estructura SBD (STONITH Block Device) sobre el dispositivo especificado, preparándolo para ser utilizado como mecanismo de fencing en el clúster de alta disponibilidad.
    - `sbd`: Herramienta utilizada para administrar dispositivos SBD empleados por Pacemaker para operaciones de fencing.
    - `-d /dev/sda`: Especifica el dispositivo de almacenamiento donde se creará la partición o metadatos SBD.
    - `create`: Crea e inicializa la estructura SBD en el dispositivo seleccionado.

&nbsp;

**Validar metadata SBD**

```bash
# sbd -d /dev/sda dump
```

- El comando muestra la información y los metadatos almacenados en el dispositivo SBD especificado, permitiendo verificar que la configuración se haya creado correctamente.
    - `sbd`: Herramienta utilizada para administrar dispositivos SBD empleados por Pacemaker para operaciones de fencing.
    - `-d /dev/sda`: Especifica el dispositivo SBD que será consultado.
    - `dump`: Muestra el contenido y los metadatos almacenados en el dispositivo SBD.


&nbsp;

**Registrar cada nodo en SBD**

Ejecutar:
<small>Aplicar en: **nodo1, nodo2 y nodo3**</small>

```bash
# sbd -d /dev/sda allocate $(hostname)
```

- El comando asigna un slot en el dispositivo SBD al nodo actual, permitiendo que el clúster pueda gestionar operaciones de fencing y monitoreo para dicho nodo.
    - `sbd`: Herramienta utilizada para administrar dispositivos SBD empleados por Pacemaker para operaciones de fencing.
    - `-d /dev/sda`: Especifica el dispositivo SBD donde se realizará la asignación.
    - `allocate`: Crea o reserva un slot para un nodo dentro del dispositivo SBD.
    - `$(hostname)`: Sustituye automáticamente el nombre del host actual, asignando el slot al nodo donde se ejecuta el comando.

&nbsp;

**Validar slots registrados**

```bash
# sbd -d /dev/sda list
```

- El comando muestra la lista de slots configurados en el dispositivo SBD, permitiendo verificar qué nodos han sido registrados para las operaciones de fencing del clúster.
    - `sbd`: Herramienta utilizada para administrar dispositivos SBD empleados por Pacemaker para operaciones de fencing.
    - `-d /dev/sda`: Especifica el dispositivo SBD que será consultado.
    - `list`: Muestra los slots y nodos registrados en el dispositivo SBD.

&nbsp;

**Cargar Watchdog del Kernel**

```bash
# modprobe softdog
```

- El comando carga en el kernel el módulo `softdog`, habilitando un watchdog por software que puede ser utilizado por el clúster para detectar fallos y realizar acciones de recuperación o fencing cuando sea necesario.
    - `modprobe`: Herramienta utilizada para cargar y administrar módulos del kernel de Linux.
    - `softdog`: Módulo de watchdog por software que supervisa el sistema y puede forzar un reinicio si deja de recibir señales de funcionamiento adecuadas.

&nbsp;

**Configurar carga automática**

```bash
# echo softdog > /etc/modules-load.d/softdog.conf
```

- El comando configura el sistema para que el módulo `softdog` se cargue automáticamente durante el arranque, garantizando la disponibilidad del watchdog por software después de cada reinicio.
    - `echo softdog`: Envía el nombre del módulo que se desea cargar automáticamente.
    - `>`: Redirige la salida del comando hacia un archivo, sobrescribiendo su contenido si ya existe.
    - `/etc/modules-load.d/softdog.conf`: Archivo de configuración utilizado por el sistema para cargar módulos del kernel automáticamente durante el inicio.

&nbsp;

**Validar watchdog**

```bash
# ls -l /dev/watchdog
```

- El comando muestra información detallada sobre el dispositivo `watchdog`, permitiendo verificar que el watchdog se encuentra disponible y correctamente creado en el sistema.
    - `ls`: Herramienta utilizada para listar archivos y directorios.
    - `-l`: Muestra la información en formato detallado, incluyendo permisos, propietario, grupo, tamaño y fecha de modificación.
    - `/dev/watchdog`: Archivo de dispositivo que proporciona acceso al watchdog del sistema.

&nbsp;

**Configurar SBD**

Editar:

```bash
# vi /etc/sysconfig/sbd
```

Configurar:

```bash
SBD_DEVICE="/dev/sda"
SBD_WATCHDOG_DEV="/dev/watchdog"
```

&nbsp;

**Habilitar servicio SBD**

```bash
# systemctl enable sbd
```

&nbsp;

**Reiniciar daemon**

```bash
# systemctl daemon-reload
```

&nbsp;

**Arrancar servicio SBD**

```bash
# systemctl start sbd
```

&nbsp;

**Verificar servicio**

```bash
# systemctl status sbd
```

---

&nbsp;
## FASE 6 — Configuración de STONITH mediante SBD

⚠️ <small>Aplicar en: **nodo1**</small>

---

Crear recurso STONITH

```bash
# pcs stonith create mi-fencing-sbd fence_sbd devices=/dev/sda pcmk_host_list="nodo1.laboratorio nodo2.laboratorio nodo3.laboratorio"
```


**Verificar recurso creado**
```bash
# pcs stonith config
```



**Verificar estado STONITH**

```bash
# pcs status
```


**Habilitar STONITH**

```bash
# pcs property set stonith-enabled=true
```



**Verificar propiedad**

```bash
# pcs property config
```


**Validar configuración general**

```bash
# pcs status
```

---
&nbsp;

## FASE 7 — Preparación del Almacenamiento Compartido

⚠️ Debido a cambios en Rocky Linux 10, la arquitectura soportada utiliza:

&nbsp;

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

**Validar disco compartido**

```bash
# lsblk
```


**Registrar disco en catálogo LVM**

Ejecutar en todos los nodos:

```bash
# lvmdevices --adddev /dev/sdb
```

---

**Validar dispositivo registrado**

```bash
# lvmdevices
```

---

**Crear Physical Volume**

⚠️ <small>Aplicar en: **nodo1**</small>

&nbsp;

Ejecutar:

```bash
# pvcreate /dev/sdb
```



**Validar PV**

```bash
# pvs
```


**Crear Volume Group**

```bash
# vgcreate vg_datos_ha /dev/sdb
```

---

**Validar VG**

```bash
# vgs
```

---

**Forzar descubrimiento en nodos secundarios**

⚠️ <small>Aplicar en: **nodo2 y nodo3**</small>

&nbsp;

Ejecutar:

```bash
# vgscan
```

---

**Crear Logical Volume**

```bash
# lvcreate -l 100%FREE --name lv_almacenamiento vg_datos_ha
```

---

**Validar LV**

```bash
# lvs
```

---

**Formatear volumen XFS**

```bash
# mkfs.xfs /dev/vg_datos_ha/lv_almacenamiento
```

---

**Validar Filesystem**

```bash
# blkid
```

---

**Desactivar Volume Group**

⚠️ Paso obligatorio.

```bash
# vgchange -an vg_datos_ha
```

---

**Verificar VG inactivo**

```bash
# vgs
```

La columna Attr debe indicar que el VG no se encuentra activo.

---
&nbsp;

## FASE 8 — Configuración de Exclusión de Activación Automática


⚠️  <small>Aplicar en: **nodo1, nodo2 y nodo3**</small>

&nbsp;


**Respaldar configuración LVM**

```bash
# cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.bak
```

---

**Editar configuración**

```bash
# vi /etc/lvm/lvm.conf
```

---

**Modificar sección activation**

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

**Validar sintaxis**

```bash
# grep -n volume_list /etc/lvm/lvm.conf
```

---

**Regenerar initramfs**

```bash
# dracut -f --regenerate-all
```

---

**Verificar finalización correcta**

```bash
# echo $?
```

Resultado esperado **`0`**

&nbsp;

---

**Reiniciar servidor**

Ejecutar nodo por nodo.

```bash
# reboot
```

---

**Validar que el VG compartido no se active automáticamente**

```bash
# lvs
```

El volumen compartido no debe encontrarse montado ni activo.

---

**Validar estado general del Cluster**

```bash
# pcs status
```

Todos los nodos deben encontrarse Online.

---
&nbsp;

## FASE 9 — Creación de Recursos del Cluster
&nbsp;

⚠️ <small>Aplicar en: **nodo1**</small>

&nbsp;

**Crear recurso LVM-activate**

```bash
# pcs resource create vg_datos_ha ocf:heartbeat:LVM-activate vgname=vg_datos_ha vg_access_mode=tagging
```

&nbsp;

**Validar recurso**

```bash
# pcs resource config
```

---

**Crear punto de montaje**

Ejecutar en todos los nodos:

```bash
# mkdir -p /datos
```

---

**Crear recurso Filesystem**

```bash
# pcs resource create fs_datos ocf:heartbeat:Filesystem device="/dev/vg_datos_ha/lv_almacenamiento" directory="/datos" fstype="xfs"
```

---

**Crear IP Virtual**

```bash
# pcs resource create vip_datos ocf:heartbeat:IPaddr2 ip=10.0.0.100 cidr_netmask=24
```

---

**Verificar recursos creados**

```bash
# pcs resource show
```

---

&nbsp;
## FASE 10 — Agrupación de Recursos

&nbsp;

**Crear grupo**

```bash
# pcs resource group add grupo_datos vg_datos_ha fs_datos vip_datos
```

&nbsp;

**Verificar grupo**

```bash
# pcs resource status
```

&nbsp;

**Validar estado general**

```bash
pcs status
```

---

&nbsp;

---

&nbsp;
## FASE 11 — Prueba de Failover
&nbsp;

**Identificar nodo activo**

```bash
# pcs status
```

&nbsp;

**Colocar nodo en standby**

Ejemplo:

```bash
pcs node standby nodo1.laboratorio
```

&nbsp;

**Verificar migración automática**

```bash
# pcs status
```

Validar:

- Grupo de recursos migrado.
- Filesystem montado en otro nodo.
- IP Virtual activa en nuevo nodo.

---

**Validar acceso a datos**

```bash
ls -l /datos
```

Debe visualizarse:

```text
test_cluster.txt
```

&nbsp;

**Regresar nodo al Cluster**

```bash
# pcs node unstandby nodo1.laboratorio
```

&nbsp;

**Verificar reintegración**

```bash
# pcs status
```

Todos los nodos deben aparecer **Online**.

---
&nbsp;

## FASE 12 — Operación Diaria

&nbsp;
**Estado general del Cluster**

```bash
# pcs status
```

---

**Estado detallado**

```bash
# pcs status --full
```

&nbsp;

**Ver recursos del cluster**

```bash
# pcs resource show
```

&nbsp;

**Ver propiedades del cluster**

```bash
# pcs property config
```

&nbsp;

**Ver STONITH**

```bash
# pcs stonith config
```

&nbsp;

**Ver quorum**

```bash
# pcs quorum status
```

&nbsp;

**Ver configuración completa**

```bash
# pcs config
```

---

**Poner nodo en mantenimiento**

```bash
# pcs node standby <nodo>
```

---

**Regresar nodo a producción**

```bash
# pcs node unstandby <nodo>
```

---

**Reiniciar recurso**

```bash
# pcs resource restart <recurso>
```

&nbsp;

**Limpiar recurso fallido**

```bash
pcs resource cleanup
```

&nbsp;

**Limpiar recurso específico**

```bash
# pcs resource cleanup <recurso>
```

---

&nbsp;

## FASE 13 — Troubleshooting
&nbsp;

**Ver eventos del Cluster**

```bash
# pcs status --full
```

&nbsp;

**Logs de Pacemaker**

```bash
journalctl -u pacemaker -f
```

&nbsp;

**Logs de Corosync**

```bash
journalctl -u corosync -f
```

&nbsp;

**Logs de SBD**

```bash
journalctl -u sbd -f
```

&nbsp;

**Verificar membresía Corosync**

```bash
corosync-quorumtool
```

&nbsp;

**Verificar transporte Corosync**

```bash
corosync-cfgtool -s
```

&nbsp;

**Verificar recursos fallidos**

```bash
pcs status
```

&nbsp;

**Ver slots SBD**

```bash
sbd -d /dev/sda list
```

&nbsp;

**Ver metadata SBD**

```bash
sbd -d /dev/sda dump
```

&nbsp;

**Validar watchdog**

```bash
ls -l /dev/watchdog
```

&nbsp;


**Verificar sesiones iSCSI**

```bash
iscsiadm -m session
```

&nbsp;


**Verificar montaje**

```bash
df -h
```

&nbsp;

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


