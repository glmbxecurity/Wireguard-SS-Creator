#!/bin/bash

PEERS_DIR="/etc/wireguard/peers"

# Buscar todos los .conf recursivamente
mapfile -t FILES < <(find "$PEERS_DIR" -type f -name "*.conf" | sort)

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No se encontraron archivos .conf en $PEERS_DIR"
    exit 1
fi

echo "Túneles disponibles:"
for i in "${!FILES[@]}"; do
    echo "[$i] ${FILES[$i]}"
done

# Preguntar selección
printf "Elige el número del túnel para generar QR: "
read -r choice

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -ge "${#FILES[@]}" ]; then
    echo "Selección inválida"
    exit 1
fi

SELECTED="${FILES[$choice]}"
echo "Generando QR para: $SELECTED"
echo

qrencode -t ansiutf8 < "$SELECTED"
