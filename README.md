# Wireguard-SS-Creator & Wireguard-SS-Connector

**Wireguard-SS-Creator** y **Wireguard-SS-Connector** son dos herramientas diseñadas para ofrecer una solución simple, segura y portátil para la creación y gestión de túneles VPN utilizando **WireGuard**. Estas herramientas están especialmente orientadas a administradores de redes y usuarios que deseen mantener la seguridad de sus claves privadas mientras utilizan conexiones VPN.

- **Wireguard-SS-Creator**: Ayuda en la creación de configuraciones de servidor y cliente de WireGuard, generando claves privadas cifradas con **GPG** y contraseñas seguras para cada cliente. Ideal para configurar servidores y distribuir configuraciones de cliente de forma segura.
- **Wireguard-SS-Connector**: Proporciona un script interactivo para conectar y desconectar fácilmente desde un dispositivo USB, utilizando las configuraciones y claves privadas generadas previamente por **Wireguard-SS-Creator**. Garantiza que la clave privada se mantenga cifrada en el dispositivo USB hasta el momento de la conexión.

---

## 🚀 ¿Qué hacen estas herramientas?

### **Wireguard-SS-Creator**
**Wireguard-SS-Creator** es una herramienta que facilita la creación y gestión de configuraciones para un servidor **WireGuard** y sus clientes. Esta herramienta genera:

- Configuraciones de **WireGuard** para el servidor y para cada cliente.
- Claves privadas **cifradas** con **GPG**.
- Contraseñas seguras generadas aleatoriamente para cifrar las claves privadas.
- Un archivo de configuración del servidor que incluye las claves públicas de todos los clientes.

**Características principales**:

- Generación automática de claves privadas y públicas para el servidor y los clientes.
- Cifrado seguro de las claves privadas de los clientes usando **GPG**.
- Actualización automática del archivo `server.conf` del servidor con las claves públicas de los clientes.
- Uso de contraseñas seguras y fáciles de recordar para cifrar las claves privadas.
- Compatibilidad con **POSIX** para funcionar en cualquier sistema Unix/Linux.

---

### **Wireguard-SS-Connector**
**Wireguard-SS-Connector** es una herramienta que permite a los usuarios conectar y desconectar de su VPN **WireGuard** de manera segura y portátil desde un dispositivo USB. Funciona de la siguiente manera:

- Detecta automáticamente los dispositivos USB montados.
- Permite al usuario seleccionar el dispositivo USB que contiene los archivos de configuración de WireGuard (`.conf`) y las claves privadas cifradas (`.gpg`).
- Descifra de manera segura la clave privada cuando se conecta al túnel VPN.
- No modifica configuraciones globales en el sistema, asegurando que todo el proceso se mantenga dentro del USB.

**Características principales**:

- **Conexión portátil**: Usa un dispositivo USB para almacenar las configuraciones y claves, permitiendo portar la conexión VPN de manera fácil y segura.
- **Descifrado seguro**: Las claves privadas se descifran únicamente cuando se establece la conexión, utilizando GPG.
- **Selector interactivo**: Permite elegir el dispositivo USB, los archivos `.conf` y `.gpg` de forma interactiva.
- **Desconexión independiente del sistema**: Utiliza `ip link del wg0` para desconectar el túnel sin modificar archivos globales.
- **Compatibilidad POSIX**: El script es completamente compatible con sistemas Unix/Linux sin depender de características específicas de Bash.

---

## 📦 Requisitos

Para ambas herramientas necesitarás:

- **WireGuard** debe estar instalado en tu servidor y en las máquinas cliente.
- **GPG** debe estar instalado para cifrar y descifrar las claves privadas.
- Un sistema compatible con **POSIX**, como Linux o macOS.
- Un dispositivo USB con:
  - Archivos de configuración de WireGuard (`.conf`).
  - Archivos de claves privadas cifradas (`.gpg`).

---
## Imagenes
[img1](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/creator1.png)  
[img2](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/creator2.png)  
[img3](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/creator3.png)  
[img4](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/creator4.png)  
[img5](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/creator5.png)  
[img6](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/creator6.png)  

[connector1](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/connector1.png)  
[connector2](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/connector2.png)  
[connector3](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/connector3.png)  
[connector4](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/connector4.png)  
[connector5](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/connector5.png)  
[connector6](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/connector6.png)  
[connector7](https://raw.githubusercontent.com/glmbxecurity/Wireguard-SS-Creator/refs/heads/main/images/connector7.png)

## 📋 Instrucciones de Uso

### 1. **Instalación de Wireguard-SS-Creator**

Clona el repositorio y entra al directorio del proyecto:

```bash
git clone https://github.com/glmbxecurity/Wireguard-SS-Creator.git
cd Wireguard-SS-Creator
```
### 2. Crear las configuraciones de WireGuard

Ejecuta el script para crear las configuraciones de tu servidor y cliente:
```bash
./Wireguard-SS-Creator.sh
```
Este script generará:
* El archivo de configuración del servidor (**server.conf**).
* Los archivos de configuración para cada cliente con sus claves privadas cifradas (**clientX.gpg**).
* Los archivos con las credenciales para descifrar cada ClientX.gpg (**ClientX.txt**).

### 3. Preparar el dispositivo USB con Wireguard-SS-Connector  

Una vez generadas las configuraciones y claves, puedes transferir los archivos de configuración (clientX.conf) y las claves privadas cifradas (clientX.gpg) a tu dispositivo USB.  

En la raíz de tu dispositivo USB, deberías tener algo como esto:  
```bash
/mi_usb/
│
├── tunel.conf        # Archivo de configuración de WireGuard
├── clave.gpg         # Clave privada cifrada con GPG
└── Wireguard-SS-Connector.sh        # Script para conectar y desconectar el túnel
```
### 4. Ejecutar el script de Wireguard-SS-Connector

Una vez tengas tu USB preparado, conecta el dispositivo y ejecuta el script **Wireguard-SS-Connector.sh** para conectar o desconectar el túnel VPN:  
```bash
cd /path/to/Wireguard-SS-Connector.sh
./Wireguard-SS-Connector.sh
```
El script contiene un menú en el que puedes seleccionar:    
* 1 **Conectar**: Elige el dispositivo USB, el archivo .conf de la configuración de WireGuard y el archivo .gpg con la clave privada. Luego, ingresa la contraseña GPG cuando se te pida.  
* 2 **Desconectar**: Desmonta el túnel VPN con ip link del wg0, sin alterar configuraciones globales.

🛠️ Flujo de trabajo general  
* Crea las configuraciones utilizando Wireguard-SS-Creator.  
* Transfiere las configuraciones a tu dispositivo USB.  
* Conecta el túnel VPN usando Wireguard-SS-Connector desde el USB.  
* Desconecta el túnel cuando lo necesites.  
  🔒 **Seguridad**  

* **Wireguard-SS-Creator** cifra las claves privadas con GPG y las guarda de forma segura.  
* **Wireguard-SS-Connector** solo descifra la clave privada al momento de la conexión y la elimina después de usarla, sin dejar rastro en el sistema.
 
  📝 **Notas adicionales**

  * Wireguard-SS-Connector no modifica archivos de configuración globales como /etc/wireguard, lo que hace que la solución sea completamente portátil.
  * Puedes gestionar múltiples configuraciones de cliente y cambiar entre ellas de forma sencilla.
  * El script limpia los archivos temporales de forma segura, eliminando las claves privadas descifradas después de la conexión.
