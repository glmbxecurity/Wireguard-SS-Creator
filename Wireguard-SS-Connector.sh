#!/bin/sh
# === Instrucciones de uso ===
clear
echo "======================================================="
echo "        🌐 Wireguard-SS-Connector (VPN desde USB)"
echo "======================================================="
echo
echo "Este script permite conectarse o desconectarse de una VPN usando configuraciones"
echo "y claves almacenadas en un dispositivo USB. Requiere privilegios de sudo."
echo
echo "🔹 ¿Qué hace?"
echo " - Escanea dispositivos USB montados."
echo " - Permite seleccionar un archivo .conf de WireGuard."
echo " - Permite seleccionar un archivo .gpg con la clave privada cifrada."
echo " - Descifra la clave, la inserta en el archivo de configuración temporalmente."
echo " - Levanta la interfaz de túnel usando 'wg-quick'."
echo " - También permite cerrar el túnel si ya está activo."
echo
echo "🔒 Consideraciones:"
echo " - Asegúrate de que el archivo .gpg contenga una clave privada válida de WireGuard."
echo " - El archivo .conf debe ser una configuración válida de WireGuard."
echo " - El script eliminará los archivos temporales usados para mayor seguridad."
echo " - El dispositivo USB debe estar montado en /media o /run/media."
echo
echo "📋 Requisitos:"
echo " - gpg"
echo " - wireguard-tools (wg-quick, wg)"
echo " - sudo"
echo
echo "⚠️ Este script sobrescribirá configuraciones previas en wg0."
echo
echo "==============================================="
# === Menú ===

echo "🌐 VPN desde USB"
echo "1) Conectar"
echo "2) Desconectar"
echo -n "Selecciona una opción: "
read OPCION

if [ "$OPCION" = "2" ]; then
    echo "🔻 Cerrando túnel WireGuard..."
    if ip link show wg0 >/dev/null 2>&1; then
        sudo ip link del wg0
        echo "✅ Túnel wg0 eliminado."
    else
        echo "ℹ️ El túnel wg0 no está activo."
    fi
    exit 0
fi

echo "📦 Buscando dispositivos USB montados..."

USB_LIST=$(find /media /run/media -mindepth 2 -maxdepth 2 -type d 2>/dev/null)

if [ -z "$USB_LIST" ]; then
    echo "❌ No se encontraron dispositivos USB montados."
    exit 1
fi

echo "🔌 Dispositivos USB encontrados:"
INDEX=0
echo "$USB_LIST" | while IFS= read -r line; do
    echo " [$INDEX] $line"
    INDEX=$((INDEX + 1))
done

echo -n "Selecciona el número del dispositivo USB: "
read SELECTED_INDEX

case "$SELECTED_INDEX" in
    *[!0-9]* | "") echo "❌ Selección inválida."; exit 1 ;;
esac

USB_PATH=""
INDEX=0
echo "$USB_LIST" | while IFS= read -r line; do
    if [ "$INDEX" -eq "$SELECTED_INDEX" ]; then
        USB_PATH="$line"
        echo "$USB_PATH" > /tmp/usb_path.tmp
        break
    fi
    INDEX=$((INDEX + 1))
done

[ ! -f /tmp/usb_path.tmp ] && echo "❌ Índice fuera de rango." && exit 1
USB_PATH=$(cat /tmp/usb_path.tmp)
rm -f /tmp/usb_path.tmp
echo "✅ Seleccionado: $USB_PATH"

# Buscar archivos .conf
CONF_LIST=$(find "$USB_PATH" -maxdepth 1 -type f -name "*.conf")
[ -z "$CONF_LIST" ] && echo "❌ No se encontraron archivos .conf" && exit 1

echo "📄 Archivos de configuración encontrados:"
INDEX=0
echo "$CONF_LIST" | while IFS= read -r line; do
    echo " [$INDEX] $(basename "$line")"
    INDEX=$((INDEX + 1))
done

echo -n "Selecciona el número del archivo .conf: "
read SELECTED_INDEX

case "$SELECTED_INDEX" in
    *[!0-9]* | "") echo "❌ Selección inválida."; exit 1 ;;
esac

CONF=""
INDEX=0
echo "$CONF_LIST" | while IFS= read -r line; do
    if [ "$INDEX" -eq "$SELECTED_INDEX" ]; then
        CONF="$line"
        echo "$CONF" > /tmp/conf_file.tmp
        break
    fi
    INDEX=$((INDEX + 1))
done

[ ! -f /tmp/conf_file.tmp ] && echo "❌ Índice inválido." && exit 1
CONF=$(cat /tmp/conf_file.tmp)
rm -f /tmp/conf_file.tmp
echo "✅ Configuración seleccionada: $(basename "$CONF")"

# Buscar archivos .gpg
GPG_LIST=$(find "$USB_PATH" -maxdepth 1 -type f -name "*.gpg")
[ -z "$GPG_LIST" ] && echo "❌ No se encontraron archivos .gpg" && exit 1

echo "🔐 Archivos .gpg encontrados:"
INDEX=0
echo "$GPG_LIST" | while IFS= read -r line; do
    echo " [$INDEX] $(basename "$line")"
    INDEX=$((INDEX + 1))
done

echo -n "Selecciona el número del archivo .gpg: "
read SELECTED_INDEX

case "$SELECTED_INDEX" in
    *[!0-9]* | "") echo "❌ Selección inválida."; exit 1 ;;
esac

KEYFILE=""
INDEX=0
echo "$GPG_LIST" | while IFS= read -r line; do
    if [ "$INDEX" -eq "$SELECTED_INDEX" ]; then
        KEYFILE="$line"
        echo "$KEYFILE" > /tmp/key_file.tmp
        break
    fi
    INDEX=$((INDEX + 1))
done

[ ! -f /tmp/key_file.tmp ] && echo "❌ Índice inválido." && exit 1
KEYFILE=$(cat /tmp/key_file.tmp)
rm -f /tmp/key_file.tmp
echo "✅ Clave seleccionada: $(basename "$KEYFILE")"

TMPKEY="/tmp/wg-tempkey"

echo "🔐 Descifrando clave privada..."
if ! gpg -d "$KEYFILE" > "$TMPKEY"; then
    echo "❌ Fallo al descifrar la clave"
    exit 1
fi

echo "🔧 Preparando y levantando túnel WireGuard..."
sudo ip link del wg0 2>/dev/null

WG_PRIVATE_KEY=$(cat "$TMPKEY")

TMPDIR=$(mktemp -d)
TMPCONF="$TMPDIR/wg0.conf"

(
    while IFS= read -r line; do
        case "$line" in
            PrivateKey\ =*) echo "PrivateKey = $WG_PRIVATE_KEY" ;;
            *) echo "$line" ;;
        esac
    done < "$CONF"
) > "$TMPCONF"

echo "▶ Ejecutando: sudo WG_QUICK_USER=$(whoami) wg-quick up $TMPCONF"
sudo WG_QUICK_USER="$(whoami)" wg-quick up "$TMPCONF" || {
    echo "❌ Fallo al levantar el túnel."
    cat "$TMPCONF"
    shred -u "$TMPKEY"
    shred -u "$TMPCONF"
    rmdir "$TMPDIR"
    exit 1
}

shred -u "$TMPKEY"
shred -u "$TMPCONF"
rmdir "$TMPDIR"

echo "✅ Túnel WireGuard levantado correctamente."
