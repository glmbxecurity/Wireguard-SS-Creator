#!/bin/sh

BASE_DIR="./wg_secure_configs"
DICT_FILE="./diccionario.txt"
mkdir -p "$BASE_DIR"

# Validar diccionario
if [ ! -f "$DICT_FILE" ]; then
    echo "❌ No se encontró el diccionario: $DICT_FILE"
    exit 1
fi

generate_passphrase() {
    pass=""
    while [ ${#pass} -lt 20 ]; do
        word=$(awk -v var=$((RANDOM % $(wc -l < "$DICT_FILE"))) 'NR == var {print $0}' "$DICT_FILE")
        pass="$pass$word"
    done
    echo "$pass"
}

create_tunnel() {
    read -p "🔤 Nombre del túnel (ej: oficina1): " TUNNEL_NAME
    TUNNEL_DIR="$BASE_DIR/$TUNNEL_NAME"
    CLIENT_DIR="$TUNNEL_DIR/clients"
    TUNNEL_CONF="$TUNNEL_DIR/${TUNNEL_NAME}.conf"

    if [ -f "$TUNNEL_CONF" ]; then
        echo "⚠️  El túnel $TUNNEL_NAME ya existe. No se sobreescribirá."
        return
    fi

    mkdir -p "$CLIENT_DIR"

    read -p "IP del endpoint (ejemplo: 192.168.1.1): " ENDPOINT_IP
    read -p "Puerto del endpoint (ejemplo: 51820): " WG_PORT
    read -p "Rango de IP del túnel (ejemplo: 10.8.0.0/24): " TUNNEL_RANGE

    SERVER_IP=$(echo "$TUNNEL_RANGE" | cut -d'/' -f1)
    SERVER_IP="${SERVER_IP%.*}.1"

    SERVER_PRIV_KEY=$(wg genkey)
    SERVER_PUB_KEY=$(echo "$SERVER_PRIV_KEY" | wg pubkey)

    echo "$SERVER_PRIV_KEY" > "$TUNNEL_DIR/server_private.key"
    echo "$SERVER_PUB_KEY" > "$TUNNEL_DIR/server_public.key"

    cat > "$TUNNEL_CONF" <<EOF
[Interface]
PrivateKey = $SERVER_PRIV_KEY
Address = $SERVER_IP/24
ListenPort = $WG_PORT
EOF

    echo "✅ Configuración del túnel creada: $TUNNEL_CONF"
}

add_clients() {
    read -p "🔤 Nombre del túnel al que deseas agregar clientes: " TUNNEL_NAME
    TUNNEL_DIR="$BASE_DIR/$TUNNEL_NAME"
    CLIENT_DIR="$TUNNEL_DIR/clients"
    TUNNEL_CONF="$TUNNEL_DIR/${TUNNEL_NAME}.conf"

    if [ ! -f "$TUNNEL_CONF" ]; then
        echo "❌ No existe el túnel: $TUNNEL_NAME"
        exit 1
    fi

    mkdir -p "$CLIENT_DIR"

    SERVER_PUB_KEY=$(cat "$TUNNEL_DIR/server_public.key")
    WG_PORT=$(awk '/ListenPort/ {print $3}' "$TUNNEL_CONF")
    TUNNEL_RANGE=$(awk '/Address/ {print $3}' "$TUNNEL_CONF")
    ALLOWED_IPS="$TUNNEL_RANGE"

    read -p "Rango de IPs para los clientes (ej: 10.8.0.0/24): " CLIENTS_RANGE

    CLIENT_COUNT=$(grep -c '\[Peer\]' "$TUNNEL_CONF")
    echo "📊 Clientes actuales en el túnel: $CLIENT_COUNT"

    read -p "¿Cuántos clientes quieres agregar? " NEW_CLIENTS

    i=1
    while [ $i -le "$NEW_CLIENTS" ]; do
        CLIENT_ID=$((CLIENT_COUNT + i))
        CLIENT_PRIV_KEY=$(wg genkey)
        CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)
        CLIENT_PSK=$(wg genpsk)

        CLIENT_IP="${CLIENTS_RANGE%.*}.$((CLIENT_ID + 1))"
        PASSPHRASE=$(generate_passphrase)

        echo "$PASSPHRASE" > "$CLIENT_DIR/client$CLIENT_ID.pass"
        echo "$CLIENT_PRIV_KEY" | gpg --symmetric --batch --passphrase "$PASSPHRASE" \
            -o "$CLIENT_DIR/client$CLIENT_ID.key.gpg"

        cat >> "$TUNNEL_CONF" <<EOF

[Peer]
PublicKey = $CLIENT_PUB_KEY
PresharedKey = $CLIENT_PSK
AllowedIPs = $CLIENT_IP/32
EOF

        cat > "$CLIENT_DIR/client$CLIENT_ID.conf" <<EOF
[Interface]
PrivateKey = __REPLACE_WITH_DECRYPTED_KEY__
Address = $CLIENT_IP/32
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB_KEY
PresharedKey = $CLIENT_PSK
Endpoint = <REEMPLAZAR_CON_ENDPOINT_REAL>:$WG_PORT
AllowedIPs = $ALLOWED_IPS
PersistentKeepalive = 25
EOF

        echo "✅ Cliente client$CLIENT_ID creado."
        i=$((i + 1))
    done
}

# Menú principal
while true; do
    echo ""
    echo "🔧 MENÚ WireGuard (modo local, seguro)"
    echo "1️⃣  Crear túnel (archivo .conf local)"
    echo "2️⃣  Agregar clientes a túnel existente"
    echo "0️⃣  Salir"
    read -p "Selecciona una opción: " option

    case "$option" in
        1) create_tunnel ;;
        2) add_clients ;;
        0) echo "👋 Saliendo..."; break ;;
        *) echo "❌ Opción inválida." ;;
    esac
done
