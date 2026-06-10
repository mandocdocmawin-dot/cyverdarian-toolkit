#!/bin/bash

# Embedded encoded CLI
PAYLOAD="ILAGAY_MO_DITO_YUNG_BASE64_OUTPUT"

echo "[*] Installing Cyverdarian CLI..."
mkdir -p ~/cyverdarian-cli
echo "$PAYLOAD" | base64 -d > ~/cyverdarian-cli/cyverdarian-cli.sh

if ! grep -q "source ~/cyverdarian-cli/cyverdarian-cli.sh" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Cyverdarian CLI" >> ~/.bashrc
    echo "source ~/cyverdarian-cli/cyverdarian-cli.sh" >> ~/.bashrc
fi

source ~/.bashrc 2>/dev/null
echo "[+] Cyverdarian CLI installed successfully!"
