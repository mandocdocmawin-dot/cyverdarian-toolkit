#!/bin/bash

mkdir -p ~/cyverdarian-cli
cp cyverdarian-cli.sh ~/cyverdarian-cli/

if ! grep -q "source ~/cyverdarian-cli/cyverdarian-cli.sh" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Cyverdarian CLI" >> ~/.bashrc
    echo "source ~/cyverdarian-cli/cyverdarian-cli.sh" >> ~/.bashrc
fi

source ~/.bashrc 2>/dev/null

echo "[+] Cyverdarian CLI installed successfully!"
