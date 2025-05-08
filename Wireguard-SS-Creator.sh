#!/bin/sh

WG_DIR="./wg_secure_configs"
DICT_FILE="./diccionario.txt"
SERVER_CONF="$WG_DIR/server.conf"
CLIENT_DIR="$WG_DIR/clients"
mkdir -p "$CLIENT_DIR"

# Validar diccionario
if [ ! -f "$DICT_FILE" ]; then
    echo "❌ No se encontró el diccionario: $DICT_FILE"
    exit 1
fi

# Función para generar una passphrase de palabras (mínimo 18 caracteres)
generate_passphrase() {
    pass=""
    while [ ${#pass} -lt 20 ]; do
        # Selección aleatoria de palabra del diccionario
        word=$(awk -v var=$((RANDOM % $(wc -l < "$DICT_FILE"))) 'NR == var {print $0}' "$DICT_FILE")
        pass="$pass$word"
    done
    echo "$pass"
}

# Función para crear el túnel (servidor)
create_tunnel() {
    clear
    echo "🛠️  Generando configuración del servidor..."
    SERVER_PRIV_KEY=$(wg genkey)
    SERVER_PUB_KEY=$(echo "$SERVER_PRIV_KEY" | wg pubkey)
    SERVER_IP="10.8.0.1"
    WG_PORT="51820"

    cat > "$SERVER_CONF" <<EOF
[Interface]
PrivateKey = $SERVER_PRIV_KEY
Address = $SERVER_IP/24
ListenPort = $WG_PORT
EOF

    echo "✅ Servidor creado: $SERVER_CONF"
}

# Función para agregar clientes
add_clients() {
    clear
    if [ ! -f "$SERVER_CONF" ]; then
        echo "❌ Debes crear primero el túnel del servidor."
        exit 1
    fi

    SERVER_PUB_KEY=$(awk '/PrivateKey/ {print $3}' "$SERVER_CONF" | wg pubkey)
    WG_PORT=$(awk '/ListenPort/ {print $3}' "$SERVER_CONF")
    ALLOWED_IPS="172.21.1.0/24"

    # Contar la cantidad de peers ya existentes en el server.conf
    CLIENT_COUNT=$(grep -c '\[Peer\]' "$SERVER_CONF")
    echo "📊 Clientes actuales en el servidor: $CLIENT_COUNT"

    read -p "¿Cuántos clientes quieres agregar? " NEW_CLIENTS

    # Validar que no se exceda el número de clientes (opcional, pero puede ser útil)
    if [ $((CLIENT_COUNT + NEW_CLIENTS)) -gt 255 ]; then
        echo "❌ No se pueden agregar más de 255 clientes."
        exit 1
    fi

    i=1
    while [ $i -le "$NEW_CLIENTS" ]; do
        CLIENT_ID=$((CLIENT_COUNT + i))
        CLIENT_PRIV_KEY=$(wg genkey)
        CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)
        CLIENT_PSK=$(wg genpsk)
        CLIENT_IP="10.8.0.$((CLIENT_ID + 1))"

        PASSPHRASE=$(generate_passphrase)

        # Guardar passphrase
        echo "$PASSPHRASE" > "$CLIENT_DIR/client$CLIENT_ID.txt"

        # Cifrar la clave privada
        echo "$CLIENT_PRIV_KEY" | gpg --symmetric --batch --passphrase "$PASSPHRASE" \
            -o "$CLIENT_DIR/client$CLIENT_ID.gpg"

        # Agregar nuevo peer al server.conf
        cat >> "$SERVER_CONF" <<EOF

[Peer]
PublicKey = $CLIENT_PUB_KEY
PresharedKey = $CLIENT_PSK
AllowedIPs = $CLIENT_IP/32
EOF

        # Configuración del cliente
        cat > "$CLIENT_DIR/client$CLIENT_ID.conf" <<EOF
[Interface]
PrivateKey = __REPLACE_WITH_DECRYPTED_KEY__
Address = $CLIENT_IP/32
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB_KEY
PresharedKey = $CLIENT_PSK
Endpoint = TU_IP_PUBLICA_O_DNS:$WG_PORT
AllowedIPs = $ALLOWED_IPS
PersistentKeepalive = 25
EOF

        echo "🧑 Cliente client$CLIENT_ID generado."

        i=$((i + 1))
    done

    echo "✅ Todos los clientes generados y server.conf actualizado."
}

# Menú principal
while true; do
    echo ""
    echo "🔧 MENÚ WireGuard"
    echo "1️⃣  Crear túnel (servidor)"
    echo "2️⃣  Agregar clientes"
    echo "0️⃣  Salir"
    read -p "Selecciona una opción: " option

    case "$option" in
        1) create_tunnel ;;
        2) add_clients ;;
        0) echo "👋 Saliendo..."; break ;;
        *) echo "❌ Opción inválida." ;;
    esac
done
