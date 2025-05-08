# Wireguard-SS-Creator (Wireguard Simple & Secure Creator)

## ¿Qué es Wireguard-SS-Creator?

**Wireguard-SS-Creator** es una herramienta sencilla y segura para la creación y gestión de túneles VPN utilizando **WireGuard**. Este proyecto está diseñado para ayudar a administradores de redes y usuarios a configurar rápidamente un servidor **WireGuard** y generar configuraciones de cliente de manera segura, con claves privadas cifradas usando **GPG** y contraseñas únicas generadas a partir de un diccionario de palabras.

El objetivo principal es automatizar la creación de túneles seguros, proporcionando una solución para crear múltiples clientes sin comprometer la seguridad de las claves.

## Características

- **Creación de un túnel WireGuard para el servidor**: El script genera automáticamente la configuración del servidor WireGuard, incluyendo la clave privada y pública del servidor, así como la configuración de red.
  
- **Generación de múltiples clientes**: Puedes agregar fácilmente múltiples clientes al servidor WireGuard. El script crea los archivos de configuración para cada cliente y actualiza el archivo `server.conf` para incluir las claves públicas de los nuevos clientes.
  
- **Cifrado de claves privadas con GPG**: Las claves privadas de los clientes se almacenan de manera segura en archivos **GPG**. Las claves se cifran con una **contraseña simétrica** única generada automáticamente y almacenada en un archivo de texto separado.

- **Contraseñas seguras y fáciles de recordar**: Las contraseñas para cifrar las claves privadas se generan a partir de un diccionario de palabras, combinando palabras aleatorias con números y caracteres especiales para asegurar una contraseña de al menos 18 caracteres.

- **Compatibilidad con POSIX**: El script es completamente compatible con sistemas POSIX, lo que significa que debería funcionar en una amplia variedad de sistemas Unix/Linux sin depender de características específicas de Bash.

- **Facilidad de uso**: El script cuenta con un menú interactivo que te permite elegir entre crear un túnel o agregar nuevos clientes al servidor sin complicaciones.

## ¿Qué hace el script?

### 1. **Creación de Túnel (Servidor)**

- Genera una clave privada y pública para el servidor.
- Crea la configuración básica del servidor WireGuard, especificando la dirección IP y el puerto de escucha.
- Guarda la configuración en el archivo `server.conf`.

### 2. **Creación de Clientes**

- Genera una clave privada y pública para cada cliente.
- Cifra la clave privada de cada cliente con GPG y una contraseña generada aleatoriamente (de acuerdo con las reglas de seguridad mencionadas).
- Crea la configuración del cliente, reemplazando la clave privada por un marcador que indica que debe ser descifrada al momento de la conexión.
- Actualiza el archivo `server.conf` con la clave pública del nuevo cliente y su configuración de red.

### 3. **Almacenamiento Seguro de Contraseñas**

- Las contraseñas utilizadas para cifrar las claves privadas de los clientes se almacenan en archivos de texto (`clientX.txt`).
- Las contraseñas son generadas aleatoriamente combinando palabras del diccionario con números y caracteres especiales.

## ¿Cómo usar Wireguard-SS-Creator?

### Requisitos

- **WireGuard** debe estar instalado en tu servidor y en las máquinas cliente.
- **GPG** debe estar instalado para cifrar las claves privadas de los clientes.
- Un sistema compatible con **POSIX**, como Linux o macOS.

### Instalación

1. Clona el repositorio:

    ```bash
    git clone https://github.com/tu_usuario/wireguard-ss-creator.git
    cd wireguard-ss-creator
    ```

2. Asegúrate de tener el diccionario de palabras (`diccionario.txt`) en el mismo directorio del script. Si no tienes uno, puedes crear uno o utilizar uno preexistente.

### Usar el script

Ejecuta el script en tu terminal:

```bash
./wg_secure_creator.sh

